import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const List<IconData> playerIcons = <IconData>[
  Icons.person_rounded,
  Icons.castle_rounded,
  Icons.shield_rounded,
  Icons.auto_awesome_rounded,
  Icons.explore_rounded,
  Icons.workspace_premium_rounded,
  Icons.dark_mode_rounded,
  Icons.bolt_rounded,
  Icons.map_rounded,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.rocket_launch_rounded,
  Icons.gamepad_rounded,
  Icons.group_rounded,
  Icons.menu_book_rounded,
  Icons.key_rounded,
  Icons.diamond_rounded,
  Icons.forest_rounded,
  Icons.tips_and_updates_rounded,
  Icons.emoji_events_rounded,
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C5CFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF8B7CFF),
      secondary: const Color(0xFF5BE4D5),
      tertiary: const Color(0xFFFFC857),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF090D18),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF121A2E),
        elevation: 6,
        shadowColor: const Color(0xFF7C5CFF).withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF121A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkScheme.primary,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF18233A),
        selectedColor: const Color(0xFF7C5CFF),
        secondarySelectedColor: const Color(0xFF7C5CFF),
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF131C31),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2B3A56)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2B3A56)),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BoardGamePlayer',
      theme: darkTheme,
      home: const GamesPage(),
    );
  }
}

enum TimerState { stopped, running, paused }

enum DieType {
  d4(4),
  d6(6),
  d8(8),
  d10(10),
  d12(12),
  d20(20),
  d100(100);

  const DieType(this.faces);

  final int faces;

  String get label => 'd$faces';
}

abstract class RandomSource {
  int nextInt(int max);
}

class DartRandomSource implements RandomSource {
  DartRandomSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(
        max,
        'max',
        'Il numero di facce deve essere > 0',
      );
    }
    return _random.nextInt(max);
  }
}

class DiceRollController {
  DiceRollController({RandomSource? randomSource})
    : _randomSource = randomSource ?? DartRandomSource();

  final RandomSource _randomSource;

  int roll(DieType dieType) {
    return _randomSource.nextInt(dieType.faces) + 1;
  }
}

Future<void> showDiceSheet(
  BuildContext context, {
  RandomSource? randomSource,
}) async {
  final bool useBottomSheet = MediaQuery.sizeOf(context).width < 700;
  final Widget content = DiceRollSheet(randomSource: randomSource);

  if (useBottomSheet) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => content,
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: content,
      ),
    ),
  );
}

class DiceRollSheet extends StatefulWidget {
  const DiceRollSheet({
    super.key,
    this.initialType = DieType.d20,
    this.randomSource,
  });

  final DieType initialType;
  final RandomSource? randomSource;

  @override
  State<DiceRollSheet> createState() => _DiceRollSheetState();
}

class _DiceRollSheetState extends State<DiceRollSheet> {
  late final DiceRollController _controller;
  late DieType _selectedDie;
  int? _result;

  @override
  void initState() {
    super.initState();
    _selectedDie = widget.initialType;
    _controller = DiceRollController(
      randomSource: widget.randomSource ?? DartRandomSource(),
    );
    _result = null;
  }

  void _rollDice() {
    final int preparedResult = _controller.roll(_selectedDie);
    setState(() => _result = preparedResult);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> dieOptions = DieType.values
        .map(
          (DieType dieType) => ChoiceChip(
            label: Text(dieType.label),
            selected: _selectedDie == dieType,
            onSelected: (_) => setState(() => _selectedDie = dieType),
          ),
        )
        .toList();

    final bool isExtreme =
        _result != null && (_result == 1 || _result == _selectedDie.faces);

    final Widget resultDisplay = Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExtreme
              ? <Color>[
                  Colors.amber.shade200,
                  Colors.orange.shade500,
                  Colors.red.shade400,
                ]
              : <Color>[
                  const Color(0xFF123E52),
                  const Color(0xFF1A6B87),
                  const Color(0xFF2B9BB6),
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (isExtreme ? Colors.orange : Colors.blue).withValues(
              alpha: 0.35,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${_result ?? 1}',
            style: const TextStyle(
              fontSize: 78,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDie.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );

    final BoxDecoration mysticalSheetDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xFF101827),
          const Color(0xFF151E35),
          const Color(0xFF10151F),
        ],
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    );

    return Container(
      decoration: mysticalSheetDecoration,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Dadi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dado attivo: ${_selectedDie.label}',
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: dieOptions,
                ),
                const SizedBox(height: 22),
                resultDisplay,
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _rollDice,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Lancia'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Chiudi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Player {
  Player({required this.id, required this.name, this.iconIndex = 0});

  final int id;
  String name;
  int iconIndex;
  Duration elapsed = Duration.zero;
  TimerState timerState = TimerState.stopped;
  int turns = 0;
  double score = 0;
  double scoreStep = 1;
  Timer? timer;

  void dispose() => timer?.cancel();

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'iconIndex': iconIndex,
    'elapsed': elapsed.inSeconds,
    'turns': turns,
    'score': score,
    'scoreStep': scoreStep,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    final Player player = Player(
      id: json['id'] as int,
      name: json['name'] as String,
      iconIndex: (json['iconIndex'] as int?) ?? 0,
    );
    player.elapsed = Duration(seconds: (json['elapsed'] as int?) ?? 0);
    player.turns = ((json['turns'] as int?) ?? 0).clamp(0, 99);
    player.score = (json['score'] as num?)?.toDouble() ?? 0;
    player.scoreStep = (json['scoreStep'] as num?)?.toDouble() ?? 1;
    return player;
  }
}

class Game {
  Game({required this.id, required this.name, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now(),
      updatedAt = DateTime.now();

  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<Player> players = <Player>[];
  int nextPlayerId = 1;
  int? selectedFirstPlayerId;

  int? pickRandomFirstPlayer({Random? randomSource}) {
    if (players.isEmpty) {
      return null;
    }

    final Random random = randomSource ?? Random();
    final int index = random.nextInt(players.length);
    return players[index].id;
  }

  void clearSelectedFirstPlayerIfRemoved(Player player) {
    if (selectedFirstPlayerId == player.id) {
      selectedFirstPlayerId = null;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'nextPlayerId': nextPlayerId,
    'selectedFirstPlayerId': selectedFirstPlayerId,
    'players': players.map((Player player) => player.toJson()).toList(),
  };

  factory Game.fromJson(Map<String, dynamic> json) {
    final Game game = Game(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
    game.updatedAt = DateTime.parse(json['updatedAt'] as String);
    game.nextPlayerId = (json['nextPlayerId'] as int?) ?? 1;
    game.players.addAll(
      (json['players'] as List<dynamic>? ?? <dynamic>[]).map(
        (dynamic item) => Player.fromJson(item as Map<String, dynamic>),
      ),
    );

    final dynamic rawSelectedFirstPlayerId =
        json['selectedFirstPlayerId'] ??
        json['selected_first_player_id'] ??
        json['firstPlayerId'];
    game.selectedFirstPlayerId = rawSelectedFirstPlayerId == null
        ? null
        : (rawSelectedFirstPlayerId as num?)?.toInt() ??
              int.tryParse(rawSelectedFirstPlayerId.toString());

    if (game.selectedFirstPlayerId != null &&
        !game.players.any(
          (Player player) => player.id == game.selectedFirstPlayerId,
        )) {
      game.selectedFirstPlayerId = null;
    }

    return game;
  }
}

class GameStore {
  static const String key = 'board_game_player_games';
  Future<void> _lastSave = Future<void>.value();
  SharedPreferences? _cachedPreferences;

  Future<SharedPreferences> _getPreferences() async {
    return _cachedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<List<Game>> load() async {
    final SharedPreferences preferences = await _getPreferences();
    final String? raw = preferences.getString(key);
    if (raw == null) return <Game>[];

    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((dynamic item) => Game.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Game>[];
    }
  }

  Future<void> save(List<Game> games) async {
    _lastSave = _lastSave.then((_) async {
      final SharedPreferences preferences = await _getPreferences();
      final bool saved = await preferences.setString(
        key,
        jsonEncode(games.map((Game game) => game.toJson()).toList()),
      );
      if (!saved) throw StateError('Salvataggio locale non riuscito.');
    });
    await _lastSave;
  }
}

class DiceLauncherButton extends StatelessWidget {
  const DiceLauncherButton({
    super.key,
    required this.onPressed,
    this.label = 'Lancia dadi',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: label,
        backgroundColor: const Color(0xFF8B7CFF),
        foregroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.casino),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> with WidgetsBindingObserver {
  final GameStore store = GameStore();
  List<Game> games = <Game>[];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadGames();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(store.save(games));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final Game game in games) {
      for (final Player player in game.players) {
        player.dispose();
      }
    }
    super.dispose();
  }

  Future<void> loadGames() async {
    try {
      final List<Game> loaded = await store.load();
      if (!mounted) return;
      setState(() {
        games = loaded;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<String?> gameNameDialog({String? initial}) async {
    final TextEditingController controller = TextEditingController(
      text: initial,
    );
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(initial == null ? 'Nuova partita' : 'Modifica partita'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nome della partita',
            hintText: 'Es. Serata del venerdì',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () {
              final String value = controller.text.trim();
              if (value.isNotEmpty && RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value)) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('SALVA'),
          ),
        ],
      ),
    );
    controller.dispose();
    return name;
  }

  Future<void> addGame() async {
    final String? name = await gameNameDialog();
    if (name == null || !mounted) return;

    setState(() {
      games.add(
        Game(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name),
      );
    });
    await store.save(games);
  }

  Future<void> deleteGame(Game game) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Elimina partita'),
        content: Text(
          'Saranno eliminati anche giocatori e statistiche di "${game.name}".',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => games.remove(game));
    await store.save(games);
  }

  Future<void> openGame(Game game) async {
    final GameDetailPage page = GameDetailPage(
      game: game,
      store: store,
      games: games,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );

    if (mounted) {
      setState(() {});
    }
  }

  String dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BoardGamePlayer')),
      floatingActionButton: loading
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: addGame,
                  tooltip: 'Crea una partita',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF0B1020),
                Color(0xFF111A2F),
                Color(0xFF090D18),
              ],
            ),
          ),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: <Widget>[
                    Positioned(
                      top: -80,
                      right: -40,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7C5CFF)
                              .withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 120,
                      left: -60,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF5BE4D5)
                              .withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: games.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  120,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Icon(
                                      Icons.casino_outlined,
                                      size: 56,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Nessuna partita presente',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  120,
                                ),
                                itemCount: games.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (BuildContext context, int index) {
                                  final Game game = games[index];
                                  return Card(
                                    key: ValueKey<String>(game.id),
                                    elevation: 6,
                                    child: ListTile(
                                      key: ValueKey<String>(game.id),
                                      onTap: () => openGame(game),
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFF1D2842),
                                        child: Icon(
                                          Icons.games_rounded,
                                          color: Color(0xFF8B7CFF),
                                        ),
                                      ),
                                      title: Text(
                                        game.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${game.players.length} giocatori • Aggiornata il ${dateLabel(game.updatedAt)}',
                                      ),
                                      trailing: IconButton(
                                        onPressed: () => deleteGame(game),
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Elimina partita',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Center(
                        child: DiceLauncherButton(
                          onPressed: () => showDiceSheet(context),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({
    super.key,
    required this.game,
    required this.store,
    required this.games,
  });

  final Game game;
  final GameStore store;
  final List<Game> games;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage>
    with WidgetsBindingObserver {
  static const List<double> scoreSteps = <double>[0.5, 1, 5, 10, 50];

  final ScrollController _scrollController = ScrollController();
  bool _selectionAnimationVisible = false;

  Game get game => widget.game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(save());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    for (final Player player in game.players) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> selectFirstPlayer() async {
    if (game.players.isEmpty) {
      return;
    }

    final int? selectedId = game.pickRandomFirstPlayer(randomSource: Random());
    if (selectedId == null || !mounted) {
      return;
    }

    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final int index = game.players.indexWhere(
      (Player player) => player.id == selectedId,
    );

    setState(() {
      game.selectedFirstPlayerId = selectedId;
      _selectionAnimationVisible = true;
    });

    if (!reduceMotion) {
      await Future<void>.delayed(const Duration(milliseconds: 240));
      if (!mounted) {
        return;
      }
      setState(() => _selectionAnimationVisible = false);
    } else {
      _selectionAnimationVisible = false;
    }

    await save();

    if (index == -1 || !_scrollController.hasClients) {
      return;
    }

    final double offset = index * 170.0;
    final double target = offset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    if (reduceMotion) {
      _scrollController.jumpTo(target);
      return;
    }

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> save() async {
    game.updatedAt = DateTime.now();
    await widget.store.save(widget.games);
  }

  Future<String?> textDialog({
    required String title,
    required String label,
    String? initial,
    required bool Function(String) isValid,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initial,
    );
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () {
              final String result = controller.text.trim();
              if (isValid(result)) Navigator.pop(dialogContext, result);
            },
            child: const Text('SALVA'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> addOrEditPlayer({Player? player}) async {
    final String? name = await textDialog(
      title: player == null ? 'Aggiungi giocatore' : 'Modifica nome',
      label: 'Nome del giocatore',
      initial: player?.name,
      isValid: (String value) =>
          RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value) &&
          !game.players.any(
            (Player item) =>
                item != player &&
                item.name.toLowerCase() == value.toLowerCase(),
          ),
    );
    if (name == null || !mounted) return;

    final int? iconIndex = await choosePlayerIcon(player?.iconIndex ?? 0);
    if (!mounted) return;

    setState(() {
      if (player == null) {
        game.players.add(
          Player(
            id: game.nextPlayerId++,
            name: name,
            iconIndex: iconIndex ?? 0,
          ),
        );
      } else {
        player.name = name;
        if (iconIndex != null) player.iconIndex = iconIndex;
      }
    });
    await save();
  }

  Future<int?> choosePlayerIcon(int currentIndex) => showDialog<int>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Scegli miniatura'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List<Widget>.generate(playerIcons.length, (int index) {
          return IconButton(
            onPressed: () => Navigator.pop(dialogContext, index),
            isSelected: index == currentIndex,
            icon: Icon(playerIcons[index]),
            tooltip: 'Miniatura ${index + 1}',
          );
        }),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('ANNULLA'),
        ),
      ],
    ),
  );

  Future<void> editTurns(Player player) async {
    final String? value = await textDialog(
      title: 'Modifica turni',
      label: 'Turni (0-99)',
      initial: '${player.turns}',
      isValid: (String value) {
        final int? parsed = int.tryParse(value);
        return parsed != null && parsed >= 0 && parsed <= 99;
      },
      keyboardType: TextInputType.number,
      formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
    );
    final int? turns = value == null ? null : int.tryParse(value);
    if (turns != null && mounted) {
      setState(() => player.turns = turns);
      await save();
    }
  }

  Future<void> editScore(Player player) async {
    final String? value = await textDialog(
      title: 'Modifica punteggio',
      label: 'Punteggio',
      initial: formatNumber(player.score),
      isValid: (String value) =>
          double.tryParse(value.replaceAll(',', '.')) != null &&
          RegExp(r'^-?\d+([.,]\d)?$').hasMatch(value),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      formatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.-]')),
      ],
    );
    final double? score = value == null
        ? null
        : double.tryParse(value.replaceAll(',', '.'));
    if (score != null && mounted) {
      setState(() => player.score = score);
      await save();
    }
  }

  Future<void> removePlayer(Player player) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Elimina giocatore'),
        content: Text('Vuoi eliminare ${player.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        player.dispose();
        game.clearSelectedFirstPlayerIfRemoved(player);
        game.players.remove(player);
      });
      await save();
    }
  }

  void toggleTimer(Player player) {
    setState(() {
      if (player.timerState == TimerState.running) {
        player.timer?.cancel();
        player.timerState = TimerState.paused;
      } else {
        player.timerState = TimerState.running;
        player.timer?.cancel();
        player.timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => player.elapsed += const Duration(seconds: 1));
        });
      }
    });
    unawaited(save());
  }

  void stopTimer(Player player) {
    setState(() {
      player.timer?.cancel();
      player.timerState = TimerState.stopped;
      player.elapsed = Duration.zero;
    });
    unawaited(save());
  }

  String formatDuration(Duration value) =>
      '${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  String formatNumber(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  Widget build(BuildContext context) {
    final bool isPortraitMobile =
        MediaQuery.sizeOf(context).width < 700 &&
        MediaQuery.orientationOf(context) == Orientation.portrait;

    final Widget firstPlayerButton = isPortraitMobile
        ? FloatingActionButton(
            heroTag: 'first-player',
            onPressed: game.players.isEmpty ? null : selectFirstPlayer,
            tooltip: 'Estrai primo giocatore',
            backgroundColor: game.players.isEmpty
                ? Colors.grey.shade700
                : const Color(0xFF8B7CFF),
            foregroundColor: game.players.isEmpty
                ? Colors.grey.shade400
                : Colors.white,
            elevation: 12,
            child: const Icon(Icons.workspace_premium_rounded),
          )
        : FloatingActionButton.extended(
            heroTag: 'first-player',
            onPressed: game.players.isEmpty ? null : selectFirstPlayer,
            tooltip: 'Estrai primo giocatore',
            backgroundColor: game.players.isEmpty
                ? Colors.grey.shade700
                : const Color(0xFF8B7CFF),
            foregroundColor: game.players.isEmpty
                ? Colors.grey.shade400
                : Colors.white,
            elevation: 12,
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('Estrai primo giocatore'),
          );

    final Widget diceButton = isPortraitMobile
        ? FloatingActionButton(
            heroTag: 'dice-launcher',
            onPressed: () => showDiceSheet(context),
            tooltip: 'Lancia dadi',
            backgroundColor: const Color(0xFF8B7CFF),
            foregroundColor: Colors.white,
            elevation: 12,
            child: const Icon(Icons.casino),
          )
        : FloatingActionButton.extended(
            heroTag: 'dice-launcher',
            onPressed: () => showDiceSheet(context),
            tooltip: 'Lancia dadi',
            backgroundColor: const Color(0xFF8B7CFF),
            foregroundColor: Colors.white,
            elevation: 12,
            icon: const Icon(Icons.casino),
            label: const Text('Lancia dadi'),
          );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            await save();
            if (context.mounted) Navigator.pop(context);
          },
        ),
        title: Text(game.name),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF0B1020),
                Color(0xFF111A2F),
                Color(0xFF090D18),
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -60,
                    left: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 90,
                    right: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF5BE4D5).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  game.players.isEmpty
                      ? const Center(child: Text('Nessun giocatore presente'))
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
                          itemCount: game.players.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, int index) {
                            final Player player = game.players[index];
                            final bool isSelected =
                                game.selectedFirstPlayerId == player.id;
                            return PlayerCard(
                              player: player,
                              isSelected: isSelected,
                              isHighlightAnimating:
                                  _selectionAnimationVisible && isSelected,
                              formatDuration: formatDuration,
                              formatNumber: formatNumber,
                              onEdit: () => addOrEditPlayer(player: player),
                              onRemove: () => removePlayer(player),
                              onToggleTimer: () => toggleTimer(player),
                              onStopTimer: () => stopTimer(player),
                              onTurnsEdit: () => editTurns(player),
                              onScoreEdit: () => editScore(player),
                              onTurnChange: (int value) {
                                setState(() {
                                  player.turns = (player.turns + value).clamp(
                                    0,
                                    99,
                                  );
                                });
                                unawaited(save());
                              },
                              onScoreChange: (double value) {
                                setState(() => player.score += value);
                                unawaited(save());
                              },
                              onStepChange: (double? value) {
                                setState(() => player.scoreStep = value ?? 1);
                                unawaited(save());
                              },
                              scoreSteps: scoreSteps,
                            );
                          },
                        ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Row(
                        children: <Widget>[
                          firstPlayerButton,
                          const Spacer(),
                          diceButton,
                          const Spacer(),
                          FloatingActionButton(
                            heroTag: 'add-player',
                            onPressed: () => addOrEditPlayer(),
                            tooltip: 'Aggiungi giocatore',
                            backgroundColor: const Color(0xFF5BE4D5),
                            foregroundColor: const Color(0xFF0B1020),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    required this.isHighlightAnimating,
    required this.formatDuration,
    required this.formatNumber,
    required this.onEdit,
    required this.onRemove,
    required this.onToggleTimer,
    required this.onStopTimer,
    required this.onTurnsEdit,
    required this.onScoreEdit,
    required this.onTurnChange,
    required this.onScoreChange,
    required this.onStepChange,
    required this.scoreSteps,
  });

  final Player player;
  final bool isSelected;
  final bool isHighlightAnimating;
  final String Function(Duration) formatDuration;
  final String Function(double) formatNumber;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onToggleTimer;
  final VoidCallback onStopTimer;
  final VoidCallback onTurnsEdit;
  final VoidCallback onScoreEdit;
  final ValueChanged<int> onTurnChange;
  final ValueChanged<double> onScoreChange;
  final ValueChanged<double?> onStepChange;
  final List<double> scoreSteps;

  @override
  Widget build(BuildContext context) {
    final BorderSide selectedBorder = BorderSide(
      color: isSelected ? Colors.red : Colors.transparent,
      width: isSelected ? 2 : 1,
    );

    return Semantics(
      label: isSelected ? '${player.name}, primo giocatore' : player.name,
      selected: isSelected,
      child: AnimatedScale(
        scale: isSelected && isHighlightAnimating ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: isSelected ? Colors.red.withValues(alpha: 0.04) : null,
          shape: RoundedRectangleBorder(
            side: selectedBorder,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    playerIcons[player.iconIndex.clamp(
                      0,
                      playerIcons.length - 1,
                    )],
                  ),
                ),
                title: InkWell(
                  onTap: onEdit,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '1st',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                subtitle: const Text('Giocatore'),
                trailing: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  tooltip: 'Elimina giocatore',
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 16,
                  children: <Widget>[
                    ControlColumn(
                      label: 'Tempo',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: onStopTimer,
                            icon: const Icon(
                              Icons.stop_rounded,
                              color: Colors.red,
                            ),
                            tooltip: 'Azzera timer',
                          ),
                          Text(formatDuration(player.elapsed)),
                          IconButton(
                            onPressed: onToggleTimer,
                            icon: Icon(
                              player.timerState == TimerState.running
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: player.timerState == TimerState.running
                                  ? Colors.amber[800]
                                  : Colors.green[700],
                            ),
                            tooltip: player.timerState == TimerState.running
                                ? 'Pausa'
                                : 'Avvia',
                          ),
                        ],
                      ),
                    ),
                    ControlColumn(
                      label: 'Turni',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: player.turns > 0
                                ? () => onTurnChange(-1)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          InkWell(
                            onTap: onTurnsEdit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text('${player.turns}'),
                            ),
                          ),
                          IconButton(
                            onPressed: player.turns < 99
                                ? () => onTurnChange(1)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    ControlColumn(
                      label: 'Punteggio',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: () => onScoreChange(-player.scoreStep),
                            icon: const Icon(Icons.remove),
                          ),
                          InkWell(
                            onTap: onScoreEdit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(formatNumber(player.score)),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onScoreChange(player.scoreStep),
                            icon: const Icon(Icons.add),
                          ),
                          DropdownButton<double>(
                            value: player.scoreStep,
                            items: scoreSteps
                                .map(
                                  (double value) => DropdownMenuItem<double>(
                                    value: value,
                                    child: Text(formatNumber(value)),
                                  ),
                                )
                                .toList(),
                            onChanged: onStepChange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ControlColumn extends StatelessWidget {
  const ControlColumn({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        child,
      ],
    );
  }
}

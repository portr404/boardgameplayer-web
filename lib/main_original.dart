import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

const List<IconData> playerIcons = <IconData>[
  Icons.person,
  Icons.catching_pokemon,
  Icons.castle,
  Icons.shield,
  Icons.auto_awesome,
  Icons.explore,
];

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Board Game Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BDB)),
        useMaterial3: true,
      ),
      home: HomePage(database: database),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Board Game Manager',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF126E82)),
      useMaterial3: true,
    ),
    home: const GamesPage(),
  );
}

enum TimerState { stopped, running, paused }

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
    player.turns = (json['turns'] as int?)?.clamp(0, 99) ?? 0;
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'nextPlayerId': nextPlayerId,
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
    return game;
  }
}

class GameStore {
  static const String key = 'board_game_player_games';
  Future<void> _lastSave = Future<void>.value();

  Future<List<Game>> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
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
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final bool saved = await preferences.setString(
        key,
        jsonEncode(games.map((Game game) => game.toJson()).toList()),
      );
      if (!saved) throw StateError('Salvataggio locale non riuscito.');
    });
    await _lastSave;
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
    super.dispose();
  }

  Future<void> loadGames() async {
    try {
      final List<Game> loaded = await store.load();
      if (mounted) {
        setState(() {
          games = loaded;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
      }
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
          decoration: const InputDecoration(
            labelText: 'Nome della partita',
            hintText: 'Es. Catan - serata del venerdì',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    controller.dispose();
    return name;
  }

  Future<void> addGame() async {
    final String? name = await gameNameDialog();
    if (name == null || !mounted || !RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(name)) {
      return;
    }
    final Game game = Game(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    setState(() => games.add(game));
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
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => games.remove(game));
    await store.save(games);
  }

  Future<void> openGame(Game game) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameDetailPage(game: game, store: store, games: games),
      ),
    );
    if (mounted) setState(() {});
  }

  String dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Le mie partite')),
    floatingActionButton: loading
        ? null
        : FloatingActionButton(
            onPressed: addGame,
            tooltip: 'Crea una partita',
            child: const Icon(Icons.add),
          ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : games.isEmpty
        ? const Center(child: Text('Nessuna partita presente'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Game game = games[index];
              return Card(
                child: ListTile(
                  onTap: () => openGame(game),
                  leading: const CircleAvatar(
                    child: Icon(Icons.casino_outlined),
                  ),
                  title: Text(
                    game.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
  );
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
    for (final Player player in game.players) {
      player.dispose();
    }
    super.dispose();
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
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => isValid(controller.text.trim())
                ? Navigator.pop(dialogContext, controller.text.trim())
                : null,
            child: const Text('OK'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
          child: const Text('CANCEL'),
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
          double.tryParse(value) != null &&
          RegExp(r'^-?\d+(\.\d)?$').hasMatch(value),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      formatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
      ],
    );
    final double? score = value == null ? null : double.tryParse(value);
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
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        player.dispose();
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
          if (mounted) {
            setState(() => player.elapsed += const Duration(seconds: 1));
            unawaited(save());
          }
        });
      }
    });
    save();
  }

  void stopTimer(Player player) {
    setState(() {
      player.timer?.cancel();
      player.timerState = TimerState.stopped;
      player.elapsed = Duration.zero;
    });
    save();
  }

  String formatDuration(Duration value) =>
      '${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';
  String formatNumber(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(
        onPressed: () async {
          await save();
          if (!context.mounted) return;
          Navigator.pop(context);
        },
      ),
      title: Text(game.name),
    ),
    floatingActionButton: game.players.length < 100
        ? FloatingActionButton(
            onPressed: () => addOrEditPlayer(),
            tooltip: 'Aggiungi un giocatore',
            child: const Icon(Icons.add),
          )
        : null,
    body: game.players.isEmpty
        ? const Center(child: Text('Nessun giocatore presente'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: game.players.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, int index) => PlayerCard(
              player: game.players[index],
              formatDuration: formatDuration,
              formatNumber: formatNumber,
              onEdit: () => addOrEditPlayer(player: game.players[index]),
              onRemove: () => removePlayer(game.players[index]),
              onToggleTimer: () => toggleTimer(game.players[index]),
              onStopTimer: () => stopTimer(game.players[index]),
              onTurnsEdit: () => editTurns(game.players[index]),
              onScoreEdit: () => editScore(game.players[index]),
              onTurnChange: (int value) {
                setState(
                  () => game.players[index].turns =
                      (game.players[index].turns + value).clamp(0, 99),
                );
                save();
              },
              onScoreChange: (double value) {
                setState(() => game.players[index].score += value);
                save();
              },
              onStepChange: (double? value) {
                setState(() => game.players[index].scoreStep = value ?? 1);
                save();
              },
              scoreSteps: scoreSteps,
            ),
          ),
  );
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
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
  final String Function(Duration) formatDuration;
  final String Function(double) formatNumber;
  final VoidCallback onEdit,
      onRemove,
      onToggleTimer,
      onStopTimer,
      onTurnsEdit,
      onScoreEdit;
  final ValueChanged<int> onTurnChange;
  final ValueChanged<double> onScoreChange;
  final ValueChanged<double?> onStepChange;
  final List<double> scoreSteps;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            child: Icon(
              playerIcons[player.iconIndex.clamp(0, playerIcons.length - 1)],
            ),
          ),
          title: InkWell(
            onTap: onEdit,
            child: Text(
              player.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(10),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 20,
            runSpacing: 12,
            children: <Widget>[
              ControlColumn(
                label: 'Tempo',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      onPressed: onStopTimer,
                      icon: const Icon(Icons.stop_rounded, color: Colors.red),
                      tooltip: 'Stop',
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
                          : 'Play',
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
  );
}

class ControlColumn extends StatelessWidget {
  const ControlColumn({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      child,
    ],
  );
}

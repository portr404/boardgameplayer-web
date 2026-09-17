import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progettino_ios/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'GameStore performance: salva/carica 10 partite con 5 giocatori',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final GameStore store = GameStore();
      final List<Game> games = <Game>[];

      for (int g = 0; g < 10; g++) {
        final Game game = Game(id: 'game-$g', name: 'Partita $g');
        for (int p = 0; p < 5; p++) {
          final Player player = Player(id: p, name: 'Giocatore $p');
          player.turns = (g * 5 + p) % 99;
          player.score = (g * 5 + p) * 2.5;
          player.elapsed = Duration(seconds: (g * 5 + p) * 10);
          game.players.add(player);
        }
        games.add(game);
      }

      final Stopwatch sw = Stopwatch()..start();
      await store.save(games);
      sw.stop();
      final int saveMs = sw.elapsedMilliseconds;
      expect(
        saveMs,
        lessThan(500),
        reason: 'Save dovrebbe terminare in <500ms',
      );

      sw.reset();
      sw.start();
      final List<Game> loaded = await store.load();
      sw.stop();
      final int loadMs = sw.elapsedMilliseconds;
      expect(
        loadMs,
        lessThan(500),
        reason: 'Load dovrebbe terminare in <500ms',
      );

      expect(loaded, hasLength(10));
      expect(loaded.first.players, hasLength(5));
    },
  );

  test('GameStore salva e ricarica una partita', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final GameStore store = GameStore();
    final Game game = Game(id: 'game-1', name: 'Catan');
    game.players.add(Player(id: 1, name: 'Francesco'));
    game.players.first.turns = 7;
    game.players.first.score = -2.5;

    await store.save(<Game>[game]);
    final List<Game> loaded = await store.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.name, 'Catan');
    expect(loaded.single.players.single.name, 'Francesco');
    expect(loaded.single.players.single.turns, 7);
    expect(loaded.single.players.single.score, -2.5);
  });

  test(
    'Game serializes selectedFirstPlayerId with backwards compatibility',
    () {
      final Game game = Game(id: 'game-serial', name: 'Back compat');
      game.players.addAll(<Player>[
        Player(id: 10, name: 'A'),
        Player(id: 11, name: 'B'),
        Player(id: 12, name: 'C'),
      ]);
      game.selectedFirstPlayerId = 11;

      final Map<String, dynamic> json = game.toJson();
      expect(json['selectedFirstPlayerId'], 11);

      final Game restored = Game.fromJson(json);
      expect(restored.selectedFirstPlayerId, 11);

      final Game legacy = Game.fromJson(<String, dynamic>{
        'id': 'legacy',
        'name': 'Legacy',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'nextPlayerId': 1,
        'players': <Map<String, dynamic>>[],
      });
      expect(legacy.selectedFirstPlayerId, isNull);
    },
  );

  testWidgets(
    'la selezione del primo giocatore mostra il badge e disabilita il bottone senza giocatori',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final Game game = Game(id: 'game-selection', name: 'Selection');
      game.players.addAll(<Player>[
        Player(id: 1, name: 'Alice'),
        Player(id: 2, name: 'Bob'),
        Player(id: 3, name: 'Carla'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: GameDetailPage(
            game: game,
            store: GameStore(),
            games: <Game>[game],
          ),
        ),
      );

      final Finder playerFab = find.byWidgetPredicate(
        (Widget widget) =>
            widget is FloatingActionButton &&
            widget.tooltip == 'Estrai primo giocatore',
      );
      expect(playerFab, findsOneWidget);
      expect(
        tester.widget<FloatingActionButton>(playerFab).onPressed,
        isNotNull,
      );

      final Game emptyGame = Game(id: 'game-empty', name: 'Empty');
      await tester.pumpWidget(
        MaterialApp(
          home: GameDetailPage(
            game: emptyGame,
            store: GameStore(),
            games: <Game>[emptyGame],
          ),
        ),
      );

      final Finder emptyPlayerFab = find.byWidgetPredicate(
        (Widget widget) =>
            widget is FloatingActionButton &&
            widget.tooltip == 'Estrai primo giocatore',
      );
      expect(emptyPlayerFab, findsOneWidget);
      expect(
        tester.widget<FloatingActionButton>(emptyPlayerFab).onPressed,
        isNull,
      );

      expect(find.text('1st'), findsNothing);
    },
  );

  testWidgets('salva la partita quando l’app viene sospesa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final GameStore store = GameStore();
    final Game game = Game(id: 'game-lifecycle', name: 'Scacchi');

    await tester.pumpWidget(
      MaterialApp(
        home: GameDetailPage(game: game, store: store, games: <Game>[game]),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(GameStore.key), isNotNull);
    expect((await store.load()).single.name, 'Scacchi');
  });

  test('DiceRollController returns values inside die bounds and uses injected random source', () {
    final FakeRandomSource random = FakeRandomSource(<int>[0, 9, 0]);
    final DiceRollController controller = DiceRollController(
      randomSource: random,
    );

    expect(controller.roll(DieType.d4), 1);
    expect(controller.roll(DieType.d20), 10);
    expect(random.calls, 2);
  });

  testWidgets('il lanciatore di dadi mostra selezione e azioni principali', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDiceSheet(context),
                child: const Text('Apri dadi'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apri dadi'));
    await tester.pumpAndSettle();

    expect(find.text('Dadi'), findsOneWidget);
    expect(find.text('Lancia'), findsOneWidget);
    expect(find.text('Chiudi'), findsOneWidget);
    expect(find.text('d20'), findsNWidgets(2));
  });

  testWidgets(
    'la pagina di una partita mostra un solo lanciatore dadi e il pulsante aggiungi giocatore',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final Game game = Game(id: 'game-ux', name: 'UX');
      game.players.addAll(<Player>[
        Player(id: 1, name: 'Alice'),
        Player(id: 2, name: 'Bob'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: GameDetailPage(
            game: game,
            store: GameStore(),
            games: <Game>[game],
          ),
        ),
      );

      expect(find.byTooltip('Lancia dadi'), findsOneWidget);
      expect(find.byTooltip('Aggiungi giocatore'), findsOneWidget);
    },
  );

  testWidgets(
    'il tavolo vuoto lascia disabilitato il primo giocatore ma mantiene attivo il lancio dadi',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final Game game = Game(id: 'game-empty-action', name: 'Empty Action');

      await tester.pumpWidget(
        MaterialApp(
          home: GameDetailPage(
            game: game,
            store: GameStore(),
            games: <Game>[game],
          ),
        ),
      );

      final Finder diceButton = find.byWidgetPredicate(
        (Widget widget) =>
            widget is FloatingActionButton && widget.tooltip == 'Lancia dadi',
      );
      final Finder firstPlayerButton = find.byWidgetPredicate(
        (Widget widget) =>
            widget is FloatingActionButton &&
            widget.tooltip == 'Estrai primo giocatore',
      );

      expect(diceButton, findsOneWidget);
      expect(
        tester.widget<FloatingActionButton>(diceButton).onPressed,
        isNotNull,
      );
      expect(firstPlayerButton, findsOneWidget);
      expect(
        tester.widget<FloatingActionButton>(firstPlayerButton).onPressed,
        isNull,
      );
    },
  );

  testWidgets('avvia l’elenco delle partite', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BoardGamePlayer'), findsOneWidget);
  });
}

class FakeRandomSource implements RandomSource {
  FakeRandomSource(this._values);

  final List<int> _values;
  int calls = 0;

  @override
  int nextInt(int max) {
    final int value = _values[calls % _values.length];
    calls++;
    return value.clamp(0, max - 1);
  }
}

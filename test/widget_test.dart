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
      print('Performance: save 10 partite (50 giocatori) = $saveMs ms');
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
      print('Performance: load 10 partite (50 giocatori) = $loadMs ms');
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

  testWidgets('avvia l’elenco delle partite', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Le mie partite'), findsOneWidget);
  });
}

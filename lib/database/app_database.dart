import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(
        min: 1,
        max: 40,
      )();

  DateTimeColumn get createdAt => dateTime().withDefault(
        currentDateAndTime,
      )();
}

@DriftDatabase(
  tables: <Type>[Players],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'board_game_manager',
          ),
        );

  @override
  int get schemaVersion => 1;

  Stream<List<Player>> watchPlayers() {
    return (select(players)
          ..orderBy(
            <OrderClauseGenerator<Players>>[
              (Players table) => OrderingTerm.asc(table.name),
            ],
          ))
        .watch();
  }

  Future<int> addPlayer(String name) {
    return into(players).insert(
      PlayersCompanion.insert(
        name: name.trim(),
      ),
    );
  }

  Future<void> deletePlayer(int playerId) {
    return (delete(players)..where(
          (Players table) => table.id.equals(playerId),
        ))
        .go();
  }

  Future<bool> playerAlreadyExists(String name) async {
    final normalizedName = name.trim().toLowerCase();

    final existingPlayers = await select(players).get();

    return existingPlayers.any(
      (Player player) => player.name.toLowerCase() == normalizedName,
    );
  }
}
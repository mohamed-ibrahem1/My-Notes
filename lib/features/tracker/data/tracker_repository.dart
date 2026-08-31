import 'package:appwrite/appwrite.dart';

import '../../../core/services/appwrite_service.dart';
import '../domain/habit.dart';
import '../domain/habit_entry.dart';

/// Handles all Appwrite operations for the Tracker feature.
/// No Appwrite API calls should appear outside this class.
class TrackerRepository {
  final AppwriteService appwrite;

  TrackerRepository(this.appwrite);

  Future<T> _retry<T>(Future<T> Function() fn, {int maxRetries = 3}) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await fn();
      } catch (e) {
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
  }

  // ── Habits ─────────────────────────────────────────────────────────────

  Future<List<Habit>> getHabits() async {
    final result = await _retry(() => appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.habitsTableId,
    ));

    return result.rows.map((row) => Habit.fromMap(row.data)).toList();
  }

  Future<Habit> addHabit({
    required String name,
    required bool challengeEnabled,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now().toUtc();

    final data = <String, dynamic>{
      'name': name,
      'challenge_enabled': challengeEnabled,
      'created_at': now.toIso8601String(),
    };

    if (challengeEnabled && startDate != null && endDate != null) {
      data['start_date'] = HabitEntry.formatDate(startDate);
      data['end_date'] = HabitEntry.formatDate(endDate);
    }

    final row = await _retry(() => appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.habitsTableId,
      rowId: ID.unique(),
      data: data,
    ));

    return Habit.fromMap(row.data);
  }

  Future<void> deleteHabit(String id) async {
    // Delete all entries for this habit first to keep the database clean.
    await _deleteAllEntriesForHabit(id);

    await _retry(() => appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.habitsTableId,
      rowId: id,
    ));
  }

  // ── Habit Entries ────────────────────────────────────────────────────────

  Future<List<HabitEntry>> getAllHabitEntries() async {
    final result = await _retry(() => appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.habitEntriesTableId,
    ));

    return result.rows.map((row) => HabitEntry.fromMap(row.data)).toList();
  }

  Future<List<HabitEntry>> getHabitEntries(String habitId) async {
    final entries = await getAllHabitEntries();
    return entries.where((entry) => entry.habitId == habitId).toList();
  }

  Future<HabitEntry> createHabitEntry({
    required String habitId,
    required DateTime date,
  }) async {
    final row = await _retry(() => appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.habitEntriesTableId,
      rowId: ID.unique(),
      data: {
        'habit_id': habitId,
        'date': HabitEntry.formatDate(date),
        'completed': true,
      },
    ));

    return HabitEntry.fromMap(row.data);
  }

  Future<void> deleteHabitEntry(String id) async {
    await _retry(() => appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.habitEntriesTableId,
      rowId: id,
    ));
  }

  Future<void> _deleteAllEntriesForHabit(String habitId) async {
    final entries = await getHabitEntries(habitId);
    for (final entry in entries) {
      await _retry(() => appwrite.tablesDB.deleteRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.habitEntriesTableId,
        rowId: entry.id,
      ));
    }
  }
}

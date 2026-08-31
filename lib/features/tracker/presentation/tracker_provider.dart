import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/appwrite_provider.dart';
import '../data/tracker_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_entry.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  return TrackerRepository(ref.watch(appwriteProvider));
});

// ── Habits provider ───────────────────────────────────────────────────────────

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<Habit>>(
  HabitsNotifier.new,
);

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  TrackerRepository get _repository => ref.read(trackerRepositoryProvider);

  @override
  Future<List<Habit>> build() => _repository.getHabits();

  Future<void> addHabit({
    required String name,
    required bool challengeEnabled,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _repository.addHabit(
      name: name,
      challengeEnabled: challengeEnabled,
      startDate: startDate,
      endDate: endDate,
    );

    ref.invalidateSelf();
  }

  Future<void> deleteHabit(String id) async {
    final previous = state.value ?? [];

    // Optimistic removal for immediate UI feedback.
    state = AsyncData(previous.where((h) => h.id != id).toList());
    ref.read(allHabitEntriesProvider.notifier).removeEntriesForHabit(id);

    try {
      await _repository.deleteHabit(id);
    } catch (e, st) {
      // Restore list if deletion fails.
      state = AsyncData(previous);
      ref.invalidate(allHabitEntriesProvider);
      debugPrint('Failed to delete habit: $e');
      debugPrintStack(stackTrace: st);
    }
  }
}

// ── Habit entries provider ────────────────────────────────────────────────────

final allHabitEntriesProvider =
    AsyncNotifierProvider<AllHabitEntriesNotifier, List<HabitEntry>>(
  AllHabitEntriesNotifier.new,
);

class AllHabitEntriesNotifier extends AsyncNotifier<List<HabitEntry>> {
  TrackerRepository get _repository => ref.read(trackerRepositoryProvider);

  @override
  Future<List<HabitEntry>> build() => _repository.getAllHabitEntries();

  /// Toggles the completion state for [date]:
  ///   - No existing entry  → create a completed entry.
  ///   - Existing entry     → delete it (uncommit).
  Future<void> toggleEntry({
    required String habitId,
    required DateTime date,
  }) async {
    final entries = state.value ?? [];
    final normalised = Habit.normalise(date);
    final existing = entries
        .where((e) => e.habitId == habitId && e.date == normalised)
        .firstOrNull;

    if (existing == null) {
      final newEntry = await _repository.createHabitEntry(
        habitId: habitId,
        date: normalised,
      );
      state = AsyncData([...entries, newEntry]);
    } else {
      await _repository.deleteHabitEntry(existing.id);
      state = AsyncData(entries.where((e) => e.id != existing.id).toList());
    }
  }

  void removeEntriesForHabit(String habitId) {
    final entries = state.value ?? [];
    state = AsyncData(entries.where((e) => e.habitId != habitId).toList());
  }
}

/// Derived provider: returns entries for a specific habit from the cached list.
final habitEntriesProvider =
    Provider.family<AsyncValue<List<HabitEntry>>, String>((ref, habitId) {
  final allEntries = ref.watch(allHabitEntriesProvider);
  return allEntries.whenData(
    (entries) => entries.where((e) => e.habitId == habitId).toList(),
  );
});

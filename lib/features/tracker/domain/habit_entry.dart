/// Records the completion state of a [Habit] on a specific calendar day.
class HabitEntry {
  final String id;
  final String habitId;

  /// Date-only (time component is always midnight UTC).
  final DateTime date;

  final bool completed;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });

  /// Parses an ISO-8601 date string into a date-only UTC [DateTime].
  /// Handles both "YYYY-MM-DD" and full datetime strings like
  /// "2026-08-22T00:00:00.000+00:00" that Appwrite may return.
  static DateTime _parseDate(String s) {
    final parsed = DateTime.parse(s);
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  factory HabitEntry.fromMap(Map<String, dynamic> map) {
    return HabitEntry(
      id: map[r'$id'] as String,
      habitId: map['habit_id'] as String,
      date: _parseDate(map['date'] as String),
      completed: map['completed'] as bool,
    );
  }

  /// Returns the date formatted as "YYYY-MM-DD" for storage.
  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

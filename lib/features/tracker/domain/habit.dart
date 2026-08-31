/// Represents a user-defined habit, optionally bounded by a challenge period.
class Habit {
  final String id;
  final String name;
  final bool challengeEnabled;

  /// Date-only (time component is always midnight UTC).
  final DateTime? startDate;

  /// Date-only (time component is always midnight UTC).
  final DateTime? endDate;

  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.challengeEnabled,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  /// Parses an ISO-8601 date string into a date-only UTC [DateTime].
  /// Handles both "YYYY-MM-DD" and full datetime strings like
  /// "2026-08-22T00:00:00.000+00:00" that Appwrite may return.
  static DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    final parsed = DateTime.parse(s);
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map[r'$id'] as String,
      name: map['name'] as String,
      challengeEnabled: map['challenge_enabled'] as bool,
      startDate: _parseDate(map['start_date'] as String?),
      endDate: _parseDate(map['end_date'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Normalises [date] to midnight UTC so comparisons are day-only.
  static DateTime normalise(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// Inclusive challenge length in days.
  /// Returns null when [challengeEnabled] is false or dates are missing.
  int? get challengeDays {
    if (!challengeEnabled || startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays + 1;
  }

  bool isWithinChallenge(DateTime date) {
    if (!challengeEnabled || startDate == null || endDate == null) return false;
    final d = normalise(date);
    return !d.isBefore(startDate!) && !d.isAfter(endDate!);
  }
}

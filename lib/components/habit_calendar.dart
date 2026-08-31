import 'package:flutter/material.dart';

import '../features/tracker/domain/habit.dart';
import '../features/tracker/domain/habit_entry.dart';

/// A custom monthly calendar widget for the habit detail screen.
///
/// Week starts on **Saturday** as per the design specification.
/// Day columns: Sat Sun Mon Tue Wed Thu Fri
class HabitCalendar extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final DateTime displayedMonth; // only year + month matter
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDayTap;

  const HabitCalendar({
    super.key,
    required this.habit,
    required this.entries,
    required this.displayedMonth,
    this.selectedDate,
    required this.onDayTap,
  });

  // ── Weekday labels (Sat→Fri) ───────────────────────────────────────────────

  static const _weekLabels = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  // ── Day-state helpers ──────────────────────────────────────────────────────

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    if (selectedDate == null) return false;
    return date.year == selectedDate!.year &&
        date.month == selectedDate!.month &&
        date.day == selectedDate!.day;
  }

  bool _isCompleted(DateTime date) {
    final normalised = Habit.normalise(date);
    return entries.any((e) => e.date == normalised && e.completed);
  }

  /// Column index (0=Sat … 6=Fri) for the first day of [displayedMonth].
  ///
  /// Dart weekdays: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
  /// Desired column: Sat=0, Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6
  int _firstDayOffset() {
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    // Map Dart weekday (Mon=1..Sun=7) → column (Sat=0..Fri=6)
    const dartToColumn = {1: 2, 2: 3, 3: 4, 4: 5, 5: 6, 6: 0, 7: 1};
    return dartToColumn[firstDay.weekday]!;
  }

  int _daysInMonth() {
    return DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
  }

  // ── Cell appearance ────────────────────────────────────────────────────────

  Widget _buildDayCell(BuildContext context, int day) {
    final cs = Theme.of(context).colorScheme;
    final date = DateTime(displayedMonth.year, displayedMonth.month, day);

    final isSelected = _isSelected(date);
    final isToday = _isToday(date);
    final isCompleted = _isCompleted(date);
    final isChallenge = habit.isWithinChallenge(date);

    // Priority: selected > today > completed > challenge > normal
    Color bgColor;
    Color textColor;
    BoxBorder? border;

    if (isSelected) {
      bgColor = cs.onSurface;
      textColor = cs.surface;
      border = null;
    } else if (isToday) {
      bgColor = cs.surfaceContainerHigh;
      textColor = cs.onSurface;
      border = Border.all(color: cs.onSurface, width: 1.5);
    } else if (isCompleted) {
      bgColor = cs.onSurface.withValues(alpha: 0.55);
      textColor = cs.surface;
      border = null;
    } else if (isChallenge) {
      bgColor = cs.surfaceContainerHighest;
      textColor = cs.onSurface;
      border = Border.all(color: cs.outline.withValues(alpha: 0.5), width: 1);
    } else {
      bgColor = cs.surfaceContainer;
      textColor = cs.onSurface;
      border = null;
    }

    return GestureDetector(
      onTap: () => onDayTap(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontWeight:
                isSelected || isCompleted ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final offset = _firstDayOffset();
    final days = _daysInMonth();
    final totalCells = offset + days;
    final rows = (totalCells / 7).ceil();
    final cellCount = rows * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Weekday header ─────────────────────────────────────────────────
          Row(
            children: _weekLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // ── Day grid ───────────────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: cellCount,
            itemBuilder: (context, index) {
              final dayNumber = index - offset + 1;

              if (dayNumber < 1 || dayNumber > days) {
                // Empty cell before the first day or after the last.
                return const SizedBox.shrink();
              }

              return _buildDayCell(context, dayNumber);
            },
          ),
        ],
      ),
    );
  }
}

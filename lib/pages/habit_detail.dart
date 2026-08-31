import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/habit_calendar.dart';
import '../features/tracker/domain/habit.dart';
import '../features/tracker/presentation/tracker_provider.dart';

class HabitDetailPage extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailPage({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Start on the habit's challenge month, or today if no challenge.
    final now = DateTime.now();
    _displayedMonth = widget.habit.startDate != null
        ? DateTime(widget.habit.startDate!.year, widget.habit.startDate!.month)
        : DateTime(now.year, now.month);
  }

  // ── Month navigation ───────────────────────────────────────────────────────

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  // ── Day tap ────────────────────────────────────────────────────────────────

  void _onDayTap(DateTime date) {
    // For challenge habits, only allow toggling within the challenge range.
    if (widget.habit.challengeEnabled && !widget.habit.isWithinChallenge(date)) {
      return;
    }

    setState(() {
      _selectedDate = date;
    });

    ref.read(allHabitEntriesProvider.notifier).toggleEntry(
          habitId: widget.habit.id,
          date: date,
        );
  }

  // ── Month label ────────────────────────────────────────────────────────────

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_displayedMonth.month - 1]} ${_displayedMonth.year}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final entriesAsync = ref.watch(habitEntriesProvider(widget.habit.id));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          widget.habit.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load entries:\n$e')),
        data: (entries) {
          final committedCount = entries.where((e) => e.completed).length;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ── Committed count ──────────────────────────────────────────
                Center(
                  child: Text(
                    '$committedCount',
                    style: tt.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Days Committed',
                    style: tt.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Month navigation ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                        tooltip: 'Previous month',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _monthLabel,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                        tooltip: 'Next month',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Calendar ─────────────────────────────────────────────────
                HabitCalendar(
                  habit: widget.habit,
                  entries: entries,
                  displayedMonth: _displayedMonth,
                  selectedDate: _selectedDate,
                  onDayTap: _onDayTap,
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

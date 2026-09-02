import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/empty_state_view.dart';
import '../components/error_state_view.dart';
import '../components/habit_card.dart';
import '../features/tracker/presentation/tracker_provider.dart';
import 'habit_detail.dart';

class TrackerPage extends ConsumerWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => ErrorStateView(
        error: error,
        onRetry: () => ref.invalidate(habitsProvider),
      ),

      data: (habits) {
        if (habits.isEmpty) {
          return const EmptyStateView(
            icon: Icons.track_changes_outlined,
            title: 'No habits yet',
            subtitle: 'Tap + to create your first habit.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];

            // Load committed count for this habit.
            final entriesAsync = ref.watch(habitEntriesProvider(habit.id));
            final committedCount =
                entriesAsync.valueOrNull?.where((e) => e.completed).length ?? 0;

            return HabitCard(
              key: ValueKey(habit.id),
              habit: habit,
              committedCount: committedCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailPage(habit: habit),
                  ),
                );
              },
              onDelete: () {
                ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              },
            );
          },
        );
      },
    );
  }
}

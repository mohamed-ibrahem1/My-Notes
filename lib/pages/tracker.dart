import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

      error: (error, _) => Center(
        child: Text(
          'Failed to load habits:\n$error',
          textAlign: TextAlign.center,
        ),
      ),

      data: (habits) {
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No habits yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first habit.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];

            // Load committed count for this habit.
            final entriesAsync = ref.watch(habitEntriesProvider(habit.id));
            final committedCount = entriesAsync.valueOrNull
                    ?.where((e) => e.completed)
                    .length ??
                0;

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

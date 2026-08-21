import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/cards.dart';
import '../features/notes/presentation/notes_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return notesAsync.when(
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },

      error: (error, stackTrace) {
        return Center(
          child: Text(
            'Failed to load notes:\n$error',
            textAlign: TextAlign.center,
          ),
        );
      },

      data: (notes) {
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];

            return AdaptiveCard(
              key: ValueKey(note.id),
              title: note.title,
              subtitle: note.content,
              onTap: () {
                // Editing will be connected here later.
              },
              onDelete: () {
                ref.read(notesProvider.notifier).deleteNote(note.id);
              },
            );
          },
        );
      },
    );
  }
}

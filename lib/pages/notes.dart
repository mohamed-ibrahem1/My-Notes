import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/notes/domain/note_domain.dart';

import '../components/cards.dart';
import '../components/notes_search_bar.dart';
import '../features/notes/presentation/notes_provider.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      final title = note.title.toLowerCase();
      final content = note.content.toLowerCase();

      return title.contains(_searchQuery) || content.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        final filteredNotes = _filterNotes(notes);

        return Column(
          children: [
            NotesSearchBar(onChanged: _onSearchChanged),

            Expanded(
              child: filteredNotes.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No notes yet'
                            : 'No matching notes',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];

                        return AdaptiveCard(
                          key: ValueKey(note.id),
                          title: note.title,
                          subtitle: note.content,
                          onTap: () {
                            // Editing will be connected here later.
                          },
                          onDelete: () {
                            ref
                                .read(notesProvider.notifier)
                                .deleteNote(note.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/notes/domain/note_domain.dart';

import '../components/cards.dart';
import '../components/empty_state_view.dart';
import '../components/error_state_view.dart';
import '../components/notes_bottom_sheet.dart';
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
    final filtered = _searchQuery.isEmpty
        ? notes
        : notes.where((note) {
            final title = note.title.toLowerCase();
            final content = note.content.toLowerCase();

            return title.contains(_searchQuery) ||
                content.contains(_searchQuery);
          }).toList();

    // Pinned notes always come first, newest-added order preserved otherwise.
    final pinned = filtered.where((note) => note.pinned).toList();
    final unpinned = filtered.where((note) => !note.pinned).toList();
    return [...pinned, ...unpinned];
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return notesAsync.when(
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },

      error: (error, stackTrace) {
        return ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(notesProvider),
        );
      },

      data: (notes) {
        final filteredNotes = _filterNotes(notes);

        return Column(
          children: [
            NotesSearchBar(onChanged: _onSearchChanged),

            Expanded(
              child: filteredNotes.isEmpty
                  ? EmptyStateView(
                      icon: Icons.note_outlined,
                      title: _searchQuery.isEmpty
                          ? 'No notes yet'
                          : 'No matching notes',
                      subtitle: _searchQuery.isEmpty
                          ? 'Tap + to create your first note.'
                          : null,
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
                          isPinned: note.pinned,
                          onTap: () {
                            // Editing will be connected here later.
                          },
                          onLongPress: () {
                            showNoteBottomSheet(
                              context,
                              initialTitle: note.title,
                              initialContent: note.content,
                              onSave: (title, content) {
                                return ref
                                    .read(notesProvider.notifier)
                                    .updateNote(
                                      id: note.id,
                                      title: title,
                                      content: content,
                                    );
                              },
                            );
                          },
                          onTogglePin: () async {
                            try {
                              await ref
                                  .read(notesProvider.notifier)
                                  .togglePin(note.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not update pin: $e'),
                                  ),
                                );
                              }
                            }
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

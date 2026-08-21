import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/appwrite_provider.dart';
import '../data/note_repository.dart';
import '../domain/note_domain.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(appwriteProvider));
});

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repository {
    return ref.read(noteRepositoryProvider);
  }

  @override
  Future<List<Note>> build() {
    return _repository.getNotes();
  }

  Future<void> addNote({required String title, required String content}) async {
    await _repository.addNote(title: title, content: content);

    ref.invalidateSelf();
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    await _repository.updateNote(id: id, title: title, content: content);

    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final previousNotes = state.value ?? [];

    // Remove the note from the UI immediately.
    state = AsyncData(previousNotes.where((note) => note.id != id).toList());

    try {
      // Delete the note from Appwrite.
      await _repository.deleteNote(id);
    } catch (e, stackTrace) {
      // Restore the note if Appwrite deletion fails.
      state = AsyncData(previousNotes);

      debugPrint('Failed to delete note: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

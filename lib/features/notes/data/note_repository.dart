import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../../core/services/appwrite_service.dart';
import '../domain/note_domain.dart';

class NoteRepository {
  final AppwriteService appwrite;

  NoteRepository(this.appwrite);

  Future<T> _retry<T>(Future<T> Function() fn, {int maxRetries = 3}) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await fn();
      } catch (e) {
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 350 * attempt));
      }
    }
  }

  Future<List<Note>> getNotes() async {
    final models.RowList result = await _retry(() => appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
    ));

    return result.rows.map((row) => Note.fromMap(row.data)).toList();
  }

  Future<Note> addNote({required String title, required String content}) async {
    final row = await _retry(() => appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
      rowId: ID.unique(),
      data: {'title': title, 'content': content},
    ));

    return Note.fromMap(row.data);
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    await _retry(() => appwrite.tablesDB.updateRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
      rowId: id,
      data: {'title': title, 'content': content},
    ));
  }

  Future<void> deleteNote(String id) async {
    await _retry(() => appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
      rowId: id,
    ));
  }
}

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../../core/services/appwrite_service.dart';
import '../domain/note_domain.dart';

class NoteRepository {
  final AppwriteService appwrite;

  NoteRepository(this.appwrite);

  Future<List<Note>> getNotes() async {
    final models.RowList result = await appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
    );

    return result.rows.map((row) => Note.fromMap(row.data)).toList();
  }

  Future<Note> addNote({required String title, required String content}) async {
    final row = await appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
      rowId: ID.unique(),
      data: {'title': title, 'content': content},
    );

    return Note.fromMap(row.data);
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    await appwrite.tablesDB.updateRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
      rowId: id,
      data: {'title': title, 'content': content},
    );
  }

  Future<void> deleteNote(String id) async {
    await appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.notesTableId,
      rowId: id,
    );
  }
}

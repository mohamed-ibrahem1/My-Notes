import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../../core/services/appwrite_service.dart';
import '../domain/task.dart';

class TaskRepository {
  final AppwriteService appwrite;

  TaskRepository(this.appwrite);

  Future<List<Task>> getTasks() async {
    final models.RowList result = await appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
    );

    return result.rows.map((row) => Task.fromMap(row.data)).toList();
  }

  Future<Task> addTask({required String content}) async {
    final row = await appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
      rowId: ID.unique(),
      data: {'content': content, 'completed': false},
    );

    return Task.fromMap(row.data);
  }

  Future<void> updateTaskCompletion({
    required String id,
    required bool completed,
  }) async {
    await appwrite.tablesDB.updateRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
      rowId: id,
      data: {'completed': completed},
    );
  }

  Future<void> deleteTask(String id) async {
    await appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
      rowId: id,
    );
  }
}

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../../core/services/appwrite_service.dart';
import '../domain/task.dart';

class TaskRepository {
  final AppwriteService appwrite;

  TaskRepository(this.appwrite);

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

  Future<List<Task>> getTasks() async {
    final models.RowList result = await _retry(() => appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
    ));

    return result.rows.map((row) => Task.fromMap(row.data)).toList();
  }

  Future<Task> addTask({required String content}) async {
    final row = await _retry(() => appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
      rowId: ID.unique(),
      data: {'content': content, 'completed': false},
    ));

    return Task.fromMap(row.data);
  }

  Future<void> updateTaskCompletion({
    required String id,
    required bool completed,
  }) async {
    await _retry(() => appwrite.tablesDB.updateRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
      rowId: id,
      data: {'completed': completed},
    ));
  }

  Future<void> deleteTask(String id) async {
    await _retry(() => appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.tasksTableId,
      rowId: id,
    ));
  }
}

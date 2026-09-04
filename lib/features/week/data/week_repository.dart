import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../../core/services/appwrite_service.dart';
import '../domain/week_task.dart';

class WeekRepository {
  final AppwriteService appwrite;

  WeekRepository(this.appwrite);

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

  Future<List<WeekTask>> getTasks() async {
    final models.RowList result = await _retry(
      () => appwrite.tablesDB.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.weekTasksTableId,
      ),
    );

    return result.rows.map((row) => WeekTask.fromMap(row.data)).toList();
  }

  Future<WeekTask> addTask({required String content}) async {
    final row = await _retry(
      () => appwrite.tablesDB.createRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.weekTasksTableId,
        rowId: ID.unique(),
        data: {'content': content, 'completed': false},
      ),
    );

    return WeekTask.fromMap(row.data);
  }

  Future<void> updateTaskCompletion({
    required String id,
    required bool completed,
  }) async {
    await _retry(
      () => appwrite.tablesDB.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.weekTasksTableId,
        rowId: id,
        data: {'completed': completed},
      ),
    );
  }

  Future<void> deleteTask(String id) async {
    await _retry(
      () => appwrite.tablesDB.deleteRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.weekTasksTableId,
        rowId: id,
      ),
    );
  }

  Future<void> updateTaskContent({
    required String id,
    required String content,
  }) async {
    await _retry(
      () => appwrite.tablesDB.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.weekTasksTableId,
        rowId: id,
        data: {'content': content},
      ),
    );
  }
}

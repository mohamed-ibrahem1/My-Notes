import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../../core/services/appwrite_service.dart';
import '../domain/week_task.dart';

class WeekRepository {
  final AppwriteService appwrite;

  WeekRepository(this.appwrite);

  Future<List<WeekTask>> getTasks() async {
    final models.RowList result = await appwrite.tablesDB.listRows(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.weekTasksTableId,
    );

    return result.rows.map((row) => WeekTask.fromMap(row.data)).toList();
  }

  Future<WeekTask> addTask({required String content}) async {
    final row = await appwrite.tablesDB.createRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.weekTasksTableId,
      rowId: ID.unique(),
      data: {'content': content, 'completed': false},
    );

    return WeekTask.fromMap(row.data);
  }

  Future<void> updateTaskCompletion({
    required String id,
    required bool completed,
  }) async {
    await appwrite.tablesDB.updateRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.weekTasksTableId,
      rowId: id,
      data: {'completed': completed},
    );
  }

  Future<void> deleteTask(String id) async {
    await appwrite.tablesDB.deleteRow(
      databaseId: AppwriteService.databaseId,
      tableId: AppwriteService.weekTasksTableId,
      rowId: id,
    );
  }
}

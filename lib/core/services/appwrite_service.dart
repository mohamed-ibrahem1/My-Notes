import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://fra.cloud.appwrite.io/v1',
  );

  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '6a8738c20014d15913ab',
  );

  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: '6a875b180026df88acc1',
  );

  static const String tasksTableId = 'tasks';
  static const String weekTasksTableId = 'week';
  static const String notesTableId = 'notes';
  static const String habitsTableId = 'habits';
  static const String habitEntriesTableId = 'habit_entries';

  late final Client client;
  late final TablesDB tablesDB;

  AppwriteService() {
    final finalEndpoint = endpoint.trim();
    final finalProjectId = projectId.trim();

    if (finalEndpoint.isEmpty || finalProjectId.isEmpty) {
      throw StateError(
        'Appwrite is not configured. Pass APPWRITE_ENDPOINT and APPWRITE_PROJECT_ID using --dart-define.',
      );
    }

    client = Client().setEndpoint(finalEndpoint).setProject(finalProjectId);

    tablesDB = TablesDB(client);
  }
}

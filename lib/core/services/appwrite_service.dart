import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';

  static const String projectId = '6a8738c20014d15913ab';

  static const String databaseId = '6a875b180026df88acc1';

  static const String tasksTableId = 'tasks';
  static const String weekTasksTableId = 'week';
  static const String notesTableId = 'notes';
  static const String habitsTableId = 'habits';
  static const String habitEntriesTableId = 'habit_entries';

  late final Client client;
  late final TablesDB tablesDB;

  AppwriteService() {
    client = Client().setEndpoint(endpoint).setProject(projectId);

    tablesDB = TablesDB(client);
  }
}

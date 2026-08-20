import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/components/notes_bottom_sheet.dart';
import 'package:my_notes/components/task_bottom_sheet.dart';
import 'package:my_notes/components/tracker_bottom_sheet.dart';
import 'package:my_notes/features/tasks/presentation/task_provider.dart';
import 'appwrite_client.dart';
import 'pages/notes.dart';
import 'pages/today.dart';
import 'pages/tracker..dart';
import 'pages/week.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'My Notes'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    TodayPage(),
    WeekPage(),
    NotesPage(),
    TrackerPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddBottomSheet() {
    switch (_selectedIndex) {
      case 0:
      case 1:
        showTaskBottomSheet(
          context,
          onSave: (content) {
            return ref.read(tasksProvider.notifier).addTask(content: content);
          },
        );
        break;

      case 2:
        showNoteBottomSheet(context);
        break;

      case 3:
        showTrackerBottomSheet(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _pages[_selectedIndex]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => client.ping(),
              child: const Text('Send a ping'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

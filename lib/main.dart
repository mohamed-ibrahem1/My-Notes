import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/components/notes_bottom_sheet.dart';
import 'package:my_notes/components/task_bottom_sheet.dart';
import 'package:my_notes/components/tracker_bottom_sheet.dart';
import 'package:my_notes/features/notes/presentation/notes_provider.dart';
import 'package:my_notes/features/tasks/presentation/task_provider.dart';
import 'package:my_notes/features/week/presentation/week_provider.dart';
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
        showTaskBottomSheet(
          context,
          onSave: (content) {
            return ref.read(tasksProvider.notifier).addTask(content: content);
          },
        );
        break;

      case 1:
        showTaskBottomSheet(
          context,
          onSave: (content) {
            return ref.read(weekProvider.notifier).addTask(content: content);
          },
        );
        break;

      case 2:
        showNoteBottomSheet(
          context,
          onSave: (title, content) {
            return ref
                .read(notesProvider.notifier)
                .addNote(title: title, content: content);
          },
        );
        break;

      case 3:
        showTrackerBottomSheet(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows body content to extend behind the floating nav bar
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Column(children: [Expanded(child: _pages[_selectedIndex])]),

      // ── Material 3 floating navigation bar ──────────────────────────────
      bottomNavigationBar: Padding(
        // Outer padding gives the "floating" gap around the bar
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_view_week_outlined),
                selectedIcon: Icon(Icons.calendar_view_week),
                label: 'Week',
              ),
              NavigationDestination(
                icon: Icon(Icons.note_outlined),
                selectedIcon: Icon(Icons.note),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.track_changes_outlined),
                selectedIcon: Icon(Icons.track_changes),
                label: 'Tracker',
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

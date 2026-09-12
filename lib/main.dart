import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_notes/components/notes_bottom_sheet.dart';
import 'package:my_notes/components/task_bottom_sheet.dart';
import 'package:my_notes/components/tracker_bottom_sheet.dart';
import 'package:my_notes/features/notes/presentation/notes_provider.dart';
import 'package:my_notes/features/tasks/presentation/task_provider.dart';
import 'package:my_notes/features/week/presentation/week_provider.dart';
import 'pages/notes.dart';
import 'pages/today.dart';
import 'pages/tracker.dart';
import 'pages/week.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ignore benign debug-only RawKeyboard assertion on Windows (e.g. Alt / Alt-Tab)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('Attempted to send a key down event') ||
        message.contains('raw_keyboard.dart')) {
      return;
    }
    originalOnError?.call(details);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appBackground = Color(0xFF1B1A55);
    const cardBackground = Color(0xFF070F2B);
    const accent = Color(0xFF535C91);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: appBackground,
        canvasColor: appBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          primary: accent,
          secondary: accent,
          surface: cardBackground,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: appBackground,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: cardBackground,
          margin: EdgeInsets.zero,
          elevation: 0,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: cardBackground,
          surfaceTintColor: Colors.transparent,
          indicatorColor: accent,
          shadowColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
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
        showTrackerBottomSheet(context, ref);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows body content to extend behind the floating nav bar
      extendBody: true,
      appBar: AppBar(
        title: Text(
          widget.title.toUpperCase(),
          style: GoogleFonts.bitcountTextTheme().titleLarge?.copyWith(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
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

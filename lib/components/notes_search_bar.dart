import 'package:flutter/material.dart';

class NotesSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const NotesSearchBar({super.key, required this.onChanged});

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends State<NotesSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        controller: _controller,
        leading: const Icon(Icons.search),
        hintText: 'Search notes...',
        trailing: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              );
            },
          ),
        ],
        onChanged: widget.onChanged,
      ),
    );
  }
}

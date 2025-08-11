import 'package:flutter/material.dart';
import '../db/notes_database.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Note> _results = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final notes = await NotesDatabase.instance.searchNotes(query);
    setState(() {
      _results = notes;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live-Suche")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _search,
              decoration: const InputDecoration(
                labelText: 'Suchbegriff eingeben...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('Keine Treffer.'))
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  return NoteCard(note: _results[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

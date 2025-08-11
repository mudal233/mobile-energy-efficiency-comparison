import 'package:flutter/material.dart';
import '../db/notes_database.dart';

class UpdateNoteByTitleScreen extends StatefulWidget {
  const UpdateNoteByTitleScreen({super.key});

  @override
  State<UpdateNoteByTitleScreen> createState() => _UpdateNoteByTitleScreenState();
}

class _UpdateNoteByTitleScreenState extends State<UpdateNoteByTitleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _newContentController = TextEditingController();
  String _selectedCategory = 'Alltag';

  final List<String> _categories = ['Alltag', 'Arbeit', 'Idee', 'Privat'];
  String _status = '';

  Future<void> _updateNotes() async {
    if (_formKey.currentState!.validate()) {
      final updatedCount = await NotesDatabase.instance.updateNoteByTitle(
        _titleController.text,
        _newContentController.text,
        _selectedCategory,
      );

      setState(() {
        _status = '$updatedCount Notiz(en) aktualisiert.';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notiz nach Titel aktualisieren')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel der Notiz (alt)'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Titel eingeben' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newContentController,
                decoration: const InputDecoration(labelText: 'Neuer Inhalt'),
                maxLines: 4,
                validator: (value) =>
                value == null || value.isEmpty ? 'Neuen Inhalt eingeben' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Neue Kategorie'),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _updateNotes,
                icon: const Icon(Icons.update),
                label: const Text('Notiz(en) aktualisieren'),
              ),
              const SizedBox(height: 16),
              if (_status.isNotEmpty)
                Text(
                  _status,
                  style: const TextStyle(color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

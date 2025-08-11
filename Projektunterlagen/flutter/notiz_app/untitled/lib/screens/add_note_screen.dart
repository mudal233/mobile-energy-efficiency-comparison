import 'package:flutter/material.dart';
import '../db/notes_database.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Alltag';

  final List<String> _categories = ['Alltag', 'Arbeit', 'Idee', 'Privat'];

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final note = Note(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      );

      await NotesDatabase.instance.insertNote(note);

    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neue Notiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Bitte Titel eingeben' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Inhalt'),
                maxLines: 6,
                validator: (value) =>
                value == null || value.isEmpty ? 'Bitte Inhalt eingeben' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategorie'),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save),
                label: const Text('Speichern'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

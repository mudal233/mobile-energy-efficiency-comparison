import 'package:flutter/material.dart';
import '../db/notes_database.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'package:intl/intl.dart';
import 'add_note_screen.dart';
import 'update_note_by_title_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }
  final List<String> dummyContents = [
    'Heute war ein sehr produktiver Tag. Ich habe nicht nur alle Aufgaben in meiner To-Do-Liste abgearbeitet, sondern auch noch ein paar neue Ideen für das Projekt entwickelt. Es fühlt sich großartig an, wenn der Tag so erfolgreich endet und man mit dem Gefühl ins Bett geht, etwas erreicht zu haben.',

    'Der Frühling ist endlich da, und das merkt man deutlich. Die Blumen blühen, die Vögel singen und die Sonne scheint. Ich habe einen langen Spaziergang im Park gemacht und mich einfach von der Frühlingsluft verzaubern lassen. Es tut so gut, nach der langen Zeit des Winters wieder draußen zu sein.',

    'Ich habe heute mit einem alten Freund telefoniert, den ich schon seit Jahren nicht mehr gesprochen hatte. Es war unglaublich schön, wieder in Kontakt zu sein und sich über die letzten Jahre auszutauschen. Wir haben beschlossen, uns bald mal wieder zu treffen und die alten Zeiten aufleben zu lassen.',

    'In der letzten Woche habe ich einige neue Rezepte ausprobiert, und einige davon waren einfach fantastisch. Es macht richtig Spaß, in der Küche kreativ zu werden und neue Gerichte auszuprobieren. Kochen ist für mich mittlerweile eine Art Meditation geworden, bei der ich vollkommen abschalten kann und meine Gedanken zur Ruhe kommen.',

    'Ich war heute bei einem Seminar über persönliche Weiterentwicklung, und es war eine der besten Entscheidungen, die ich in letzter Zeit getroffen habe. Es ging darum, wie man seine Ziele klar definiert und Strategien entwickelt, um diese zu erreichen. Am meisten hat mich die Methode zur Selbstreflexion beeindruckt.',

    'Der heutige Tag war ziemlich stressig. Es gab viele unerwartete Probleme, die es zu lösen galt, und einige Dinge, die ich nicht auf die Reihe bekommen habe. Aber trotzdem habe ich es geschafft, mich nicht unterkriegen zu lassen und das Beste aus der Situation zu machen. Morgen wird ein besserer Tag.',

    'Ich habe heute eine alte Schule von Freunden wieder besucht und viele Erinnerungen kamen zurück. Die Menschen, die Gebäude, und die Gerüche – alles fühlte sich gleichzeitig fremd und vertraut an. Es ist erstaunlich, wie stark unser Gedächtnis an bestimmten Orten hängt und wie nostalgisch man bei so einem Besuch wird.',

    'Es war ein Tag voller Überraschungen. Zuerst habe ich einen unerwarteten Anruf von einem ehemaligen Kollegen erhalten, der mir ein unglaubliches Jobangebot gemacht hat. Dann habe ich einen unerklärlichen Anflug von Inspiration bekommen und mir eine ganze Liste neuer Projekte und Ideen notiert, die ich in Angriff nehmen möchte.',

    'Heute habe ich mir endlich die Zeit genommen, mich um meine Finanzen zu kümmern. Es fühlt sich immer gut an, wenn man den Überblick behält und weiß, wo man steht. Ich habe ein neues Budget erstellt und mir Ziele gesetzt, um meine Ausgaben besser zu kontrollieren. Es wird ein herausforderndes, aber gutes Jahr.',

    'Ich war heute auf einer Kunstausstellung, die mich wirklich inspiriert hat. Die Gemälde, die Skulpturen und die kreativen Ideen haben mich zum Nachdenken angeregt. Ich liebe es, mich von Kunst inspirieren zu lassen, und oft finde ich dort neue Perspektiven, die ich in meinem eigenen Leben anwenden kann. Es war eine wundervolle Erfahrung.'
  ];


  Future<void> _loadNotes() async {
    final notes = await NotesDatabase.instance.fetchAllNotes();
    setState(() {
      _notes = notes;
    });
  }
  Future<void> _updateNoteByTitle() async {
    final updatedCount = await NotesDatabase.instance.updateNoteByTitle(
      'Test', // <-- Titel
      'Dies ist der neue Inhalt nach Update',
      'Idee', // <-- neue Kategorie
    );

    print('$updatedCount Notiz(en) aktualisiert.');
    _loadNotes(); // neu laden
  }

  Future<void> _generateDummyNotes() async {
    final now = DateTime.now();
    final random = Random();

    for (int i = 0; i < 5000; i++) {
      final note = Note(
        title: 'Notiz $i',
        content: dummyContents[random.nextInt(dummyContents.length)],
        category: ['Alltag', 'Arbeit', 'Idee', 'Privat'][i % 4],
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      );
      await NotesDatabase.instance.insertNote(note);
    }

    _loadNotes();
  }

  // Delete all notes
  Future<void> _deleteAllNotes() async {
    await NotesDatabase.instance.deleteAllNotes();
    _loadNotes();
  }

  // Delete notes of a specific category
  Future<void> _deleteNotesByCategory(String category) async {
    await NotesDatabase.instance.deleteNotesByCategory(category);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Notizen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('Noch keine Notizen vorhanden.'))
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          return NoteCard(note: _notes[index]);
        },
      ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            FloatingActionButton(
              heroTag: 'manuell',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                );
                if (result == true) {
                  _loadNotes();
                }
              },
              child: const Icon(Icons.edit_note),
              tooltip: 'Manuell Notiz erstellen',
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'dummy',
              onPressed: _generateDummyNotes,
              child: const Icon(Icons.add),
              tooltip: '1000 Dummy-Notizen erstellen',
            ),

            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'delete_all',
              onPressed: _deleteAllNotes,
              child: const Icon(Icons.delete_forever),
              tooltip: 'Alle Notizen löschen',
            ),



            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'update_by_input',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdateNoteByTitleScreen()),
                );
                if (result == true) {
                  _loadNotes();
                }
              },
              child: const Icon(Icons.edit),
              tooltip: 'Notiz per Titel aktualisieren',
            ),

          ],
        ),

    );
  }
}

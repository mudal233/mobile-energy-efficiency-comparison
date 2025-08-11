package com.example.notesapp.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.*;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.notesapp.R;
import com.example.notesapp.data.*;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import android.widget.Toast;

import java.text.SimpleDateFormat;
import java.util.*;

public class HomeFragment extends Fragment {
    private static final List<String> dummyContents = Arrays.asList(
            "Heute war ein sehr produktiver Tag. Ich habe nicht nur alle Aufgaben in meiner To-Do-Liste abgearbeitet, sondern auch noch ein paar neue Ideen für das Projekt entwickelt. Es fühlt sich großartig an, wenn der Tag so erfolgreich endet und man mit dem Gefühl ins Bett geht, etwas erreicht zu haben.",
            "Der Frühling ist endlich da, und das merkt man deutlich. Die Blumen blühen, die Vögel singen und die Sonne scheint. Ich habe einen langen Spaziergang im Park gemacht und mich einfach von der Frühlingsluft verzaubern lassen. Es tut so gut, nach der langen Zeit des Winters wieder draußen zu sein.",
            "Ich habe heute mit einem alten Freund telefoniert, den ich schon seit Jahren nicht mehr gesprochen hatte. Es war unglaublich schön, wieder in Kontakt zu sein und sich über die letzten Jahre auszutauschen. Wir haben beschlossen, uns bald mal wieder zu treffen und die alten Zeiten aufleben zu lassen.",
            "In der letzten Woche habe ich einige neue Rezepte ausprobiert, und einige davon waren einfach fantastisch. Es macht richtig Spaß, in der Küche kreativ zu werden und neue Gerichte auszuprobieren. Kochen ist für mich mittlerweile eine Art Meditation geworden, bei der ich vollkommen abschalten kann und meine Gedanken zur Ruhe kommen.",
            "Ich war heute bei einem Seminar über persönliche Weiterentwicklung, und es war eine der besten Entscheidungen, die ich in letzter Zeit getroffen habe. Es ging darum, wie man seine Ziele klar definiert und Strategien entwickelt, um diese zu erreichen. Am meisten hat mich die Methode zur Selbstreflexion beeindruckt.",
            "Der heutige Tag war ziemlich stressig. Es gab viele unerwartete Probleme, die es zu lösen galt, und einige Dinge, die ich nicht auf die Reihe bekommen habe. Aber trotzdem habe ich es geschafft, mich nicht unterkriegen zu lassen und das Beste aus der Situation zu machen. Morgen wird ein besserer Tag.",
            "Ich habe heute eine alte Schule von Freunden wieder besucht und viele Erinnerungen kamen zurück. Die Menschen, die Gebäude, und die Gerüche – alles fühlte sich gleichzeitig fremd und vertraut an. Es ist erstaunlich, wie stark unser Gedächtnis an bestimmten Orten hängt und wie nostalgisch man bei so einem Besuch wird.",
            "Es war ein Tag voller Überraschungen. Zuerst habe ich einen unerwarteten Anruf von einem ehemaligen Kollegen erhalten, der mir ein unglaubliches Jobangebot gemacht hat. Dann habe ich einen unerklärlichen Anflug von Inspiration bekommen und mir eine ganze Liste neuer Projekte und Ideen notiert, die ich in Angriff nehmen möchte.",
            "Heute habe ich mir endlich die Zeit genommen, mich um meine Finanzen zu kümmern. Es fühlt sich immer gut an, wenn man den Überblick behält und weiß, wo man steht. Ich habe ein neues Budget erstellt und mir Ziele gesetzt, um meine Ausgaben besser zu kontrollieren. Es wird ein herausforderndes, aber gutes Jahr.",
            "Ich war heute auf einer Kunstausstellung, die mich wirklich inspiriert hat. Die Gemälde, die Skulpturen und die kreativen Ideen haben mich zum Nachdenken angeregt. Ich liebe es, mich von Kunst inspirieren zu lassen, und oft finde ich dort neue Perspektiven, die ich in meinem eigenen Leben anwenden kann. Es war eine wundervolle Erfahrung."
    );

    private static final int ADD_NOTE_REQUEST = 1;

    private NoteAdapter adapter;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        // RecyclerView setup
        RecyclerView recycler = view.findViewById(R.id.recycler_notes);
        recycler.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new NoteAdapter();
        recycler.setAdapter(adapter);

        // Dummy notes FAB
        FloatingActionButton fabGenerate = view.findViewById(R.id.fabAddNotes);
        fabGenerate.setOnClickListener(v -> {
            generateDummyNotes();
            loadNotes();
        });
        FloatingActionButton fabUpdate = view.findViewById(R.id.fabUpdateNote);
        fabUpdate.setOnClickListener(v -> {
            Intent intent = new Intent(getContext(), UpdateNoteActivity.class);
            startActivity(intent);
        });
        FloatingActionButton fabDelete = view.findViewById(R.id.fabDeleteNotes);
        fabDelete.setOnClickListener(v -> {
            NotesDatabase.getInstance(getContext()).noteDao().deleteAllNotes();
            loadNotes(); // Liste neu laden
            Toast.makeText(getContext(), "Alle Notizen wurden gelöscht", Toast.LENGTH_SHORT).show();
        });


        // Manual add note FAB
        FloatingActionButton fabManualAdd = view.findViewById(R.id.fabManualAdd);
        fabManualAdd.setOnClickListener(v -> {
            Intent intent = new Intent(getContext(), AddNoteActivity.class);
            startActivityForResult(intent, ADD_NOTE_REQUEST);
        });

        loadNotes();
        return view;
    }

    private void loadNotes() {
        List<Note> notes = NotesDatabase.getInstance(getContext()).noteDao().getAllNotes();
        adapter.setNotes(notes);
    }

    private void generateDummyNotes() {
        NoteDao dao = NotesDatabase.getInstance(getContext()).noteDao();
        String[] categories = {"Alltag", "Arbeit", "Idee", "Privat"};
        String now = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());
        Random random = new Random();

        for (int i = 0; i < 1000; i++) {
            String title = "Notiz " + i;
            String content = dummyContents.get(random.nextInt(dummyContents.size()));
            String category = categories[i % categories.length];

            dao.insert(new Note(title, content, category, now));
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == ADD_NOTE_REQUEST && resultCode == getActivity().RESULT_OK) {
            loadNotes(); // reload after adding manually
        }
    }
}

package com.example.notesapp.ui;

import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.example.notesapp.R;
import com.example.notesapp.data.*;

import java.util.List;

public class UpdateNoteActivity extends AppCompatActivity {

    private EditText searchTitleInput, contentInput;
    private Spinner categorySpinner;
    private Button updateButton;
    private NoteDao dao;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_update_note);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("Notiz aktualisieren");
        }

        dao = NotesDatabase.getInstance(this).noteDao();

        searchTitleInput = findViewById(R.id.edit_search_title);
        contentInput = findViewById(R.id.edit_content);
        categorySpinner = findViewById(R.id.spinner_category);
        updateButton = findViewById(R.id.btn_update_note);

        String[] categories = {"Alltag", "Arbeit", "Idee", "Privat"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, categories);
        categorySpinner.setAdapter(adapter);

        updateButton.setOnClickListener(v -> updateNotesByTitle());

    }

    private void updateNotesByTitle() {
        String title = searchTitleInput.getText().toString().trim();
        String newContent = contentInput.getText().toString().trim();
        String newCategory = categorySpinner.getSelectedItem().toString();

        if (title.isEmpty() || newContent.isEmpty()) {
            Toast.makeText(this, "Titel und Inhalt müssen ausgefüllt sein", Toast.LENGTH_SHORT).show();
            return;
        }

        List<Note> notesToUpdate = dao.getNotesByTitle(title);
        if (notesToUpdate.isEmpty()) {
            Toast.makeText(this, "Keine Notizen mit diesem Titel gefunden", Toast.LENGTH_SHORT).show();
            return;
        }

        for (Note note : notesToUpdate) {
            note.content = newContent;
            note.category = newCategory;
            dao.insert(note); // ersetzt vorhandene Note mit gleicher ID
        }

        Toast.makeText(this, "Notizen erfolgreich aktualisiert", Toast.LENGTH_SHORT).show();finish();
    }
    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}

package com.example.notesapp.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.example.notesapp.R;
import com.example.notesapp.data.*;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import androidx.appcompat.widget.Toolbar;


public class AddNoteActivity extends AppCompatActivity {

    private EditText titleInput, contentInput;
    private Spinner categorySpinner;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_note);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("manuell speicher"); // optionaler Titel
        }

        // Handle click on the navigation icon
        toolbar.setNavigationOnClickListener(v -> onBackPressed());
        titleInput = findViewById(R.id.edit_title);
        contentInput = findViewById(R.id.edit_content);
        categorySpinner = findViewById(R.id.spinner_category);
        Button saveButton = findViewById(R.id.btn_save_note);

        // Spinner setup
        String[] categories = {"Alltag", "Arbeit", "Idee", "Privat"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, categories);
        categorySpinner.setAdapter(adapter);

        saveButton.setOnClickListener(v -> saveNote());
    }



    private void saveNote() {
        String title = titleInput.getText().toString().trim();
        String content = contentInput.getText().toString().trim();
        String category = categorySpinner.getSelectedItem().toString();
        String now = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());

        if (title.isEmpty() || content.isEmpty()) {
            Toast.makeText(this, "Bitte Titel und Inhalt eingeben", Toast.LENGTH_SHORT).show();
            return;
        }

        Note note = new Note(title, content, category, now);
        NotesDatabase.getInstance(this).noteDao().insert(note);

        Toast.makeText(this, "Notiz gespeichert!", Toast.LENGTH_SHORT).show();

        // ✅ Stay on the screen. Don't finish or navigate.
        // Optionally clear inputs:
        titleInput.setText("");
        contentInput.setText("");
        categorySpinner.setSelection(0);
    }
}

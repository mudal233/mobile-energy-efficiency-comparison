package com.example.notesapp.ui;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.*;
import android.widget.EditText;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.notesapp.R;
import com.example.notesapp.data.*;

import java.util.List;

public class SearchFragment extends Fragment {

    private NoteAdapter adapter;
    private NoteDao noteDao;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_search, container, false);
        EditText searchInput = view.findViewById(R.id.input_search);
        RecyclerView recycler = view.findViewById(R.id.recycler_search);
        adapter = new NoteAdapter();
        recycler.setLayoutManager(new LinearLayoutManager(getContext()));
        recycler.setAdapter(adapter);

        noteDao = NotesDatabase.getInstance(getContext()).noteDao();

        searchInput.addTextChangedListener(new TextWatcher() {
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                search(s.toString());
            }
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            public void afterTextChanged(Editable s) {}
        });

        return view;
    }

    private void search(String query) {
        List<Note> results = noteDao.searchNotes("%" + query + "%");
        adapter.setNotes(results);
    }
}

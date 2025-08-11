package com.example.notesapp.ui;

import android.view.*;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.notesapp.R;
import com.example.notesapp.data.Note;

import java.util.ArrayList;
import java.util.List;

public class NoteAdapter extends RecyclerView.Adapter<NoteAdapter.NoteViewHolder> {
    private List<Note> notes = new ArrayList<>();

    public void setNotes(List<Note> notes) {
        this.notes = notes;
        notifyDataSetChanged();
    }

    public static class NoteViewHolder extends RecyclerView.ViewHolder {
        TextView title, content, category;

        public NoteViewHolder(View view) {
            super(view);
            title = view.findViewById(R.id.text_title);
            content = view.findViewById(R.id.text_content);
            category = view.findViewById(R.id.text_category);
        }
    }

    @NonNull
    @Override
    public NoteViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_note, parent, false);
        return new NoteViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull NoteViewHolder holder, int pos) {
        Note note = notes.get(pos);
        holder.title.setText(note.title);
        holder.content.setText(note.content.length() > 100 ? note.content.substring(0, 100) + "..." : note.content);
        holder.category.setText(note.category);
    }

    @Override
    public int getItemCount() {
        return notes.size();
    }
}

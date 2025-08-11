package com.example.notesapp.data;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;

import java.util.List;

@Dao
public interface NoteDao {

    @Insert
    void insert(Note note);
    @Query("SELECT * FROM notes WHERE title = :title")
    List<Note> getNotesByTitle(String title);

    @Query("SELECT * FROM notes ORDER BY createdAt DESC")
    List<Note> getAllNotes();

    @Query("SELECT * FROM notes WHERE title LIKE :query OR content LIKE :query")
    List<Note> searchNotes(String query);

    @Query("SELECT category, COUNT(*) as count FROM notes GROUP BY category")
    List<CategoryCount> getCategoryStats();
    @Query("DELETE FROM notes")
    void deleteAllNotes();
    @Query("SELECT * FROM notes WHERE title = :title LIMIT 1")
    Note getNoteByTitle(String title);

    class CategoryCount {
        public String category;
        public int count;
    }
}

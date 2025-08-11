import { Capacitor } from '@capacitor/core';
import { CapacitorSQLite, SQLiteConnection, SQLiteDBConnection } from '@capacitor-community/sqlite';

const sqlite = new SQLiteConnection(CapacitorSQLite);
let db: SQLiteDBConnection | null = null;

export const initDB = async () => {
  if (!db) {
    db = await sqlite.createConnection('notizen-db', false, 'no-encryption', 1);
    await db.open();

    await db.execute(`
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        category TEXT,
        createdAt TEXT
      );
    `);
  }
};

export const insertNote = async (title: string, content: string, category: string, createdAt: string) => {
  await db?.run(
    `INSERT INTO notes (title, content, category, createdAt) VALUES (?, ?, ?, ?)`,
    [title, content, category, createdAt]
  );
};

export const getAllNotes = async (): Promise<any[]> => {
  const res = await db?.query(`SELECT * FROM notes ORDER BY id DESC`);
  return res?.values ?? [];
};
export const deleteAllNotes = async () => {
    await db?.execute(`DELETE FROM notes`);
  };
export const searchNotes = async (query: string): Promise<any[]> => {
    const pattern = `%${query}%`; // SQLite LIKE mit Platzhalter
    const res = await db?.query(
      `SELECT * FROM notes WHERE title LIKE ? OR content LIKE ? ORDER BY id DESC`,
      [pattern, pattern]
    );
    return res?.values ?? [];
  };
  export const getNoteByTitle = async (title: string): Promise<any | null> => {
    const res = await db?.query(`SELECT * FROM notes WHERE title = ?`, [title]);
    return res?.values?.[0] ?? null;
  };
  export const updateNoteByTitle = async (title: string, content: string, category: string) => {
    await db?.run(
      `UPDATE notes SET content = ?, category = ? WHERE title = ?`,
      [content, category, title]
    );
  };
  

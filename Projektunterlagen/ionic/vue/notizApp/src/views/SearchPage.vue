<template>
    <ion-page>
      <ion-header>
        <ion-toolbar>
          <ion-title>Suche</ion-title>
        </ion-toolbar>
        <ion-toolbar>
          <ion-searchbar
            v-model="searchTerm"
            placeholder="Titel oder Inhalt durchsuchen..."
            debounce="300"
          />
        </ion-toolbar>
      </ion-header>
  
      <ion-content :fullscreen="true">
        <div class="note-list">
          <ion-card v-for="note in notes" :key="note.id">
            <ion-card-header class="note-header">
              <ion-card-title class="note-title">{{ note.title }}</ion-card-title>
              <div class="note-category">{{ note.category }}</div>
            </ion-card-header>
            <ion-card-content>
              <p>{{ note.content }}</p>
            </ion-card-content>
          </ion-card>
  
          <p v-if="notes.length === 0 && searchTerm.trim() !== ''" class="no-results">
           Keine Notizen gefunden.
          </p>
        </div>
      </ion-content>
    </ion-page>
  </template>
  
  <script setup lang="ts">
  import {
    IonPage,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonCard,
    IonCardHeader,
    IonCardTitle,
    IonCardContent,
    IonSearchbar
  } from '@ionic/vue';
  
  import { ref, watch, onMounted } from 'vue';
  import { initDB, searchNotes } from '@/db/sqlite';
  
  const notes = ref<any[]>([]);
  const searchTerm = ref('');
  
  // Initialisiere DB einmal beim Start
  onMounted(async () => {
    await initDB();
  });
  
  // Reagiere auf Eingaben in Echtzeit und suche über SQLite
  watch(searchTerm, async (newVal) => {
    if (newVal.trim() === '') {
      notes.value = [];
      return;
    }
  
    notes.value = await searchNotes(newVal);
  });
  </script>
  
  <style scoped>
  .note-list {
    padding: 16px;
  }
  
  ion-card {
    margin-bottom: 16px;
    border-radius: 12px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  }
  
  .note-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .note-title {
    font-size: 1.1em;
    font-weight: bold;
    flex: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  
  .note-category {
    font-size: 0.9em;
    color: #666;
    font-style: italic;
    margin-left: 8px;
    white-space: nowrap;
  }
  
  .no-results {
    text-align: center;
    margin-top: 2rem;
    font-size: 1em;
    color: #999;
  }
  </style>
  
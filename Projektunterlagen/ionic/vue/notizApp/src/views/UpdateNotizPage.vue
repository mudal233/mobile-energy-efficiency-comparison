<template>
    <ion-page>
      <ion-header>
        <ion-toolbar>
          <ion-title>Direkt aktualisieren</ion-title>
        </ion-toolbar>
      </ion-header>
  
      <ion-content class="ion-padding">
        <ion-item>
          <ion-label position="stacked">Titel (zum Aktualisieren)</ion-label>
          <ion-input v-model="title" />
        </ion-item>
  
        <ion-item>
          <ion-label position="stacked">Neuer Inhalt</ion-label>
          <ion-textarea v-model="content" auto-grow />
        </ion-item>
  
        <ion-item>
          <ion-label>Neue Kategorie</ion-label>
          <ion-select v-model="category" interface="action-sheet">
            <ion-select-option v-for="cat in categories" :key="cat" :value="cat">
              {{ cat }}
            </ion-select-option>
          </ion-select>
        </ion-item>
  
        <ion-button expand="block"  class="save-btn" @click="updateNote">🔁 Aktualisieren</ion-button>
        <ion-button expand="block"  class="save-btn"  @click="goBack">
        🔙 Zurück
      </ion-button>
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
    IonItem,
    IonLabel,
    IonInput,
    IonTextarea,
    IonSelect,
    IonSelectOption,
    IonButton
  } from '@ionic/vue';
  
  import { ref } from 'vue';
  import { useRouter } from 'vue-router';
  import { updateNoteByTitle, initDB } from '@/db/sqlite';
  
  const router = useRouter();
  
  const title = ref('');
  const content = ref('');
  const category = ref('');
  const categories = ['Alltag', 'Arbeit', 'Idee', 'Privat'];
  
  const updateNote = async () => {
    if (!title.value || !content.value || !category.value) {
      alert('Bitte alle Felder ausfüllen.');
      return;
    }
  
    await initDB();
    await updateNoteByTitle(title.value, content.value, category.value);
    alert('Notiz wurde aktualisiert.');
    
  };
  const goBack = () => {
  router.push('/tabs/home');
};
  </script>
    <style scoped>
    .save-btn {
    margin: 24px 16px 0;
  }
  
 
  
    </style>
  
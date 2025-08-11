<template>
    <ion-page>
      <!-- Header mit Back-Button -->
      <ion-header>
      <ion-toolbar>
        <ion-buttons slot="start">
          <ion-back-button default-href="/tabs/home" />
        </ion-buttons>
        <ion-title>Notiz hinzufügen</ion-title>
      </ion-toolbar>
    </ion-header>
  
      <!-- Content mit Formular -->
      <ion-content>
        <ion-item>
          <ion-label position="stacked">Titel</ion-label>
          <ion-input v-model="title" placeholder="Titel eingeben" />
        </ion-item>
  
        <ion-item>
          <ion-label position="stacked">Inhalt</ion-label>
          <ion-textarea v-model="content" placeholder="Notizinhalt..." auto-grow />
        </ion-item>
  
        <ion-item>
          <ion-label>Kategorie</ion-label>
          <ion-select
            v-model="category"
            placeholder="Kategorie wählen"
            interface="action-sheet"
          >
            <ion-select-option
              v-for="cat in categories"
              :key="cat"
              :value="cat"
            >
              {{ cat }}
            </ion-select-option>
          </ion-select>
        </ion-item>
  
        <ion-button expand="block" class="save-btn" @click="saveNote">
          💾 Speichern
        </ion-button>
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
    IonButtons,
    IonBackButton,
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
  import { insertNote, initDB } from '@/db/sqlite';
  
  const router = useRouter();
  
  const title = ref('');
  const content = ref('');
  const category = ref('');
  const categories = ['Alltag', 'Arbeit', 'Idee', 'Privat'];
  
  const saveNote = async () => {
    if (!title.value || !content.value || !category.value) {
      alert('Bitte fülle alle Felder aus.');
      return;
    }
  
    await initDB();
    const createdAt = new Date().toISOString();
    await insertNote(title.value, content.value, category.value, createdAt);
  
    // Zurück zur HomePage
  
  };
  const goBack = () => {
  router.push('/tabs/home');
};
  </script>
  
  <style scoped>
  .save-btn {
  margin: 24px 16px 0;
}

/* Add safe area inset for notch support */
ion-header,
ion-toolbar {
  padding-top: env(safe-area-inset-top);
}

  </style>
  
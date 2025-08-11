<template>
  <ion-page>
    <ion-header>
      <ion-toolbar>
        <ion-title>Notizen</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content :fullscreen="true">
      <!-- Notizenliste als Cards -->
      <div class="note-list">
        <ion-card v-for="note in notes" :key="note.id">
          <ion-card-header>
  <div class="note-header">
    <ion-card-title class="note-title">{{ note.title }}</ion-card-title>
    <div class="note-category">{{ note.category }}</div>
  </div>
</ion-card-header>
          <ion-card-content>
            <p>{{ note.content }}</p>
          </ion-card-content>
        </ion-card>
      </div>

      <!-- Floating Action Buttons -->
      <div class="fab-stack">
        <ion-fab-button @click="onManual">
          <ion-icon :icon="book" />
        </ion-fab-button>
        <ion-fab-button @click="onUpdate">
          <ion-icon :icon="create" />
        </ion-fab-button>
        <ion-fab-button @click="onDelete">
          <ion-icon :icon="trash" />
        </ion-fab-button>
        <ion-fab-button @click="onInput">
          <ion-icon :icon="add" />
        </ion-fab-button>
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
  IonFabButton,
  IonIcon,
  IonCard,
  IonCardHeader,
  IonCardTitle,
  IonCardContent
} from '@ionic/vue';

import { add, trash, create, book } from 'ionicons/icons';
import { onMounted, ref } from 'vue';
import { initDB, insertNote, getAllNotes } from '@/db/sqlite';
import { deleteAllNotes } from '@/db/sqlite';
import { nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { onIonViewWillEnter } from '@ionic/vue';


const notes = ref<any[]>([]);

const contents = [
  "Heute war ein sehr produktiver Tag. Ich habe nicht nur alle Aufgaben in meiner To-Do-Liste abgearbeitet, sondern auch noch ein paar neue Ideen für das Projekt entwickelt...",
  "Der Frühling ist endlich da, und das merkt man deutlich...",
  "Ich habe heute mit einem alten Freund telefoniert...",
  "In der letzten Woche habe ich einige neue Rezepte ausprobiert...",
  "Ich war heute bei einem Seminar über persönliche Weiterentwicklung...",
  "Der heutige Tag war ziemlich stressig...",
  "Ich habe heute eine alte Schule von Freunden wieder besucht...",
  "Es war ein Tag voller Überraschungen...",
  "Heute habe ich mir endlich die Zeit genommen, mich um meine Finanzen zu kümmern...",
  "Ich war heute auf einer Kunstausstellung, die mich wirklich inspiriert hat..."
];
const router = useRouter();

const categories = ["Alltag", "Arbeit", "Idee", "Privat"];

const onInput = async () => {
  for (let i = 1; i <= 500; i++) {
    const title = `Notiz ${i}`;
    const content = contents[Math.floor(Math.random() * contents.length)];
    const category = categories[Math.floor(Math.random() * categories.length)];
    const createdAt = new Date().toISOString();

    await insertNote(title, content, category, createdAt);
  }
  notes.value = await getAllNotes();
  
};

const onDelete = async () => {


  await deleteAllNotes();
  notes.value = []; 
  await nextTick(); 

 
  notes.value = await getAllNotes();
};
const onUpdate = () => {
  router.push('/tabs/update');
};

const onManual = () => {
  router.push('/tabs/manual');
};

onMounted(async () => {
  await initDB();
  notes.value = await getAllNotes();
});
onIonViewWillEnter(async () => {
  await initDB();
  notes.value = await getAllNotes();
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
  padding: 0 8px;
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


.fab-stack {
  position: fixed;
  bottom: 20px;
  right: 20px;
  display: flex;
  flex-direction: column-reverse;
  gap: 16px;
  z-index: 999;
}
</style>

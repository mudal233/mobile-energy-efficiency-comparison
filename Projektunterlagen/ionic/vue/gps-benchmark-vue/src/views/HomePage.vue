
<template>
  <ion-page>
    <ion-content class="ion-padding" style="background:#FAFAFA">
      <h1 style="font-size: 24px; font-weight: bold; color: #212121">GPS Benchmark</h1>

      <ion-input
        v-model="countInput"
        placeholder="Wie oft Standort abrufen?"
        type="number"
        class="custom-input"
      ></ion-input>

      <ion-button
        expand="block"
        :disabled="isRunning"
        color="primary"
        @click="startTest"
      >
        {{ isRunning ? 'Läuft...' : 'Start' }}
      </ion-button>

      <div
        style="background:#E0E0E0; padding:16px; min-height:120px; margin-top:20px; color:#424242"
      >
        <p style="white-space:pre-line;">{{ result }}</p>
      </div>
    </ion-content>
  </ion-page>
</template>

<script setup>
import {
  IonPage,
  IonContent,
  IonInput,
  IonButton
} from '@ionic/vue'

import { FreshGps } from 'fresh-gps' // ✅ Importiere dein natives Plugin direkt
import axios from 'axios'
import { ref } from 'vue'

const countInput = ref('')
const result = ref('Aktueller Standort erscheint hier...')
const isRunning = ref(false)

let totalCount = 0
let currentCount = 0
const INTERVAL_MS = 2000

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

const getAddressFromCoords = async (lat, lon) => {
  try {
    const res = await axios.get(`https://nominatim.openstreetmap.org/reverse`, {
      params: { lat, lon, format: 'json' }
    })
    return res.data.display_name || 'Keine Adresse gefunden'
  } catch {
    return 'Adresse konnte nicht geladen werden'
  }
}

const fetchLocationLoop = async () => {
  if (currentCount >= totalCount) {
    isRunning.value = false
    return
  }

  try {
    const pos = await FreshGps.getFreshLocation()
    const lat = pos.lat
    const lon = pos.lng
    const address = await getAddressFromCoords(lat, lon)

    currentCount++
    result.value = `Abruf ${currentCount} von ${totalCount}\nLatitude: ${lat}\nLongitude: ${lon}\nAdresse: ${address}`
  } catch (err) {
    result.value = 'GPS-Fehler: ' + err.message
    isRunning.value = false
    return
  }

  await sleep(INTERVAL_MS)
  await fetchLocationLoop()
}

const startTest = async () => {
  if (!countInput.value || isNaN(parseInt(countInput.value))) {
    result.value = 'Bitte gültige Zahl eingeben.'
    return
  }

  totalCount = parseInt(countInput.value)
  currentCount = 0
  isRunning.value = true

  await fetchLocationLoop()
}
</script>

<style>
.custom-input {
  background: white;
  margin: 16px 0;
  padding: 12px;
  border-radius: 4px;
  font-size: 16px;
  border: 1px solid #ccc;
}
</style>

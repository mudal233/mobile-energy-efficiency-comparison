<template>
    <ion-card style="border-radius: 12px; margin: 8px; box-shadow: 2px 2px 8px rgba(0,0,0,0.1);">
      <ion-card-content style="padding: 16px;">
        <h2 style="font-size: 20px; font-weight: bold; color: black;">{{ symbol }}</h2>
        <p v-if="price !== undefined" style="font-size: 18px; font-weight: 500; color: green;">
          ${{ price.toFixed(2) }}
        </p>
      </ion-card-content>
    </ion-card>
  </template>
  
  <script setup>
  import { IonCard, IonCardContent } from '@ionic/vue';
  
  defineProps({
    symbol: {
      type: String,
      required: true
    },
    price: {
      type: Number,
      required: true
    }
  });
  </script>
  
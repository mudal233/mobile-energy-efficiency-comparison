<template>
    <ion-page>
      <ion-tabs>
        <ion-router-outlet></ion-router-outlet>
        <ion-tab-bar slot="bottom">
          <ion-tab-button tab="home" href="/tabs/home">
            <ion-icon :icon="home" />
            <ion-label>Notizen</ion-label>
          </ion-tab-button>
  
          <ion-tab-button tab="search" href="/tabs/search">
            <ion-icon :icon="search" />
            <ion-label>Suche</ion-label>
          </ion-tab-button>
        </ion-tab-bar>
      </ion-tabs>
    </ion-page>
  </template>
  
  <script setup lang="ts">
  import {
    IonPage,
    IonTabs,
    IonTabBar,
    IonTabButton,
    IonIcon,
    IonLabel,
    IonRouterOutlet
  } from '@ionic/vue';
  
  import { home, search } from 'ionicons/icons';
  </script>
  
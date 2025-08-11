<template>
  <ion-page>
    <ion-header>
      <ion-toolbar color="primary">
        <ion-title>Crypto Prices</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content :fullscreen="true" class="ion-padding" style="background-color: white;">
      <ion-button expand="block" color="danger" @click="stopUpdating" style="margin: 8px;">
        ionic vesion
      </ion-button>

      <ion-list>
        <CryptoCard
          v-for="crypto in cryptoList"
          :key="crypto.symbol"
          :symbol="crypto.symbol"
          :price="crypto.price"
        />
      </ion-list>
    </ion-content>
  </ion-page>
</template>

<script setup>
import { IonPage, IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonList } from '@ionic/vue';
import { ref, onMounted, onUnmounted } from 'vue';
import CryptoCard from '@/components/CryptoCard.vue';

const cryptoList = ref([]);
let intervalId = null;
const isUpdating = ref(true);

async function fetchCryptoPrices() {
  try {
    const response = await fetch('https://api.binance.com/api/v3/ticker/price');
    const data = await response.json();
    const filtered = data
      .filter((coin) => coin.symbol.endsWith('USDT'))
      .map((coin) => ({
        symbol: coin.symbol,
        price: parseFloat(coin.price),
      }));

    filtered.sort((a, b) => b.price - a.price);
    cryptoList.value = filtered.slice(0, 100);
  } catch (error) {
    console.error('Error fetching prices:', error);
  }
}

function startAutoUpdate() {
  fetchCryptoPrices();
  intervalId = setInterval(() => {
    if (isUpdating.value) {
      fetchCryptoPrices();
    }
  }, 2000);
}

function stopUpdating() {
  isUpdating.value = false;
}

onMounted(() => {
  startAutoUpdate();
});

onUnmounted(() => {
  clearInterval(intervalId);
});
</script>

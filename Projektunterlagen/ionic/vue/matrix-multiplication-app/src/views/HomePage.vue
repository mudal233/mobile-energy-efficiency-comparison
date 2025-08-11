<template>
  <ion-page>
    <ion-header>
      <ion-toolbar>
        <ion-title>Matrix Multiplikation Benchmark</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content class="ion-padding">
      <p>
        Diese App multipliziert Matrizen mit Multi-Threading und zeigt die
        Berechnungszeit sowie die Anzahl der durchgeführten Berechnungen an.
      </p>

      <ion-item>
        <ion-label position="floating">Anzahl der Multiplikationen</ion-label>
        <ion-input data-testid="input-field" type="number" v-model="numMultiplications"></ion-input>
      </ion-item>

      <ion-button id="startButton" expand="full" :disabled="isRunning" @click="startMultiplication">
        {{ isRunning ? "Läuft..." : "Matrix multiplizieren" }}
      </ion-button>

      <ion-text>
        <h2 id="multiplicationCount">Anzahl Berechnungen: {{ completedMultiplications }}</h2>
      </ion-text>
      <ion-text>
        <h2>Laufzeit: {{ (elapsedTime / 1000).toFixed(2) }} Sekunden</h2>
      </ion-text>
      <ion-text>
        <h2>Letzte Berechnungszeit: {{ lastDuration }} ms</h2>
      </ion-text>
      <ion-text>
        <h2>Durchgeführte Multiplikationen: {{ totalOperations }}</h2>
      </ion-text>
    </ion-content>
  </ion-page>
</template>

<script>
import {
  IonPage,
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonItem,
  IonLabel,
  IonInput,
  IonText,
} from "@ionic/vue";

export default {
  components: {
    IonPage,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonItem,
    IonLabel,
    IonInput,
    IonText,
  },
  data() {
    return {
      numMultiplications: 1,
      completedMultiplications: 0,
      elapsedTime: 0,
      lastDuration: "--",
      totalOperations: "--",
      isRunning: false,
      timerInterval: null,
      workers: [],
      workerResults: [],
      maxWorkers: navigator.hardwareConcurrency ,
    };
  },
  methods: {
    generateMatrix(size) {
      return Array.from({ length: size }, () =>
        Array.from({ length: size }, () => Math.floor(Math.random() * 100))
      );
    },
    async startMultiplication() {
      const numLoops = parseInt(this.numMultiplications);
      if (isNaN(numLoops) || numLoops <= 0) {
        alert("Bitte eine gültige Anzahl eingeben.");
        return;
      }

      this.isRunning = true;
      this.elapsedTime = 0;
      this.completedMultiplications = 0;
      this.lastDuration = "--";
      this.totalOperations = "--";

      this.initWorkerPool();

      let startGlobal = performance.now();

      this.timerInterval = setInterval(() => {
        this.elapsedTime = performance.now() - startGlobal;
      }, 100);

      for (let loop = 0; loop < numLoops; loop++) {
        const size = 1500;
        let matrixA = this.generateMatrix(size);
        let matrixB = this.generateMatrix(size);
        let results = Array.from({ length: size }, () => Array(size).fill(0));
        this.workerResults = Array(this.maxWorkers).fill(null);

        let start = performance.now();

        for (let t = 0; t < this.maxWorkers; t++) {
          const startRow = Math.floor((size / this.maxWorkers) * t);
          const endRow = Math.floor((size / this.maxWorkers) * (t + 1));
          this.workers[t].postMessage({ size, matrixA, matrixB, startRow, endRow, index: t });
        }

        await new Promise((resolve) => {
          const check = () => {
            if (this.workerResults.every((res) => res !== null)) {
              for (let i = 0; i < this.workerResults.length; i++) {
                const part = this.workerResults[i];
                const startRow = i * (size / this.maxWorkers);
                for (let row = 0; row < part.length; row++) {
                  results[startRow + row] = part[row];
                }
              }
              resolve();
            } else {
              setTimeout(check, 20);
            }
          };
          check();
        });

        let end = performance.now();
        let duration = end - start;

        this.completedMultiplications++;
        this.lastDuration = duration.toFixed(2);
        this.totalOperations = (size * size * size).toLocaleString();
        this.$forceUpdate();

        matrixA = null;
        matrixB = null;
        results = null;
        await new Promise((r) => setTimeout(r, 50));
      }

      clearInterval(this.timerInterval);
      this.cleanupWorkerPool();
      this.elapsedTime = (performance.now() - startGlobal).toFixed(2);
      this.isRunning = false;
    },

    initWorkerPool() {
      if (this.workers.length > 0) return;
      this.workerResults = Array(this.maxWorkers).fill(null);
      for (let i = 0; i < this.maxWorkers; i++) {
        const worker = new Worker(new URL("../workers/matrixWorker.js", import.meta.url));
        worker.onmessage = (e) => {
          const index = e.data.index ?? i;
          this.workerResults[index] = e.data.result;
        };
        this.workers.push(worker);
      }
    },

    cleanupWorkerPool() {
      for (const worker of this.workers) {
        worker.terminate();
      }
      this.workers = [];
    },
  },
};
</script>

<style scoped>
ion-text h2 {
  font-size: 1.2rem;
  font-weight: bold;
  margin-top: 10px;
}
</style>

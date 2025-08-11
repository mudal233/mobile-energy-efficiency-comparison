package com.example.matrixmultiplicationapp;

import java.util.Random;
import java.util.Random;

public class MatrixCalculator {
    private static final int SIZE = 1500; // 2500x2500 Matrix
    private static final int THREADS = Runtime.getRuntime().availableProcessors();

    public static int getSize() {
        return SIZE; // Getter für Matrixgröße
    }

    public static int[][] generateMatrix() {
        int[][] matrix = new int[SIZE][SIZE];
        Random random = new Random();
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                matrix[i][j] = random.nextInt(100); // Werte zwischen 0-99
            }
        }
        return matrix;
    }

    public static int[][] multiplyMatrices(int[][] A, int[][] B) {
        int[][] C = new int[SIZE][SIZE];
        Thread[] workers = new Thread[THREADS];

        for (int t = 0; t < THREADS; t++) {
            final int startRow = t * (SIZE / THREADS);
            final int endRow = (t + 1) * (SIZE / THREADS);

            workers[t] = new Thread(() -> {
                for (int i = startRow; i < endRow; i++) {
                    for (int j = 0; j < SIZE; j++) {
                        for (int k = 0; k < SIZE; k++) {
                            C[i][j] += A[i][k] * B[k][j];
                        }
                    }
                }
            });
            workers[t].start();
        }

        for (Thread worker : workers) {
            try {
                worker.join(); // Warten, bis alle Threads fertig sind
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        return C;
    }
}
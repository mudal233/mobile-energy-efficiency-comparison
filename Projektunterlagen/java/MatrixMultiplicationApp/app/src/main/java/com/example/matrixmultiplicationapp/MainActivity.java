package com.example.matrixmultiplicationapp;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private TextView descriptionText, resultText, timerText, operationsText, multiplicationCountText;
    private EditText inputMultiplicationCount;
    private Button startButton;
    private Handler handler = new Handler();
    private boolean isRunning = false;
    private int elapsedTime = 0; // Zeit in Millisekunden
    private int multiplicationCount = 0; // Zähler für Matrix-Multiplikationen

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        descriptionText = findViewById(R.id.descriptionText);
        resultText = findViewById(R.id.resultText);
        timerText = findViewById(R.id.timerText);
        operationsText = findViewById(R.id.operationsText);
        multiplicationCountText = findViewById(R.id.multiplicationCountText);
        inputMultiplicationCount = findViewById(R.id.inputMultiplicationCount);
        startButton = findViewById(R.id.startButton);

        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String inputText = inputMultiplicationCount.getText().toString().trim();
                if (inputText.isEmpty()) {
                    inputMultiplicationCount.setError("Bitte eine Zahl eingeben");
                    return;
                }

                int numberOfMultiplications = Integer.parseInt(inputText);
                if (numberOfMultiplications <= 0) {
                    inputMultiplicationCount.setError("Mindestens 1 eingeben");
                    return;
                }

                startButton.setEnabled(false);
                startButton.setText("Berechnung läuft...");
                elapsedTime = 0;
                isRunning = true;
                startTimer();

                new Thread(() -> {
                    for (int i = 0; i < numberOfMultiplications; i++) {
                        int[][] A = MatrixCalculator.generateMatrix();
                        int[][] B = MatrixCalculator.generateMatrix();

                        long startTime = System.currentTimeMillis();
                        int[][] C = MatrixCalculator.multiplyMatrices(A, B);
                        long endTime = System.currentTimeMillis();
                        long duration = endTime - startTime;

                        long totalOperations = (long) MatrixCalculator.getSize() * MatrixCalculator.getSize() * MatrixCalculator.getSize();

                        runOnUiThread(() -> {
                            resultText.setText("Berechnungszeit: " + duration + " ms");
                            operationsText.setText("Durchgeführte Multiplikationen: " + totalOperations);

                            // Zähler nach der Berechnung inkrementieren
                            multiplicationCount++;
                            multiplicationCountText.setText("Anzahl Berechnungen: " + multiplicationCount);
                        });
                    }

                    runOnUiThread(() -> {
                        isRunning = false;
                        startButton.setText("Matrix multiplizieren");
                        startButton.setEnabled(true);
                    });

                }).start();
            }
        });
    }

    private void startTimer() {
        new Thread(() -> {
            while (isRunning) {
                try {
                    Thread.sleep(100);
                    elapsedTime += 100;
                    int seconds = elapsedTime / 1000;
                    int milliseconds = elapsedTime % 1000;

                    runOnUiThread(() -> timerText.setText("Laufzeit: " + seconds + "." + milliseconds + " s"));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }
}

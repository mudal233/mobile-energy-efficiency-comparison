package com.example.gpsbenchmark;

import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;

import java.io.IOException;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executor;

public class MainActivity extends AppCompatActivity {

    private FusedLocationProviderClient fusedLocationClient;
    private TextView textViewResult;
    private EditText inputCount;
    private Button startButton;

    private int totalRequests = 0;
    private int currentCount = 0;
    private final int INTERVAL_MS = 2000;
    private final Handler handler = new Handler(Looper.getMainLooper());

    private final Executor executor = command -> new Thread(command).start();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        textViewResult = findViewById(R.id.textViewResult);
        inputCount = findViewById(R.id.inputCount);
        startButton = findViewById(R.id.startButton);

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        ActivityCompat.requestPermissions(this, new String[]{
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
        }, 1);

        startButton.setOnClickListener(v -> {
            String input = inputCount.getText().toString();
            if (input.isEmpty()) {
                Toast.makeText(this, "Bitte Anzahl eingeben", Toast.LENGTH_SHORT).show();
                return;
            }

            totalRequests = Integer.parseInt(input);
            currentCount = 0;
            startButton.setEnabled(false);
            startButton.setText("Läuft...");
            startLocationLoop();
        });
    }

    private void startLocationLoop() {
        handler.postDelayed(this::fetchCurrentLocation, INTERVAL_MS);
    }

    private void fetchCurrentLocation() {
        if (currentCount >= totalRequests) {
            startButton.setEnabled(true);
            startButton.setText("Start");
            Toast.makeText(this, "Fertig!", Toast.LENGTH_SHORT).show();
            return;
        }

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }

        fusedLocationClient.getCurrentLocation(
                LocationRequest.PRIORITY_HIGH_ACCURACY,
                null
        ).addOnSuccessListener(executor, location -> {
            if (location != null) {
                currentCount++;

                double lat = location.getLatitude();
                double lng = location.getLongitude();
                String address = getAddressFromLocation(lat, lng);

                String result = "Abruf " + currentCount + " von " + totalRequests + "\n"
                        + "Latitude: " + lat + "\n"
                        + "Longitude: " + lng + "\n"
                        + "Adresse: " + address;

                Log.d("GPS", "Abruf " + currentCount + " @ " + System.currentTimeMillis());

                runOnUiThread(() -> textViewResult.setText(result));

                handler.postDelayed(this::fetchCurrentLocation, INTERVAL_MS);
            }
        });
    }

    private String getAddressFromLocation(double lat, double lng) {
        Geocoder geocoder = new Geocoder(this, Locale.getDefault());
        try {
            List<Address> addresses = geocoder.getFromLocation(lat, lng, 1);
            if (addresses != null && !addresses.isEmpty()) {
                return addresses.get(0).getAddressLine(0);
            }
        } catch (IOException e) {
            return "Adresse konnte nicht geladen werden";
        }
        return "Keine Adresse gefunden";
    }
}

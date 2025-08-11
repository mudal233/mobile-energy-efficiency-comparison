package com.example.cryptopriceappjava;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private CryptoAdapter adapter;
    private List<Crypto> cryptoList = new ArrayList<>();
    private Handler handler = new Handler();
    private boolean isUpdating = true;

    private final Runnable updateTask = new Runnable() {
        @Override
        public void run() {
            if (isUpdating) {
                fetchData();
                handler.postDelayed(this, 2000); // 2 Sekunden
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        recyclerView = findViewById(R.id.cryptoList);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new CryptoAdapter(cryptoList);
        recyclerView.setAdapter(adapter);

        Button stopButton = findViewById(R.id.stopButton);
        stopButton.setOnClickListener(v -> isUpdating = false);

        fetchData();
        handler.postDelayed(updateTask, 2000);
    }

    private void fetchData() {
        ApiService.fetchPrices(new ApiService.Callback() {
            @Override
            public void onSuccess(List<Crypto> data) {
                runOnUiThread(() -> {
                    cryptoList.clear();
                    cryptoList.addAll(data);
                    adapter.notifyDataSetChanged();
                });
            }

            @Override
            public void onError(String message) {
                Log.e("API_ERROR", message);
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(updateTask);
    }
}
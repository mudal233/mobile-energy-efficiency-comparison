package com.example.cryptopriceappjava;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

public class ApiService {

    public interface Callback {
        void onSuccess(List<Crypto> data);
        void onError(String message);
    }

    public static void fetchPrices(Callback callback) {
        new Thread(() -> {
            try {
                URL url = new URL("https://api.binance.com/api/v3/ticker/price");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");

                BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }

                JSONArray jsonArray = new JSONArray(response.toString());
                List<Crypto> result = new ArrayList<>();

                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject obj = jsonArray.getJSONObject(i);
                    String symbol = obj.getString("symbol");
                    if (symbol.endsWith("USDT")) {
                        double price = Double.parseDouble(obj.getString("price"));
                        result.add(new Crypto(symbol, price));
                    }
                }

                result.sort((a, b) -> Double.compare(b.price, a.price));
                callback.onSuccess(result.subList(0, Math.min(100, result.size())));

            } catch (Exception e) {
                callback.onError(e.getMessage());
            }
        }).start();
    }
}
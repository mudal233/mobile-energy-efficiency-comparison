package com.example.cryptopriceappjava;


public class Crypto {
    public final String symbol;
    public final double price;

    public Crypto(String symbol, double price) {
        this.symbol = symbol;
        this.price = price;
    }
}
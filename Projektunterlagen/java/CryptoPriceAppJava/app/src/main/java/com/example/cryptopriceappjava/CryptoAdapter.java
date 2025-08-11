package com.example.cryptopriceappjava;


import android.view.*;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class CryptoAdapter extends RecyclerView.Adapter<CryptoAdapter.ViewHolder> {
    private final List<Crypto> cryptoList;

    public CryptoAdapter(List<Crypto> cryptoList) {
        this.cryptoList = cryptoList;
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView symbol, price;

        ViewHolder(View view) {
            super(view);
            symbol = view.findViewById(R.id.symbolText);
            price = view.findViewById(R.id.priceText);
        }
    }

    @NonNull
    @Override
    public CryptoAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.crypto_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull CryptoAdapter.ViewHolder holder, int position) {
        Crypto crypto = cryptoList.get(position);
        holder.symbol.setText(crypto.symbol);
        holder.price.setText(String.format("$%.2f", crypto.price));
    }

    @Override
    public int getItemCount() {
        return cryptoList.size();
    }
}

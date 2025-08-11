package com.example.notesapp.ui;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

import com.example.notesapp.R;
import com.google.android.material.bottomnavigation.BottomNavigationView;

import androidx.fragment.app.Fragment;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        BottomNavigationView nav = findViewById(R.id.bottom_nav);
        nav.setOnItemSelectedListener(item -> {
            Fragment fragment = null;
            if (item.getItemId() == R.id.menu_notes) {
                fragment = new HomeFragment();
            } else if (item.getItemId() == R.id.menu_search) {
                fragment = new SearchFragment();
            }
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragment_container, fragment)
                    .commit();
            return true;
        });

        nav.setSelectedItemId(R.id.menu_notes);
    }
}

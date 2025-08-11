package com.example.javamediabenchmark;

import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.view.inputmethod.InputMethodManager;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private TextView statusText;
    private Button startButton;
    private EditText repeatInput;
    private SurfaceView videoSurface;
    private SurfaceHolder surfaceHolder;

    private final String videoFileName = "video_8mbps.mp4";
    private final String videoBitrate = "8 Mbps";

    private int repeatCount = 1;
    private int currentRepeat = 0;
    private boolean surfaceReady = false;

    private MediaPlayer mediaPlayer; // Klassenvariable

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        statusText = findViewById(R.id.statusText);
        startButton = findViewById(R.id.startButton);
        repeatInput = findViewById(R.id.repeatInput);
        videoSurface = findViewById(R.id.videoSurface);
        surfaceHolder = videoSurface.getHolder();

        surfaceHolder.addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                surfaceReady = true;
                startButton.setEnabled(true);
                startButton.setAlpha(1f);
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {}

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                surfaceReady = false;
                startButton.setEnabled(false);
                startButton.setAlpha(0.5f);
            }
        });

        // Tastatur ausblenden bei "Done"
        repeatInput.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE ||
                    (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
                repeatInput.clearFocus();
                InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
                if (imm != null) {
                    imm.hideSoftInputFromWindow(repeatInput.getWindowToken(), 0);
                }
                return true;
            }
            return false;
        });

        startButton.setOnClickListener(v -> {
            String input = repeatInput.getText().toString().trim();
            try {
                repeatCount = Integer.parseInt(input);
            } catch (NumberFormatException e) {
                repeatCount = 1;
            }
            if (repeatCount <= 0) repeatCount = 1;

            currentRepeat = 0;
            startButton.setEnabled(false);
            startButton.setText("Wird wiederholt...");
            startButton.setAlpha(0.5f);
            statusText.setText("Starte Wiedergabe...");
            playVideo();
        });
    }

    private void playVideo() {
        if (!surfaceReady) {
            statusText.setText("Warte auf Oberfläche...");
            videoSurface.postDelayed(this::playVideo, 100);
            return;
        }

        if (currentRepeat >= repeatCount) {
            statusText.setText("Alle Wiederholungen abgeschlossen.");
            startButton.setEnabled(true);
            startButton.setText("Wiedergabe starten");
            startButton.setAlpha(1f);
            return;
        }

        // Vorherigen MediaPlayer korrekt freigeben
        if (mediaPlayer != null) {
            try {
                mediaPlayer.stop();
            } catch (Exception ignored) {}
            mediaPlayer.release();
            mediaPlayer = null;
        }

        statusText.setText("Wiedergabe " + (currentRepeat + 1) + " von " + repeatCount + " (" + videoBitrate + ")");

        try {
            AssetFileDescriptor afd = getAssets().openFd(videoFileName);
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
            afd.close();

            mediaPlayer.setDisplay(surfaceHolder);
            mediaPlayer.setOnCompletionListener(mp -> {
                mp.release();
                mediaPlayer = null;
                currentRepeat++;
                playVideo();
            });

            mediaPlayer.prepareAsync();
            mediaPlayer.setOnPreparedListener(MediaPlayer::start);

        } catch (Exception e) {
            statusText.setText("Fehler bei Wiedergabe.");
            if (mediaPlayer != null) {
                try {
                    mediaPlayer.release();
                } catch (Exception ignored) {}
                mediaPlayer = null;
            }
            startButton.setEnabled(true);
            startButton.setText("Wiedergabe starten");
            startButton.setAlpha(1f);
            e.printStackTrace();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mediaPlayer != null) {
            try {
                mediaPlayer.release();
            } catch (Exception ignored) {}
            mediaPlayer = null;
        }
    }
}

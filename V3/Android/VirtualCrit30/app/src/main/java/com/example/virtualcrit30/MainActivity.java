package com.example.virtualcrit30;

import android.annotation.SuppressLint;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    private final static String TAG = MainActivity.class.getSimpleName();
    private TextView mTextMessage;
    private TextView mValueTimer;
    private TextView mActiveTimer;

    private long startTime = 0;
    private long activeMillis = 0;
    private long totalMillis = 0;
    private long lastMillis = 0;

    private String settingsName = "TIM";
    private String settingsGPS = "OFF";

    Handler timerHandler = new Handler();
    Runnable timerRunnable = new Runnable() {
        @SuppressLint("DefaultLocale")
        @Override
        public void run() {
            totalMillis = System.currentTimeMillis() - startTime;
            Timer.setTotalMillis(totalMillis);

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mValueTimer.setText(Timer.getTotalTimeString());
                }
            });

            if (Timer.getStatus() == 0 && lastMillis > 0) {
                activeMillis += (totalMillis - lastMillis);
                Timer.setActiveMillis(activeMillis);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mActiveTimer.setText(Timer.getActiveTimeString());
                    }
                });
            }

            lastMillis = totalMillis;
            timerHandler.postDelayed(this, 1000);
        }
    };


    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            switch (item.getItemId()) {
                case R.id.navigation_home:
                    mTextMessage.setText(R.string.title_home);
                    return true;
                case R.id.navigation_dashboard:
                    mTextMessage.setText(R.string.title_dashboard);
                    return true;
                case R.id.navigation_notifications:
                    mTextMessage.setText(R.string.title_notifications);
                    return true;
            }
            return false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTextMessage = (TextView) findViewById(R.id.message);
        mValueTimer = findViewById(R.id.valueTimer);
        mActiveTimer = findViewById(R.id.activeTimer);
        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
    }

    public void clickName(View view) {
        Log.i(TAG, "clickName: ");
        inputName();
    }

    public void displayName(String n) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView mName = findViewById(R.id.valueName);
                mName.setText(n);
            }
        });
    }

    public void inputName() {
        final EditText txtUrl = new EditText(this);

        new AlertDialog.Builder(this)
                .setTitle("SETTINGS")
                .setMessage("ENTER NAME")
                .setView(txtUrl)
                .setPositiveButton("SUBMIT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        settingsName = txtUrl.getText().toString().toUpperCase();
                        Log.i(TAG, "settingsName:  " + settingsName);
                        displayName(settingsName);
                    }
                })
                .setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    }
                })
                .show();
    }


    public void clickGPS(View view) {
        TextView mGPS = findViewById(R.id.valueGPS);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (settingsGPS.equals("OFF")) {
                    mGPS.setText("ON");
                    settingsGPS = "ON";
                    Log.i(TAG, "clickGPS: ON");
                    // Show Alert
                    Toast.makeText(getApplicationContext(),
                            "GPS ON" , Toast.LENGTH_SHORT)
                            .show();
                } else {
                    mGPS.setText("OFF");
                    settingsGPS = "OFF";
                    Log.i(TAG, "clickGPS: OFF");
                    Toast.makeText(getApplicationContext(),
                            "GPS OFF" , Toast.LENGTH_SHORT)
                            .show();
                }
            }
        });
    }

    public void clickStart(View view) {
        Log.i(TAG, "clickStart: ");

        if (Timer.getStatus() == 99) {
            Log.i(TAG, "Start Timer - First Time");
            //mValueTimer.setText("00:00:00");
            startTime = System.currentTimeMillis();
            timerHandler.postDelayed(timerRunnable, 0);
            manageTimer(0);
        }

        if (Timer.getStatus() == 1) {
            Log.i(TAG, "Resume Timer");
            timerHandler.postDelayed(timerRunnable, 0);
            manageTimer(0);
        }

        if (Timer.getStatus() == 2) {
            Log.i(TAG, "ReStart Timer");
            //WILL NOT ALLOW THIS...
            //mValueTimer.setText("00:00:00");
            totalMillis = 0;
            lastMillis = 0;
            activeMillis = 0;
            startTime = System.currentTimeMillis();
            timerHandler.postDelayed(timerRunnable, 0);
            manageTimer(0);
        }


    }


    public void clickPause(View view) {
        Log.i(TAG, "clickPause: ");
        //CAN'T REMOVE CB, NEED ACTIVE TIME TO CONTINUE
        //timerHandler.removeCallbacks(timerRunnable);
        manageTimer(1);
    }

    public void clickEnd(View view) {
        Log.i(TAG, "clickEnd: ");
        timerHandler.removeCallbacks(timerRunnable);
        manageTimer(2);
    }

    private void manageTimer(int i) {
        Log.i(TAG, "manageTimer: " + i);

        switch (i) {
            case 0:
                Log.i(TAG, "manageTimer: Start");
                Timer.setStatus(0);
                Toast.makeText(getApplicationContext(),
                        "START" , Toast.LENGTH_SHORT)
                        .show();
                return;
            case 1:
                Log.i(TAG, "manageTimer: Pause");
                Timer.setStatus(1);
                Toast.makeText(getApplicationContext(),
                        "PAUSE" , Toast.LENGTH_SHORT)
                        .show();
                return;
            case 2:
                Log.i(TAG, "manageTimer: End");
                Timer.setStatus(2);
                Toast.makeText(getApplicationContext(),
                        "COMPLETE" , Toast.LENGTH_SHORT)
                        .show();
        }


    }
}

package com.example.virtualcrit3_lite;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelUuid;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

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
    private int settingsSecondsPerRound = 60;

    private int currentRound = 1;

    private double oldDistance = 0;
    private double newDistance = 0;
    private double roundHeartrateTotal = 0;
    private double roundHeartRateCount = 0;
    private double roundHeartRate = 0;
    private double roundSpeed;

    @SuppressLint("DefaultLocale")
    private void roundEndCalculate() {
        newDistance = geoDistance;
        double roundDistance = newDistance - oldDistance; //MILES
        roundSpeed = roundDistance / ((double) settingsSecondsPerRound / 60.0 / 60.0);
        setMessageText("ROUND SPEED: " + String.format("%.2f MPH", roundSpeed)+ ",  HR:  " + String.format("%.1f BPM", roundHeartRate));
        Log.i(TAG, "roundEndCalculate: roundHeartrate:  " + String.format("%.1f MPH", roundHeartRate));
        Log.i(TAG, "roundEndCalculate: roundSpeed:  " + String.format("%.2f MPH", roundSpeed));

        //after...
        oldDistance = newDistance;
        roundHeartrateTotal = 0;
        roundHeartRateCount = 0;
        roundHeartRate = 0;

    }

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
                    TextView t1 = findViewById(R.id.tvHeader1);
                    t1.setText(Timer.getTotalTimeString());
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

            if (totalMillis > (currentRound * settingsSecondsPerRound * 1000)) {
                currentRound += 1;
                Log.i(TAG, "round " + (currentRound - 1) + " complete");
                //setMessageText("ROUND " + (currentRound));
                roundEndCalculate();
                //PROCESS NEW ROUND
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
                    //mTextMessage.setText(R.string.title_home);
                    setMessageText("HOME");
                    changeState(0);
                    return true;
                case R.id.navigation_dashboard:
//                    mTextMessage.setText(R.string.title_dashboard);
                    setMessageText("DASHBOARD");
                    changeState(1);
                    return true;
                case R.id.navigation_notifications:
//                    mTextMessage.setText(R.string.title_notifications);
                    setMessageText("NOTIFICATIONS");
                    return true;
            }
            return false;
        }
    };


    private int viewState = 0;
    private void changeState(final int i) {

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ScrollView sv = findViewById(R.id.svSettings);
                LinearLayout ll = findViewById(R.id.llView);

                switch (viewState) {
                    case 0: {

                        if (i == 1) {
                            viewState = 1;
//                        mTextMessage.setVisibility(View.GONE);
                            ll.setVisibility(View.VISIBLE);
                            sv.setVisibility(View.GONE);
                        }

                        break;
                    }

                    case 1: {

                        if (i == 0) {
                            viewState = 0;
//                        mTextMessage.setVisibility(View.GONE);
                            ll.setVisibility(View.GONE);
                            sv.setVisibility(View.VISIBLE);
                        }

                        break;
                    }

                    default: {
                        Log.i(TAG, "default...");
                    }
                }
            }
        });



    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        clickStart(getCurrentFocus());
        Variables.setMessageBarValue("onCreate");
        mTextMessage = (TextView) findViewById(R.id.message);
        mValueTimer = findViewById(R.id.valueTimer);
        mActiveTimer = findViewById(R.id.activeTimer);

        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
    }


    @Override
    protected void onResume() {
        super.onResume();


//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                TextView mDistance = (TextView) findViewById(R.id.valueDistanceBLE);
//                mDistance.setText(Variables.getDistance());
//
//                TextView mAvgSpeed = (TextView) findViewById(R.id.valueAverageSpeedBLE);
//                mAvgSpeed.setText(Variables.getAvgSpeed());
//            }
//        });

//        init();
    }

    @Override
    protected void onPause() {
        super.onPause();
        //unregisterReceiver(receiver);
    }




    public void clickName(View view) {
        Log.i(TAG, "clickName: ");
        inputName();
    }

    public void displayName(final String n) {
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


    double distance_between(Double lat1, Double lon1, Double lat2, Double lon2)
    {
        //float results[] = new float[1];
    /* Doesn't work. returns inconsistent results
    Location.distanceBetween(
            l1.getLatitude(),
            l1.getLongitude(),
            l2.getLatitude(),
            l2.getLongitude(),
            results);
            */
//        double lat1=l1.getLatitude();
//        double lon1=l1.getLongitude();
//        double lat2=l2.getLatitude();
//        double lon2=l2.getLongitude();
        double R = 6371; // km
        double dLat = (lat2-lat1)*Math.PI/180;
        double dLon = (lon2-lon1)*Math.PI/180;
        lat1 = lat1*Math.PI/180;
        lat2 = lat2*Math.PI/180;

        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        double d = R * c * 1000;

        return d;
    }

    private int nextMile = 1;
    private int calibratedWheelSize = 0;
    private int revsAtStartOfMile = 1;


    @SuppressLint("DefaultLocale")
    public void onLocationReceived(Location location) {
        Log.i(TAG, "onLocationReceived");
        arrLats.add(location.getLatitude());
        arrLons.add(location.getLongitude());

        if (arrLats.size() < 5) {
            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        } else {
            Location.distanceBetween(oldLat, oldLon, location.getLatitude(), location.getLongitude(), results);

            if (results.length > 0) {

                //mPrinter("RESULTS[0]  " + results[0] * 0.000621371 +  "  MILES"); //AS MILES
                if (results[0] == 0) {
                    //mPrinter("NOTHING AT RESULTS[0] - RETURN");
                    return;
                }
                if (results[0] * 0.000621371 <= 0) {
                    //mPrinter("NO DISTANCE TRAVELED - RETURN");
                    return;
                }

                //OPT 1.  QUICKREAD GEO SPEED
                final double geoSpeedQuick = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr
                Log.i(TAG, "onLocationReceived: QuickSpeedCalc: " + geoSpeedQuick);


                //TRY DIRECT CALC FORMULA
                Double result = distance_between(oldLat, oldLon, location.getLatitude(), location.getLongitude());
                //REPLACE results[0] with returned result


                //OPT 2.  GEO SPEED, LONG VERSION
//                Double gd = results[0] * 0.000621371;
                Double gd = result * 0.000621371;
                long gt = (location.getTime() - oldTime);  //MILLI
                Double geoSpeed = gd / ((double) gt / 1000 / 60 / 60);
//                geoDistance += results[0] * 0.000621371;
                geoDistance += result * 0.000621371;




                totalTimeGeo += (location.getTime() - oldTime);  //MILLI
                double ttg = totalTimeGeo;  //IN MILLI
                final double geoAvgSpeed = geoDistance / (ttg / 1000.0 / 60.0 / 60.0);
                long millis = totalTimeGeo;
                @SuppressLint("DefaultLocale")
                final String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                        TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                        TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));

                //UPDATE UI WITH SPEED AND DISTANCE
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        TextView tvSpd = (TextView) findViewById(R.id.valueSpeedGPS);
                        tvSpd.setText(String.format("%.1f MPH", geoSpeedQuick));
                        TextView t1 = findViewById(R.id.tvMiddle);
                        t1.setText(String.format("%.1f", geoSpeedQuick));

                        TextView tvDst = (TextView) findViewById(R.id.valueDistanceGPS);
                        tvDst.setText(String.format("%.1f MILES", geoDistance));

                        TextView t3 = findViewById(R.id.tvFooter2);
                        t3.setText(String.format("%.0f AV", averageHR));

                        //PLACEHOLDER
                        TextView tx = findViewById(R.id.tvBottom);
                        tx.setText(String.format("%.2f", geoDistance));
                        //PLACEHOLDER


                        TextView tvTime = (TextView) findViewById(R.id.valueActiveTimeGPS);
                        tvTime.setText(hms);
                        TextView t4 = findViewById(R.id.tvFooter1);
                        t4.setText(hms);

                        TextView tvAvgSpd = (TextView) findViewById(R.id.valueAverageSpeedGPS);
                        tvAvgSpd.setText(String.format("%.1f MPH", geoAvgSpeed));
                        TextView t2 = findViewById(R.id.tvHeader2);
                        t2.setText(String.format("%.1f AV", geoAvgSpeed));
                    }
                });



            }

            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        }


    }

    private ArrayList<Double> arrLats = new ArrayList<>();
    private ArrayList<Double> arrLons = new ArrayList<>();
    private Double oldLat = 0.0;
    private Double oldLon = 0.0;
    private Double geoDistance = 0.0;
    private Double geoAvgSpeed = 0.0;
    private float[] results = new float[2];
    private long oldTime = 0;
    private long totalTimeGeo = 0;  //GPS MOVING TIME IN MILLI

    private void startGPS() {
        Log.i(TAG, "startGPS: ");
        //START GPS
        LocationRequest mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(3000);
        mLocationRequest.setFastestInterval(2000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder().addLocationRequest(mLocationRequest);


        //mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
        //CHANGE FROM WORKING ORIGINAL
        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(getApplicationContext());

        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                onNewLocation(locationResult.getLastLocation());
            }

            private void onNewLocation(Location lastLocation) {
                ////Log.i(TAG, "onNewLocation: " + lastLocation.getSpeed());
                onLocationReceived(lastLocation);
            }
        };

        try {
            mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                    mLocationCallback, Looper.myLooper());
        } catch (SecurityException unlikely) {
            //Utils.setRequestingLocationUpdates(this, false);
            Log.e(TAG, "Lost location permission. Could not request updates. " + unlikely);
        }

    }


    private LocationRequest mLocationRequest;
    private FusedLocationProviderClient mFusedLocationClient;
    private LocationCallback mLocationCallback;
    private Handler mServiceHandler;
    private Location mLocation;


    public void clickGPS(View view) {
//        TextView mGPS = findViewById(R.id.valueGPS);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView mGPS = findViewById(R.id.valueGPS);
                if (settingsGPS.equals("OFF")) {
                    mGPS.setText("ON");
                    settingsGPS = "ON";
                    Log.i(TAG, "clickGPS: ON");
                    startGPS();
                    // Show Alert
                    Toast.makeText(getApplicationContext(),
                            "GPS ON" , Toast.LENGTH_SHORT)
                            .show();
                } else {
                    mGPS.setText("OFF");
                    settingsGPS = "OFF";
                    Log.i(TAG, "clickGPS: OFF");
                    //STOP GPS
                    try {
                        mFusedLocationClient.removeLocationUpdates(mLocationCallback);
                    } catch (Exception e){
                        Log.i(TAG, "Error,  DIDN'T STOP LOCATION");
                    }
                    //SHOWALERT
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
        //close();
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

    public void clickBLE(View view) {
        Log.i(TAG, "clickBLE: SCAN FOR BLE DEVICES");
        onScanStart();

    }

    public void clickMessageBar(View view) {
    }



    public void clickAudio(View view) {
    }

    public void clickWheelSize(View view) {
    }



    private int REQUEST_ENABLE_BT = 1;
    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;
    private static final long SCAN_PERIOD = 3000;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mLEScanner;
    private ScanSettings settings;
    private List<ScanFilter> filters;
    private BluetoothDevice deviceDiscovered;
//    private BluetoothDevice deviceDiscoveredCSC;



    public void onScanStart() {
        Log.i(TAG, "SCANNING HR");
        deviceDiscovered = null;
        //setMessageText("SCANNING HR");

        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        if (bluetoothManager != null) {
            mBluetoothAdapter = bluetoothManager.getAdapter();
        }

        // Make sure we have access coarse location enabled, if not, prompt the user to enable it
        if (this.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            Log.i(TAG, "PROMPT FOR LOCATION ENABLED");
            final AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("This app needs location access");
            builder.setMessage("Please grant location access so this app can detect peripherals and use GPS to calculate speed and distance.");
            builder.setPositiveButton(android.R.string.ok, null);
            builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
                }
            });
            builder.show();
        }

        Log.i(TAG, "CHECK FOR BT ENABLED");
        if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        } else {
            mLEScanner = mBluetoothAdapter.getBluetoothLeScanner();
            settings = new ScanSettings.Builder()
                    .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                    .build();
            filters = new ArrayList<>();
            ScanFilter scanFilter = new ScanFilter.Builder()
                    .setServiceUuid(ParcelUuid.fromString("0000180D-0000-1000-8000-00805f9b34fb"))
                    .build();
            filters.add(scanFilter);

            // Show Alert
            Toast.makeText(getApplicationContext(),
                    "SCANNING HR" , Toast.LENGTH_SHORT)
                    .show();

            //START SCAN
            Log.i(TAG, "START SCANNING HR");
            mLEScanner.startScan(filters, settings, mScanCallback);
            Handler mHandler = new Handler();
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mLEScanner.stopScan(mScanCallback);
                    Log.i(TAG, "run: STOP SCANNING");
                    //setMessageText("-");
                    deviceDiscovered = null;
                    postScanPopup();
                }
            }, SCAN_PERIOD);

        }
    } //END HR SCAN


//SCAN RESULT CB HR

    private ArrayList<BluetoothDevice> devicesDiscoveredHR = new ArrayList<>();
//    private ArrayList<BluetoothDevice> devicesDiscoveredCSC = new ArrayList<>();
    private ArrayList<BluetoothDevice> devicesConnectedHR = new ArrayList<>();
//    private ArrayList<BluetoothDevice> devicesConnectedCSC = new ArrayList<>();


    private ScanCallback mScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);

            BluetoothDevice deviceDiscovered = result.getDevice();

            if (deviceDiscovered.getName() == null) {
                Log.i(TAG, "onScanResult: isNull return");
                return;
            }

            if (devicesDiscoveredHR.contains(deviceDiscovered)) {
                Log.i(TAG, "onScanResult: Already in HR Device Array List, return");
                return;
            }

            Log.i(TAG, "onScanResult: New HR device");
            devicesDiscoveredHR.add(deviceDiscovered);
            Log.i(TAG, "onScanResult added HR: " + deviceDiscovered.getName());
            setMessageText("FOUND:  " + deviceDiscovered.getName());
            Log.i(TAG, "onScanResult: getSizeOfDevicesDiscoveredHR:  " + devicesDiscoveredHR.size());
        }

        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            super.onBatchScanResults(results);
            Log.i(TAG, "onBatchScanResults: " + results.toString());
        }

        @Override
        public void onScanFailed(int errorCode) {
            super.onScanFailed(errorCode);
            Log.i(TAG, "onScanFailed: " + errorCode);
        }
    };
    //END SCAN CB HR

    private void postScanPopup() {

        Log.i(TAG, "postScanPopup");
//        if (devicesDiscoveredHR.size() + devicesDiscoveredCSC.size() == 0) {
        if (devicesDiscoveredHR.size() == 0) {
            //setMessageText("NO DEVICES FOUND");
            Toast.makeText(getApplicationContext(),
                    "NO FOUND DEVICES" , Toast.LENGTH_SHORT)
                    .show();
            return;
        }

        for(final BluetoothDevice d : devicesDiscoveredHR) {
            Log.i(TAG, "postScanPopup: attempt connect to " + d.getName());


            if (devicesConnectedHR.contains(d)) {
                Log.i(TAG, "postScanPopup: already connected to " + d.getName());
                return;
            }

            new AlertDialog.Builder(this)
                    .setTitle("Bluetooth")
                    .setMessage("Connect to " + d.getName() + "?")
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int whichButton) {
                            Log.i(TAG, "onClick: YES, now call to connect to device " + d.getName());
                            //send connection request
                            devicesConnectedHR.add(d);
                            setBluetoothDeviceNames(d.getName().toUpperCase());
                            //initManagerHR(d);
                            //START CONNECTION...
                            deviceHR = d;
                            connectHR(deviceHR);


                        }
                    })
                    .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int whichButton) {
                            Log.i(TAG, "onClick: NO");
                        }
                    }).show();
        }

        //NEED TO WAIT UNTIL HR CONNECTION IS COMPLETE OR TRUST THAT NORDIC WILL BUFFER
        //postScanPopupCSC();
    }




    private void setBluetoothDeviceNames (final String x) {
        Log.i(TAG, "setBluetoothDeviceNames: " + x);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView tv1 = MainActivity.this.findViewById(R.id.valueBluetoothDevice1);
                TextView tv2 = MainActivity.this.findViewById(R.id.valueBluetoothDevice2);
                TextView tv3 = MainActivity.this.findViewById(R.id.valueBluetoothDevice3);
                if (tv1.getText().equals("")) {
                    Log.i(TAG, "setBluetoothDeviceNames: tv1");
                    tv1.setText(x);
                    return;
                }
                if (tv2.getText().equals("")) {

                    tv2.setText(x);
                    return;
                }
                if (tv3.getText().equals("")) {
                    tv3.setText(x);
                }
                Log.i(TAG, "setBluetoothDeviceNames: all name slots taken");

            }
        });
    }

    private void setMessageText (final String x) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTextMessage.setText(x);
            }
        });
    }

    private void setValueHR (final String x) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView h = findViewById(R.id.valueHeartrateBLE);
                h.setText(x + " BPM");

                TextView t1 = findViewById(R.id.tvTop);
                t1.setText(x);

            }
        });
    }



    private BluetoothDevice deviceHR;
    private BluetoothGatt mBluetoothGatt;

    private static final UUID CSC_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
    private static final UUID CSC_CHARACTERISTIC_UUID = UUID.fromString("00002a5b-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
    private static final UUID BTLE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    private void connectHR(BluetoothDevice d) {
        Log.i(TAG, "connectHR " + d.getName());
        mBluetoothGatt = d.connectGatt(this, false, mGattCallback);
    }



    private String mBluetoothDeviceAddress;
    private int mConnectionState = STATE_DISCONNECTED;
    private boolean enabled;
    private static final int STATE_DISCONNECTED = 0;
    private static final int STATE_CONNECTING = 1;
    private static final int STATE_CONNECTED = 2;

    private final static String ACTION_GATT_CONNECTED =
            "com.example.virtualcrit3_lite.ACTION_GATT_CONNECTED";
    private final static String ACTION_GATT_DISCONNECTED =
            "com.example.virtualcrit3_lite.ACTION_GATT_DISCONNECTED";
    private final static String ACTION_GATT_SERVICES_DISCOVERED =
            "com.example.virtualcrit3_lite.ACTION_GATT_SERVICES_DISCOVERED";
    private final static String ACTION_DATA_AVAILABLE =
            "com.example.virtualcrit3_lite.ACTION_DATA_AVAILABLE";
    private final static String EXTRA_DATA =
            "com.example.virtualcrit3_lite.EXTRA_DATA";


    private Boolean reconnect = true;


    private void setReconnectRequest(BluetoothGatt g) {

        Log.i(TAG, "setReconnectRequest: attempt reconnect");
        deviceHR.connectGatt(this, true, mGattCallback);
        reconnect = false;
    }
//
//    // Various callback methods defined by the BLE API.
    private final BluetoothGattCallback mGattCallback =
            new BluetoothGattCallback() {
                @Override
                public void onConnectionStateChange(BluetoothGatt gatt, int status,
                                                    int newState) {
                    String intentAction;
                    if (newState == BluetoothProfile.STATE_CONNECTED) {
                        intentAction = ACTION_GATT_CONNECTED;
                        mConnectionState = STATE_CONNECTED;
                        mBluetoothGatt = gatt;
                        mBluetoothDeviceAddress = gatt.getDevice().getAddress();
//                        broadcastUpdate(intentAction);
                        setMessageText(gatt.getDevice().getName() + "  CONNECTED");
                        Log.i(TAG, "Connected to GATT server. " + gatt.getDevice().getName());

                        Log.i(TAG, "Attempting to start service discovery: " +
                                gatt.discoverServices());

                    } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                        //intentAction = ACTION_GATT_DISCONNECTED;
                        mConnectionState = STATE_DISCONNECTED;
                        Log.i(TAG, "Disconnected from GATT server. " + gatt.getDevice().getName());
                        setMessageText(gatt.getDevice().getName() + "  DISCONNECTED");
                        //broadcastUpdate(intentAction);
                        close();
                        setReconnectRequest(gatt);
                    }
                }

                @Override
                // New services discovered
                public void onServicesDiscovered(BluetoothGatt gatt, int status) {

                    if (reconnect == false) {
                        Log.i(TAG, "onServicesDiscovered: notify already set, disable first");
                        BluetoothGattCharacteristic valueCharacteristic = gatt.getService(HR_SERVICE_UUID).getCharacteristic(HR_CHARACTERISTIC_UUID);
                        boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, false);
                        Log.i(TAG, "de-registered for HR updates " + (notificationSet ? "successfully" : "unsuccessfully"));
                    }

                    if (status == BluetoothGatt.GATT_SUCCESS) {
//                        broadcastUpdate(ACTION_GATT_SERVICES_DISCOVERED);
                        Log.i(TAG, "onServicesDiscovered: " + gatt.getDevice().getName());
                        setMessageText(gatt.getDevice().getName() + "  SERVICES DISCOVERED");

                        //set notifications
                        Log.i(TAG, "onServicesDiscovered: setting notify");
                        //gatt.setCharacteristicNotification(gatt.getService(HR_SERVICE_UUID).getCharacteristic(HR_CHARACTERISTIC_UUID), enabled);
                        BluetoothGattCharacteristic valueCharacteristic = gatt.getService(HR_SERVICE_UUID).getCharacteristic(HR_CHARACTERISTIC_UUID);
                        boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
                        Log.i(TAG, "registered for HR updates " + (notificationSet ? "successfully" : "unsuccessfully"));
                        BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
                        descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
                        Log.i(TAG, "wrote Descriptor for HR updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));



                    } else {
                        Log.i(TAG, "onServicesDiscovered received: " + status);
                    }
                }

                @Override
                // Result of a characteristic read operation
                public void onCharacteristicRead(BluetoothGatt gatt,
                                                 BluetoothGattCharacteristic characteristic,
                                                 int status) {
                    if (status == BluetoothGatt.GATT_SUCCESS) {
                        //broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
                        Log.i(TAG, "onCharacteristicRead: " + gatt.getDevice().getName());
                    }
                }

                private int format = -1;
                @Override
                // Characteristic notification
                public void onCharacteristicChanged(BluetoothGatt gatt,
                                                    BluetoothGattCharacteristic characteristic) {
                    //broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
                    Log.i(TAG, "onCharacteristicChanged: HR");

                    // This is special handling for the Heart Rate Measurement profile. Data
                    // parsing is carried out as per profile specifications.
                    if (HR_CHARACTERISTIC_UUID.equals(characteristic.getUuid())) {
                        int flag = characteristic.getProperties();
//                        int format = -1;
                        if ((flag & 0x01) != 0) {
                            format = BluetoothGattCharacteristic.FORMAT_UINT16;
                            Log.d(TAG, "Heart rate format UINT16.");
                        } else {
                            format = BluetoothGattCharacteristic.FORMAT_UINT8;
                            Log.d(TAG, "Heart rate format UINT8.");
                        }
                        final int heartRate = characteristic.getIntValue(format, 1);
                        Log.i(TAG, String.format("%d BPM", heartRate));
                        //intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));
                        calcAvgHR(heartRate);
                        setValueHR(String.format("%d", heartRate));
                    } else {
                        // For all other profiles, writes the data formatted in HEX.
                        Log.i(TAG, "onCharacteristicChanged: strangeval");
                    }
                }


            };

    int totHR;
    int countHR;
    double averageHR = 0;
    private void calcAvgHR(int hr) {
        if (hr > 50) {
            //TOTAL
            totHR += hr;
            countHR += 1;
            averageHR = (double) totHR / (double) countHR;
            //ROUND
            roundHeartrateTotal += hr;
            roundHeartRateCount += 1;
            roundHeartRate = (double) roundHeartrateTotal / (double) roundHeartRateCount;

        }
    }

//TEST ROUNDS

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        LinearLayout ortTview2 = findViewById(R.id.llTopView);
        LinearLayout ortTview = findViewById(R.id.llBottomView);

        // Checks the orientation of the screen
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            //Toast.makeText(this, "landscape", Toast.LENGTH_SHORT).show();
            ortTview.setVisibility(View.GONE);
            ortTview2.setVisibility(View.GONE);

        } else if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT){
            //Toast.makeText(this, "portrait", Toast.LENGTH_SHORT).show();
            ortTview.setVisibility(View.VISIBLE);
            ortTview2.setVisibility(View.VISIBLE);
        }
    }


    private void close() {
        if (mBluetoothGatt == null) {
            return;
        }
        mBluetoothGatt.close();
        mBluetoothGatt = null;
    }





}

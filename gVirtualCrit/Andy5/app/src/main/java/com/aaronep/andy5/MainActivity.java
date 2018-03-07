package com.aaronep.andy5;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.widget.Toast;

import com.akhgupta.easylocation.EasyLocationAppCompatActivity;
import com.akhgupta.easylocation.EasyLocationRequest;
import com.akhgupta.easylocation.EasyLocationRequestBuilder;
import com.google.android.gms.location.LocationRequest;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import static android.text.format.DateUtils.formatElapsedTime;

public class MainActivity extends EasyLocationAppCompatActivity {

    private TextView mTextMessage;

    private UUID HEART_RATE_SERVICE_UUID = convertFromInteger(0x180D);
    private UUID HEART_RATE_MEASUREMENT_CHAR_UUID = convertFromInteger(0x2A37);
    private UUID CSC_SERVICE_UUID = convertFromInteger(0x1816);
    private UUID CSC_MEASUREMENT_CHAR_UUID = convertFromInteger(0x2A5B);
    private UUID CLIENT_CHARACTERISTIC_CONFIG_UUID = convertFromInteger(0x2902);


    public UUID convertFromInteger(int i) {
        final long MSB = 0x0000000000001000L;
        final long LSB = 0x800000805f9b34fbL;
        long value = i & 0xFFFFFFFF;
        return new UUID(MSB | (value << 32), LSB);
    }

//    private final static UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
//    private static final UUID HR_SENSOR_LOCATION_CHARACTERISTIC_UUID = UUID.fromString("00002A38-0000-1000-8000-00805f9b34fb");
//    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
//    private final static UUID CYCLING_SPEED_AND_CADENCE_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
//    private static final UUID CSC_MEASUREMENT_CHARACTERISTIC_UUID = UUID.fromString("00002A5B-0000-1000-8000-00805f9b34fb");
//    private UUID CLIENT_CHARACTERISTIC_CONFIG_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    private static final byte WHEEL_REVOLUTIONS_DATA_PRESENT = 0x01; // 1 bit
    private static final byte CRANK_REVOLUTION_DATA_PRESENT = 0x02; // 1 bit

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



    private int REQUEST_ENABLE_BT = 1;
    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;
    private Handler mHandler;
    private static final long SCAN_PERIOD = 5000;

    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mLEScanner;
    private ScanSettings settings;
    private List<ScanFilter> filters;
    public BluetoothGatt mGatt;
    public BluetoothDevice mDevice;

    private void mLog(String t, String s) {
        Log.i(t, s);
    }
    private void mPrinter(String p) {
        System.out.println("mPrinter: " + p);
    }

    // setup UI handler
//    private final static int UPDATE_DEVICE = 0;
//    private final static int UPDATE_VALUE = 1;
//    private final static int UPDATE_CSC = 2;
    private final static int UPDATE_HR = 3;
    private final static int UPDATE_SPEED = 4;
    private final static int UPDATE_CADENCE = 5;

    @SuppressLint("HandlerLeak")
    private final Handler uiHandler = new Handler() {
        public void handleMessage(Message msg) {
            final int what = msg.what;
            final String value = (String) msg.obj;
            switch(what) {
                //case UPDATE_DEVICE: updateDevice(value); break;
                //case UPDATE_VALUE: updateValue(value); break;
//                case UPDATE_CSC:
//                    updateValueCSC(value);
//                    break;
                case UPDATE_HR:
                    updateValueHR(value);
                    break;
                case UPDATE_CADENCE:
                    updateValueCADENCE(value);
                    break;
                case UPDATE_SPEED:
                    updateValueSPEED(value);
                    break;
            }
        }
    };


    private void updateValueHR(String value) {
        TextView t = findViewById(R.id.textView100);
        veloHrNew = value;
        t.setText(value);
    }

    private void updateValueCADENCE(String value) {
        TextView t = findViewById(R.id.textView102);
        veloCadNew = value;
        t.setText(value);
    }

    private void updateValueSPEED(String value) {
        TextView t = findViewById(R.id.textView101);
        t.setText(value);
        veloSpdNew = value;
        updateTotals();
    }

    private String veloSpdOld = "Old";
    private String veloSpdNew = "New";
    private String veloCadOld = "Old";
    private String veloCadNew = "New";
    private String veloHrOld = "Old";
    private String veloHrNew = "New";

    private void myVeloTester() {
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {

                //mPrinter("VELO TEST");
                if (veloSpdNew == veloSpdOld) {
                    updateValueSPEED("00.00\nMPH(B)");
                }
                veloSpdOld = veloSpdNew;


                if (veloCadNew == veloCadOld) {
                    updateValueCADENCE("0\nRPM");
                }
                veloCadOld = veloCadNew;


//                if (veloHrNew == veloHrOld) {
//                    updateValueHR("HR: 0");
//                }
//                veloHrOld = veloHrNew;

                myVeloTester();
                getActualTime();


            }
        }, 15000);
    }


    @SuppressLint({"DefaultLocale", "SetTextI18n"})
    private void updateTotals() {
//    mPrinter("UPDATING TOTALS");
//        String nString = formatElapsedTime((long) totalWheelTimeSeconds);
//        TextView t2 = findViewById(R.id.textView112);
//        t2.setText(nString + " MOV");

        long millis = (long) totalWheelTimeMilli;
        @SuppressLint("DefaultLocale") String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));
        //actualTimeElapsedBT = hms;
        TextView t2 = findViewById(R.id.textView112);
        t2.setText(hms + "  (BT)");


        TextView t1 = findViewById(R.id.textView111);
        String st1 = String.format("%.1f", totalAverageMovingSpeed);
//        t1.setText(String.format("AVG.MPH: %.1f", totalAverageMovingSpeed));
        t1.setText(st1 + " MPH");

        TextView t0 = findViewById(R.id.textView110);
        String st2 = String.format("%.2f", totalDistance);
        t0.setText(st2 + " MI");

    }

    @SuppressLint("SetTextI18n")
    private void updateGeoButtons() {
        TextView t0 = findViewById(R.id.textView210);
        @SuppressLint("DefaultLocale") String st0 = String.format("%.2f", geoDistance);
        t0.setText(st0 + "  MI");

        TextView t1 = findViewById(R.id.textView211);
        @SuppressLint("DefaultLocale") String st1 =  String.format("%.1f", geoSpeed);
        t1.setText(st1 + "\nMPH(G)");

        TextView t2 = findViewById(R.id.textView2111);
        @SuppressLint("DefaultLocale") String st2 =  String.format("%.1f", geoAvgSpeed);
        t2.setText(st2 + "  MPH");
    }

    private void getActualTime() {

        Calendar nowTime = Calendar.getInstance(Locale.ENGLISH);

        Long st = startTime.getTimeInMillis();
        Long nt = nowTime.getTimeInMillis();

        long millis = nt - st;
        @SuppressLint("DefaultLocale") String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));

        actualTimeElapsed = hms;
        //mPrinter("ELAPSED TIME: " + actualTimeElapsed);
        TextView t = findViewById(R.id.textView23);
        t.setText(actualTimeElapsed + "  (ACTUAL)");
    }


    private Calendar startTime;
    private String actualTimeElapsed = "00:00:00";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        startTime = Calendar.getInstance(Locale.ENGLISH);
        mPrinter("Starttime: " + ""+startTime.get(Calendar.HOUR_OF_DAY)+":"+startTime.get(Calendar.MINUTE)+":"+startTime.get(Calendar.SECOND));
        //mPrinter("Starttime in Milli: " + startTime.getTimeInMillis());

        mTextMessage = findViewById(R.id.message);
        BottomNavigationView navigation = findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

//START BT SETUP
        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        if (bluetoothManager != null) {
            mBluetoothAdapter = bluetoothManager.getAdapter();
        }

        if (mBluetoothAdapter != null && !mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        }

        //TODO:  DISABLE TO LAUNCH ON EMULATOR
        // Make sure we have access coarse location enabled, if not, prompt the user to enable it
        if (this.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            final AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("This app needs location access");
            builder.setMessage("Please grant location access so this app can detect peripherals.");
            builder.setPositiveButton(android.R.string.ok, null);
            builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
                }
            });
            builder.show();
        }

        mHandler = new Handler();
        //TODO:  DISABLE TO LAUNCH ON EMULATOR
//        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
//            Toast.makeText(this, "BLE Not Supported",
//                    Toast.LENGTH_SHORT).show();
//            finish();
//        }
        //END BT SETUP

        //START BROADCAST REC
        //NOT USED YET
        localBroadcastReceiver = new LocalBroadcastReceiver();
        LocalBroadcastManager.getInstance(this).registerReceiver(
                localBroadcastReceiver,
                new IntentFilter("B1_ACTION"));
        LocalBroadcastManager.getInstance(this).registerReceiver(
                localBroadcastReceiver,
                new IntentFilter("B2_ACTION"));
        //END BROADCAST REC

        myVeloTester();



        }
    //END ON CREATE





    @Override
    public void onLocationPermissionGranted() {
    mLog("LOC", "ONLOCATIONPERMISSIONGRANTED");
    }

    @Override
    public void onLocationPermissionDenied() {
        mLog("LOC", "ONLOCATIONPERMISSIONDENIED");
    }

    private ArrayList<Double> arrLats = new ArrayList<>();
    private ArrayList<Double> arrLons = new ArrayList<>();
    private Double oldLat = 0.0;
    private Double oldLon = 0.0;
    private Double geoDistance = 0.0;
    private Double geoSpeed = 0.0;
    private Double geoAvgSpeed = 0.0;
    private float[] results = new float[2];
    private long oldTime = 0;
    private long totalTimeGeo = 0;  //GPS MOVING TIME IN MILLI


    @Override
    public void onLocationReceived(Location location) {
        mPrinter("ON LOCATION RECEIVED:  " + location.getProvider() + "," + location.getLatitude() + "," + location.getLongitude());
        arrLats.add(location.getLatitude());
        arrLons.add(location.getLongitude());
        mPrinter("ARRLATS.SIZE: " + arrLats.size());

        if (arrLats.size() < 2) {
            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        } else {
            Location.distanceBetween(oldLat, oldLon, location.getLatitude(), location.getLongitude(), results);

            if (results.length > 0) {
                geoSpeed = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr
                mPrinter("GEO SPEED: " + geoSpeed);
                mPrinter("RESULTS[0]  " + results[0] * 0.000621371 +  "  MILES"); //AS MILES
                if (results[0] == 0) {
                    mPrinter("NOTHING AT RESULTS[0] - RETURN");
                    return;
                }
                if (results[0] * 0.000621371 <= 0) {
                    mPrinter("NO DISTANCE TRAVELED - RETURN");
                    return;
                }

                geoDistance += results[0] * 0.000621371;
                mPrinter("OLDTIME " + oldTime);
                mPrinter("NEWTIME " + location.getTime());
                mPrinter("totalTimeGeo " + totalTimeGeo);
                totalTimeGeo += (location.getTime() - oldTime);  //MILLI
                mPrinter("GEODISTANCE: " + geoDistance);
                mPrinter("TOTALTIMEGEO: " + totalTimeGeo);

                double ttg = totalTimeGeo;
                geoAvgSpeed = geoDistance / (ttg / 1000.0 / 60.0 / 60.0);
                mPrinter("geoAvgSpeed: " + geoAvgSpeed);

                long millis = totalTimeGeo;
                @SuppressLint("DefaultLocale") String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                        TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                        TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));


                mPrinter("ELAPSED TIME (GEO): " + hms);
                TextView t = findViewById(R.id.textView2311);
                t.setText(hms + "  (GEO)");

                getActualTime();

                updateGeoButtons();

            }

            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        }


    }


    @Override
    public void onLocationProviderEnabled() {
        mLog("LOC", "ONLOCATIONPROVIDERENABLED");
    }

    @Override
    public void onLocationProviderDisabled() {
        mLog("LOC", "ONLOCATIONPROVIDERDISABLED");
    }

    //NOT USED YET
    private BroadcastReceiver localBroadcastReceiver;

    public void onClick_GPS(View view) {
        //ON CLICK GPS
        mPrinter("STARTING GPS");
        LocationRequest locationRequest = new LocationRequest()
//                            .setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY)
                .setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
                .setInterval(3000)
                .setFastestInterval(1000);
        EasyLocationRequest easyLocationRequest = new EasyLocationRequestBuilder()
                .setLocationRequest(locationRequest)
                .setFallBackToLastLocationTime(3000)
                .build();
        requestLocationUpdates(easyLocationRequest);
    }

    private class LocalBroadcastReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            // safety check
            if (intent == null || intent.getAction() == null) {
                return;
            }
            if (intent.getAction().equals("CONNECT")) {
                //doSomeAction();
                Log.i("TAG", "CONNECT onReceive");
            }
            if (intent.getAction().equals("REMOVE")) {
                //doSomeAction();
                Log.i("TAG", "REMOVE onReceive");
            }
        }
    }


    @Override
    protected void onResume() {
        super.onResume();

        //TODO:  TO LAUNCH WITH EMULATOR, DISABLE
//        if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
//            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
//            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
//        } else {
//            mLEScanner = mBluetoothAdapter.getBluetoothLeScanner();
//            settings = new ScanSettings.Builder()
//                    .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
//                    .build();
//            filters = new ArrayList<>();
//        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mBluetoothAdapter != null && mBluetoothAdapter.isEnabled()) {
            scanLeDevice(false);
        }
        LocalBroadcastManager.getInstance(this).unregisterReceiver(
                localBroadcastReceiver);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_ENABLE_BT) {
            if (resultCode == Activity.RESULT_CANCELED) {
                //Bluetooth not enabled.
                finish();
                return;
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }


    private ArrayList<BluetoothDevice> devicesDiscovered = new ArrayList<>();
    private ArrayList<String> namesDiscovered = new ArrayList<>();
    private ArrayList<String> addressesDiscovered = new ArrayList<>();
    private ScanCallback mScanCallback;
    private Integer deviceIndexVal = 0;

//SCANCALLBACK - START
    {
        mScanCallback = new ScanCallback() {
            @Override
            public void onScanResult(int callbackType, ScanResult result) {

                if (result.getDevice().getName() != null) {
                    BluetoothDevice deviceDiscovered = result.getDevice();
                    String deviceName = result.getDevice().getName();
                    String deviceAddress = result.getDevice().getAddress();


                    if (!addressesDiscovered.contains(deviceAddress)) {
                        devicesDiscovered.add(deviceDiscovered);
                        addressesDiscovered.add(deviceAddress);
                        namesDiscovered.add(deviceName);

                        sendToaster("FOUND:  " + deviceName);

                        Log.i("deviceIndexVal", "deviceIndexVal  " + deviceIndexVal);
                        Log.i("result", "NAME  " + result.getDevice().getName());
                        Log.i("result", "ADDRESS  " + result.getDevice().getAddress());
                        Log.i("result", "getDevice.toString  " + result.getDevice().toString());
                        //Log.i("result", String.format("getDevice.ScanRecord  %s", result.getScanRecord().getServiceData().toString()));

                        Button btn100 = findViewById(R.id.button100);
                        Button btn101 = findViewById(R.id.button101);
                        Button btn102 = findViewById(R.id.button102);
                        Button btn103 = findViewById(R.id.button103);
                        Button btn104 = findViewById(R.id.button104);

                        if (deviceIndexVal == 0) {
                            //btn1.setText(deviceName);
                            btn100.setVisibility(View.VISIBLE);
                            btn100.setText(deviceName);
                            Log.i("btn100", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 1) {
                            //btn2.setText(deviceName);
                            btn101.setVisibility(View.VISIBLE);
                            btn101.setText(deviceName);
                            Log.i("btn101", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 2) {
                            //btn3.setText(deviceName);
                            btn102.setVisibility(View.VISIBLE);
                            btn102.setText(deviceName);
                            Log.i("btn102", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 3) {
                            //btn3.setText(deviceName);
                            btn103.setVisibility(View.VISIBLE);
                            btn103.setText(deviceName);
                            Log.i("btn103", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 4) {
                            //btn3.setText(deviceName);
                            btn104.setVisibility(View.VISIBLE);
                            btn104.setText(deviceName);
                            Log.i("btn104", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        deviceIndexVal = deviceIndexVal + 1;
                    }  //DUPLICATE, DON'T ADD
                }  //NO NAME, DON'T, ADD


            }
            //END ON RESULT

            @Override
            public void onBatchScanResults(List<ScanResult> results) {
                for (ScanResult sr : results) {
                    Log.i("ScanResult - Results", sr.toString());
                }
            }

            @Override
            public void onScanFailed(int errorCode) {
                Log.e("Scan Failed", "Error Code: " + errorCode);
            }
        };
    }
//SCANCALLBACK - FINISH

    private Boolean isScanning = false;
    private Boolean isConnecting = false;
    //private BluetoothDevice mDevice;



    //NOT USING
    private void requestDeviceConnection() {
        mLog("REQ", "REQUEST DEVICE CONNECTION");

        if (deviceIndexVal == 0) {
            return;
        } else {
            if (isConnecting == true) {
                return;
            }
            //TODO SET TO TRUE UNIL COMPLETED, THEN FALSE TO AWAIT THE NEXT CONNECTION
            isConnecting = true;
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("PICK")
                    .setItems(namesDiscovered.toArray(new CharSequence[namesDiscovered.size()]), new DialogInterface.OnClickListener() {
//                    .setItems(R.array.colors_array, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            // The 'which' argument contains the index position
                            // of the selected item
                            mLog("WHICH", "WHICH, DEV NAME CLICKED:  " + which + ",  " + namesDiscovered.get(which));
                            mDevice = devicesDiscovered.get(which);
                            connectToDevice(mDevice);
                        }
                    });

            builder.create().show();

        }
        mLog("REQ DONE", "NO MORE DEVICES TO CONSIDER");
        //x = x + 1;
    }

    private void sendToaster(String toasterText) {
        Toast.makeText(this,toasterText,Toast.LENGTH_SHORT).show();
    }

    private void scanLeDevice(final boolean enable) {
        if (enable) {
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mLEScanner.stopScan(mScanCallback);
                    mLog("SCAN","STOP SCAN");
                    isScanning = false;
                    sendToaster("SCAN COMPLETE");
                //requestDeviceConnection();
                }
            }, SCAN_PERIOD);

            if (isScanning == false) {
                mLEScanner.startScan(filters, settings, mScanCallback);
                isScanning = true;
//                sendToaster("SCANNING...");
                Toast.makeText(this,"SCANNING...",Toast.LENGTH_LONG);
                mLog("SCAN","START SCAN");
            }
        } else {
            isScanning = false;
            mLEScanner.stopScan(mScanCallback);
        }
    }





    private ArrayList<BluetoothDevice> arrayListConnectedDevices = new ArrayList();

    public void connectToDevice(BluetoothDevice mDevice) {
        Log.i("connectToDevice", "Device: " + mDevice.getName());
        Log.i("connectToDevice", "Addresss: " + mDevice.getAddress());
        if (mGatt == null) {
            Log.i("connectToDevice", "connecting to device: "+mDevice.toString());
            mGatt = mDevice.connectGatt(this, false, gattCallback);

            Toast.makeText(this,"Connecting to: " + mDevice.getName(), Toast.LENGTH_LONG).show();

            arrayListConnectedDevices.add(mDevice);
            for (BluetoothDevice d : arrayListConnectedDevices) {
                String d2 = String.valueOf(arrayListConnectedDevices.indexOf(d)) + ".  " + d.getName();
                mPrinter(d2);
            }


            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }


    private Boolean onCharChangedHR = false;
    private Boolean onCharChangedCAD = false;

    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {

        @Override
        public void onConnectionStateChange(BluetoothGatt mGatt, int status, int newState) {
            Log.i("gattCallback", "gattCallback: " + status);
            Log.i("onConnectionStateChange", "Status: " + status);
            switch (newState) {
                case BluetoothProfile.STATE_CONNECTED:
                    Log.i("gattCallback", "STATE_CONNECTED");
                    Log.i("gattCallback", "CONNECTED TO:  " + mGatt.getDevice().getName());
                    Log.i("discoverServices", "discoverServices:  " + mGatt.getDevice().getName());
                    mGatt.discoverServices();
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    break;
                case BluetoothProfile.STATE_DISCONNECTED:
                    Log.i("gattCallback", "STATE_DISCONNECTED " + mGatt.getDevice().getName());
                    Log.i("gattCallback", "reconnecting...");
                    mGatt = null;
                    break;
                default:
                    Log.i("gattCallback", "STATE_OTHER");
            }

        }

        private BluetoothGattCharacteristic findNotifyCharacteristic(BluetoothGattService service, UUID characteristicUUID) {
            BluetoothGattCharacteristic characteristic = null;

            Log.i("GATT3", "CALLED  findNotifyCharacteristic");
            // Check for Notify first
            List<BluetoothGattCharacteristic> characteristics = service.getCharacteristics();
            for (BluetoothGattCharacteristic c : characteristics) {
                if ((c.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0 && characteristicUUID.equals(c.getUuid())) {
                    characteristic = c;
                    break;
                }
            }

            if (characteristic != null) return characteristic;

            // If there wasn't Notify Characteristic, check for Indicate
            for (BluetoothGattCharacteristic c : characteristics) {
                if ((c.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0 && characteristicUUID.equals(c.getUuid())) {
                    characteristic = c;
                    break;
                }
            }

            // As a last resort, try and find ANY characteristic with this UUID, even if it doesn't have the correct properties
            if (characteristic == null) {
                characteristic = service.getCharacteristic(characteristicUUID);
            }

            return characteristic;
        }


        // This seems way too complicated
        private void registerNotifyCallback(UUID serviceUUID, UUID characteristicUUID) {
            Log.i("GATT1", "CALLED  registerNotifyCallback, UUID serviceUUID, UUID characteristicUUID: " + serviceUUID + "  -  " + characteristicUUID);
            boolean success = false;

            if (isVeloTransmittingHR == true) {

                mPrinter("REGISTER NOTIFY, isVeloTransmittingHR IS TRUE");

                mGatt = veloGatt;
                BluetoothGattService service = mGatt.getService(serviceUUID);
                BluetoothGattCharacteristic characteristic = findNotifyCharacteristic(service, characteristicUUID);


                if (characteristic != null) {

                    if (mGatt.setCharacteristicNotification(characteristic, true)) {

                        // Why doesn't setCharacteristicNotification write the descriptor?
                        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID);
                        try {
                            Thread.sleep(500);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        if (descriptor != null) {

                            // prefer notify over indicate
                            if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0) {
                                Log.i("4", "SET NOTIFY  descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)");
                                descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            } else if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0) {
                                Log.i("4", "SET INDICATE  descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE)");
                                descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            } else {
                                Log.i("Tag", "OTHER NOTIFY ATTEMPT  Characteristic " + characteristicUUID + " does not have NOTIFY or INDICATE property set");
                            }

                            if (mGatt.writeDescriptor(descriptor)) {
                                success = true;
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                                Log.i("Write Success", "Able to set client characteristic notification1");
                                mGatt = null;


                            } else {
                                Log.i("Write Err", "Failed to set client characteristic notification1");
                            }

                        } else {
                            Log.i("Write Err", "Failed to set client characteristic notification2");
                        }

                    } else {
                        Log.i("Write Err", "Failed to set client characteristic notification3");
                    }

                } else {
                    Log.i("Write Err", "Failed to set client characteristic notification4");
                }
                //isVelo = false;
            } else {
                BluetoothGattService service = mGatt.getService(serviceUUID);
                Log.i("GATT2", "CALLING  findNotifyCharacteristic, passing (service aka mGatt.getService(serviceUUID),charUUID)");
                BluetoothGattCharacteristic characteristic = findNotifyCharacteristic(service, characteristicUUID);
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                if (characteristic != null) {

                    if (mGatt.setCharacteristicNotification(characteristic, true)) {

                        // Why doesn't setCharacteristicNotification write the descriptor?
                        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID);
                        try {
                            Thread.sleep(500);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        if (descriptor != null) {

                            // prefer notify over indicate
                            if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0) {
                                Log.i("4", "SET NOTIFY  descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)");
                                descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            } else if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0) {
                                Log.i("4", "SET INDICATE  descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE)");
                                descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            } else {
                                Log.i("Tag", "OTHER NOTIFY ATTEMPT  Characteristic " + characteristicUUID + " does not have NOTIFY or INDICATE property set");
                            }

                            if (mGatt.writeDescriptor(descriptor)) {
                                success = true;
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                                Log.i("Write Success", "Able to set client characteristic notification1");
                                mGatt = null;


                            } else {
                                Log.i("Write Err", "Failed to set client characteristic notification1");
                            }

                        } else {
                            Log.i("Write Err", "Failed to set client characteristic notification2");
                        }

                    } else {
                        Log.i("Write Err", "Failed to set client characteristic notification3");
                    }

                } else {
                    Log.i("Write Err", "Failed to set client characteristic notification4");
                }

                if (!success) {
                    //commandCompleted();
                    Log.i("Notify", "Finished Set Notification");
                }
            }
        }
        //END REGISTER NOTIFY



        public Boolean isVelo = false;
        public Boolean isVeloTransmittingHR = false;
        private String veloAddress = "";
        private BluetoothGatt veloGatt;

        private void tryVeloConnect() {
            mPrinter("CALLED FCTN:  TRY VELO CONNECT, AFTER HR STARTS");
            registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID);
            mGatt.readCharacteristic(mGatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_MEASUREMENT_CHAR_UUID));
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt mGatt, int status) {

            Boolean hasHR = false;
            Boolean hasCSC = false;

            List<BluetoothGattService> services = mGatt.getServices();
            Log.i("onServicesDiscovered", services.toString());

            if (services == null) return;

            //START VELO TEST
            Log.i("VELO", "VELO, DETERMINE IF BOTH SERVICES EXIST");
            for (BluetoothGattService service : services) {
                if (service.getUuid().equals(HEART_RATE_SERVICE_UUID)) {
                    hasHR = true;
                }
                if (service.getUuid().equals(CSC_SERVICE_UUID)) {
                    hasCSC = true;
                }

            }
            if (hasHR == true && hasCSC == true) {
                mPrinter("VELO, BOTH ARE TRUE");
                isVelo = true;
                veloAddress = mGatt.getDevice().getAddress();
                veloGatt = mGatt;
                //1.  Register for HR
                registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
                mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));
            }

            //read all services
            Log.i("Read Services", "Loop through and read services and chars");
            for (BluetoothGattService service : services) {
                Log.i("BluGattService", "for each uuid = gattService.getUuid().toString(): " + service.getUuid().toString());
                Log.i("onServicesDiscovered: ", "HR?  " + service.getUuid().equals(HEART_RATE_SERVICE_UUID));
                Log.i("onServicesDiscovered: ", "CSC?  " + service.getUuid().equals(CSC_SERVICE_UUID));
                if (service.getUuid().equals(HEART_RATE_SERVICE_UUID)) {
                    if (hasHR == true && hasCSC == true) {return;}
                    Log.i("DISCOVERED HR", "CALLING  registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID)");
                    registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                }

                if (service.getUuid().equals(CSC_SERVICE_UUID)) {
                    if (hasHR == true && hasCSC == true) {return;}
                    Log.i("DISCOVERED CSC", "CALLING  registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID)");
                    registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID);
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    mGatt.readCharacteristic(mGatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_MEASUREMENT_CHAR_UUID));
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                }
            }
        }


        @Override
        public void onCharacteristicRead(BluetoothGatt mGatt,
                                         BluetoothGattCharacteristic
                                                 characteristic, int status) {
            Log.i("onCharacteristicRead", characteristic.toString());
            Log.i("onCharacteristicRead", characteristic.getUuid().toString());
        }

        @SuppressLint({"NewApi", "DefaultLocale"})
        @Override
        public void onCharacteristicChanged(BluetoothGatt mGatt,
                                            BluetoothGattCharacteristic
                                                    characteristic) {

            boolean hasWheel, hasCrank;
            long wheelRotations;
            int crankRotations;
            int time;


            Log.i("onChChanged: ", "HR?  " + characteristic.getUuid().equals(HEART_RATE_MEASUREMENT_CHAR_UUID));
            Log.i("onChChanged: ", "CSC?  " + characteristic.getUuid().equals(CSC_MEASUREMENT_CHAR_UUID));

            if (characteristic.getUuid().equals(HEART_RATE_MEASUREMENT_CHAR_UUID)) {
                //IF HR...AFTER SETTING NOTIFY ON ALL
                onCharChangedHR = true;
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
                //final int heartRate = characteristic.getIntValue(format, 1);
                final Integer hrValue = characteristic.getIntValue(format, 1);

                Log.i("HR", String.format("HR: %d", hrValue));

                if (isVelo == true) {
                    mPrinter("IS VELO, TRYVELOCONNECT NOW");
                    isVelo = false;
                    isVeloTransmittingHR = true;
                    tryVeloConnect();


                }

                //update UI - HR
//                String value = String.valueOf(String.format("HR: %d", hrValue));
                String value = String.valueOf(String.format("%d", hrValue));
                value = value + "\nBPM";
                Message msg = Message.obtain();
                msg.obj = value;
                msg.what = 3;
                msg.setTarget(uiHandler);
                msg.sendToTarget();
            }

            if (characteristic.getUuid().equals(CSC_MEASUREMENT_CHAR_UUID)) {
                //IF CSC...AFTER SETTING NOTIFY ON ALL
                onCharChangedCAD = true;
                mPrinter("ON CSC CHAR CHANGED");
                isVelo = false;
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }

                //byte[] value = parent.mMeasurementChar.getValue();
                byte[] value = characteristic.getValue();
                hasWheel = (value[0] & 0x1) != 0;
                hasCrank = (value[0] & 0x2) != 0;


                final int csc1 = characteristic.getIntValue(format, 1);
                final Integer csc1value = characteristic.getIntValue(format, 1);
                final int csc5 = characteristic.getIntValue(format, 5);
                final Integer csc5value = characteristic.getIntValue(format, 5);
                final int csc7 = characteristic.getIntValue(format, 7);
                final Integer csc7value = characteristic.getIntValue(format, 7);
                final int csc9 = characteristic.getIntValue(format, 9);
                final Integer csc9value = characteristic.getIntValue(format, 9);

                Log.i("CSC1", String.format("CSC1: %d", csc1value));
                Log.i("CSC5", String.format("CSC5: %d", csc5value));
                Log.i("CSC7", String.format("CSC7: %d", csc7value));
                Log.i("CSC9", String.format("CSC9: %d", csc9value));
                String spd_cad = csc1 + " - " + csc7;
                Log.i("SPD-CSC","SPD-CSC - " + spd_cad);


//                intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));
//            String value = String.valueOf(heartRate);
//            Log.i("hrValue.toString", hrValue.toString());


//                if (csc1 >= 0) {
//                    //String value = String.format("CSC1: %d", csc1value);
//                    Message msg = Message.obtain();
//                    msg.obj = String.format("CSC1: %d", csc1value);
//                    msg.what = 4;
//                    msg.setTarget(uiHandler);
//                    msg.sendToTarget();
//                }
//
//                if (csc7 >= 0) {
//                    //String value = String.format("CSC1: %d", csc7value);
//                    Message msg = Message.obtain();
//                    msg.obj = String.format("CSC1: %d", csc7value);
//                    msg.what = 5;
//                    msg.setTarget(uiHandler);
//                    msg.sendToTarget();
//                }


                int i = 1;

                // Note: We only send out a delta update when we have a meaningful
                // delta. If the user was coasting or stopped, the last update will
                // be from a long ago, making the delta meaningless for both
                // instantaneous and average calculations.

                if (hasWheel) {
                    wheelRotations = readU32(value, i);
                    time = readU16(value, i + 4);

                    if (wheelRotations == 0) {
                        // We've stopped moving
                        mWheelStopped = true;

                    } else if (mWheelStopped) {
                        // Wheel's started again
                        mWheelStopped = false;
                        mLastWheelReading = wheelRotations;
                        mLastWheelTime = time;

                        //parent.mCallback.onSpeedUpdate(parent, 0, 0.0);

                    } else {
                        // Delta over last update
                        int timeDiff;

                        if (wheelRotations < mLastWheelReading) {
                            // Can happen if bicycle reverses
                            wheelRotations = 0;
                        }



                        timeDiff = do16BitDiff(time, mLastWheelTime);
                        double dTimeDiff = timeDiff;
                        double wheelCircumference = 2105;
                        double wheelTimeSeconds = dTimeDiff / 1024;
                        double wheelCircumferenceCM = wheelCircumference / 10;
                        double wheelRot = wheelRotations - mLastWheelReading;
                        double wheelRPM = wheelRot / (wheelTimeSeconds / 60);
                        double cmPerMi = 0.00001 * 0.621371;
                        double minsPerHour = 60.0;
                        double speed =  wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour;

                        //parent.mCallback.onSpeedUpdate(parent, (wheelRotations - mLastWheelReading) * mCircumference, (timeDiff * 1000000.0) / 1024.0);
                        mPrinter("CURRENT SPEED:  " + String.format("%.2f", speed));

                        if (speed > 0 && speed < 40 && wheelTimeSeconds < 15 && !Double.isNaN(speed)) {

                            totalWheelRotations += wheelRot;
                            totalWheelTimeSeconds += wheelTimeSeconds;
                            totalDistance = totalWheelRotations * wheelCircumferenceCM * cmPerMi;
                            totalAverageMovingSpeed = (totalWheelRotations / (totalWheelTimeSeconds / 60)) * wheelCircumferenceCM * cmPerMi * minsPerHour;
                            totalWheelTimeMilli += dTimeDiff;

                            if (totalDistance >= nextMileMarker) {
                                nextMileMarker += 1;
                                sendToaster("MILE " + (nextMileMarker - 1) + "COMPLETED");
                            }

                            //String value = String.format("CSC1: %d", csc1value);
                            Message msg = Message.obtain();
                            String vs = String.format("%.2f", speed);
                            vs = vs + "\nMPH(B)";
                            msg.obj = vs;
//                            msg.obj = String.format("MPH: %.2f", speed);
                            msg.what = 4;
                            msg.setTarget(uiHandler);
                            msg.sendToTarget();
                        }


                        mLastWheelReading = wheelRotations;
                        mLastWheelTime = time;
                    }

                    i += 6;
                }

                if (hasCrank) {
                    crankRotations = readU16(value, i);
                    time = readU16(value, i + 2);

                    if (crankRotations == 0) {
                        // Coasting or stopped
                        mCrankStopped = true;

                    } else if (mCrankStopped) {
                        // Crank's started up again

                        mCrankStopped = false;
                        mLastCrankReading = crankRotations;
                        mLastCrankTime = time;

                        //parent.mCallback.onCadenceUpdate(parent, 0, 0.0);

                    } else {
                        // Delta over last update
                        int rotDiff, timeDiff;

                        rotDiff = do16BitDiff(crankRotations, mLastCrankReading);
                        timeDiff = do16BitDiff(time, mLastCrankTime);

                        currentCadence = rotDiff / (((timeDiff) / 1024.0) / 60);
                        mPrinter("CURRENT CADENCE:  " + String.format("%.1f", currentCadence));

                        if (currentCadence > 0 && timeDiff < 10000 && !Double.isNaN(currentCadence)) {
                            //String value = String.format("CSC1: %d", csc7value);
                            Message msg = Message.obtain();
                            String vc = String.format("%.0f", currentCadence);
                            vc = vc + "\nRPM";
                            msg.obj = vc;
//                            msg.obj = String.format("RPM: %.0f", currentCadence);
                            msg.what = 5;
                            msg.setTarget(uiHandler);
                            msg.sendToTarget();
                        }


                        mLastCrankReading = crankRotations;
                        mLastCrankTime = time;
                    }
                }





            }

            //gatt.disconnect();

        }

    };


    private boolean mWheelStopped, mCrankStopped;
    private long mLastWheelReading;
    private int mLastCrankReading;
    private int mLastWheelTime, mLastCrankTime;
    private double currentSpeed;
    private double currentCadence;
    private double mCircumference = 2105;

    private double totalDistance = 0.0;
    private double totalWheelRotations = 0.0;
    private double totalWheelTimeSeconds = 0.0;
    private double totalWheelTimeMilli = 0.0;
    private double totalAverageMovingSpeed = 0.0;
    private double nextMileMarker = 1.0;



    private int do16BitDiff(int a, int b)
    {
        if (a >= b)
            return a - b;
        else
            return (a + 65536) - b;
    }

    private int readU32(byte[] bytes, int offset)
    {
        // Does not perform bounds checking
        return ((bytes[offset + 3] << 24) & 0xff000000) +
                ((bytes[offset + 2] << 16) & 0xff0000) +
                ((bytes[offset + 1] << 8) & 0xff00) +
                (bytes[offset] & 0xff);
    }

    private int readU16(byte[] bytes, int offset)
    {
        return ((bytes[offset + 1] << 8) & 0xff00) + (bytes[offset] & 0xff);
    }


//    public String displayOrRemove(String displayName) {
//        AlertDialog.Builder builder = new AlertDialog.Builder(this);
//        builder.setTitle("CONNECT OR REMOVE?")
//                .setItems(["CONNECT", "REMOVE"]), new DialogInterface.OnClickListener() {
//                    public void onClick(DialogInterface dialog, int which) {
//                        // The 'which' argument contains the index position
//                        // of the selected item
//                        mLog("WHICH", "WHICH WAS CLICKED:  " + which);
//                        mDevice = devicesDiscovered.get(which);
//                        connectToDevice(mDevice);
//                    }
//                };
//
//        builder.create().show();
//        return "a_String";
//    }


    public void onClick_Bluetooth(View view) {
        //TODO:  DISABLE FOR EMULATOR
        mLog("onCLICK","ONCLICK BLUETOOTH");
        Toast.makeText(this,"SCANNING...", Toast.LENGTH_LONG).show();
        scanLeDevice(true);
    }


    public void onClick_104(View view) {
        mDevice = devicesDiscovered.get(4);
        isConnecting = true;
        //Toast.makeText(this,"Connecting to: " + mDevice.getName(), Toast.LENGTH_LONG).show();
        //connectToDevice(mDevice);


        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("CONNECT TO:  " + mDevice.getName())
                .setCancelable(false)
                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B1","CONNECT");
                        connectToDevice(mDevice);
                        Button btn104 = findViewById(R.id.button104);
                        btn104.setTextColor(Color.RED);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("CONNECT"));
                        dialog.cancel();
                    }
                })
                .setNegativeButton("REMOVE", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B2","REMOVE");

                        //TODO:  CHANGE FOR EACH BUTTON
                        Button btn104 = findViewById(R.id.button104);
                        btn104.setVisibility(View.GONE);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("REMOVE"));
                        dialog.cancel();
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();
    }

    //private Button buttonToHide;

    public void onClick_103(View view) {
        mDevice = devicesDiscovered.get(3);
        isConnecting = true;
        //Toast.makeText(this,"Connecting to: " + mDevice.getName(), Toast.LENGTH_LONG).show();
//        connectToDevice(mDevice);


        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("CONNECT TO:  " + mDevice.getName())
                .setCancelable(false)
                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B1","CONNECT");
                        connectToDevice(mDevice);
                        Button btn103 = findViewById(R.id.button103);
                        btn103.setTextColor(Color.RED);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("CONNECT"));
                        dialog.cancel();
                    }
                })
                .setNegativeButton("REMOVE", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B2","REMOVE");

                        //TODO:  CHANGE FOR EACH BUTTON
                        Button btn103 = findViewById(R.id.button103);
                        btn103.setVisibility(View.GONE);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("REMOVE"));
                        dialog.cancel();
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();

    }

    public void onClick_102(View view) {
        mDevice = devicesDiscovered.get(2);
        isConnecting = true;
        //Toast.makeText(this,"Connecting to: " + mDevice.getName(), Toast.LENGTH_LONG).show();
//        connectToDevice(mDevice);


        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("CONNECT TO:  " + mDevice.getName())
                .setCancelable(false)
                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B1","CONNECT");
                        connectToDevice(mDevice);
                        Button btn102 = findViewById(R.id.button102);
                        btn102.setTextColor(Color.RED);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("CONNECT"));
                        dialog.cancel();
                    }
                })
                .setNegativeButton("REMOVE", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B2","REMOVE");

                        //TODO:  CHANGE FOR EACH BUTTON
                        Button btn102 = findViewById(R.id.button102);
                        btn102.setVisibility(View.GONE);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("REMOVE"));
                        dialog.cancel();
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();


    }

    public void onClick_101(View view) {
        mDevice = devicesDiscovered.get(1);
        isConnecting = true;

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("CONNECT TO:  " + mDevice.getName())
                .setCancelable(false)
                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B1","CONNECT");
                        connectToDevice(mDevice);
                        Button btn101 = findViewById(R.id.button101);
                        btn101.setTextColor(Color.RED);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("CONNECT"));
                        dialog.cancel();
                    }
                })
                .setNegativeButton("REMOVE", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B2","REMOVE");

                        //TODO:  CHANGE FOR EACH BUTTON
                        Button btn101 = findViewById(R.id.button101);
                        btn101.setVisibility(View.GONE);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("REMOVE"));
                        dialog.cancel();
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();

    }

    public void onClick_100(View view) {
        mDevice = devicesDiscovered.get(0);
        isConnecting = true;

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("CONNECT TO:  " + mDevice.getName())
                .setCancelable(false)
                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B1","CONNECT");
                        connectToDevice(mDevice);
                        Button btn100 = findViewById(R.id.button100);
                        btn100.setTextColor(Color.RED);


                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("CONNECT"));
                        dialog.cancel();
                    }
                })
                .setNegativeButton("REMOVE", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("B2","REMOVE");

                        //TODO:  CHANGE FOR EACH BUTTON
                        Button btn100 = findViewById(R.id.button100);
                        btn100.setVisibility(View.GONE);

                        //NOT USED
                        LocalBroadcastManager.getInstance(getParent()).sendBroadcast(
                                new Intent("REMOVE"));
                        dialog.cancel();
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();
    }
}


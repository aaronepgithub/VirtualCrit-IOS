package com.example.aaronep.myapplication1;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanSettings;
import android.os.Bundle;
import android.os.Looper;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;



import android.bluetooth.le.BluetoothLeScanner;

import android.bluetooth.le.ScanResult;

import android.content.Intent;
import android.content.pm.PackageManager;

import android.os.Handler;




import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;


public class MainActivity extends AppCompatActivity {

    private Button btn1;
    private TextView tview1;

    private static final String TAG = "ClientActivity";
    private static final int REQUEST_ENABLE_BT = 1;
    private static final int REQUEST_FINE_LOCATION = 2;

    //private ActivityClientBinding mBinding;

    private boolean mScanning;
    private Handler mHandler;
    private Handler mLogHandler;
    private Map<String, BluetoothDevice> mScanResults;

    private boolean mConnected;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mBluetoothLeScanner;
    private ScanCallback mScanCallback;
    private BluetoothGatt mGatt;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.e("Tag","oncreate");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        btn1 = (Button) findViewById(R.id.btn1);
        tview1 = (TextView) findViewById(R.id.tview1);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });


        mLogHandler = new Handler(Looper.getMainLooper());

        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();

        //mBinding = DataBindingUtil.setContentView(this, R.layout.activity_client);
        //@SuppressLint("HardwareIds")
        String deviceInfo = "Device Info"
                + "\nName: " + mBluetoothAdapter.getName()
                + "\nAddress: " + mBluetoothAdapter.getAddress();

        Log.d("tag", "deviceinfo:  " + deviceInfo);




//        mBinding.clientDeviceInfoTextView.setText(deviceInfo);
//        mBinding.startScanningButton.setOnClickListener(v -> startScan());
//        mBinding.stopScanningButton.setOnClickListener(v -> stopScan());
//        mBinding.disconnectButton.setOnClickListener(v -> disconnectGattServer());
//        mBinding.viewClientLog.clearLogButton.setOnClickListener(v -> clearLogs());

    }

    @Override
    protected void onResume() {
        super.onResume();

        Log.e("Tag","onResume");
        // Check low energy support
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            // Get a newer device
            logError("No LE Support.");
            finish();
        }
    }



    private void startScan() {
        if (hasPermissions() || mScanning) {
            return;
        }
        Log.e("Tag","startScan");

//        disconnectGattServer();

//        mBinding.serverListContainer.removeAllViews();

        mScanResults = new HashMap<>();
        mScanCallback = new BtleScanCallback(mScanResults);

        mBluetoothLeScanner = mBluetoothAdapter.getBluetoothLeScanner();


        ScanFilter scanFilter = new ScanFilter.Builder().build();
        List<ScanFilter> filters = new ArrayList<>();
        filters.add(scanFilter);

//        ScanFilter scanFilter = new ScanFilter.Builder()
//                .setServiceUuid(new ParcelUuid(SERVICE_UUID))
//                .build();
//        List<ScanFilter> filters = new ArrayList<>();
//        filters.add(scanFilter);


        ScanSettings settings = new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_POWER)
                .build();

        Log.e("Tag","startScan");
        mBluetoothLeScanner.startScan(filters, settings, mScanCallback);

//        mHandler = new Handler();
//        mHandler.postDelayed(this::stopScan, 5000);

        mScanning = true;
        log("Started scanning.");

//        mHandler.postDelayed(this::stopScan, 5000);

    }


    private void stopScan() {
        if (mScanning && mBluetoothAdapter != null && mBluetoothAdapter.isEnabled() && mBluetoothLeScanner != null) {
            mBluetoothLeScanner.stopScan(mScanCallback);
            Log.e("Tag","scanComplete");
            scanComplete();
        }


        Log.e("Tag","Stopped scanning");

        mScanCallback = null;
        mScanning = false;
        mHandler = null;
        log("Stopped scanning.");

    }



    private void scanComplete() {
        if (mScanResults.isEmpty()) {
            return;
        }

        for (String deviceAddress : mScanResults.keySet()) {
            BluetoothDevice device = mScanResults.get(deviceAddress);


//            Log.e("Tag","mScanResults:  " + mScanResults.toString());
//            Log.e("Tag","mScanResults:  " + device.getName());
            log("mScanResults:  " + mScanResults.toString());
            log("mScanResults:  " + device.getName());
            if (device.getName() != null) {
                String st = tview1.getText().toString();
                tview1.setText(st + "\n" + device.getName() + "\n");

                if (Objects.equals(device.getName(), "Apple-VELO")) {
                    log("got velo, try connect");
                    connectDevice(device);
                }
            }



//            GattServerViewModel viewModel = new GattServerViewModel(device);
//
//            ViewGattServerBinding binding = DataBindingUtil.inflate(LayoutInflater.from(this),
//                    R.layout.view_gatt_server,
//                    mBinding.serverListContainer,
//                    true);
//            binding.setViewModel(viewModel);
//            binding.connectGattServerButton.setOnClickListener(v -> connectDevice(device));
        }
    }


    private boolean hasPermissions() {
        if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
            requestBluetoothEnable();
            return false;
        } else if (!hasLocationPermissions()) {
            requestLocationPermission();
            return false;
        }
        return true;
    }

    private void requestBluetoothEnable() {
        Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        log("Requested user enables Bluetooth. Try starting the scan again.");
    }

    private boolean hasLocationPermissions() {
        return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
    }

    private void requestLocationPermission() {
        requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_FINE_LOCATION);
        log("Requested user enable Location. Try starting the scan again.");
    }




    private void connectDevice(BluetoothDevice device) {
        log("Connecting to " + device.getAddress());
        Log.d(TAG, "Connecting to " + device.getAddress());
        GattClientCallback gattClientCallback = new GattClientCallback();
        mGatt = device.connectGatt(this, false, gattClientCallback);
    }

    // Logging

//    private void clearLogs() {
//        mLogHandler.post(() -> mBinding.viewClientLog.logTextView.setText(""));
//    }
//
//    // Gat Client Actions
//
    public void log(String msg) {
        Log.d(TAG, msg);
//        mLogHandler.post(() -> {
//            mBinding.viewClientLog.logTextView.append(msg + "\n");
//            mBinding.viewClientLog.logScrollView.post(() -> mBinding.viewClientLog.logScrollView.fullScroll(View.FOCUS_DOWN));
//        });
    }

    public void logError(String msg) {
        log("Error: " + msg);
    }

    public void setConnected(boolean connected) {
        mConnected = connected;
    }

    public void disconnectGattServer() {
        log("Closing Gatt connection");
        //clearLogs();
        mConnected = false;
        if (mGatt != null) {
            mGatt.disconnect();
            mGatt.close();
        }
    }


    private class BtleScanCallback extends ScanCallback {

//        Log.e("Tag","BLE Scan Failed with code ");

        private Map<String, BluetoothDevice> mScanResults;

        BtleScanCallback(Map<String, BluetoothDevice> scanResults) {
            mScanResults = scanResults;
        }

        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            addScanResult(result);
        }

        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            for (ScanResult result : results) {
                addScanResult(result);
            }
        }

        @Override
        public void onScanFailed(int errorCode) {
            logError("BLE Scan Failed with code " + errorCode);
            Log.e("Tag","BLE Scan Failed with code " + errorCode);
        }

        private void addScanResult(ScanResult result) {
            BluetoothDevice device = result.getDevice();
            String deviceAddress = device.getAddress();
            mScanResults.put(deviceAddress, device);
        }
    }



    private class GattClientCallback extends BluetoothGattCallback {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            super.onConnectionStateChange(gatt, status, newState);
            log("onConnectionStateChange newState: " + newState);

            if (status == BluetoothGatt.GATT_FAILURE) {
                logError("Connection Gatt failure status " + status);
                disconnectGattServer();
                return;
            } else if (status != BluetoothGatt.GATT_SUCCESS) {
                logError("Connection not GATT success status " + status);
                disconnectGattServer();
                return;
            }

            if (newState == BluetoothProfile.STATE_CONNECTED) {
                log("Connected to device " + gatt.getDevice().getAddress());
                setConnected(true);
                gatt.discoverServices();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                log("Disconnected from device");
                disconnectGattServer();
            }
        }
    }




    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    Boolean btnCounter = false;
    public void BtnClick(View view)
    {


        if (btnCounter == true) {
            tview1.setText("");
            Log.e("Tag","stopping");
            btnCounter = false;
            stopScan();
        } else {
            tview1.setText("");
            Log.e("Tag","starting");
            btnCounter = true;
            startScan();
        }


    }
}

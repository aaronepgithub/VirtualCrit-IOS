package com.example.aaronep.myapplication1;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Map;

import android.app.Service;

import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;

import java.util.UUID;


import static android.bluetooth.BluetoothAdapter.STATE_CONNECTING;
import static android.bluetooth.BluetoothAdapter.STATE_DISCONNECTED;


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
    private BluetoothGattCallback mBluetoothGattCallback;



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


    }

    @Override
    protected void onResume() {
        super.onResume();
        log("onResume");

//        Log.e("Tag","onResume");
//        // Check low energy support
//        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
//            // Get a newer device
//            logError("No LE Support.");
//            finish();
//        }
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





//    private class BtleScanCallback extends ScanCallback {
//
////        Log.e("Tag","BLE Scan Failed with code ");
//
//        private Map<String, BluetoothDevice> mScanResults;
//
//        BtleScanCallback(Map<String, BluetoothDevice> scanResults) {
//            mScanResults = scanResults;
//        }
//
//        @Override
//        public void onScanResult(int callbackType, ScanResult result) {
//            addScanResult(result);
//        }
//
//        @Override
//        public void onBatchScanResults(List<ScanResult> results) {
//            for (ScanResult result : results) {
//                addScanResult(result);
//            }
//        }

//        @Override
//        public void onScanFailed(int errorCode) {
//            logError("BLE Scan Failed with code " + errorCode);
//            Log.e("Tag","BLE Scan Failed with code " + errorCode);
//        }
//
//        private void addScanResult(ScanResult result) {
//            BluetoothDevice device = result.getDevice();
//            String deviceAddress = device.getAddress();
//            mScanResults.put(deviceAddress, device);
//        }
//    }



    private final BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {



        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {

            Log.e("Tag", "onServicesDiscovered:  " + status);

            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "onServicesDiscovered gatt _success: " + status);
            } else {
                Log.d(TAG, "onServicesDiscovered no _success: " + status);
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic characteristic,
                                         int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "onCharacteristicRead _success: " + status);
            }
        }

    };




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







//    private class LeDeviceListAdapter  {
//    // Adapter for holding devices found through scanning.
////    private class LeDeviceListAdapter extends BaseAdapter {
//        private ArrayList<BluetoothDevice> mLeDevices;
//        //private LayoutInflater mInflator;
//
//        public LeDeviceListAdapter() {
//            super();
//            mLeDevices = new ArrayList<BluetoothDevice>();
//            //mInflator = DeviceScanActivity.this.getLayoutInflater();
//        }
//
//        public void addDevice(BluetoothDevice device) {
//            if(!mLeDevices.contains(device)) {
//                mLeDevices.add(device);
//            }
//        }
//
//        public BluetoothDevice getDevice(int position) {
//            return mLeDevices.get(position);
//        }
//
//        public void clear() {
//            mLeDevices.clear();
//        }
//
//        @Override
//        public int getCount() {
//            return mLeDevices.size();
//        }
//
//        @Override
//        public Object getItem(int i) {
//            return mLeDevices.get(i);
//        }
//
//        @Override
//        public long getItemId(int i) {
//            return i;
//        }
//
//        @Override
//        public View getView(int i, View view, ViewGroup viewGroup) {
//            ViewHolder viewHolder;
//            // General ListView optimization code.
//            if (view == null) {
//                view = mInflator.inflate(R.layout.listitem_device, null);
//                viewHolder = new ViewHolder();
//                viewHolder.deviceAddress = (TextView) view.findViewById(R.id.device_address);
//                viewHolder.deviceName = (TextView) view.findViewById(R.id.device_name);
//                view.setTag(viewHolder);
//            } else {
//                viewHolder = (ViewHolder) view.getTag();
//            }
//
//            BluetoothDevice device = mLeDevices.get(i);
//            final String deviceName = device.getName();
//            if (deviceName != null && deviceName.length() > 0)
//                viewHolder.deviceName.setText(deviceName);
//            else
//                viewHolder.deviceName.setText(R.string.unknown_device);
//            viewHolder.deviceAddress.setText(device.getAddress());
//
//            return view;
//        }
//    }






    private void connectDevice(BluetoothDevice device) {
        Log.e("Tag", "connectDevice:  " + device.getName());
        device.connectGatt(this, false, mGattCallback, BluetoothDevice.TRANSPORT_LE);
    }



    // Device scan callback.
    private BluetoothAdapter.LeScanCallback mLeScanCallback;

    {
        mLeScanCallback = new BluetoothAdapter.LeScanCallback() {

            public ArrayList<BluetoothDevice> mLeDevices;
            private String aDeviceName;
            private String aDeviceAddress;
            private String myDeviceName = "BLUETOOTH SMART HRM";
            private BluetoothDevice mDevice;

            @Override
            public void onLeScan(final BluetoothDevice device, int rssi, byte[] scanRecord) {
                Log.e("Tag", "onLeScan");

                if (btnCounter == false) {
                    Log.e("Tag", "btnCtr is false");
                    //stopped, can try to connect here
                    return;
                }

                if (device != null) {
                    if (device.getName() != null) {
                        Log.e("Tag", "onLeScan, anyName:  " + device.getName());
                        aDeviceName = device.getName();
                        aDeviceAddress = device.getAddress();
                        if (aDeviceName.equals(myDeviceName)) {
                            Log.e("Tag", "onLeScan, myBLE:  " + device.getName());
                            Log.e("Tag", "onLeScan:  " + device.getAddress());
                            mDevice = device;
                            aDeviceName = device.getName();
                            aDeviceAddress = device.getAddress();
                            connectDevice(mDevice);
                            mBluetoothAdapter.stopLeScan(mLeScanCallback);

                        }
                    }
                }

            }
        };
    }


    private void findLowEnergyDevices() {
    Log.e("Tag","findLowEnergyDevices");
        //log("findLowEnergyDevices");
//    if (mBluetoothAdapter.isDiscovering() {
//        return;
//    }
//    mBluetoothAdapter.startDiscovery();


    mBluetoothAdapter.startLeScan(mLeScanCallback);


    Handler handler = new Handler();
    handler.postDelayed(new Runnable() {
        @Override
        public void run() {
            Log.e("Tag","stopping after 5 seconds");
            mBluetoothAdapter.stopLeScan(mLeScanCallback);
        }
    }, 5000);
}

//private void scan() {
//        log("scan");
//    findLowEnergyDevices();
//}

    Boolean btnCounter = false;
    public void BtnClick(View view)
    {

        if (btnCounter == true) {
            tview1.setText("stopping");
            Log.e("Tag","stopping");
            btnCounter = false;
            mBluetoothAdapter.stopLeScan(mLeScanCallback);

        } else {
            tview1.setText("starting");
            btnCounter = true;
            Log.e("Tag","starting");
            findLowEnergyDevices();

            //scan();
            //findLowEnergyDevices();
            //startScan();
        }


    }
}


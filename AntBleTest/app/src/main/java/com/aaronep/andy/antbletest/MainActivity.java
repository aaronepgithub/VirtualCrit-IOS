package com.aaronep.andy.antbletest;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.ParcelUuid;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {

    private final static String TAG = MainActivity.class.getSimpleName();

    private static final UUID CSC_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
    private static final UUID CSC_CHARACTERISTIC_UUID = UUID.fromString("00002a5b-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
    private static final UUID BTLE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");


    private int REQUEST_ENABLE_BT = 1;
    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;
    private static final long SCAN_PERIOD = 2000;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mLEScanner;
    private ScanSettings settings;
    private List<ScanFilter> filters;

    //SERVICE VARS / SERVICE MANAGEMENT
    private BluetoothLeService mBluetoothLeService;
    private boolean mConnected = false;



    // Code to manage Service lifecycle.
    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            Log.i(TAG, "onServiceConnected");
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            if (!mBluetoothLeService.initialize()) {
                Log.i(TAG, "Unable to initialize Bluetooth");
                finish();
            }
            // Automatically connects to the device upon successful start-up initialization.
            //mBluetoothLeService.connect(mDeviceAddress);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mBluetoothLeService = null;
        }
    };

    private final BroadcastReceiver mGattUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            Log.i(TAG, "onReceive: Broadcast Receiver");
            


            if (BluetoothLeService.ACTION_GATT_CONNECTED.equals(action)) {
                Log.i(TAG, "onReceive: ACTION_GATT_CONNECTED");
                displayData("ACTION_GATT_CONNECTED");
                mConnected = true;
                refreshDevicesList();
                //updateConnectionState(R.string.connected);
                //invalidateOptionsMenu();
            } else if (BluetoothLeService.ACTION_GATT_DISCONNECTED.equals(action)) {
                Log.i(TAG, "onReceive: ACTION_GATT_DISCONNECTED");
                displayData("ACTION_GATT_DISCONNECTED");
                displayDataDISCONNECTED(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
                Log.i(TAG, "onReceive: DISCONNECTED: " + intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
//                GO THROUGH DISCOVERED DEVICES AND REMOVE THE ONE WITH THE MATCHING NAME AND REFRESH
                refreshDevicesList();
                mConnected = false;
            } else if (BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                Log.i(TAG, "onReceive: ACTION_GATT_SERVICES_DISCOVERED");
                displayData("ACTION_GATT_SERVICES_DISCOVERED");
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE.equals(action)) {
                Log.i(TAG, "onReceive: ACTION DATA AVAILABLE");
                displayData("ACTION_DATA_AVAILABLE  " + intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE_HR.equals(action)) {
                Log.i(TAG, "onReceive: ACTION DATA AVAILABLE_HR");
                displayDataHR(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE_SPD.equals(action)) {
                Log.i(TAG, "onReceive: ACTION DATA AVAILABLE_SPD");
                displayDataSPD(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE_CAD.equals(action)) {
                Log.i(TAG, "onReceive: ACTION DATA AVAILABLE_CAD");
                displayDataCAD(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE_DISTANCE.equals(action)) {
                Log.i(TAG, "onReceive: ACTION DATA AVAILABLE_DISTANCE");
                displayDataDISTANCE(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
            }
        }
    };

    private void displayData(String data) {
        if (data != null) {
            Log.i(TAG, "displayData: " + data);
        }
    }




    private void displayDataHR(final String data) {
        if (data != null) {
        Log.i(TAG, "displayDataHR: " + data);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView tview10 = (TextView) findViewById(R.id.TextView10);
                tview10.setText(data);
            }
        });
        }
    }

    private void displayDataSPD(final String data) {
        if (data != null) {
            Log.i(TAG, "displayDataSPD: " + data);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView tview11 = (TextView) findViewById(R.id.TextView11);
                    tview11.setText(data);
                }
            });
        }
    }

    private void displayDataCAD(final String data) {
        if (data != null) {
            Log.i(TAG, "displayDataCAD: " + data);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView tview12 = (TextView) findViewById(R.id.TextView12);
                    tview12.setText(data);
                }
            });
        }
    }

    private void displayDataDISTANCE(final String data) {
        if (data != null) {
            Log.i(TAG, "displayDataDISTANCE: " + data);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView tview13 = (TextView) findViewById(R.id.TextView13);
                    tview13.setText(data);
                }
            });
        }
    }

    private void displayDataDISCONNECTED(final String nameOfDisconnectedDevice) {
        if (nameOfDisconnectedDevice != null) {
            Log.i(TAG, "displayDataDISCONNECTED: name:  " + nameOfDisconnectedDevice);
        }
    }

    //END SERVICE MANAGEMENT


    private TextView mTextMessage;
    private Button btn0;
    private Button btn1;
    private Button btn2;
//    private TextView tview10;
//    private TextView tview11;
//    private TextView tview12;

    ListView listView ;

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


    private Storage storage = new Storage();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTextMessage = (TextView) findViewById(R.id.message);
        btn0 = (Button) findViewById(R.id.button0);
        btn1 = (Button) findViewById(R.id.button1);
        btn2 = (Button) findViewById(R.id.button2);


        btn0.setText("SCAN");
        btn1.setText("DISCONNECT");
        btn2.setVisibility(View.GONE);
        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);

        //Log.i(TAG, "onCreate: getSizeOfDevicesDiscovered: " + mBluetoothLeService.getSizeOfDevicesDiscovered());
    }


    private int localCounter = 0;

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbindService(mServiceConnection);
        mBluetoothLeService = null;
    }

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
        //refreshDevicesList();
    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(mGattUpdateReceiver);
    }


    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE_HR);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE_SPD);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE_CAD);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE_DISTANCE);
        return intentFilter;
    }



    //SCAN CALLBACK mScanCallback
    private ArrayList<BluetoothDevice> devicesDiscoveredX = new ArrayList<>();
    private ArrayList<BluetoothDevice> devicesConnectedX = new ArrayList<>();
    private ScanCallback mScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);

            BluetoothDevice deviceDiscovered = result.getDevice();
            if (deviceDiscovered.getName() != null) {
//                if (!devicesDiscovered.contains(deviceDiscovered)) {
//                    devicesDiscovered.add(deviceDiscovered);
//                    Log.i(TAG, "onScanResult: " + deviceDiscovered.getName());
//                    mBluetoothLeService.updateDiscoveredDevices(deviceDiscovered);
//
//                    storage.setDevice(deviceDiscovered);
//                    storage.setDeviceAddress(deviceDiscovered.getAddress());
//                    storage.setStorageCounter();
//                    localCounter += 1;
//                    Log.i(TAG, "onScanResult: localCounter:  " + localCounter);
//
//                }

                if (!mBluetoothLeService.getDevicesDiscovered().contains(deviceDiscovered)) {
                    //THIS MAY NOT WORK, MAY NEED TO DO THE SEARCH IN THE SERVICE...
                    mBluetoothLeService.addDeviceDiscovered(deviceDiscovered);
                    Log.i(TAG, "onScanResult: " + deviceDiscovered.getName());
                    //mBluetoothLeService.updateDiscoveredDevices(deviceDiscovered);
                    localCounter += 1;
                    Log.i(TAG, "onScanResult: localCounter:  " + localCounter);

                }
            }
            Log.i(TAG, "onScanResult: getSizeOfDevicesDiscovered:  " + mBluetoothLeService.getSizeOfDevicesDiscovered());
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
    //END SCAN CB

    private BluetoothGatt mGatt0;
    private BluetoothGatt mGatt1;
    private BluetoothGatt mGatt2;
    private BluetoothGatt mGatt3;
    private BluetoothGatt mGatt4;
    private BluetoothGatt mGatt5;


//    //GATT CALLBACK  mBluetoothGattCallback0
//    private BluetoothGattCallback mBluetoothGattCallback0 = new BluetoothGattCallback() {
//        @Override
//        public void onPhyUpdate(BluetoothGatt gatt, int txPhy, int rxPhy, int status) {
//            super.onPhyUpdate(gatt, txPhy, rxPhy, status);
//        }
//
//        @Override
//        public void onPhyRead(BluetoothGatt gatt, int txPhy, int rxPhy, int status) {
//            super.onPhyRead(gatt, txPhy, rxPhy, status);
//        }
//
//        @Override
//        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//            super.onConnectionStateChange(gatt, status, newState);
//            Log.i(TAG, "onConnectionStateChange: gatt:  " + gatt.getDevice().getName());
//            switch (status) {
//                case BluetoothGatt.GATT_SUCCESS: {
//                    Log.i(TAG, "onConnectionStateChange: GATT_SUCCESS  " + gatt.getDevice().getName());
//                    break;
//                }
//                case BluetoothGatt.GATT_FAILURE: {
//                    Log.i(TAG, "onConnectionStateChange: GATT_FAILURE  " + gatt.getDevice().getName());
//                    break;
//                }
//                default:
//                    Log.i(TAG, "onConnectionStateChange: NOT SUCCESS OR FAILURE  " + gatt.getDevice().getName());
//            }
//
//            switch (newState) {
//                case BluetoothAdapter.STATE_CONNECTED: {
//                    Log.i(TAG, "onConnectionStateChange: STATE CONNECTED, DISCOVER SERVICES: " + gatt.getDevice().getName());
//                    gatt.discoverServices();
//                    break;
//                }
//                case BluetoothAdapter.STATE_CONNECTING: {
//                    Log.i(TAG, "onConnectionStateChange: STATE CONNECTING:  " + gatt.getDevice().getName());
//                    break;
//                }
//                case BluetoothAdapter.STATE_DISCONNECTED: {
//                    Log.i(TAG, "onConnectionStateChange: STATE DISCONNECTED:  " + gatt.getDevice().getName());
//                    closeSpecificGatt(gatt.getDevice());
//                    removeFromDeviceList(gatt.getDevice());
//                    break;
//                }
//
//            }
//
//        }
//
//        private void closeSpecificGatt(BluetoothDevice bluetoothDevice) {
//            Log.i(TAG, "close gatt after disconnection & try to reconnect");
//            if (mGatt0 == null) {
//                Log.i(TAG, "closeSpecificGatt & try to reconnect: no gatt0");
//            } else {
//                if (mGatt0.getDevice() != null && bluetoothDevice == mGatt0.getDevice()) {
//                    Log.i(TAG, "close: mGatt0");
//                    bluetoothDevice.connectGatt(MainActivity.this, false, mBluetoothGattCallback0);
//                    mGatt0.close();
//                    //mGatt0 = null;
//                }
//            }
//
//            if (mGatt1 == null) {
//                Log.i(TAG, "closeSpecificGatt: no gatt1");
//            } else {
//                if (mGatt1.getDevice() != null && bluetoothDevice == mGatt1.getDevice()) {
//                    Log.i(TAG, "close: mGatt1");
//                    bluetoothDevice.connectGatt(MainActivity.this, false, mBluetoothGattCallback0);
//                    mGatt1.close();
//                    //mGatt1 = null;
//                }
//            }
//
//            if (mGatt2 == null) {
//                Log.i(TAG, "closeSpecificGatt: no gatt2");
//            } else {
//                if (mGatt2.getDevice() != null && bluetoothDevice == mGatt2.getDevice()) {
//                    Log.i(TAG, "close: mGatt2");
//                    bluetoothDevice.connectGatt(MainActivity.this, false, mBluetoothGattCallback0);
//                    mGatt2.close();
//                    //mGatt2 = null;
//                }
//            }
//
//            if (mGatt3 == null) {
//                Log.i(TAG, "closeSpecificGatt: no mGatt3");
//            } else {
//                if (mGatt3.getDevice() != null && bluetoothDevice == mGatt3.getDevice()) {
//                    Log.i(TAG, "close: mGatt3");
//                    bluetoothDevice.connectGatt(MainActivity.this, false, mBluetoothGattCallback0);
//                    mGatt3.close();
//                }
//            }
//
//            if (mGatt4 == null) {
//                Log.i(TAG, "closeSpecificGatt: no mGatt4");
//            } else {
//                if (mGatt4.getDevice() != null && bluetoothDevice == mGatt4.getDevice()) {
//                    Log.i(TAG, "close: mGatt4");
//                    bluetoothDevice.connectGatt(MainActivity.this, false, mBluetoothGattCallback0);
//                    mGatt4.close();
//                }
//            }
//
//            if (mGatt5 == null) {
//                Log.i(TAG, "closeSpecificGatt: no gatt5");
//            } else {
//                if (mGatt5.getDevice() != null && bluetoothDevice == mGatt5.getDevice()) {
//                    Log.i(TAG, "close: mGatt5");
//                    bluetoothDevice.connectGatt(MainActivity.this, false, mBluetoothGattCallback0);
//                    mGatt5.close();
//                }
//            }
//
//        }
//
//        private void removeFromDeviceList(BluetoothDevice bluetoothDevice) {
//            Log.i(TAG, "removeFromDeviceList: size before: " + devicesDiscovered.size());
//            for (BluetoothDevice i : devicesDiscovered) {
//                if (i == bluetoothDevice) {
//
//                    devicesDiscovered.remove(i);
//                    Log.i(TAG, "removeFromDeviceList: size after: " + devicesDiscovered.size());
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            refreshDevicesList();
//                        }
//                    });
//
//
//
//                }
//
//            }
//
//        }
//
//
//        private Boolean tryVelo = false;
//        @Override
//        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//            super.onServicesDiscovered(gatt, status);
//
//            //CHECK TO SEE IF DEVICE IS ALREADY IN LIST BEFORE ADDING
//            devicesConnected.add(gatt.getDevice());
//
//            runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
//                    btn0.setText("SCAN");
//                }
//            });
//
//            Boolean hasHR = false;
//            Boolean hasCSC = false;
//
//            Log.i(TAG, "onServicesDiscovered");
//            List<BluetoothGattService> services = gatt.getServices();
//            for (BluetoothGattService service : services) {
//                if (service.getUuid().equals(HR_SERVICE_UUID)) {
//                    hasHR = true;
//                    BluetoothGattCharacteristic valueCharacteristic = gatt.getService(HR_SERVICE_UUID).getCharacteristic(HR_CHARACTERISTIC_UUID);
//                    boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
//                    Log.i(TAG, "registered for HR updates " + (notificationSet ? "successfully" : "unsuccessfully"));
//                    BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
//                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
//                    boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
//                    Log.i(TAG, "wrote Descriptor for HR updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
//                }
//                if (service.getUuid().equals(CSC_SERVICE_UUID)) {
//                    hasCSC = true;
//                    if (hasHR) {
//                        Log.i(TAG, "onServicesDiscovered: IS A VELO");
//                        if (!tryVelo) {
//                            tryVelo = true;
//                        }
//                    }
//                    BluetoothGattCharacteristic valueCharacteristic = gatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_CHARACTERISTIC_UUID);
//                    boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
//                    Log.i(TAG, "registered for CSC updates " + (notificationSet ? "successfully" : "unsuccessfully"));
//                    BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
//                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
//                    boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
//                    Log.i(TAG, "wrote Descriptor for CSC updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
//                }
//            }
//        }
//
//        @Override
//        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//            super.onCharacteristicRead(gatt, characteristic, status);
//        }
//
//        @Override
//        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//            super.onCharacteristicWrite(gatt, characteristic, status);
//        }
//
//
//
//        @Override
//        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//            super.onCharacteristicChanged(gatt, characteristic);
//            Log.i(TAG, "onCharacteristicChanged");
//            //byte[] value = characteristic.getValue();
//
//
//            if (HR_CHARACTERISTIC_UUID.equals(characteristic.getUuid())) {
//                Log.i(TAG, "onCharacteristicChanged: HR: " + gatt.getDevice().getAddress());
//                getHeartrateValue(characteristic);
//
//                if (tryVelo) {
//                    tryVelo = false;
//                    Log.i(TAG, "onCharacteristicChanged: TRYING VELO...SET NOTIFY");
//                    BluetoothGattCharacteristic valueCharacteristic = gatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_CHARACTERISTIC_UUID);
//                    boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
//                    Log.i(TAG, "registered for VELO CSC updates " + (notificationSet ? "successfully" : "unsuccessfully"));
//                    BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
//                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
//                    boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
//                    Log.i(TAG, "wrote Descriptor for VELO CSC updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
//                }
//
//            }
//            if (CSC_CHARACTERISTIC_UUID.equals(characteristic.getUuid())) {
//                Log.i(TAG, "onCharacteristicChanged: CSC" + gatt.getDevice().getAddress());
//                getSpeedCadenceValue(characteristic);
//            }
//            connectingState = 0;
//        }
//
//        @Override
//        public void onDescriptorRead(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
//            super.onDescriptorRead(gatt, descriptor, status);
//        }
//
//        @Override
//        public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
//            super.onDescriptorWrite(gatt, descriptor, status);
//        }
//
//        @Override
//        public void onReliableWriteCompleted(BluetoothGatt gatt, int status) {
//            super.onReliableWriteCompleted(gatt, status);
//        }
//
//        @Override
//        public void onReadRemoteRssi(BluetoothGatt gatt, int rssi, int status) {
//            super.onReadRemoteRssi(gatt, rssi, status);
//        }
//
//        @Override
//        public void onMtuChanged(BluetoothGatt gatt, int mtu, int status) {
//            super.onMtuChanged(gatt, mtu, status);
//        }
//    };
//    //GATT CALLBACK END


//    private void getHeartrateValue(BluetoothGattCharacteristic characteristic) {
//        Log.i(TAG, "getHeartrateValue: ");
//        final int flag = characteristic.getValue()[0]; // 1 byte
//        int format;
//        if ((flag & 0x01) != 0) {
//            format = BluetoothGattCharacteristic.FORMAT_UINT16;
//        } else {
//            format = BluetoothGattCharacteristic.FORMAT_UINT8;
//        }
//        final int hrValue = characteristic.getIntValue(format, 1);
//        Log.i(TAG, "getHeartrateValue: HR Value: " + hrValue);
//
//        @SuppressLint("DefaultLocale") final String hrString = String.format("%d H", hrValue);
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                TextView tview10 = (TextView) findViewById(R.id.TextView10);
//                tview10.setText(hrString);
//            }
//        });
//
//
//    }

//    final byte WHEEL_REVOLUTIONS_DATA_PRESENT = 0x01; // 1 bit
//    final byte CRANK_REVOLUTION_DATA_PRESENT = 0x02; // 1 bit
//    private void getSpeedCadenceValue(BluetoothGattCharacteristic characteristic) {
//        Log.i(TAG, "getSpeedCadenceValue: ");
//        byte[] value = characteristic.getValue();
//        final int flags = characteristic.getValue()[0]; // 1 byte
//        final boolean wheelRevPresent = (flags & WHEEL_REVOLUTIONS_DATA_PRESENT) > 0;
//        final boolean crankRevPresent = (flags & CRANK_REVOLUTION_DATA_PRESENT) > 0;
//
//        if (wheelRevPresent) {
//            final int cumulativeWheelRevolutions = (value[1] & 0xff) | ((value[2] & 0xff) << 8);
//            final int lastWheelEventReadValue = (value[5] & 0xff) | ((value[6] & 0xff) << 8);
//            //Log.i(TAG, "getSpeedValue: Wheel = " + cumulativeWheelRevolutions + "  lastWheelEventReadValue = " + lastWheelEventReadValue);
//
//            onWheelMeasurementReceived(cumulativeWheelRevolutions, lastWheelEventReadValue);
//
//
//            if (crankRevPresent) {
//                final int cumulativeCrankRevolutions = (value[7] & 0xff) | ((value[8] & 0xff) << 8);
//                final int lastCrankEventReadValue = (value[9] & 0xff) | ((value[10] & 0xff) << 8);
//                Log.i(TAG, "getCandeceValue, revs, time:  " + cumulativeCrankRevolutions + ", " + lastCrankEventReadValue);
//
//                onCrankMeasurementReceived(cumulativeCrankRevolutions, lastCrankEventReadValue);
//
//            }
//        } else {
//            if (crankRevPresent) {
//                final int cumulativeCrankRevolutions = (value[1] & 0xff) | ((value[2] & 0xff) << 8);
//                final int lastCrankEventReadValue = (value[3] & 0xff) | ((value[4] & 0xff) << 8);
//                //Log.i(TAG, "getCandeceValue, revs, time:  " + cumulativeCrankRevolutions + ", " + lastCrankEventReadValue);
//
//                onCrankMeasurementReceived(cumulativeCrankRevolutions, lastCrankEventReadValue);
//
//            }
//        }
//
//
//    }

    private void connectToBtDevice(Integer indexValue, BluetoothDevice indexDevice, String indexDeviceAddress) {

        //mGatt0 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        if (indexValue == 0) {
//            mGatt0 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        }
//        if (indexValue == 1) {
//            mGatt1 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        }
//        if (indexValue == 2) {
//            mGatt2 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        }
//        if (indexValue == 3) {
//            mGatt3 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        }
//        if (indexValue == 4) {
//            mGatt4 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        }
//        if (indexValue == 5) {
//            mGatt5 = indexDevice.connectGatt(this, false, mBluetoothGattCallback0);
//        }

        //devicesConnected.add(indexDevice);
//        mBluetoothLeService.addDeviceConnected(indexDevice);
        mBluetoothLeService.connectToBtDevice(indexValue, indexDeviceAddress);
        //btn0.setText(".....");

    }

    Integer connectingState = 0;
    Integer counter = 0;

//    private void connectToBtDevices() {
//        Log.i(TAG, "connectToBtDevices");
//        Log.i(TAG, "connectToBtDevices: counter value:  " + counter);
//        Log.i(TAG, "connectToBtDevices: deviceDiscovered size:  " + devicesDiscovered.size());
//
//        refreshDevicesList();
////        String devName;
////        String devMacAddress;
//
//
//        if (counter >= devicesDiscovered.size()) {
//            Log.i(TAG, "connectToBtDevices, counter is >= devicesDiscovered.size, so exit and reset counter to 0, we already processed the list so scan again");
//            counter = 0;
//            return;
//        }
//
//
//        //NEED TO FIND OUT IF ALREADY CONNECTED
//        if (devicesConnected.contains(devicesDiscovered.get(counter))) {
//            Log.i(TAG, "connectToBtDevices: Already connected, so increase counter and return");
//            counter += 1;
//            return;
//        }
//
//
//        Log.i(TAG, "Should I connect to:  " + devicesDiscovered.get(counter).getName() + "  devAddress:  " + devicesDiscovered.get(counter).getAddress());
//        connectingState = 1;
////        devName = devicesDiscovered.get(counter).getName();
////        devMacAddress = devicesDiscovered.get(counter).getAddress();
//
//        AlertDialog.Builder builder = new AlertDialog.Builder(this);
//        final Integer finalCounter = counter;
//        builder.setMessage("CONNECT TO:  " + devicesDiscovered.get(counter).getName())
//                .setCancelable(false)
//                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
//                    public void onClick(DialogInterface dialog, int id) {
//                        Log.i(TAG, "connectToBtDevice:  " + finalCounter);
//                        //btn0.setText("....");
//                        connectToBtDevice(finalCounter, devicesDiscovered.get(finalCounter), devicesDiscovered.get(finalCounter).getAddress());
//
//                    }
//                })
//                .setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
//                    public void onClick(DialogInterface dialog, int id) {
//                        Log.i(TAG, "DO NOT CONNECT");
//                        connectingState = 0;
//                    }
//                });
//        AlertDialog alert = builder.create();
//        alert.show();
//
//        counter += 1;
//        //}
//    }




    public void onClick_0(View view) {
        Log.i(TAG, "onClick_0:  SCANNING");
        //btn0.setText("....");
//        Log.i(TAG, "onClick_0: counter value:  " + counter);
//        Log.i(TAG, "onClick_0: deviceDiscovered size:  " + devicesDiscovered.size());
//        if (counter > 0 && counter < devicesDiscovered.size()) {
//            connectToBtDevices();
//            Log.i(TAG, "counter > 0 && counter < devicesDiscovered, so tconnectToBtDevices() and return");
//            return;
//        }

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
            builder.setMessage("Please grant location access so this app can detect peripherals.");
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
            ScanFilter scanFilter2 = new ScanFilter.Builder()
                    .setServiceUuid(ParcelUuid.fromString("00001816-0000-1000-8000-00805f9b34fb"))
                    .build();
            filters.add(scanFilter2);

            //START SCAN
            Log.i(TAG, "START SCANNING");
            mLEScanner.startScan(filters, settings, mScanCallback);
            Handler mHandler = new Handler();
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mLEScanner.stopScan(mScanCallback);
                    Log.i(TAG, "run: STOP SCANNING");
                    if (mBluetoothLeService.getSizeOfDevicesDiscovered() > 0) {
                        Log.i(TAG, "devicesDiscovered.size = " + mBluetoothLeService.getSizeOfDevicesDiscovered());
                        //NOW...PROCESS THE LIST, START WITH THE FIRST
                        //btn0.setText("CONNECT");
                        //connectToBtDevices();
                        refreshDevicesList();
                    } else {
                        Log.i(TAG, "NO DEVICES DISCOVERED");
                        btn0.setText("SCAN");
                    }

                }
            }, SCAN_PERIOD);

        }

    }

//    private void close() {
//        Log.i(TAG, "close");
//        if (mGatt0 != null) {
//            Log.i(TAG, "close: mGatt0");
//            mGatt0.close();
//            mGatt0 = null;
//        }
//        if (mGatt1 != null) {
//            Log.i(TAG, "close: mGatt1");
//            mGatt1.close();
//            mGatt1 = null;
//        }
//        if (mGatt2 != null) {
//            Log.i(TAG, "close: mGatt2");
//            mGatt2.close();
//            mGatt2 = null;
//        }
//        if (mGatt3 != null) {
//            Log.i(TAG, "close: mGatt3");
//            mGatt3.close();
//            mGatt3 = null;
//        }
//        if (mGatt4 != null) {
//            Log.i(TAG, "close: mGatt4");
//            mGatt4.close();
//            mGatt4 = null;
//        }
//        if (mGatt5 != null) {
//            Log.i(TAG, "close: mGatt5");
//            mGatt5.close();
//            mGatt5 = null;
//        }
//        devicesDiscovered = new ArrayList<>();
//        devicesConnected = new ArrayList<>();
//        counter = 0;
//        btn0.setText("SCAN");
//        refreshDevicesList();
//
//    }

    public void onClick_1(View view) {
        Log.i(TAG, "onClick_1");
        //close();
        mBluetoothLeService.close();
    }



    public ArrayList<String> devicesDiscoveredFromMainActivityNames = new ArrayList<String>();
    public void refreshDevicesList() {

        Log.i(TAG, "refreshDevicesList");
        devicesDiscoveredFromMainActivityNames = new ArrayList<>();
//        if (devicesDiscovered.size() == 0 ) {
//            Log.i(TAG, "refreshDevicesList: Nothing in Devices Discovered, Try Service");
//            if (mBluetoothLeService.getDevicesDiscovered() != null ) {
//                Log.i(TAG, "refreshDevicesList from service, size is: " + mBluetoothLeService.getDevicesDiscovered().size());
//                devicesDiscovered = mBluetoothLeService.getDevicesDiscovered();
//            }
//        }

        String y;
        Integer arrCounter = 0;
//        for (BluetoothDevice i : devicesDiscovered) {
//            y = (i.getName() + " : " +i.getAddress());
//            Log.i(TAG, "refreshDevicesList: y:  " + y);
//            devicesDiscoveredFromMainActivityNames.add(y);
//            arrCounter += 1;
//        }

//        if (mBluetoothLeService.getSizeOfDevicesDiscovered() == 0) {
//            Log.i(TAG, "refreshDevicesList: no devicesDiscovered, return");
//            return;
//        }



        for (BluetoothDevice i : mBluetoothLeService.getDevicesDiscovered()) {
            y = (i.getName() + " : " +i.getAddress());
            Log.i(TAG, "refreshDevicesList: y:  " + y);
            devicesDiscoveredFromMainActivityNames.add(y);
            arrCounter += 1;
        }

        Log.i(TAG, "refreshDevicesList: devicesDiscoveredFromMainActivityNames  " + devicesDiscoveredFromMainActivityNames.size());
        
        listView = findViewById(R.id.list0);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, android.R.id.text1, devicesDiscoveredFromMainActivityNames);
        listView.setAdapter(adapter);

        // ListView Item Click Listener
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {

                // ListView Clicked item index
                int itemPosition = position;

                // ListView Clicked item value
                String  itemValue = (String) listView.getItemAtPosition(position);

                //THIS IS WHAT IS CONTROLLING THINGS
//                if (devicesConnected.contains(devicesDiscovered.get(itemPosition))) {
//                    Log.i(TAG, "connectToBtDevices: Already connected, so do nothing");
//                    return;
//                }



                if (mBluetoothLeService.getDevicesConnected().contains(mBluetoothLeService.getDevicesDiscovered().get(itemPosition))) {
                    Log.i(TAG, "onItemClick: mBluetoothLeService.getSizeOfDevicesConnected():  " + mBluetoothLeService.getSizeOfDevicesConnected());
                    Log.i(TAG, "connectToBtDevices: Already connected, so do nothing");
                    return;
                }

                // Show Alert
                Toast.makeText(getApplicationContext(),
                        "Position :"+itemPosition+"  ListItem : " +itemValue , Toast.LENGTH_LONG)
                        .show();

//                connectToBtDevice(itemPosition, devicesDiscovered.get(itemPosition), devicesDiscovered.get(itemPosition).getAddress());
                connectToBtDevice(itemPosition, mBluetoothLeService.getDevicesDiscovered().get(itemPosition), mBluetoothLeService.getDevicesDiscovered().get(itemPosition).getAddress());
            }
        });
    }

//    public void onClick_2(View view) {
//        Log.i(TAG, "onClick_2");
//        refreshDevicesList();
//    }




    private int mFirstWheelRevolutions = -1;
    private int mLastWheelRevolutions = -1;
    private int mLastWheelEventTime = -1;
    private int mFirstCrankRevolutions = -1;
    private int mLastCrankRevolutions = -1;
    private int mLastCrankEventTime = -1;

    private double totalWheelRevolutions = 0;
    private double totalTimeInSeconds = 0;


    public void onWheelMeasurementReceived(final int wheelRevolutionValue, final int wheelRevolutionTimeValue) {


//        final int circumference = Integer.parseInt(preferences.getString(SettingsFragment.SETTINGS_WHEEL_SIZE, String.valueOf(SettingsFragment.SETTINGS_WHEEL_SIZE_DEFAULT))); // [mm]
        final int circumference = 2155; // [mm]

        if (mFirstWheelRevolutions < 0) {
            mFirstWheelRevolutions = wheelRevolutionValue;
            mLastWheelRevolutions = wheelRevolutionValue;
            mLastWheelEventTime = wheelRevolutionTimeValue;
            return;
        }

        if (mLastWheelEventTime == wheelRevolutionTimeValue) {
            return;
        }


        final int timeDiff = do16BitDiff(wheelRevolutionTimeValue, mLastWheelEventTime);
        final int wheelDiff = do16BitDiff(wheelRevolutionValue, mLastWheelRevolutions);

        if (wheelDiff == 0 || wheelDiff > 35) {
            mLastWheelRevolutions = wheelRevolutionValue;
            mLastWheelEventTime = wheelRevolutionTimeValue;
            return;
        }

        if (timeDiff < 1000) {
            //LET'S NOT PROCESS SO MANY, IGNORE EVERY OTHER ONE?
            return;
        }

        if (timeDiff > 30000) {
            mLastWheelRevolutions = wheelRevolutionValue;
            mLastWheelEventTime = wheelRevolutionTimeValue;
            return;
        }


        totalWheelRevolutions += (double) wheelDiff;
        totalTimeInSeconds += (double) timeDiff / 1024.0;

        mLastWheelRevolutions = wheelRevolutionValue;
        mLastWheelEventTime = wheelRevolutionTimeValue;

        final double wheelTimeInSeconds = timeDiff / 1024.0;
        final double wheelCircumference = (double) circumference;
        final double wheelCircumferenceCM = wheelCircumference / 10;
        final double wheelRPM = (double) wheelDiff / (wheelTimeInSeconds / 60.0);
        final double cmPerMi = 0.00001 * 0.621371;
        final double minsPerHour = 60.0;
        final double speed = wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour;  //MPH CURRENT
        final double totalDistance = totalWheelRevolutions * wheelCircumferenceCM * cmPerMi;

        final double btAvgSpeed = totalDistance / (totalTimeInSeconds / 60.0 / 60.0);
        Log.d(TAG, "onWheelMeasurementReceived: btAvgSpeed = " + String.format("%.1f Avg Speed", btAvgSpeed));

            @SuppressLint("DefaultLocale") final String spdString = String.format("%.2f S", speed);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView tview11 = findViewById(R.id.TextView11);
                    tview11.setText(spdString);
                }
            });

    }  //END WHEEL CALC

    public void onCrankMeasurementReceived(final int crankRevolutionValue, final int crankRevolutionTimeValue) {

        if (mFirstCrankRevolutions < 0) {
            mFirstCrankRevolutions = crankRevolutionValue;
            mLastCrankRevolutions = crankRevolutionValue;
            mLastCrankEventTime = crankRevolutionTimeValue;
            return;
        }

        if (mLastCrankEventTime == crankRevolutionTimeValue) {
            return;
        }


        final int timeDiff = do16BitDiff(crankRevolutionTimeValue, mLastCrankEventTime);
        final int crankDiff = do16BitDiff(crankRevolutionValue, mLastCrankRevolutions);

        if (crankDiff == 0) {
            mLastCrankRevolutions = crankRevolutionValue;
            mLastCrankEventTime = crankRevolutionTimeValue;
            return;
        }

        if (timeDiff < 2000) {
            return;
        }

        if (timeDiff > 30000) {
            mLastCrankRevolutions = crankRevolutionValue;
            mLastCrankEventTime = crankRevolutionTimeValue;
            return;
        }


        ////Log.i("CAD", "onWheelMeasurementReceived: crankDiff, timeDiff: " + crankDiff + ", " + timeDiff);
        final double cadence = (double) crankDiff / ((((double) timeDiff) / 1024.0) / 60);
        if (cadence == 0) {
            return;
        }
        if (cadence > 150) {
            return;
        }


        @SuppressLint("DefaultLocale") final String cadString = String.format("%.1f C", cadence);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView tview12 = findViewById(R.id.TextView12);
                tview12.setText(cadString);
            }
        });

    }
    //END CAD CALC

    private int do16BitDiff(int a, int b) {
        if (a >= b)
            return a - b;
        else
            return (a + 65536) - b;
    }

//    public String getTimeStringFromMilli(long totalMilliseconds) {
//        return String.format(Locale.US,"%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(totalMilliseconds),
//                TimeUnit.MILLISECONDS.toMinutes(totalMilliseconds) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(totalMilliseconds)),
//                TimeUnit.MILLISECONDS.toSeconds(totalMilliseconds) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(totalMilliseconds)));
//    }









}

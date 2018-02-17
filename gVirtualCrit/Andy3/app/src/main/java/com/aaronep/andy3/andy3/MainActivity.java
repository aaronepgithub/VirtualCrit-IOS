package com.aaronep.andy3.andy3;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.ParcelUuid;
import android.os.Parcelable;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
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
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.UUID;


import static android.widget.Toast.LENGTH_SHORT;

public class MainActivity extends AppCompatActivity {

    private BluetoothAdapter mBluetoothAdapter;

    private ArrayList arrayListFoundDevices = new ArrayList();

    private Button btn1;
    private Button btn2;
    private Button btn3;
    public TextView tView1;
    public TextView tView2;
    public TextView tView3;


    private UUID HEART_RATE_SERVICE_UUID = convertFromInteger(0x180D);
    private UUID HEART_RATE_MEASUREMENT_CHAR_UUID = convertFromInteger(0x2A37);
    //private UUID HEART_RATE_CONTROL_POINT_CHAR_UUID = convertFromInteger(0x2A39);

    private UUID CSC_SERVICE_UUID = convertFromInteger(0x1816);
    private UUID CSC_MEASUREMENT_CHAR_UUID = convertFromInteger(0x2A5B);
    //private UUID CSC_CONTROL_POINT_CHAR_UUID = convertFromInteger(0x2A39);


    private UUID CLIENT_CHARACTERISTIC_CONFIG_UUID = convertFromInteger(0x2902);


    public UUID convertFromInteger(int i) {
        final long MSB = 0x0000000000001000L;
        final long LSB = 0x800000805f9b34fbL;
        long value = i & 0xFFFFFFFF;
        return new UUID(MSB | (value << 32), LSB);
    }

    public void mLog(String t, String s) {
        Log.i(t, s);
    }


    //private BluetoothAdapter mBluetoothAdapter;
    private int REQUEST_ENABLE_BT = 1;
    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;
    private Handler mHandler;
    private static final long SCAN_PERIOD = 5000;
    private BluetoothLeScanner mLEScanner;
    private ScanSettings settings;
    private List<ScanFilter> filters;
    private BluetoothGatt mGatt;
    private BluetoothDevice mDevice;

    // setup UI handler
    private final static int UPDATE_DEVICE = 0;
    private final static int UPDATE_VALUE = 1;
    private final static int UPDATE_CSC = 2;

    @SuppressLint("HandlerLeak")
    private final Handler uiHandler = new Handler() {
        public void handleMessage(Message msg) {
            final int what = msg.what;
            final String value = (String) msg.obj;
            switch(what) {
//                case UPDATE_DEVICE: updateDevice(value); break;
                case UPDATE_VALUE: updateValue(value); break;
                case UPDATE_CSC: updateValueCSC(value); break;
            }
        }
    };

//    private void updateDevice(String devName){
//        TextView t= findViewById(R.id.dev_type);
//        t.setText(devName);
//    }

    private void updateValue(String value){
        TextView t= findViewById(R.id.tView1);
        t.setText(value);
    }
    private void updateValueCSC(String value){
        TextView t= findViewById(R.id.tView2);
        t.setText(value);
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);



        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        if (bluetoothManager != null) {
            mBluetoothAdapter = bluetoothManager.getAdapter();
        }

        if (mBluetoothAdapter != null && !mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        }

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



        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "SCANNING...", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();

                scanLeDevice(true);

            }
        });

        mHandler = new Handler();
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(this, "BLE Not Supported",
                    Toast.LENGTH_SHORT).show();
            finish();
        }

    }
    //end onCreate


    @Override
    protected void onResume() {
        super.onResume();
        if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        } else {
            mLEScanner = mBluetoothAdapter.getBluetoothLeScanner();
            settings = new ScanSettings.Builder()
                    .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                    .build();
            filters = new ArrayList<>();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mBluetoothAdapter != null && mBluetoothAdapter.isEnabled()) {
            scanLeDevice(false);
        }
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

    private void scanLeDevice(final boolean enable) {
        if (enable) {
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mLEScanner.stopScan(mScanCallback);

                }
            }, SCAN_PERIOD);
            mLEScanner.startScan(filters, settings, mScanCallback);
        } else {
            mLEScanner.stopScan(mScanCallback);
        }
    }

    private Boolean isAutoConnected = false;
    private ArrayList<BluetoothDevice> devicesDiscovered = new ArrayList<>();
    private ArrayList<String> namesDiscovered = new ArrayList<>();
    private ArrayList<String> addressesDiscovered = new ArrayList<>();
    private ScanCallback mScanCallback;
    private Integer deviceIndexVal = 0;

    {
        mScanCallback = new ScanCallback() {
            @Override
            public void onScanResult(int callbackType, ScanResult result) {

//                Log.i("mScanCallback", "Name:  " + result.getDevice().getName());
//                Log.i("mScanCallback", "Address:  " + result.getDevice().getAddress());
//                Log.i("onScanResult", "onScanResult");
//                Log.i("mScanCallback", "onScanResult");
//                Log.i("callbackType", String.valueOf(callbackType));

//                if (result.getScanRecord().getServiceUuids() != null) {
//                    Log.i("SvcData - All", "UUID " + result.getScanRecord().getServiceUuids().toString());
//                    List<String> svcs = new ArrayList<>();
//                    svcs.add(result.getScanRecord().getServiceUuids().toString());
//                    for (String svc : svcs) {
//                        List<String> indivServices = new ArrayList<String>();
//                        Log.i("Svc", "svc: " + svc);
//                        //mLog("UUIDs to String", "HR:  " + HEART_RATE_SERVICE_UUID.toString());
//                        String x = "[" + HEART_RATE_SERVICE_UUID.toString() + "]";
//                        String y = "[" + CSC_SERVICE_UUID.toString() + "]";
//                        if (Objects.equals(svc, x)) {
//                            mLog(" is HR", "Yes");
//                            BluetoothDevice btDevice = result.getDevice();
//                            Log.i("btDevice", "Device.getName: " + btDevice.getName());
//                            Log.i("btDevice", "ConnectToDevice...");
//
//                            if (isAutoConnected == false) {
//                                connectToDevice(btDevice);
//                                isAutoConnected = true;
//                            }
//                            //testing - auto connect to hr device
//                            //only 1 at a time
//
//                        }
//                        if (Objects.equals(svc, y)) {
//                            mLog(" is CSC", "Yes");
//                        }
//                    }
//                }




                if (result.getDevice().getName() != null) {

                    BluetoothDevice deviceDiscovered = result.getDevice();
                    String deviceName = result.getDevice().getName();
                    String deviceAddress = result.getDevice().getAddress();

                    if (!addressesDiscovered.contains(deviceAddress)) {

                        devicesDiscovered.add(deviceDiscovered);
                        addressesDiscovered.add(deviceAddress);
                        namesDiscovered.add(deviceName);

                        Log.i("deviceIndexVal", "deviceIndexVal  " + deviceIndexVal);
                        Log.i("result", "NAME  " + result.getDevice().getName());
                        Log.i("result", "ADDRESS  " + result.getDevice().getAddress());
                        Log.i("result", "getDevice.toString  " + result.getDevice().toString());
                        //Log.i("result", String.format("getDevice.ScanRecord  %s", result.getScanRecord().getServiceData().toString()));

                        btn1 = findViewById(R.id.btn1);
                        btn2 = findViewById(R.id.btn2);
                        btn3 = findViewById(R.id.btn3);

                        if (deviceIndexVal == 0) {
                            btn1.setText(deviceName);
                            Log.i("btn1", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 1) {
                            btn2.setText(deviceName);
                            Log.i("btn2", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 2) {
                            btn3.setText(deviceName);
                            Log.i("btn3", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }

                        deviceIndexVal += 1;


                    }  //DUPLICATE, DON'T ADD

                }  //NO NAME, DON'T, ADD

            }




//                    if (!arrayListFoundDevices.contains(result)) {
//                        Log.i("ArrayList", "Add Result");
//                        arrayListFoundDevices.add(result);
//                    } else {
//                        Log.i("ArrayList", "Duplicate");
//                    }
//                    //Log.d("arrList", "arrListFoundDevices:  " + arrayListFoundDevices);
//                    mLog("mLog ArrayList", result.toString());

//testing filter / auto connect
//                if (devicename.startsWith("Bl")){
//                    Log.i("mScanCallback", "Device name: "+devicename);
//                    Log.i("result", result.toString());
//                    //GET UUIDS (ALREADY IN RESULT.STRING) TO DETERMINE IF HR OR CSC)
//                    BluetoothDevice btDevice = result.getDevice();
//                    Log.i("btDevice", "Device.getName: "+ btDevice.getName());
//                    Log.i("btDevice", "ConnectToDevice...");
//                    connectToDevice(btDevice);
//                }




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

//    private BluetoothAdapter.LeScanCallback mLeScanCallback =
//            new BluetoothAdapter.LeScanCallback() {
//
//                @Override
//                public void onLeScan(final BluetoothDevice device, int rssi,
//                                     byte[] scanRecord) {
//
//                    Log.i("mLeScanCallback", "onLeScan");
//
//
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            Log.i("onLeScan", device.toString());
//                            connectToDevice(device);
//                        }
//                    });
//                }
//            };

    public void connectToDevice(BluetoothDevice device) {
        Log.i("connectToDevice", "Device: " + device.getName());
        if (mGatt == null) {
            Log.d("connectToDevice", "connecting to device: "+device.toString());
            this.mDevice = device;
            mGatt = device.connectGatt(this, false, gattCallback);
        }
    }

    //same for all char
    protected static final UUID CHARACTERISTIC_UPDATE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");


    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {


        @Override
        public void onConnectionStateChange(BluetoothGatt mGatt, int status, int newState) {
            Log.i("gattCallback", "gattCallback: " + status);
            Log.i("onConnectionStateChange", "Status: " + status);
            switch (newState) {
                case BluetoothProfile.STATE_CONNECTED:
                    Log.i("gattCallback", "STATE_CONNECTED");
                    Log.i("gattCallback", "CONNECTED TO:  " + mGatt.getDevice().getName());

                    //update UI
//                    Message msg = Message.obtain();
//                    String deviceName = mGatt.getDevice().getName();
//                    msg.obj = deviceName;
//                    msg.what = 0;
//                    msg.setTarget(uiHandler);
//                    msg.sendToTarget();

                    Log.i("discoverServices", "discoverServices:  " + mGatt.getDevice().getName());
                    mGatt.discoverServices();
                    break;
                case BluetoothProfile.STATE_DISCONNECTED:
                    Log.i("gattCallback", "STATE_DISCONNECTED " + mGatt.getDevice().getName());
                    Log.i("gattCallback", "reconnecting...");
                    //BluetoothDevice mDevice = mGatt.getDevice();
                    mGatt = null;
                    //connectToDevice(mDevice);
                    break;
                default:
                    Log.i("gattCallback", "STATE_OTHER");
            }

        }

        //private boolean enabled;

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

            BluetoothGattService service = mGatt.getService(serviceUUID);
            Log.i("GATT2", "CALLING  findNotifyCharacteristic, passing (service aka mGatt.getService(serviceUUID),charUUID)");
            BluetoothGattCharacteristic characteristic = findNotifyCharacteristic(service, characteristicUUID);


            if (characteristic != null) {

                if (mGatt.setCharacteristicNotification(characteristic, true)) {

                    // Why doesn't setCharacteristicNotification write the descriptor?
                    BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID);
                    if (descriptor != null) {

                        // prefer notify over indicate
                        if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0) {
                            Log.i("4", "SET NOTIFY  descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)");
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        } else if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0) {
                            Log.i("4", "SET INDICATE  descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE)");
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
                        } else {
                            Log.i("Tag", "OTHER NOTIFY ATTEMPT  Characteristic " + characteristicUUID + " does not have NOTIFY or INDICATE property set");
                        }

                        if (mGatt.writeDescriptor(descriptor)) {
                            success = true;
                            Log.i("Write Success", "Able to set client characteristic notification1");
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


        @Override
        public void onServicesDiscovered(final BluetoothGatt mGatt, int status) {
            //mGatt = gatt;
            List<BluetoothGattService> services = mGatt.getServices();
            Log.i("onServicesDiscovered", services.toString());

            if (services == null) return;



            //determine if HR, then register notify callback AFTER!!!
//            Log.i("ONDISCOVERED1", "CALLING  registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID)");
//            registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
//            mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));


            //read all services
            Log.i("Read Services", "Loop through and read services and chars");
            for (BluetoothGattService service : services) {
                Log.i("BluGattService", "for each uuid = gattService.getUuid().toString(): " + service.getUuid().toString());

                Log.i("onServicesDiscovered: ", "HR?  " + service.getUuid().equals(HEART_RATE_SERVICE_UUID));
                Log.i("onServicesDiscovered: ", "CSC?  " + service.getUuid().equals(CSC_SERVICE_UUID));

                if (service.getUuid().equals(HEART_RATE_SERVICE_UUID)) {
                    Log.i("DISCOVERED HR", "CALLING  registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID)");
                    registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
                    mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));
                }

                if (service.getUuid().equals(CSC_SERVICE_UUID)) {
                    Log.i("DISCOVERED CSC", "CALLING  registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID)");
                    registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID);
                    mGatt.readCharacteristic(mGatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_MEASUREMENT_CHAR_UUID));
                }


//                List<BluetoothGattCharacteristic> characteristics = service.getCharacteristics();
//                for (BluetoothGattCharacteristic characteristic : characteristics) {
//                    Log.i("BlueSvcChar", "service.getChar UUID:  " + characteristic.getUuid());
//                    Log.i("BlueSvcChar", "service.getChar Properties:  " + characteristic.getProperties());
//                }
            }

            //New Loop and Log
            // Loops through available GATT Services.
//            for (BluetoothGattService gattService : services) {
//
//                final String uuid = gattService.getUuid().toString();
//                System.out.println("Service discovered: " + uuid);
////                MainActivity.this.runOnUiThread(new Runnable() {
////                    public void run() {
////                        //peripheralTextView.append("Service Discovered: "+uuid+"\n");
////                        //System.out.println("Service discovered: " + uuid);
////                    }
////                });
//                new ArrayList<HashMap<String, String>>();
//                List<BluetoothGattCharacteristic> gattCharacteristics =
//                        gattService.getCharacteristics();
//
//                // Loops through available Characteristics.
//                for (BluetoothGattCharacteristic gattCharacteristic :
//                        gattCharacteristics) {
//
//                    final String charUuid = gattCharacteristic.getUuid().toString();
//                    System.out.println("Characteristic discovered for service: " + charUuid);
////                    MainActivity.this.runOnUiThread(new Runnable() {
////                        public void run() {
////                            //peripheralTextView.append("Characteristic discovered for service: "+charUuid+"\n");
////                        }
////                    });
//
//                }
//            }




        }


        @Override
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic
                                                 characteristic, int status) {
            Log.i("onCharacteristicRead", characteristic.toString());
            Log.i("onCharacteristicRead", characteristic.getUuid().toString());
        }

        @SuppressLint("DefaultLocale")
        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt,
                                            BluetoothGattCharacteristic
                                                    characteristic) {



            Log.i("onCharacteristicChanged: ", "HR?  " + characteristic.getUuid().equals(HEART_RATE_MEASUREMENT_CHAR_UUID));
            Log.i("onCharacteristicChanged: ", "CSC?  " + characteristic.getUuid().equals(CSC_MEASUREMENT_CHAR_UUID));

            if (characteristic.getUuid().equals(HEART_RATE_MEASUREMENT_CHAR_UUID)) {
                //IF HR...AFTER SETTING NOTIFY ON ALL
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
                final int heartRate = characteristic.getIntValue(format, 1);
                final Integer hrValue = characteristic.getIntValue(format, 1);

                Log.i("HR", String.format("HR: %d", hrValue));
//                intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));
//            String value = String.valueOf(heartRate);
//            Log.i("hrValue.toString", hrValue.toString());
                String value = String.valueOf(String.format("HR: %d", hrValue));
                Message msg = Message.obtain();
                msg.obj = value;
                msg.what = 1;
                msg.setTarget(uiHandler);
                msg.sendToTarget();
            }

            if (characteristic.getUuid().equals(CSC_MEASUREMENT_CHAR_UUID)) {
                //IF CSC...AFTER SETTING NOTIFY ON ALL
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
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


//                intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));

//            String value = String.valueOf(heartRate);
//            Log.i("hrValue.toString", hrValue.toString());



                String value = String.valueOf(String.format("CSC1: %d", csc1value));
                Message msg = Message.obtain();
                msg.obj = value;
                msg.what = 2;
                msg.setTarget(uiHandler);
                msg.sendToTarget();


            }

            //gatt.disconnect();
        }

    };





    //TRY #2

    private final BluetoothGattCallback gattCallback2 = new BluetoothGattCallback() {


        @Override
        public void onConnectionStateChange(BluetoothGatt mGatt, int status, int newState) {
            Log.i("gattCallback", "gattCallback: " + status);
            Log.i("onConnectionStateChange", "Status: " + status);
            switch (newState) {
                case BluetoothProfile.STATE_CONNECTED:
                    Log.i("gattCallback", "STATE_CONNECTED");
                    Log.i("gattCallback", "CONNECTED TO:  " + mGatt.getDevice().getName());

                    //update UI
//                    Message msg = Message.obtain();
//                    String deviceName = mGatt.getDevice().getName();
//                    msg.obj = deviceName;
//                    msg.what = 0;
//                    msg.setTarget(uiHandler);
//                    msg.sendToTarget();

                    Log.i("discoverServices", "discoverServices:  " + mGatt.getDevice().getName());
                    mGatt.discoverServices();
                    break;
                case BluetoothProfile.STATE_DISCONNECTED:
                    Log.i("gattCallback", "STATE_DISCONNECTED " + mGatt.getDevice().getName());
                    Log.i("gattCallback", "reconnecting...");
                    //BluetoothDevice mDevice = mGatt.getDevice();
                    mGatt = null;
                    //connectToDevice(mDevice);
                    break;
                default:
                    Log.i("gattCallback", "STATE_OTHER");
            }

        }

        //private boolean enabled;

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

            BluetoothGattService service = mGatt.getService(serviceUUID);
            Log.i("GATT2", "CALLING  findNotifyCharacteristic, passing (service aka mGatt.getService(serviceUUID),charUUID)");
            BluetoothGattCharacteristic characteristic = findNotifyCharacteristic(service, characteristicUUID);


            if (characteristic != null) {

                if (mGatt.setCharacteristicNotification(characteristic, true)) {

                    // Why doesn't setCharacteristicNotification write the descriptor?
                    BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID);
                    if (descriptor != null) {

                        // prefer notify over indicate
                        if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0) {
                            Log.i("4", "SET NOTIFY  descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)");
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        } else if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0) {
                            Log.i("4", "SET INDICATE  descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE)");
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
                        } else {
                            Log.i("Tag", "OTHER NOTIFY ATTEMPT  Characteristic " + characteristicUUID + " does not have NOTIFY or INDICATE property set");
                        }

                        if (mGatt.writeDescriptor(descriptor)) {
                            success = true;
                            Log.i("Write Success", "Able to set client characteristic notification1");
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


        @Override
        public void onServicesDiscovered(final BluetoothGatt mGatt, int status) {
            //mGatt = gatt;
            List<BluetoothGattService> services = mGatt.getServices();
            Log.i("onServicesDiscovered", services.toString());

            if (services == null) return;



            //determine if HR, then register notify callback AFTER!!!
//            Log.i("ONDISCOVERED1", "CALLING  registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID)");
//            registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
//            mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));


            //read all services
            Log.i("Read Services", "Loop through and read services and chars");
            for (BluetoothGattService service : services) {
                Log.i("BluGattService", "for each uuid = gattService.getUuid().toString(): " + service.getUuid().toString());

                Log.i("onServicesDiscovered: ", "HR?  " + service.getUuid().equals(HEART_RATE_SERVICE_UUID));
                Log.i("onServicesDiscovered: ", "CSC?  " + service.getUuid().equals(CSC_SERVICE_UUID));

                if (service.getUuid().equals(HEART_RATE_SERVICE_UUID)) {
                    Log.i("DISCOVERED HR", "CALLING  registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID)");
                    registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
                    mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));
                }

                if (service.getUuid().equals(CSC_SERVICE_UUID)) {
                    Log.i("DISCOVERED CSC", "CALLING  registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID)");
                    registerNotifyCallback(CSC_SERVICE_UUID, CSC_MEASUREMENT_CHAR_UUID);
                    mGatt.readCharacteristic(mGatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_MEASUREMENT_CHAR_UUID));
                }

        }


        @Override
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic
                                                 characteristic, int status) {
            Log.i("onCharacteristicRead", characteristic.toString());
            Log.i("onCharacteristicRead", characteristic.getUuid().toString());
        }

        @SuppressLint("DefaultLocale")
        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt,
                                            BluetoothGattCharacteristic
                                                    characteristic) {



            Log.i("onCharacteristicChanged: ", "HR?  " + characteristic.getUuid().equals(HEART_RATE_MEASUREMENT_CHAR_UUID));
            Log.i("onCharacteristicChanged: ", "CSC?  " + characteristic.getUuid().equals(CSC_MEASUREMENT_CHAR_UUID));

            if (characteristic.getUuid().equals(HEART_RATE_MEASUREMENT_CHAR_UUID)) {
                //IF HR...AFTER SETTING NOTIFY ON ALL
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
                final int heartRate = characteristic.getIntValue(format, 1);
                final Integer hrValue = characteristic.getIntValue(format, 1);

                Log.i("HR", String.format("HR: %d", hrValue));
//                intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));
//            String value = String.valueOf(heartRate);
//            Log.i("hrValue.toString", hrValue.toString());
                String value = String.valueOf(String.format("HR: %d", hrValue));
                Message msg = Message.obtain();
                msg.obj = value;
                msg.what = 1;
                msg.setTarget(uiHandler);
                msg.sendToTarget();
            }

            if (characteristic.getUuid().equals(CSC_MEASUREMENT_CHAR_UUID)) {
                //IF CSC...AFTER SETTING NOTIFY ON ALL
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
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


//                intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));

//            String value = String.valueOf(heartRate);
//            Log.i("hrValue.toString", hrValue.toString());



                String value = String.valueOf(String.format("CSC1: %d", csc1value));
                Message msg = Message.obtain();
                msg.obj = value;
                msg.what = 2;
                msg.setTarget(uiHandler);
                msg.sendToTarget();


            }

            //gatt.disconnect();
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

    public void onBtn1(View view) {
        Log.i("onBtn1","onBtn1");
        //Toast.makeText(this,"my Toast", LENGTH_SHORT).show();
        //txtView1 = (TextView) findViewById(R.id.txtView1);
        //txtView1.setText("Setting txtView1");
        BluetoothDevice device1 = devicesDiscovered.get(0);
        connectToDevice(device1);
    }

    public void onBtn2(View view) {
        Log.i("onBtn1","onBtn2");
        BluetoothDevice device1 = devicesDiscovered.get(1);
        connectToDevice(device1);
    }

    public void onBtn3(View view) {
        Log.i("onBtn3","onBtn3");
        BluetoothDevice device1 = devicesDiscovered.get(2);
        connectToDevice(device1);
    }



}

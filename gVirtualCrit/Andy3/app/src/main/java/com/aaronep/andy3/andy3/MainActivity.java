package com.aaronep.andy3.andy3;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.os.Bundle;
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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;


import static android.widget.Toast.LENGTH_SHORT;

public class MainActivity extends AppCompatActivity {

    private BluetoothAdapter mBluetoothAdapter;

    private Button btn1;
    private TextView txtView1;

    private UUID HEART_RATE_SERVICE_UUID = convertFromInteger(0x180D);
    private UUID HEART_RATE_MEASUREMENT_CHAR_UUID = convertFromInteger(0x2A37);
    private UUID HEART_RATE_CONTROL_POINT_CHAR_UUID = convertFromInteger(0x2A39);
    private UUID CLIENT_CHARACTERISTIC_CONFIG_UUID = convertFromInteger(0x2902);

    public UUID convertFromInteger(int i) {
        final long MSB = 0x0000000000001000L;
        final long LSB = 0x800000805f9b34fbL;
        long value = i & 0xFFFFFFFF;
        return new UUID(MSB | (value << 32), LSB);
    }




    //private BluetoothAdapter mBluetoothAdapter;
    private int REQUEST_ENABLE_BT = 1;
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
    @SuppressLint("HandlerLeak")
    private final Handler uiHandler = new Handler() {
        public void handleMessage(Message msg) {
            final int what = msg.what;
            final String value = (String) msg.obj;
            switch(what) {
                case UPDATE_DEVICE: updateDevice(value); break;
                case UPDATE_VALUE: updateValue(value); break;
            }
        }
    };

    private void updateDevice(String devName){
        TextView t=(TextView)findViewById(R.id.dev_type);
        t.setText(devName);
    }

    private void updateValue(String value){
        TextView t=(TextView)findViewById(R.id.value_read);
        t.setText(value);
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();



        Button btn1 = (Button) findViewById(R.id.btn1);


        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);




        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
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
            if (Build.VERSION.SDK_INT >= 21) {
                mLEScanner = mBluetoothAdapter.getBluetoothLeScanner();
                settings = new ScanSettings.Builder()
                        .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                        .build();
                filters = new ArrayList<ScanFilter>();
            }
            //scanLeDevice(true);
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
    protected void onDestroy() {
        if (mGatt == null) {
            return;
        }
        mGatt.close();
        mGatt = null;
        super.onDestroy();
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
                    if (Build.VERSION.SDK_INT < 21) {
                        mBluetoothAdapter.stopLeScan(mLeScanCallback);
                    } else {
                        mLEScanner.stopScan(mScanCallback);

                    }
                }
            }, SCAN_PERIOD);
            if (Build.VERSION.SDK_INT < 21) {
                mBluetoothAdapter.startLeScan(mLeScanCallback);
            } else {
                mLEScanner.startScan(filters, settings, mScanCallback);
            }
        } else {
            if (Build.VERSION.SDK_INT < 21) {
                mBluetoothAdapter.stopLeScan(mLeScanCallback);
            } else {
                mLEScanner.stopScan(mScanCallback);
            }
        }
    }


    private ScanCallback mScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            Log.i("onScanResult", "onScanResult");
            Log.i("mScanCallback", "onScanResult");

            Log.i("callbackType", String.valueOf(callbackType));
            String devicename = result.getDevice().getName();


//NOW HAVE TO DETERMINE IF IT IS AN HR OR CSC

            if (devicename != null){
                if (devicename.startsWith("Bl")){
                    Log.i("mScanCallback", "Device name: "+devicename);
                    Log.i("result", result.toString());
//GET UUIDS (ALREADY IN RESULT.STRING) TO DETERMINE IF HR OR CSC)
                    BluetoothDevice btDevice = result.getDevice();
                    Log.i("btDevice", "Device.getName: "+ btDevice.getName());

                    Log.i("btDevice", "ConnectToDevice...");
                    connectToDevice(btDevice);
                }
            }

        }

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

    private BluetoothAdapter.LeScanCallback mLeScanCallback =
            new BluetoothAdapter.LeScanCallback() {

                @Override
                public void onLeScan(final BluetoothDevice device, int rssi,
                                     byte[] scanRecord) {

                    Log.i("mLeScanCallback", "onLeScan");


                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Log.i("onLeScan", device.toString());
                            connectToDevice(device);
                        }
                    });
                }
            };

    public void connectToDevice(BluetoothDevice device) {
        Log.i("connectToDevice", "Device: " + device.getName());
        if (mGatt == null) {
            Log.d("connectToDevice", "connecting to device: "+device.toString());
            this.mDevice = device;
            mGatt = device.connectGatt(this, false, gattCallback);
            scanLeDevice(false);// will stop after first device detection
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

                    //update UI
                    Message msg = Message.obtain();

                    String deviceName = mGatt.getDevice().getName();

                    msg.obj = deviceName;
                    msg.what = 0;
                    msg.setTarget(uiHandler);
                    msg.sendToTarget();
                    Log.i("discoverServices", "discoverServices");
                    mGatt.discoverServices();
                    break;
                case BluetoothProfile.STATE_DISCONNECTED:
                    Log.e("gattCallback", "STATE_DISCONNECTED");
                    Log.i("gattCallback", "reconnecting...");
                    BluetoothDevice mDevice = mGatt.getDevice();
                    mGatt = null;
                    //connectToDevice(mDevice);
                    break;
                default:
                    Log.e("gattCallback", "STATE_OTHER");
            }

        }

        private boolean enabled;

        private BluetoothGattCharacteristic findNotifyCharacteristic(BluetoothGattService service, UUID characteristicUUID) {
            BluetoothGattCharacteristic characteristic = null;

            Log.i("3", "findNotifyCharacteristic");
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
            Log.i("2", "registerNotifyCallback UUID serviceUUID, UUID characteristicUUID: " + serviceUUID + characteristicUUID);
            boolean success = false;

            BluetoothGattService service = mGatt.getService(serviceUUID);
            Log.i("3", "findNotifyCharacteristic, passing (service aka mGatt.getService(serviceUUID),charUUID)");
            BluetoothGattCharacteristic characteristic = findNotifyCharacteristic(service, characteristicUUID);


            if (characteristic != null) {

                if (mGatt.setCharacteristicNotification(characteristic, true)) {

                    // Why doesn't setCharacteristicNotification write the descriptor?
                    BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID);
                    if (descriptor != null) {

                        // prefer notify over indicate
                        if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0) {
                            Log.i("4", "descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)");
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        } else if ((characteristic.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0) {
                            Log.i("4", "descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE)");
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
                        } else {
                            Log.d("Tag", "Characteristic " + characteristicUUID + " does not have NOTIFY or INDICATE property set");
                        }

                        if (mGatt.writeDescriptor(descriptor)) {
                            success = true;
                        } else {
                            Log.d("Write Err", "Failed to set client characteristic notification1");
                        }

                    } else {
                        Log.d("Write Err", "Failed to set client characteristic notification2");
                    }

                } else {
                    Log.d("Write Err", "Failed to set client characteristic notification3");
                }

            } else {
                Log.d("Write Err", "Failed to set client characteristic notification4");
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
            //determine if HR, then register notify callback



            Log.i("1", "registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID)");
            registerNotifyCallback(HEART_RATE_SERVICE_UUID, HEART_RATE_MEASUREMENT_CHAR_UUID);
            mGatt.readCharacteristic(mGatt.getService(HEART_RATE_SERVICE_UUID).getCharacteristic(HEART_RATE_MEASUREMENT_CHAR_UUID));



            //read all services
            Log.i("Read Services", "Loop through and read services and chars");
            for (BluetoothGattService service : services) {
                Log.i("BluGattService", "uuid = gattService.getUuid().toString(): " + service.getUuid().toString());
                List<BluetoothGattCharacteristic> characteristics = service.getCharacteristics();
                for (BluetoothGattCharacteristic characteristic : characteristics) {
                    Log.i("BlueSvcChar", "service.getChar UUID:  " + characteristic.getUuid());
                    Log.i("BlueSvcChar", "service.getChar Properties:  " + characteristic.getProperties());
                }
            }



        }


        @Override
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic
                                                 characteristic, int status) {
            Log.i("onCharacteristicRead", characteristic.toString());
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt,
                                            BluetoothGattCharacteristic
                                                    characteristic) {
            Log.i("onCharacteristicChanged", "onCharacteristic Changed");

            int flag = characteristic.getProperties();
            int format = -1;
            if ((flag & 0x01) != 0) {
                format = BluetoothGattCharacteristic.FORMAT_UINT16;
                //Log.i("HR Format 16", "Heart rate format UINT16.");
            } else {
                format = BluetoothGattCharacteristic.FORMAT_UINT8;
                //Log.i("HR Format 8", "Heart rate format UINT8.");
            }
            final int heartRate = characteristic.getIntValue(format, 1);
            final Integer hrValue = characteristic.getIntValue(format, 1);

            Log.i("HR-FINALLY", String.format("HR: %d", hrValue));
            //intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));

            String value = String.valueOf(heartRate);
            Log.i("hrValue.toString", hrValue.toString());

            //update UI
            Message msg = Message.obtain();
            msg.obj = value;
            msg.what = 1;
            msg.setTarget(uiHandler);
            msg.sendToTarget();

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

    public void onYes(View view) {
        Log.i("myTag","myMsg");
        Toast.makeText(this,"my Toast", LENGTH_SHORT).show();
        txtView1 = (TextView) findViewById(R.id.txtView1);
        txtView1.setText("Setting txtView1");



    }
}

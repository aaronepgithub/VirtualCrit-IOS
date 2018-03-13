package com.aaronep.andy;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
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
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelUuid;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.text.InputType;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.aaronep.andy.BluetoothUtil;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.Task;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {

    private TextView mTextMessage;
    private static final String TAG = MainActivity.class.getSimpleName();

    private static final UUID CSC_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
    private static final UUID CSC_CHARACTERISTIC_UUID = UUID.fromString("00002a5b-0000-1000-8000-00805f9b34fb");
    private final static UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
    private static final UUID BTLE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    public static final int NOT_SET = Integer.MIN_VALUE;
    private int REQUEST_ENABLE_BT = 1;
    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;
    private static final long SCAN_PERIOD = 5000;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mLEScanner;
    private ScanSettings settings;
    private List<ScanFilter> filters;


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

    private Calendar startTime;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTextMessage = (TextView) findViewById(R.id.message);
        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        startTime = Calendar.getInstance(Locale.ENGLISH);
        mPrinter("Starttime: " + ""+startTime.get(Calendar.HOUR_OF_DAY)+":"+startTime.get(Calendar.MINUTE)+":"+startTime.get(Calendar.SECOND));

//        Log.i("TIME", "getActualTime");
//        Calendar nowTime = Calendar.getInstance(Locale.ENGLISH);
//        Long st = startTime.getTimeInMillis();
//        Long nt = nowTime.getTimeInMillis();
//        long millis_act = nt - st;
//        @SuppressLint("DefaultLocale") String hms_act = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis_act),
//                TimeUnit.MILLISECONDS.toMinutes(millis_act) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis_act)),
//                TimeUnit.MILLISECONDS.toSeconds(millis_act) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis_act)));


        //START BT SETUP
        //TODO:  TO LAUNCH WITH EMULATOR, DISABLE
        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        if (bluetoothManager != null) {
            mBluetoothAdapter = bluetoothManager.getAdapter();
        }

        if (mBluetoothAdapter != null && !mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        }


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


    }
    //END ON_CREATE

    public Timer timer = new Timer();
    private Integer timerSecondsCounter = 0;
    private Integer currentMile = 1;
    private Integer previousMile = 1;
    private Integer secondsAtEndOfMile = 0;
    private double bestMileMPH = 0;
    private double currentMileSpeedBT = 0;
    private double currentMileSpeedGEO = 0;

    private Integer secondsPerRound = 60;
    private Integer currentRound = 1;
    private Integer previousRound = 1;

    private double bestRoundMPH = 0;
    private double currentRoundSpeedBT = 0;
    private double currentRoundSpeedGEO = 0;

    private Boolean newRoundFlagGEO = false;
    private Boolean newRoundFlagBT = false;

    public void onClick_0(View view) {
        Button b0 = findViewById(R.id.button0);
        String on1 = "ON";
        b0.setText(on1);
        //Set the schedule function
        timer.scheduleAtFixedRate(new TimerTask() {
              @Override
              public void run() {
                  //Log.i(TAG, "timer: " + timerSecondsCounter);

                  updateActualTime();
                  timerSecondsCounter += 1;


                  if (timerSecondsCounter > 31) {
                      if (timerSecondsCounter % 10 == 0) {veloTester1();}
                      if (timerSecondsCounter % 25 == 0) {veloTester2();}
                  }


                  //START END OF ROUND LOGIC


                  //FOR IN ROUND DISPLAY
                  double calcCurrentRoundSpd = currentRoundSpeedBT;
                  if (currentRoundSpeedGEO > calcCurrentRoundSpd) {
                      calcCurrentRoundSpd = currentRoundSpeedGEO;
                  }
                  final double currentRoundSpeed = calcCurrentRoundSpd;
                  //display this at 7a
                  Log.i(TAG, "CURRENT ROUND SPEED: " + currentRoundSpeed);


                  //END OF ROUND
                  if (timerSecondsCounter % secondsPerRound == 0 && timerSecondsCounter > 50) {

                      Log.i(TAG, "NEW ROUND: " + timerSecondsCounter);
                      currentRound += 1;

                      //DETERMINE BEST AND LAST
                      final double lastRoundSpeed = currentRoundSpeed;
                      //display at 7b

                      double calcBestRoundSpd = bestRoundMPH;
                      if (lastRoundSpeed > bestRoundMPH) {
                          bestRoundMPH = lastRoundSpeed;
                      }
                      final double bestRoundSpeed = bestRoundMPH;


                      newRoundFlagBT = true;
                      newRoundFlagGEO = true;
                      runOnUiThread(new Runnable() {
                          @Override
                          public void run() {
                              TextView tr = findViewById(R.id.rtStatus);
                              tr.setText(String.format("ROUND COMPLETED: %d", currentRound - 1));

                              TextView t7b = findViewById(R.id.rtText7b);
                              t7b.setText(String.format("%.1f MPH", lastRoundSpeed));

                              TextView t7c = findViewById(R.id.rtText7c);
                              t7c.setText(String.format("%.1f MPH", bestRoundSpeed));
                          }
                      });
                  }

                  //END ROUND LOGIC



                  //START MILE LOGIC

                  if (previousMile != currentMile) {
                      Log.i(TAG, "NEW MILE");
                      previousMile = currentMile;

                      double speedForLastMile = currentMileSpeedBT;
                      if (currentMileSpeedGEO > currentMileSpeedBT) {
                          speedForLastMile = currentMileSpeedGEO;
                      }

                      if (speedForLastMile > bestMileMPH) {bestMileMPH = speedForLastMile;}
                      final double finalSpeedForLastMile = speedForLastMile;
                      runOnUiThread(new Runnable() {
                          @Override
                          public void run() {
                              TextView t = findViewById(R.id.rtStatus);
                              t.setText(String.format("MILE COMPLETED: %d", previousMile));

                              TextView t1 = findViewById(R.id.rtText6b);
                              t1.setText(String.format("%.1f MPH", finalSpeedForLastMile));

                              TextView t2 = findViewById(R.id.rtText6c);
                              t2.setText(String.format("%.1f MPH", bestMileMPH));
                          }
                      });
                      secondsAtEndOfMile = timerSecondsCounter;
                  }

                  //RT SPEED FOR DURING THE MILE...
                  if (timerSecondsCounter - secondsAtEndOfMile > 5) {
                      double currentMileSpeedMPH = currentMileSpeedBT;
                      if (currentMileSpeedGEO > currentMileSpeedBT) {
                          currentMileSpeedMPH = currentMileSpeedGEO;
                      }
                      final double finalCurrentMileSpeedMPH = currentMileSpeedMPH;
                      Log.i(TAG, "CURRENT MILE SPEED: " + finalCurrentMileSpeedMPH);
                      runOnUiThread(new Runnable() {
                          @Override
                          public void run() {
                              TextView t3 = findViewById(R.id.rtText6a);
                              t3.setText(String.format("%.1f MPH", finalCurrentMileSpeedMPH));

                              TextView t37 = findViewById(R.id.rtText7a);
                              t37.setText(String.format("%.1f MPH", currentRoundSpeed));
                          }
                      });
                  }

                  //END MILE LOGIC






//                  if (previousRound != currentRound) {
//                      //Log.i(TAG, "NEW ROUND");
//                      runOnUiThread(new Runnable() {
//                          @Override
//                          public void run() {
//                              TextView t = findViewById(R.id.rtStatus);
//                              t.setText(String.format("ROUND COMPLETED: %d", previousRound));
//
//                              TextView rtText7b = findViewById(R.id.rtText7b);
//                            rtText7b.setText(String.format("%.1f MPH (BT)", finallastRoundMPH));
//                            TextView rtText7c = findViewById(R.id.rtText7c);
//                            rtText7c.setText(String.format("%.1f MPH (BT)", finalBestRoundMPH));
//
//                          }
//                      });
//                      previousRound = currentRound;
//
//                  }


              }
          },
        1000, 1000);
        //END TIMER
    }



    private String oldHR = "START", oldSPD = "START", oldCAD = "START";
    private void veloTester1() {
        //TEST FOR 0, SPD/CAD
        //SET TEXTVIEW TO "0", VELO
        //Log.i("TIMER", "TEST FOR 0 VAL SPD/CAD");
        TextView t2 = findViewById(R.id.textView2);
        String s2 = t2.getText().toString();
        if (Objects.equals(s2, oldSPD)) {
            resetSPD0();
        }
        oldSPD = s2;

        TextView t3 = findViewById(R.id.textView3);
        String s3 = t3.getText().toString();
        if (Objects.equals(s3, oldCAD)) {
            resetCAD0();
        }
        oldCAD = s3;
    }
    private void veloTester2() {
        //TEST FOR 0, HR
        //SET TEXTVIEW TO "0", VELO
        //Log.i("TIMER", "TEST FOR 0 VAL HR");
        TextView t1 = findViewById(R.id.textView1);
        String s1 = t1.getText().toString();
        if (Objects.equals(s1, oldHR)) {
            resetHR0();
        }
        oldHR = s1;
    }

    private void resetSPD0() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //Log.i("SPD", "RESET SPD");
                TextView t1 = findViewById(R.id.textView2);
                String s1x = "0.0 MPH";
                t1.setText(s1x);
            }
        });
    }
    private void resetHR0() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //Log.i("HR", "RESET HR");
                TextView t1 = findViewById(R.id.textView1);
                String s1x = "0 BPM";
                t1.setText(s1x);
            }
        });
    }
    private void resetCAD0() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //Log.i("CAD", "RESET CAD");
                TextView t1 = findViewById(R.id.textView3);
                String s1x = "0 RPM";
                t1.setText(s1x);
            }
        });
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


    //private BluetoothManager bluetooth;
    private BluetoothGattCallback bluetoothGattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int state) {

            connectingToGatt = false;
            super.onConnectionStateChange(gatt, status, state);

            switch (status) {
                case BluetoothGatt.GATT_SUCCESS: {
                    Log.i(TAG, "onConnectionStateChange: GATT_SUCCESS");
                    break;
                }
                case BluetoothGatt.GATT_FAILURE: {
                    Log.i(TAG, "onConnectionStateChange: GATT_FAILURE");
                    break;
                }
                default:
                    Log.i(TAG, "onConnectionStateChange: NOT SUCCESS OR FAILURE");

            }

            switch (state) {
                case BluetoothProfile.STATE_CONNECTED: {
                    Log.i(TAG, "onConnectionStateChange: STATE_CONNECTED");
                    setConnectedGatt(gatt);
                    gatt.discoverServices();
                    break;
                }
                case BluetoothProfile.STATE_DISCONNECTED: {
                    Log.i(TAG, "onConnectionStateChange: STATE_DISCONNECTED");
                    setConnectedGatt(null);
                    //TODO: DO THIS HERE?
                    break;
                }
                case BluetoothProfile.STATE_CONNECTING: {
                    Log.i(TAG, "onConnectionStateChange: STATE_CONNECTING");
                    break;
                }
                case BluetoothProfile.STATE_DISCONNECTING: {
                    Log.i(TAG, "onConnectionStateChange: STATE_DISCONNECTING");
                    break;
                }
                default:
                    Log.i("gattCallback", "STATE_OTHER");

            }
        }  //END CONNECTION STATE CHANGE

        @Override
        public void onReadRemoteRssi(BluetoothGatt gatt, int rssi, int status) {
            super.onReadRemoteRssi(gatt, rssi, status);
            Log.i(TAG, "onReadRemoteRssi: " + rssi);
        }


        public Boolean tryVelo = false;

        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            super.onServicesDiscovered(gatt, status);
            Log.d(TAG, "onServicesDiscovered status:" + BluetoothUtil.statusToString(status));

            Boolean hasHR = false;
            Boolean hasCSC = false;

            List<BluetoothGattService> services = gatt.getServices();
            Log.i("TEST", "DETERMINE IF BOTH SERVICES EXIST");
            for (BluetoothGattService service : services) {


                if (service.getUuid().equals(HR_SERVICE_UUID)) {
                    hasHR = true;
                    BluetoothGattCharacteristic valueCharacteristic = gatt.getService(HR_SERVICE_UUID).getCharacteristic(HR_CHARACTERISTIC_UUID);
                    boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
                    Log.i(TAG, "registered for HR updates " + (notificationSet ? "successfully" : "unsuccessfully"));
                    BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                    boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
                    Log.i(TAG, "wrote Descriptor for HR updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
                }
                if (service.getUuid().equals(CSC_SERVICE_UUID)) {
                    hasCSC = true;
                    if (hasHR) {
                        //need to wait and then try to notify
                        Log.i(TAG, "onServicesDiscovered: IS A VELO");
                        gatt0 = gatt;
                        if (!tryVelo) {
                            tryVelo = true;
                        }

                    }

                    BluetoothGattCharacteristic valueCharacteristic = gatt.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_CHARACTERISTIC_UUID);
                    boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
                    Log.i(TAG, "registered for CSC updates " + (notificationSet ? "successfully" : "unsuccessfully"));
                    BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                    boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
                    Log.i(TAG, "wrote Descriptor for CSC updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
                }

            }

        }


        double lastWheelTime = NOT_SET;
        long lastWheelCount = NOT_SET;
        double wheelSize = 2105;

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            super.onCharacteristicChanged(gatt, characteristic);
            byte[] value = characteristic.getValue();


            if (characteristic.getUuid().equals(HR_CHARACTERISTIC_UUID)) {
                gatt1 = gatt;
                int flag = characteristic.getProperties();
                int format = -1;
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
                final Integer hrValue = characteristic.getIntValue(format, 1);
                final String hr = String.valueOf(hrValue) + " BPM";

//                updateActualTime();

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //Log.i("HR", "hr: " + hr);
                        TextView t1 = findViewById(R.id.textView1);
                        t1.setText(hr);
                    }
                });


                if (tryVelo) {
                    tryVelo = false;
                    //Log.i(TAG, "onCharacteristicChanged: TRYING VELO...SET NOTIFY");
                    BluetoothGattCharacteristic valueCharacteristic = gatt0.getService(CSC_SERVICE_UUID).getCharacteristic(CSC_CHARACTERISTIC_UUID);
                    boolean notificationSet = gatt0.setCharacteristicNotification(valueCharacteristic, true);
                    //Log.d(TAG, "registered for VELO CSC updates " + (notificationSet ? "successfully" : "unsuccessfully"));
                    BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                    boolean writeDescriptorSuccess = gatt0.writeDescriptor(descriptor);
                    //Log.d(TAG, "wrote Descriptor for VELO CSC updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
                }

                return;
            }  //END HR


            final byte WHEEL_REVOLUTIONS_DATA_PRESENT = 0x01; // 1 bit
            final byte CRANK_REVOLUTION_DATA_PRESENT = 0x02; // 1 bit

            if (characteristic.getUuid().equals(CSC_CHARACTERISTIC_UUID)) {

                final int flags = characteristic.getValue()[0]; // 1 byte
                final boolean wheelRevPresent = (flags & WHEEL_REVOLUTIONS_DATA_PRESENT) > 0;
                final boolean crankRevPreset = (flags & CRANK_REVOLUTION_DATA_PRESENT) > 0;

                if (wheelRevPresent) {
                    gatt2 = gatt;
                    final int cumulativeWheelRevolutions = (value[1] & 0xff) | ((value[2] & 0xff) << 8);
                    final int lastWheelEventReadValue = (value[5] & 0xff) | ((value[6] & 0xff) << 8);


                    //Log.i("WHEEL_EVENT", "onCharacteristicChanged, revs, time:  " + cumulativeWheelRevolutions + ", " + lastWheelEventReadValue);
//                    runOnUiThread(new Runnable() {
//                        @SuppressLint("DefaultLocale")
//                        public void run() {
//                            TextView t = findViewById(R.id.textView1);
//                            t.setText(String.valueOf(cumulativeWheelRevolutions));
//                        }
//                    });
                    onWheelMeasurementReceived(cumulativeWheelRevolutions, lastWheelEventReadValue);

                    if (crankRevPreset) {
                        gatt3 = gatt;
                        final int cumulativeCrankRevolutions = (value[7] & 0xff) | ((value[8] & 0xff) << 8);
                        final int lastCrankEventReadValue = (value[9] & 0xff) | ((value[10] & 0xff) << 8);
                        //Log.i("CRANK_EVENT", "onCharacteristicChanged, revs, time:  " + cumulativeCrankRevolutions + ", " + lastCrankEventReadValue);
                        onCrankMeasurementReceived(cumulativeCrankRevolutions, lastCrankEventReadValue);
                    }
                } else {
                    if (crankRevPreset) {
                        gatt3 = gatt;
                        final int cumulativeCrankRevolutions = (value[1] & 0xff) | ((value[2] & 0xff) << 8);
                        final int lastCrankEventReadValue = (value[3] & 0xff) | ((value[4] & 0xff) << 8);
                        //Log.i("CRANK_EVENT", "onCharacteristicChanged, revs, time:  " + cumulativeCrankRevolutions + ", " + lastCrankEventReadValue);
                        onCrankMeasurementReceived(cumulativeCrankRevolutions, lastCrankEventReadValue);
                    }
                }

            }  //END CSC CALC


        }  //END ON CHAR CHANGED


    }; //END BLUETOOTHGATTCALLBACK


    private int mFirstWheelRevolutions = -1;
    private int mLastWheelRevolutions = -1;
    private int mLastWheelEventTime = -1;
    private int mFirstCrankRevolutions = -1;
    private int mLastCrankRevolutions = -1;
    private int mLastCrankEventTime = -1;

    private double totalWheelRevolutions = 0;
    private double totalTimeInSeconds = 0;

    private double distanceAtStartOfPreviousRound = 0;
    private double secondsAtStartOfPreviousRound = 0;

    //CSC ADVANCED CALC
    private void onWheelMeasurementReceived(final int wheelRevolutionValue, final int wheelRevolutionTimeValue) {
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

        if (wheelDiff == 0 || wheelDiff > 15) {
            mLastWheelRevolutions = wheelRevolutionValue;
            mLastWheelEventTime = wheelRevolutionTimeValue;
            return;
        }

        if (timeDiff < 500) {
            return;
        }

        if (timeDiff > 5000) {
            mLastWheelRevolutions = wheelRevolutionValue;
            mLastWheelEventTime = wheelRevolutionTimeValue;
            return;
        }

        //Log.i(TAG, "onWheelMeasurementReceived: wheelDiff, timeDiff: " + wheelDiff + ", " + timeDiff);

        totalWheelRevolutions += (double) wheelDiff;
        totalTimeInSeconds += (double) timeDiff / 1024.0;

        final double wheelTimeInSeconds = timeDiff / 1024.0;
        final double wheelCircumference = wheelSizeMM;
        final double wheelCircumferenceCM = wheelCircumference / 10;


        final double wheelRPM = (double) wheelDiff / (wheelTimeInSeconds / 60.0);
        final double cmPerMi = 0.00001 * 0.621371;
        final double minsPerHour = 60.0;
        final double speed = wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour;  //MPH CURRENT

        final double totalDistance = totalWheelRevolutions * wheelCircumferenceCM * cmPerMi;
        //final double totalAverageMovingSpeed = (totalWheelRevolutions / (totalTimeInSeconds / 60.0)) * wheelCircumferenceCM * cmPerMi * minsPerHour;

        currentMileSpeedBT = (totalDistance - ((double) currentMile - 1)) / (((double) timerSecondsCounter - (double) secondsAtEndOfMile) / 60.0 / 60.0);
        if (totalDistance > (double) currentMile && totalDistance > 0.5) {
            currentMile += 1;
            secondsAtEndOfMile = timerSecondsCounter;
        }


//        Log.i(TAG, "onWheelMeasurementReceived: DISTANCE = " + String.valueOf(totalDistance));
//        Log.i(TAG, "onWheelMeasurementReceived: SPEED = " + String.valueOf(speed));
//        Log.i(TAG, "onWheelMeasurementReceived: AVG SPEED = " + String.valueOf(totalAverageMovingSpeed));

        final long millis = (long) totalTimeInSeconds * 1000;
        final String hms = getTimeStringFromMilli(millis);
//        @SuppressLint("DefaultLocale") final String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
//                TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
//                TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));


        final double btAvgSpeed = totalDistance / (totalTimeInSeconds / 60.0 / 60.0);


        //ROUND CALC
        //USES TIMERCOUNTER, NOT BT.TOTALTIME IN SECONDS
        double distanceDuringCurrentRound = totalDistance - distanceAtStartOfPreviousRound;
        double elapsedSecondsInCurrentRound = (double) timerSecondsCounter - (double) secondsAtStartOfPreviousRound;
        double currentRoundSpeedMPH = 0;
        if (elapsedSecondsInCurrentRound > 5) {
            currentRoundSpeedMPH = distanceDuringCurrentRound / (elapsedSecondsInCurrentRound / 60.0 / 60.0);
        }
        currentRoundSpeedBT = currentRoundSpeedMPH;

//        Log.i(TAG, "distanceDuringCurrentRound: " + distanceDuringCurrentRound);
//        Log.i(TAG, "elapsedSecondsInCurrentRound: " + elapsedSecondsInCurrentRound);
//        Log.i(TAG, "currentRoundSpeedMPH: " + currentRoundSpeedMPH);

        if (newRoundFlagBT && totalDistance > distanceAtStartOfPreviousRound) {
            Log.i(TAG, "BT NEW ROUND");

            distanceAtStartOfPreviousRound = totalDistance;
            secondsAtStartOfPreviousRound = timerSecondsCounter;
            newRoundFlagBT = false;
        }


        runOnUiThread(new Runnable() {
            @SuppressLint("DefaultLocale")
            public void run() {
                TextView t2 = findViewById(R.id.textView2);
                t2.setText(String.format("%.1f MPH (BT)", speed));
                TextView t4 = findViewById(R.id.rtText1a);
                String hms2 = hms + " (BT)";
                t4.setText(hms2);
                TextView td = findViewById(R.id.rtText4a);
                td.setText(String.format("%.2f MI (BT)", totalDistance));
                TextView rtText8a = findViewById(R.id.rtText8a);
                rtText8a.setText(String.format("%.1f AVG (BT)", btAvgSpeed));

                TextView rtText3a = findViewById(R.id.rtText3a);
                rtText3a.setText(String.format("%s (BT)", calcPace(speed)));

                TextView rtText9a = findViewById(R.id.rtText9a);
                rtText9a.setText(String.format("%s (BT)", calcPace(btAvgSpeed)));

            }
        });


        mLastWheelRevolutions = wheelRevolutionValue;
        mLastWheelEventTime = wheelRevolutionTimeValue;
    }


    private void onCrankMeasurementReceived(final int crankRevolutionValue, final int crankRevolutionTimeValue) {
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

        if (timeDiff < 500) {
            return;
        }

        if (timeDiff > 5000) {
            mLastCrankRevolutions = crankRevolutionValue;
            mLastCrankEventTime = crankRevolutionTimeValue;
            return;
        }


        Log.i("CAD", "onWheelMeasurementReceived: crankDiff, timeDiff: " + crankDiff + ", " + timeDiff);
        final double cadence = (double) crankDiff / ((((double) timeDiff) / 1024.0) / 60);
        if (cadence == 0) {
            return;
        }
        if (cadence > 150) {
            return;
        }
        Log.i("CAD", "CADENCE: " + cadence);

        runOnUiThread(new Runnable() {
            @SuppressLint("DefaultLocale")
            public void run() {
                TextView t3 = findViewById(R.id.textView3);
                t3.setText(String.format("%.0f RPM", cadence));
            }
        });
    }


    //END CSC ADVANCED CALC

    private int do16BitDiff(int a, int b) {
        if (a >= b)
            return a - b;
        else
            return (a + 65536) - b;
    }

    public String getTimeStringFromMilli(long totalMilliseconds) {
        @SuppressLint("DefaultLocale") final String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(totalMilliseconds),
                TimeUnit.MILLISECONDS.toMinutes(totalMilliseconds) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(totalMilliseconds)),
                TimeUnit.MILLISECONDS.toSeconds(totalMilliseconds) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(totalMilliseconds)));
        return hms;
    }


    private BluetoothGatt connectedGatt;

    private BluetoothGatt gatt0;
    private BluetoothGatt gatt1;
    private BluetoothGatt gatt2;
    private BluetoothGatt gatt3;
    private BluetoothGatt gatt4;

    private boolean connectingToGatt;
    private final Object connectingToGattMonitor = new Object();

    private int cycle = 1;

    //DISCONNECT ALL
    public void onClick_4(View view) {
        Log.i(TAG, "onClick_4: clicked");

        //remove GPS
        try {
            mFusedLocationClient.removeLocationUpdates(mLocationCallback);
        } catch (Exception e){
            Log.i(TAG, "onClick_4: DIDN'T STOP LOCATION");
        }
        //mFusedLocationClient.removeLocationUpdates(mLocationCallback);

        //TODO, CYCLE THROUGH gattsConnected arrList, disconnect all nonNull
        for (BluetoothGatt btGatt : bluetoothGatts) {
            if (btGatt != null) {
                Log.i(TAG, "bluetoothGatts to disconnect, Name: " + btGatt.getDevice().getName());
                btGatt.disconnect();
                btGatt.close();
                setConnectedGatt(null);
            }

        }


        if (connectedGatt != null) {
            Log.i(TAG, "onClick_4: connectedGatt name:  " + connectedGatt.getDevice().getName());
            connectedGatt.disconnect();
            connectedGatt.close();
            setConnectedGatt(null);
        }


        int locCycle = cycle;
        if (locCycle == 1) {
            if (gatt1 != null) {
                Log.i(TAG, "onClick_4: gatt1 name:  " + gatt1.getDevice().getName());
                gatt1.disconnect();
                gatt1.close();
                setConnectedGatt(null);
                gatt1 = null;
            }
            cycle = 2;
        }
        if (locCycle == 2) {
            if (gatt2 != null) {
                Log.i(TAG, "onClick_4: gatt2 name:  " + gatt2.getDevice().getName());
                gatt2.disconnect();
                gatt2.close();
                setConnectedGatt(null);
                gatt2 = null;
            }
            cycle = 3;
        }
        if (locCycle == 3) {
            if (gatt3 != null) {
                Log.i(TAG, "onClick_4: gatt3 name:  " + gatt3.getDevice().getName());
                gatt3.disconnect();
                gatt3.close();
                setConnectedGatt(null);
                gatt3 = null;
            }
            cycle = 1;
        }

    }



    //start on location received

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

    Double distanceAtStartOfPreviousRoundGeo = 0.0;
    Integer secondsAtStartOfPreviousRoundGeo = 0;


    @SuppressLint("DefaultLocale")
    public void onLocationReceived(Location location) {
        mPrinter("ON LOCATION RECEIVED:  " + location.getProvider() + "," + location.getLatitude() + "," + location.getLongitude());
        arrLats.add(location.getLatitude());
        arrLons.add(location.getLongitude());
        //mPrinter("ARRLATS.SIZE: " + arrLats.size());

        if (arrLats.size() < 5) {
            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        } else {
            Location.distanceBetween(oldLat, oldLon, location.getLatitude(), location.getLongitude(), results);

            if (results.length > 0) {

                mPrinter("RESULTS[0]  " + results[0] * 0.000621371 +  "  MILES"); //AS MILES
                if (results[0] == 0) {
                    mPrinter("NOTHING AT RESULTS[0] - RETURN");
                    return;
                }
                if (results[0] * 0.000621371 <= 0) {
                    mPrinter("NO DISTANCE TRAVELED - RETURN");
                    return;
                }

                //OPT 1.  QUICKREAD GEO SPEED
                final double geoSpeedQuick = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr
                mPrinter("GEO SPEED Q: " + geoSpeedQuick);

                //OPT 2.  GEO SPEED, LONG VERSION
                Double gd = results[0] * 0.000621371;
                long gt = (location.getTime() - oldTime);  //MILLI
                geoSpeed = gd / ((double) gt / 1000 / 60 / 60);
                mPrinter("GEO SPEED: " + geoSpeed);
                //END GEO SPEED CALC




                currentMileSpeedGEO = (geoDistance - ((double) currentMile - 1)) / (((double) timerSecondsCounter - (double) secondsAtEndOfMile) / 60.0 / 60.0);
                geoDistance += results[0] * 0.000621371;
                if (geoDistance > (double) currentMile && geoDistance > 0.5) {
                    currentMile += 1;
                    secondsAtEndOfMile = timerSecondsCounter;
                }
//                mPrinter("OLDTIME " + oldTime);
//                mPrinter("NEWTIME " + location.getTime());
//                mPrinter("totalTimeGeo " + totalTimeGeo);
                totalTimeGeo += (location.getTime() - oldTime);  //MILLI
//                mPrinter("GEODISTANCE: " + geoDistance);
//                mPrinter("TOTALTIMEGEO: " + totalTimeGeo);

                double ttg = totalTimeGeo;  //IN MILLI
                geoAvgSpeed = geoDistance / (ttg / 1000.0 / 60.0 / 60.0);

                long millis = totalTimeGeo;
                @SuppressLint("DefaultLocale") final String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                        TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                        TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));


                mPrinter("ELAPSED TIME (GEO): " + hms);

                //START ROUND CALC
                double distanceDuringCurrentRoundGeo = geoDistance - distanceAtStartOfPreviousRoundGeo;
                double elapsedSecondsInCurrentRoundGeo = (double) timerSecondsCounter - (double) secondsAtStartOfPreviousRoundGeo;

                double currentRoundSpeedMPHGeo = 0;
                if (elapsedSecondsInCurrentRoundGeo > 5) {
                    currentRoundSpeedMPHGeo = distanceDuringCurrentRoundGeo / (elapsedSecondsInCurrentRoundGeo / 60.0 / 60.0);
                }
                currentRoundSpeedGEO = currentRoundSpeedMPHGeo;
                Log.i(TAG, "CURRENT ROUND SPEED GEO: " + currentRoundSpeedMPHGeo);
                if (newRoundFlagGEO && geoDistance > distanceAtStartOfPreviousRoundGeo) {
                    Log.i(TAG, "GEO NEW ROUND");

                    distanceAtStartOfPreviousRoundGeo = geoDistance;
                    secondsAtStartOfPreviousRoundGeo = timerSecondsCounter;
                    newRoundFlagGEO = false;
                }
                //END ROUND CALC


                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        TextView rtText2b = findViewById(R.id.rtText2b);
                        rtText2b.setText(String.format("%.1f MPH (G)", geoSpeedQuick));

                        TextView rtText3b = findViewById(R.id.rtText3b);
                        rtText3b.setText(String.format("%s (G)", calcPace(geoSpeedQuick)));

                        TextView rtText8b = findViewById(R.id.rtText8b);
                        rtText8b.setText(String.format("%.1f AVG (G)", geoAvgSpeed));

                        TextView rtText9b = findViewById(R.id.rtText9b);
                        rtText9b.setText(String.format("%s (G)", calcPace(geoAvgSpeed)));

                        TextView t = findViewById(R.id.rtText1b);
                        t.setText(String.format("%s  (G)", hms));

                        TextView rtText4b = findViewById(R.id.rtText4b);
                        rtText4b.setText(String.format("%.2f MI (G)", geoDistance));
                    }
                });

//                mPrinter("geoAvgSpeed: " + geoAvgSpeed);

            }

            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        }


    }

    private void mPrinter(String s) {
        Log.i(TAG, ":" + s);
    }

    //end on location


private String calcPace(double mph) {


        double a = (60.0 / mph);
        if (a == 0 || a > 50) {
            return "00:00";
        }

        double m = a * 60.0 * 1000.0;
        long mill = (long) m;
    @SuppressLint("DefaultLocale") final String minutesPerMile = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(mill),
            TimeUnit.MILLISECONDS.toMinutes(mill) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(mill)),
            TimeUnit.MILLISECONDS.toSeconds(mill) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(mill)));


        return minutesPerMile;

}


    private LocationRequest mLocationRequest;
    private FusedLocationProviderClient mFusedLocationClient;
    private LocationCallback mLocationCallback;
    private Handler mServiceHandler;
    private Location mLocation;


    //GPS BUTTON...
    private Boolean isGpsActive = false;
    public void onClick_2(View view) {
        Log.i(TAG, "onClick_2: clicked");
        Button b2 = findViewById(R.id.button2);

        if (isGpsActive) {
            b2.setText("OFF");
            try {
                mFusedLocationClient.removeLocationUpdates(mLocationCallback);
            } catch (Exception e){
                Log.i(TAG, "onClick_2 Error,  DIDN'T STOP LOCATION");
            }
        }


        isGpsActive = true;
        b2.setText("ON");

        LocationRequest mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(3000);
        mLocationRequest.setFastestInterval(2000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder()
                .addLocationRequest(mLocationRequest);

        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                onNewLocation(locationResult.getLastLocation());
            }

            private void onNewLocation(Location lastLocation) {
                //Log.i(TAG, "onNewLocation: " + lastLocation.getSpeed());
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

        //when ready to stop...mFusedLocationClient.removeLocationUpdates(mLocationCallback);





}  //end onclick2





    //START SCAN BUTTON
    public void onClick_1(View view) {
        Log.i("CLICK", "onClick_1: clicked");
        Button b1 = findViewById(R.id.button1);
        b1.setText("ON");
        Toast.makeText(this,"SCANNING...", Toast.LENGTH_LONG).show();
        //scanLeDevice(true);

            Log.i("SCANLEDEVICE", "START SCANNING");
        mLEScanner.startScan(filters, settings, mScanCallback);
        isScanning = true;
        Handler mHandler = new Handler();
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mLEScanner.stopScan(mScanCallback);
                Log.i("SCANLEDEVICE", "TOP SCANNING");
//                    sendToaster("SCAN COMPLETE");
                isScanning = false;
                sendToaster("SCAN COMPLETE");
            }
        }, SCAN_PERIOD);

        if (!isScanning) {
            devicesDiscovered = new ArrayList<>();
            deviceIndexVal = 0;

            Button btn100 = findViewById(R.id.button100);
            Button btn101 = findViewById(R.id.button101);
            Button btn102 = findViewById(R.id.button102);
            Button btn103 = findViewById(R.id.button103);
            Button btn104 = findViewById(R.id.button104);

            btn100.setVisibility(View.GONE);
            btn101.setVisibility(View.GONE);
            btn102.setVisibility(View.GONE);
            btn103.setVisibility(View.GONE);
            btn104.setVisibility(View.GONE);

            mLEScanner.startScan(filters, settings, mScanCallback);
            isScanning = true;
            Log.i("SCAN", "isScanning: ");
        }





        //final BluetoothAdapter adapter = bluetooth.getAdapter();
//        UUID[] serviceUUIDs = new UUID[]{HR_SERVICE_UUID};
//
//        mBluetoothAdapter.startLeScan(serviceUUIDs, new BluetoothAdapter.LeScanCallback() {
//
//            @Override
//            public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
//                Log.d(TAG, "found device " + device.getAddress());
//                synchronized (connectingToGattMonitor){
//                    if (!connectingToGatt) {
//                        connectingToGatt = true;
//                        Log.d(TAG, "connecting to " + device.getAddress());
////                        device.connectGatt(MainActivity.this, false, bluetoothGattCallback);
//                        device.connectGatt(MainActivity.this, false, bluetoothGattCallback);
//
//                        runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                        Button b1 = findViewById(R.id.button1);
//                        b1.setEnabled(false);
//                            }
//                        });
//                        updateRssiDisplay(rssi);
//                        Log.i(TAG, "onLeScan: UPDATE RSSI: " + rssi);
//
//                        mBluetoothAdapter.stopLeScan(this);
//                    }
//                }
//            }
//        });//onLEScan CB Finished
//        Button b1 = findViewById(R.id.button1);
//        b1.setEnabled(false);

    } //END BTN1 CLICK

    private void sendToaster(String toasterText) {
        Toast.makeText(this,toasterText, Toast.LENGTH_SHORT).show();
    }

    //SCANCALLBACK - START
    public ScanCallback mScanCallback;
    {
        mScanCallback = new ScanCallback() {
            @Override
            public void onScanResult(int callbackType, ScanResult result) {

                if (result.getDevice().getName() != null) {
                    Log.i("SCAN_CB", "onScanResult: " + result.getDevice().getName());
                    BluetoothDevice deviceDiscovered = result.getDevice();
                    String deviceName = result.getDevice().getName();
                    String deviceAddress = result.getDevice().getAddress();

                    if (!devicesDiscovered.contains(deviceDiscovered)) {
                        devicesDiscovered.add(deviceDiscovered);

                        sendToaster("FOUND:  " + deviceName);

                        Log.i("deviceIndexVal", "deviceIndexVal  " + deviceIndexVal);
                        Log.i("result", "NAME  " + result.getDevice().getName());
                        Log.i("result", "ADDRESS  " + result.getDevice().getAddress());

                        Button btn100 = findViewById(R.id.button100);
                        Button btn101 = findViewById(R.id.button101);
                        Button btn102 = findViewById(R.id.button102);
                        Button btn103 = findViewById(R.id.button103);
                        Button btn104 = findViewById(R.id.button104);

                        if (deviceIndexVal == 0) {
                            btn100.setVisibility(View.VISIBLE);
                            btn100.setText(deviceName);
                            Log.i("btn100", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 1) {
                            btn101.setVisibility(View.VISIBLE);
                            btn101.setText(deviceName);
                            Log.i("btn101", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 2) {
                            btn102.setVisibility(View.VISIBLE);
                            btn102.setText(deviceName);
                            Log.i("btn102", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 3) {
                            btn103.setVisibility(View.VISIBLE);
                            btn103.setText(deviceName);
                            Log.i("btn103", "deviceIndexVal:  " + deviceIndexVal + " - " + deviceName);
                        }
                        if (deviceIndexVal == 4) {
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
                Log.i("Scan Failed", "Error Code: " + errorCode);
            }
        };
    }
//SCANCALLBACK - FINISH

    public void connectToDevice(BluetoothDevice mDevice) {
        Log.i("connectToDevice", "Device: " + mDevice.getName());
        Log.i("connectToDevice", "Addresss: " + mDevice.getAddress());

        connectedGatt = mDevice.connectGatt(this, false, bluetoothGattCallback);
        Toast.makeText(this,"Connecting to: " + mDevice.getName(), Toast.LENGTH_LONG).show();
        devicesConnected.add(mDevice);
        bluetoothGatts.add(connectedGatt);


//        if (connectedGatt == null) {
//            Log.i("connectToDevice", "connecting to device: "+mDevice.toString());
//            connectedGatt = mDevice.connectGatt(this, false, gattCallback);
//            Toast.makeText(this,"Connecting to: " + mDevice.getName(), Toast.LENGTH_LONG).show();
//            devicesConnected.add(mDevice);
//            for (BluetoothDevice d : devicesConnected) {
//                String d2 = String.valueOf(devicesConnected.indexOf(d)) + ".  " + d.getName();
//                Log.i("CONNECTED", "devicesConnected: " + d2);;
//            }
//        }
    }


    private ArrayList<BluetoothDevice> devicesDiscovered = new ArrayList<>();
    private ArrayList<BluetoothDevice> devicesConnected = new ArrayList<>();
    private ArrayList<BluetoothGatt> bluetoothGatts = new ArrayList<>();
    private Integer deviceIndexVal = 0;
    private Boolean isScanning = false;

//    private void scanLeDevice(final boolean enable) {
//        Log.i(TAG, "scanLeDevice: CALLED SCANLEDEVICE");
//        if (enable) {
//        isScanning = true;
//        Handler mHandler = new Handler();
//        mHandler.postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                mLEScanner.stopScan(mScanCallback);
//                Log.i("SCANLEDEVICE", "run: STOP SCANNING");
////                    sendToaster("SCAN COMPLETE");
//                isScanning = false;
//                sendToaster("SCAN COMPLETE");
//            }
//        }, SCAN_PERIOD);
//
//        if (!isScanning) {
//            devicesDiscovered = new ArrayList<>();
//            deviceIndexVal = 0;
//
//            Button btn100 = findViewById(R.id.button100);
//            Button btn101 = findViewById(R.id.button101);
//            Button btn102 = findViewById(R.id.button102);
//            Button btn103 = findViewById(R.id.button103);
//            Button btn104 = findViewById(R.id.button104);
//
//            btn100.setVisibility(View.GONE);
//            btn101.setVisibility(View.GONE);
//            btn102.setVisibility(View.GONE);
//            btn103.setVisibility(View.GONE);
//            btn104.setVisibility(View.GONE);
//
//            mLEScanner.startScan(filters, settings, mScanCallback);
//            isScanning = true;
//            Log.i("SCAN", "scanLeDevice: ");
//        }
//    } else {
//        isScanning = false;
//        mLEScanner.stopScan(mScanCallback);
//    }
//}




    public void setConnectedGatt(final BluetoothGatt connectedGatt) {
        this.connectedGatt = connectedGatt;

        Log.i(TAG, "setConnectedGatt, is null?: " + (connectedGatt == null));
        Log.i(TAG, "setConnectedGatt: NOT GETTING CONNECTED STATE CHANGE AFTER FIRST DISCONNECT, BECAUSE OF CLOSE()");
        //NO CONNECTED STATE CHANGE?
        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                if (connectedGatt != null) {
                    Log.i(TAG, "run: :CONNECTED GATT DEVICE NAME " + connectedGatt.getDevice().getName());
                    Log.i(TAG, "run: CONNECTED GATT DEVICE: " + connectedGatt.toString());
                    Button b2 = findViewById(R.id.button2);
                    b2.setEnabled(true);
                } //else {
//                    Button b1 = findViewById(R.id.button1);
//                    b1.setEnabled(true);
//
//                    Button b2 = findViewById(R.id.button2);
//                    b2.setEnabled(false);
//                }

            }
        });
    }


    private void updateActualTime(){
        //update actual time
        Calendar nowTime = Calendar.getInstance(Locale.ENGLISH);
        long st = startTime.getTimeInMillis();
        long nt = nowTime.getTimeInMillis();
        long millis_act = nt - st;
        @SuppressLint("DefaultLocale") final String hms_act = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis_act),
                TimeUnit.MILLISECONDS.toMinutes(millis_act) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis_act)),
                TimeUnit.MILLISECONDS.toSeconds(millis_act) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis_act)));
//        TextView at = findViewById(R.id.rtText1);
//        at.setText(String.format("%s  ", hms_act));


        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView at = findViewById(R.id.rtText1);
                at.setText(String.format("%s  (ACT)", hms_act));
            }
        });

    }

    private BluetoothDevice mDevice;

    public void mConnectToDevice(final int indexVal) {
        mDevice = devicesDiscovered.get(indexVal);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("CONNECT TO:  " + mDevice.getName())
                .setCancelable(false)
                .setPositiveButton("CONNECT", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("BTN","CONNECT");
                        connectToDevice(mDevice);

                        switch (indexVal) {
                            case 0: {
                                Button btn100 = findViewById(R.id.button100);
                                btn100.setTextColor(Color.RED);
                                dialog.cancel();
                                break;
                            }
                            case 1: {
                                Button btn101 = findViewById(R.id.button101);
                                btn101.setTextColor(Color.RED);
                                dialog.cancel();
                                break;
                            }
                            case 2: {
                                Button btn102 = findViewById(R.id.button102);
                                btn102.setTextColor(Color.RED);
                                dialog.cancel();
                                break;
                            }
                            case 3: {
                                Button btn103 = findViewById(R.id.button103);
                                btn103.setTextColor(Color.RED);
                                dialog.cancel();
                                break;
                            }
                            case 4: {
                                Button btn104 = findViewById(R.id.button104);
                                btn104.setTextColor(Color.RED);
                                dialog.cancel();
                                break;
                            }


                        }


                    }
                })
                .setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.i("BTN","CANCEL");
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();
    }


    public void onClick_100(View view) {
        Button b1 = findViewById(R.id.button1);
        mConnectToDevice(0);
    }

    public void onClick_101(View view) {
        mConnectToDevice(1);
    }

    public void onClick_102(View view) {
        mConnectToDevice(2);
    }

    public void onClick_103(View view) {
        mConnectToDevice(3);
    }

    public void onClick_104(View view) {
        mConnectToDevice(4);
    }

    public void onClick_3(View view) {
        //RESET??
    }


    public void onClick_setSecondsPerRound(View view) {
        Button b = findViewById(R.id.button54b);
        switch (secondsPerRound) {
            case 60:
                secondsPerRound = 300;
                b.setText("300 Seconds");
                break;
            case 300:
                secondsPerRound = 1800;
                b.setText("30 Minutes");
                break;
            case 1800:
                secondsPerRound = 60;
                b.setText("1 Minute");
        }
    }

    public Boolean audioValue = true;
    public void onClick_setAudio(View view) {
        Button b = findViewById(R.id.button53b);
        if (audioValue) {
            audioValue = false;
            b.setText("OFF");
        } else {
            audioValue = true;
            b.setText("ON");
        }
    }

    public double wheelSizeMM = 2105.0;
    public void onClick_setTireSize(View view) {
        Button b = findViewById(R.id.button52b);
        String bVal = b.getText().toString();
        switch (bVal) {
            case "700X25": {
                wheelSizeMM = 2136.0;
                b.setText("700X28");
                break;
            }
            case "700X28": {
                wheelSizeMM = 2155.0;
                b.setText("700X32");
                break;
            }
            case "700X32": {
                wheelSizeMM = 2105.0;
                b.setText("700X25");
                break;
            }
        }

    }

    public String activityValue = "BIKE";
    public void onClick_setActivity(View view) {
        Button b = findViewById(R.id.button51b);
        switch (activityValue) {
            case "BIKE":
                b.setText("RUN");
                activityValue = "RUN";
                break;
            case "RUN":
                b.setText("ROW");
                activityValue = "ROW";
                break;
            case "ROW":
                activityValue = "BIKE";
                b.setText("BIKE");
                break;
        }
    }

    public String userName = "TIM";
    public void onClick_setName(View view) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        AlertDialog dialog;
        builder.setTitle("NAME");

// Set up the input
        final EditText input = new EditText(this);
// Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);


// Set up the buttons
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                userName = input.getText().toString().toUpperCase();
                Button b = findViewById(R.id.button50b);
                b.setText(userName);

                try {
                    getSupportActionBar().setTitle("VIRTUAL CRIT (" + userName + ")");
                } catch (Exception e) {
                    e.printStackTrace();
                }


            }
        });
        builder.setNegativeButton("RANDOM", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                Random r = new Random();
                int i1 = r.nextInt(9999 - 1001);
                userName = userName + i1;
                Button b = findViewById(R.id.button50b);
                b.setText(userName);

                try {
                    getSupportActionBar().setTitle("VIRTUAL CRIT (" + userName + ")");
                } catch (Exception e) {
                    e.printStackTrace();
                }


                dialog.cancel();
            }
        });

        builder.show();
    }




}

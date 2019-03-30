package com.example.virtualcrit3_lite;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.TabActivity;
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
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.ParcelUuid;
import android.os.Vibrator;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.speech.tts.TextToSpeech;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TabLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.text.InputType;
import android.text.LoginFilter;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import com.mapbox.android.core.location.LocationEngine;
import com.mapbox.android.core.location.LocationEngineCallback;
import com.mapbox.android.core.location.LocationEngineProvider;
import com.mapbox.android.core.location.LocationEngineRequest;
import com.mapbox.android.core.location.LocationEngineResult;
import com.mapbox.android.core.permissions.PermissionsListener;
import com.mapbox.android.core.permissions.PermissionsManager;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import com.mapbox.geojson.LineString;
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.location.LocationComponent;
import com.mapbox.mapboxsdk.location.OnCameraTrackingChangedListener;
import com.mapbox.mapboxsdk.location.modes.CameraMode;
import com.mapbox.mapboxsdk.location.modes.RenderMode;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.MapboxMap.OnMapClickListener;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;
import com.mapbox.mapboxsdk.maps.Style;
import com.mapbox.mapboxsdk.style.layers.LineLayer;
import com.mapbox.mapboxsdk.style.layers.Property;
import com.mapbox.mapboxsdk.style.layers.PropertyFactory;
import com.mapbox.mapboxsdk.style.layers.SymbolLayer;
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource;
import com.mapbox.mapboxsdk.text.LocalGlyphRasterizer;

import org.qap.ctimelineview.TimelineRow;
import org.qap.ctimelineview.TimelineViewAdapter;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import es.atrapandocucarachas.gpxparser.model.Gpx;
import es.atrapandocucarachas.gpxparser.model.Trk;
import es.atrapandocucarachas.gpxparser.model.Trkpt;
import es.atrapandocucarachas.gpxparser.model.Wpt;
import es.atrapandocucarachas.gpxparser.parser.GpxParser;

import static com.example.virtualcrit3_lite.Timer.getTimeStringFromMilliSecondsToDisplay;

public class MainActivity extends AppCompatActivity implements SharedPreferences.OnSharedPreferenceChangeListener, TextToSpeech.OnInitListener {

    private final static String TAG = MainActivity.class.getSimpleName();



    // Used in checking for runtime permissions.
    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

    // The BroadcastReceiver used to listen from broadcasts from the service.
    private MyReceiver myReceiver;

    // A reference to the service used to get location updates.
    private LocationUpdatesService mService = null;

    // Tracks the bound state of the service.
    private boolean mBound = false;

    // UI elements.
    private Button mRequestLocationUpdatesButton;
    private Button mRemoveLocationUpdatesButton;

    public void clickGpsStart(View view) {
        Log.i(TAG, "clickGpsStart: ");
    }

    public void clickGpsStop(View view) {
        Log.i(TAG, "clickGpsStop: ");
    }

    // Monitors the state of the connection to the service.
    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            LocationUpdatesService.LocalBinder binder = (LocationUpdatesService.LocalBinder) service;
            mService = binder.getService();
            mBound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mService = null;
            mBound = false;
        }
    };

    /**
     * Returns the current state of the permissions needed.
     */
    private boolean checkPermissions() {
        return  PackageManager.PERMISSION_GRANTED == ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private void requestPermissions() {
        boolean shouldProvideRationale =
                ActivityCompat.shouldShowRequestPermissionRationale(this,
                        Manifest.permission.ACCESS_FINE_LOCATION);

        // Provide an additional rationale to the user. This would happen if the user denied the
        // request previously, but didn't check the "Don't ask again" checkbox.
        if (shouldProvideRationale) {
            Log.i(TAG, "Displaying permission rationale to provide additional context.");
            Snackbar.make(
                    findViewById(R.id.activity_main),
                    R.string.permission_rationale,
                    Snackbar.LENGTH_INDEFINITE)
                    .setAction(R.string.ok, new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            // Request permission
                            ActivityCompat.requestPermissions(MainActivity.this,
                                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                                    REQUEST_PERMISSIONS_REQUEST_CODE);
                        }
                    })
                    .show();
        } else {
            Log.i(TAG, "Requesting permission");
            // Request permission. It's possible this can be auto answered if device policy
            // sets the permission in a given state or the user denied the permission
            // previously and checked "Never ask again".
            ActivityCompat.requestPermissions(MainActivity.this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                    REQUEST_PERMISSIONS_REQUEST_CODE);
        }
    }



    public void onClickShowUserTrackline(View view) {

        if (doSetUserTrackingLine) {
            doSetUserTrackingLine = false;
        } else {
            doSetUserTrackingLine = true;
            setMapboxStreets();
        }
    }

    public void onclickLeaderMessage(View view) {
        Log.i(TAG, "onclickLeaderMessage: ");
        inputFinishMessage();
    }

//    /**
//     * Callback received when a permissions request has been completed.
//     */

    //NOT WORKING!!!
//    @Override
//    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
//                                           @NonNull int[] grantResults) {
//        Log.i(TAG, "onRequestPermissionResult");
//        permissionsManager.onRequestPermissionsResult(requestCode, permissions, grantResults);
//
//        if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE) {
//            if (grantResults.length <= 0) {
//                // If user interaction was interrupted, the permission request is cancelled and you
//                // receive empty arrays.
//                Log.i(TAG, "User interaction was cancelled.");
//            } else if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                // Permission was granted.
//                mService.requestLocationUpdates();
//            } else {
//                // Permission denied.
//                setButtonsState(false);
//                Snackbar.make(
//                        findViewById(R.id.activity_main),
//                        R.string.permission_denied_explanation,
//                        Snackbar.LENGTH_INDEFINITE)
//                        .setAction(R.string.settings, new View.OnClickListener() {
//                            @Override
//                            public void onClick(View view) {
//                                // Build intent that displays the App settings screen.
//                                Intent intent = new Intent();
//                                intent.setAction(
//                                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
//                                Uri uri = Uri.fromParts("package",
//                                        BuildConfig.APPLICATION_ID, null);
//                                intent.setData(uri);
//                                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//                                startActivity(intent);
//                            }
//                        })
//                        .show();
//            }
//        }
//    }




    /**
     * Receiver for broadcasts sent by {@link LocationUpdatesService}.
     */
    private class MyReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            Location location = intent.getParcelableExtra(LocationUpdatesService.EXTRA_LOCATION);
            if (location != null) {
//                Toast.makeText(MainActivity.this, Utils.getLocationText(location), Toast.LENGTH_SHORT).show();

                //PROCESS ONLOCATION....
                Log.i(TAG, "onReceive: MainActivityLocation, calling LocationReceived: " + location.getProvider() + ":  " + location.getLatitude() + "," + location.getLongitude());
                //onMapboxLocationReceived(location);
                onTimerLocationReceived();

            }
        }
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String s) {
        // Update the buttons state depending on whether location updates are being requested.
        if (s.equals(Utils.KEY_REQUESTING_LOCATION_UPDATES)) {
            setButtonsState(sharedPreferences.getBoolean(Utils.KEY_REQUESTING_LOCATION_UPDATES,
                    false));
        }
    }

//    private void setButtonsState(boolean requestingLocationUpdates) {
//        if (requestingLocationUpdates) {
//            mRequestLocationUpdatesButton.setEnabled(false);
//            mRemoveLocationUpdatesButton.setEnabled(true);
//        } else {
//            mRequestLocationUpdatesButton.setEnabled(true);
//            mRemoveLocationUpdatesButton.setEnabled(false);
//        }
//    }


    private void setButtonsState(boolean requestingLocationUpdates) {
        if (requestingLocationUpdates) {
            mRequestLocationUpdatesButton.setEnabled(true);
            mRemoveLocationUpdatesButton.setEnabled(true);
        } else {
            mRequestLocationUpdatesButton.setEnabled(true);
            mRemoveLocationUpdatesButton.setEnabled(true);
        }
    }





    private MapView mapView;
    private MapboxMap mapboxMap;
    // variables for adding location layer
    private PermissionsManager permissionsManager;
    private LocationComponent locationComponent;
    // Variables needed to add the location engine
    private LocationEngine locationEngine;
    private long DEFAULT_INTERVAL_IN_MILLISECONDS = 2000L;
    private long DEFAULT_MAX_WAIT_TIME = 3000L;
// Variables needed to listen to location updates

    //private MainActivityLocationCallback callback = new MainActivityLocationCallback(this);



    private TextToSpeech engine;
    private TextView mTextMessage;
    private Button mValueTimer;


    //GPX
    private ArrayList<Double> latTemp = new ArrayList<Double>();
    private ArrayList<Double> lonTemp = new ArrayList<Double>();
    private ArrayList<String> namesTemp = new ArrayList<String>();



    private ArrayList<Double> critPointLocationLats = new ArrayList<>();
    private ArrayList<Double> critPointLocationLons = new ArrayList<>();
    private ArrayList<String> critPointLocationNames = new ArrayList<>();

    private String llp = "";
    private String lln = "";


    private void resetCritPointLocationArrays() {
        critPointLocationLats = new ArrayList<>();
        critPointLocationLons = new ArrayList<>();
        critPointLocationNames = new ArrayList<>();
    }

    private ArrayList<Wpt> wpts = new ArrayList<>();
    private ArrayList<Trkpt> trkpts = new ArrayList<>();
    private ArrayList<LatLng> critBuilderLatLng = new ArrayList<>();
    private ArrayList<String> critBuilderLatLngNames = new ArrayList<>();

    private ArrayList<Long> waypointTimesTim = new ArrayList<>();
    private ArrayList<Long> waypointTimesBest = new ArrayList<>();
    private String waypointTimesTimString;

    private long raceStartTime = 0;


    //TIMER
    private long startTime = 0;
    private String fbCurrentDate = "00000000";

    //SETTINGS
    private String settingsName = "TIM";
    private String settingsGPS = "OFF";
    private Boolean settingsAudio = true;
    private String settingsSport = "BIKE";
    private String settingsLeaderMessage = "SORRY, YOU CAN'T BEAT ME.";
    private int settingsSecondsPerRound = 1800;
    private int settingsMaxHeartrate = 185;

    //ROUND
    private int currentRound = 1;
    private double oldDistance = 0;
    private double roundHeartrateTotal = 0;
    private double roundHeartrateCount = 0;
    private double roundHeartrate = 0;
    private double bestRoundSpeed = 1;
    private double bestRoundHeartrate = 1;
    private double bestRoundScore = 1;

    //GPS
//    private FusedLocationProviderClient mFusedLocationClient;
//    private LocationCallback mLocationCallback;
    private ArrayList<Location> arrLocations = new ArrayList<>();
    private double geoSpeed = 0;
    private double geoDistance = 0.0;
    private double geoAvgSpeed = 0.0;
    private long oldTime = 0;
    private long newTime = 0;
    private long totalTimeGeo = 0;  //GPS MOVING TIME IN MILLI


    //HR
    //private int currentHR = 0;
    private int totHR;
    private int countHR;
    private double averageHR = 0;
    private Boolean showHR = false;

    private static final int PERMISSION_REQUEST_COARSE_LOCATION = 1;
    private static final long SCAN_PERIOD = 3000;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mLEScanner;
    private ArrayList<BluetoothDevice> devicesDiscoveredHR = new ArrayList<>();
    private ArrayList<BluetoothDevice> devicesConnectedHR = new ArrayList<>();
    private BluetoothDevice deviceHR;
    private BluetoothGatt mBluetoothGatt;

    //private static final UUID CSC_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
    //private static final UUID CSC_CHARACTERISTIC_UUID = UUID.fromString("00002a5b-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
    private static final UUID BTLE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

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


    public static final String MyPREFERENCES = "MyPrefs";
    public static final String Name = "nameKey";
    public static final String Sport = "sportKey";
    public static final String MaxHR = "maxhrKey";
    public static final String LeaderMsg = "leadermsgKey";
    SharedPreferences sharedpreferences;


    private void getSharedPrefs() {
        Log.i(TAG, "getSharedPrefs: ");
        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);

        settingsName = sharedpreferences.getString(Name, settingsName);
        settingsSport = sharedpreferences.getString(Sport, settingsSport);
        settingsMaxHeartrate = sharedpreferences.getInt(MaxHR, settingsMaxHeartrate);
        settingsLeaderMessage = sharedpreferences.getString(LeaderMsg, settingsLeaderMessage);

        Log.i(TAG, "getSharedPrefs: " + settingsName + settingsMaxHeartrate + settingsSport);

        displayName(settingsName);
        Crit.setRacerName(settingsName);
        Crit.setLeaderMessage(settingsLeaderMessage);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b1 = (Button) findViewById(R.id.valueEditMaxHR);
                b1.setText(String.format("%s  MAX HR", String.valueOf(settingsMaxHeartrate)));
                Button b2 = (Button) findViewById(R.id.valueEditSport);
                b2.setText(settingsSport);
                TextView t2 = (TextView) findViewById(R.id.valueLeaderMessage);
                t2.setText(settingsLeaderMessage);
            }
        });


    }

    private void setSharedPrefs() {
        Log.i(TAG, "setSharedPrefs: ");
        SharedPreferences.Editor editor = sharedpreferences.edit();

        editor.putString(Name, settingsName);
        editor.putString(LeaderMsg, settingsLeaderMessage);
        editor.putString(Sport, settingsSport);
        editor.putInt(MaxHR, settingsMaxHeartrate);
        editor.commit();
    }







    private int currentWaypoint = 0;
    private int maxWaypoint;
    private int maxTrackpoint;
    private String trkName = "NONE";

    private Boolean isCritGPXActive = false;

    //GPX
    public void startGPX() {
        Log.i(TAG, "startGPX");
        resetRace();

        isCritBuilderActive = false;
        isCritBuilderIDActive = false;
        isCritGPXActive = true;

        AssetManager assetManager = getAssets();
        GpxParser parser;
        Gpx gpx = null;

        try {


//            InputStream inputStream = getContentResolver().openInputStream(selectedfile);
            //InputStream inputStream = assetManager.open("Prospect_Park_Brooklyn_Single_Loop.gpx");
            InputStream inputStream = getContentResolver().openInputStream(selectedfile);

//            if (selectedfile != null) {
//                inputStream = getContentResolver().openInputStream(selectedfile);
//            }

            parser = new GpxParser(inputStream);
            gpx = parser.parse();

        } catch (IOException e) {
            e.printStackTrace();
        }

        assert gpx != null;
        wpts = gpx.getWpts();
        maxWaypoint = wpts.size();  //add start and finish as waypoints

        ArrayList<Trk> trks = gpx.getTrks();
        trkpts = trks.get(0).getTrkseg();
        trkName = trks.get(0).getName().toUpperCase();
        Log.i(TAG, "startGPX: trkName  " + trkName);
        maxTrackpoint = trkpts.size();
        Log.i(TAG, "trkpts size: " + maxTrackpoint);



        //reset arrays
        resetCritPointLocationArrays();
        lln = "";llp = "";
        //add start point/name
        critPointLocationLats.add(trkpts.get(0).getLat());
        critPointLocationLons.add(trkpts.get(0).getLon());
        critPointLocationNames.add(trks.get(0).getName());
        lln += trks.get(0).getName() + ",";
        llp += trkpts.get(0).getLat() + "," + trkpts.get(0).getLon() + ":";
        //add waypoints/names
        for (Wpt w : wpts) {
            Log.i("Name of waypoint ", w.getName());
            //Log.i("Coordinates ", String.valueOf(w.getLatLon()));
            critPointLocationLats.add(w.getLat());
            critPointLocationLons.add(w.getLon());
            critPointLocationNames.add(w.getName());
            lln += w.getName() + ",";
            llp += w.getLat() + "," + w.getLon() + ":";
        }

        //add finish
        critPointLocationLats.add(trkpts.get(trkpts.size()-1).getLat());
        critPointLocationLons.add(trkpts.get(trkpts.size()-1).getLon());
        critPointLocationNames.add("FINISH");
        lln += "FINISH";
        llp += trkpts.get(trkpts.size()-1).getLat() + "," + trkpts.get(trkpts.size()-1).getLon();

        latTemp = critPointLocationLats;
        lonTemp = critPointLocationLons;


//do this when getting back data from fb
        //addMapboxLine();
        
        if (critPointLocationNames.size() > 0) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {

                    TextView mGPS = findViewById(R.id.valueGPS);
                    mGPS.setText("ON");
                    settingsGPS = "ON";
                }
            });
            //addAnotherMarker(critPointLocationLats.get(0), critPointLocationLons.get(0));
            Crit.setRaceName(critPointLocationNames.get(0));
            createTimeline("CRIT GPX PROCESSED: " + critPointLocationNames.get(0).toUpperCase(), Timer.getCurrentTimeStamp());
            //requestRaceData(critPointLocationNames.get(0));
//            Log.i(TAG, "startGPX, GENERATE CRITID");
//            postRaceProcessing(0);

            Integer rd = Integer.valueOf(fbCurrentDate);
            long longTime = 0;
            Race postR = new Race("NEW", trkName.toUpperCase(),longTime, rd, waypointTimesTimString, llp, lln);
            Log.i(TAG, "after startGPX: postRaceProcessing " + postR.toString());
            postRaceProcessing(postR);


        }


    }


    //TIMES FOR RACE

    private ArrayList<Long> raceTimesTim = new ArrayList<>();
    private long bestRaceTime = -1;
    private String bestRacerName = "";



    //CHECKPOINTS
    private long lastCheckpointTime = 0;
    private int distanceBetweenValue = 100;
    private Boolean isRaceStarted = false;


    //RACE FCTNS
    private void resetRace() {
        Log.i(TAG, "resetRace: ");
        int currentTrackpoint = 0;
        lastCheckpointTime = 0;
        raceStartTime = 0;
        isRaceStarted = false;

        Timer.raceStartTime = 0;
        Timer.isRaceStarted = false;
        Timer.currentWaypointCB = 0;

    }



    private void postRaceProcessing(final Race r) {
        Log.i(TAG, "postRaceProcessing, Race r");

        //Integer raceDate = Integer.valueOf(fbCurrentDate);
//        String raceName = trkName;
        Integer raceDate = r.raceDate;
        final String raceName = r.raceName;

        //Race r = new Race(settingsName, raceName, rt, raceDate, waypointTimesTimString, llp, lln);
        Log.i(TAG, "postRaceProcessing: r");

        //WRITE RACE DATA
        Log.i(TAG, "fbWrite Race Data: ");
        String raceURL = "race/" + r.raceName;
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference(raceURL);
        // Creating new user node, which returns the unique key value
        // new user node would be /users/$userid/
        String userId = mDatabase.push().getKey();
        // creating user object
//        Round round = new Round(settingsName, roundSpeed, roundHeartrate, returnScoreFromHeartrate(pastRoundHeartrate), (currentRound - 1));
        // pushing user to 'users' node using the userId
        mDatabase.child(userId).setValue(r)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        // Write was successful!
                        Log.i(TAG, "onSuccess: write RACE was successful");

                        if (isCritGPXActive) {
                            Log.i(TAG, "onSuccess: critGPXActive == true, requestRaceData for " + raceName);
                            requestRaceData(raceName);
                            isCritGPXActive = false;
                        }

                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        // Write failed
                        Log.i(TAG, "onFailure: write RACE failed");
                    }
                });
    }


    private ArrayList<String> listOfCrits = new ArrayList<>();

    private void listOnlineCrits() {
        String r1 = "race";
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference(r1);
        listOfCrits = new ArrayList<>();

        mDatabase.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot oneTimeDS) {

                for (DataSnapshot oneDS : oneTimeDS.getChildren()) {
                    //Log.i(TAG, "onDataChange: have oneTime snapshot");
                    final String oT = oneDS.toString();
                    final String otKey = Objects.requireNonNull(oneDS.getKey()).toUpperCase();
                    //Log.i(TAG, "onDataChange: otKey " + otKey);
                    listOfCrits.add(otKey);
                }

                Log.i(TAG, "onDataChange: allCrits " + listOfCrits.toString());

            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                Log.i(TAG, "onCancelled: db error getting list");
            }
        });
    }


    private ValueEventListener valueEventListener;
    private String oldRaceDataName;


    private void requestRaceData(String raceDataName) {


        Log.i(TAG, "fb request race data for " + raceDataName);
        String raceURL = "race/" + raceDataName;
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference(raceURL);

        //remove all listners
        if (valueEventListener != null) {
            Log.i(TAG, "requestRaceData: remove old listner first");
            mDatabase.removeEventListener(valueEventListener);            
        }
        if (oldRaceDataName != null) {
            Log.i(TAG, "requestRaceData: remove old listner for: " + oldRaceDataName);
            String raceURLremove = "race/" + oldRaceDataName;
            DatabaseReference mDatabaseRemove = FirebaseDatabase.getInstance().getReference(raceURLremove);
            mDatabaseRemove.removeEventListener(valueEventListener);
        }

        oldRaceDataName = raceDataName;


        //REQUEST RACE DATA
        valueEventListener = mDatabase.limitToFirst(1).orderByChild("raceTimeToComplete").addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                Log.i(TAG, "onDataChange: READ RACE DATA");

                for (DataSnapshot ds : dataSnapshot.getChildren()) {
                    Log.i(TAG, "onDataChange: have race data snapshot");
                    final String raceName = ds.child("raceName").getValue(String.class);
                    String riderName = ds.child("riderName").getValue(String.class);
                    String raceWaypointTimes = ds.child("waypointTimes").getValue(String.class);
                    Integer raceTimeToComplete = ds.child("raceTimeToComplete").getValue(Integer.class);



                    String lm = ds.child("leaderMessage").getValue(String.class);
                    if (lm != null) {
                        Log.i(TAG, "onDataChange: leadermessage: " + lm);
                        Timer.setBestRacerLeaderMessage(lm);
                    } else {
                        lm = "";
                    }


                    if (raceName == null) {
                        Log.i(TAG, "onDataChange: raceName is null");
                        return;
                    }
                    Log.i(TAG, "onDataChange: raceName " + raceName);

                    String post1 = "";
                    String post2 = "";
                    //String post2b = "\n" + lm;


                    if (Objects.equals(Crit.getRaceName(), raceName)) {
                        Log.i(TAG, "onDataChange: same race name");
                        //post1 = raceName.toUpperCase() + "  IS LOADED, PROCEED TO START.\n";
                    } else {
                        Crit.setRaceName(raceName);
                        post1 = raceName.toUpperCase() + "  IS LOADED, PROCEED TO START.\n";
                    }


                    if (raceTimeToComplete == null || raceTimeToComplete == 2147483646) {
                        Log.i(TAG, "onDataChange: no racetime, first racer");
                    } else {
                        Log.i(TAG, "onDataChange: RACE, LEADER, TIME: " + raceName + ",  " + riderName + ",  " + getTimeStringFromMilliSecondsToDisplay(raceTimeToComplete) + ".");
//                        post2 = "ACTIVE CRIT UPDATE FOR \n" + raceName.toUpperCase() + ".\nCRIT LEADER IS: " + riderName + ",  " + getTimeStringFromMilliSecondsToDisplay(raceTimeToComplete) + ".";
                        post2 = "\nUPDATE:  THE CRIT LEADER IS " + riderName + ".\n" + getTimeStringFromMilliSecondsToDisplay(raceTimeToComplete) + ".\n\n" + lm;
                        //speakText("CRIT LEADER IS " + riderName + ".  FOR " + raceName);
                        //speakText(post2);
                        //createTimeline(post, Timer.getCurrentTimeStamp());
                    }

                    Log.i(TAG, "onDataChange: WAYPOINT Times: " + raceWaypointTimes);

                    String post3 = post1 + post2;
                    speakText(post3);
                    createTimeline(post3, Timer.getCurrentTimeStamp());



                    String dwnloadPoints = ds.child("llPoints").getValue(String.class);
                    String dwnloadNames = ds.child("llNames").getValue(String.class);


                    Log.i(TAG, "onDataChange: dwnloadPoints " + dwnloadPoints);
                    Log.i(TAG, "onDataChange: dwnloadNames " + dwnloadNames);

                    if (dwnloadPoints != null && dwnloadNames != null) {
                        Log.i(TAG, "onDataChange: calling convertPointNamesToCrit, to call startFrom Id");
                        convertPointsNamesToCrit(dwnloadPoints, dwnloadNames);
                        Timer.setWaypointNamesString(dwnloadNames);
                        Timer.setWaypointPointsString(dwnloadPoints);

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                TextView tv1 = (TextView) findViewById(R.id.valueCritIdName);
                                tv1.setText(raceName.toUpperCase());
                                TextView tv2 = (TextView) findViewById(R.id.valueActiveCritName);
                                tv2.setText(raceName.toUpperCase());

                                TextView mGPS = findViewById(R.id.valueGPS);
                                mGPS.setText("ON");
                                settingsGPS = "ON";

                                //setMessageText(raceName.toUpperCase() + " IS ACTIVE");
                                //createTimeline("ACTIVE CRIT: " + raceName.toUpperCase(), Timer.getCurrentTimeStamp());
                            }
                        });
                    }



                    //CONVERT STRING TO ARR-BEST
                    //convert string to ArrayList with splice
                    if (raceWaypointTimes != null) {
                        ArrayList<String> str = new ArrayList<String>(Arrays.asList(raceWaypointTimes.split(",")));
                        //convert ArrayList of Strings to ArrayList of Longs
                        ArrayList<Long> longs = new ArrayList<>();
                        for (String s : str) {
                            Long l = null;
                            l = Long.valueOf(s);
                            longs.add(l);
                        }
                        Log.i(TAG, "trackpointTest: longs: " + longs.toString());

                        bestRaceTime = raceTimeToComplete;
                        waypointTimesBest = longs;
                        bestRacerName = riderName.toUpperCase();

                        Timer.setBestRacerName(riderName.toUpperCase());
                        Timer.setBestRaceTime(raceTimeToComplete);
                        Timer.setWaypointTimesBest(longs);
                        Timer.setBestRacerLeaderMessage(lm);

                        Log.i(TAG, "onDataChange: waypointTimesBest: " + waypointTimesBest.toString());
                    } else {
                        waypointTimesBest = new ArrayList<>();
                        Timer.setWaypointTimesBest(new ArrayList<Long>());
                        Timer.setBestRaceTime(2147483646);
                    }


                    //END CONVERT
                }  //COMPLETED - READING EACH SNAP
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // Failed to read value
                Log.i(TAG, "Failed to read value - RACE", databaseError.toException());
            }
        });
    }


    //TEXT TO SPEECH
    public void speakText(String st) {
        if (!settingsAudio) {
            return;
        }
        engine.speak(st, TextToSpeech.QUEUE_ADD, null, null);

        Toast.makeText(MainActivity.this, st, Toast.LENGTH_SHORT).show();
    }


    @Override
    public void onInit(int i) {
        if (i == TextToSpeech.SUCCESS) {
            //Setting speech Language
            engine.setLanguage(Locale.ENGLISH);
            engine.setPitch(1);
        }
    }


    private void calcAvgHR(int hr) {
        if (hr > 50) {
            //TOTAL
            totHR += hr;
            countHR += 1;
            averageHR = (double) totHR / (double) countHR;
            //ROUND
            roundHeartrateTotal += hr;
            roundHeartrateCount += 1;
            roundHeartrate = (double) roundHeartrateTotal / (double) roundHeartrateCount;
        }
    }

    private double returnScoreFromHeartrate(double hr) {
        return ((double) hr) / ((double) settingsMaxHeartrate) * 100.0;
    }

    @SuppressLint("DefaultLocale")
    private void roundEndCalculate() {
        Log.i(TAG, "roundEndCalculate: removed...");
//        double newDistance = geoDistance;
//        double roundDistance = newDistance - oldDistance; //MILES
//        double roundSpeed = roundDistance / ((double) settingsSecondsPerRound / 60.0 / 60.0);
//        double pastRoundHeartrate = roundHeartrate;
//
//        Log.i(TAG, "roundEndCalculate: roundHeartrate:  " + String.format("%.1f BPM", roundHeartrate));
//        Log.i(TAG, "roundEndCalculate: roundSpeed:  " + String.format("%.2f MPH", roundSpeed));
//
//        if (roundSpeed > bestRoundSpeed) {
//            //vibrator600();
//            bestRoundSpeed = roundSpeed;
//            //createTimeline("MY FASTEST SPEED" + "\n[" + String.format("%.2f MPH", bestRoundSpeed) + "]", "");
//        } else {
//            //vibrator300();
//            Log.i(TAG, "roundEndCalculate: not the best");
//        }
//        if (returnScoreFromHeartrate(roundHeartrate) > bestRoundScore) {
//            bestRoundScore = returnScoreFromHeartrate(roundHeartrate);
////            createTimeline("HIGHEST SCORE" + "  [" + String.format("%.2f", bestRoundScore) + "]", "");
//        } else {
//            Log.i(TAG, "roundEndCalculate: not the best");
//        }
//        if (roundHeartrate > bestRoundHeartrate) {
//            bestRoundHeartrate = roundHeartrate;
////            createTimeline("MY HIGHEST HR" + "  [" + String.format("%.1f BPM", bestRoundHeartrate) + "]", "");
//            //createTimeline("MY HIGHEST SCORE" + "\n[" + String.format("%.2f %%MAX", returnScoreFromHeartrate(bestRoundHeartrate)) + "]", "");
//        } else {
//            Log.i(TAG, "roundEndCalculate: not the best");
//        }
//        String s1 = "COMPLETED ROUND: " + (currentRound - 1);
//        String s2 = "\nSPEED: " + String.format("%.2f MPH", roundSpeed);
//        String s2x = "  [" + String.format("%.2f MPH", bestRoundSpeed) + "]";
//        String s3 = "\nHR:  " + String.format("%.1f BPM", roundHeartrate);
//        String s3x = "  [" + String.format("%.1f BPM", bestRoundHeartrate) + "]";
//        String s4 = "\nSCORE:  " + String.format("%.0f%%", returnScoreFromHeartrate(bestRoundHeartrate));
//        String s4x = "  [" + String.format("%.0f%%", returnScoreFromHeartrate(bestRoundHeartrate)) + "]";
//        //createTimeline("ROUND "+ currentRound + ":\nSPEED: " + String.format("%.2f MPH", roundSpeed)+ "\nHR:  " + String.format("%.1f BPM", roundHeartrate), Timer.getCurrentTimeStamp());
//
////        if (roundHeartrate > 50) {
////            createTimeline(s1 + s2 + s2x + s3 + s3x + s4 + s4x, Timer.getCurrentTimeStamp());
////        } else {
////            createTimeline(s1 + s2 + s2x, Timer.getCurrentTimeStamp());
////        }
////        setMessageText("R" + (currentRound - 1) + ": SPEED: " + String.format("%.1f MPH", roundSpeed) + ",  HR:  " + String.format("%.0f BPM", roundHeartrate));
//        Log.i(TAG, "roundEndCalculate: \n" + s1 + s2 + s2x + s3 + s3x);
//
//        if (roundHeartrateCount == 0) {
//            showHR = false;
//        } else {
//            showHR = true;
//        }
//
//        //after...
//        oldDistance = newDistance;
//        roundHeartrateTotal = 0;
//        roundHeartrateCount = 0;
//        roundHeartrate = 0;

        //ROUNDS
        //WRITE END OF ROUND DATA
//        Log.i(TAG, "fbWriteNewRound: ");
//        String roundURL = "rounds/" + fbCurrentDate;
//        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference(roundURL);
//        // Creating new user node, which returns the unique key value
//        // new user node would be /users/$userid/
//        String userId = mDatabase.push().getKey();
//        // creating user object
//        Round round = new Round(settingsName, roundSpeed, roundHeartrate, returnScoreFromHeartrate(pastRoundHeartrate), (currentRound - 1));
//        // pushing user to 'users' node using the userId
//        mDatabase.child(userId).setValue(round)
//                .addOnSuccessListener(new OnSuccessListener<Void>() {
//                    @Override
//                    public void onSuccess(Void aVoid) {
//                        // Write was successful!
//                        Log.i(TAG, "onSuccess: write ROUNDS was successful");
//                        //fbWriteNewTotal();
//                    }
//                })
//                .addOnFailureListener(new OnFailureListener() {
//                    @Override
//                    public void onFailure(@NonNull Exception e) {
//                        // Write failed
//                        Log.i(TAG, "onFailure: write ROUNDS failed");
//                    }
//                });

        //TOTALS
//        Log.i(TAG, "fbWriteNewTotal: ");
//        //WRITE UPDATE TOTAL DATA
//        String totalsURL = "totals/" + fbCurrentDate + "/" + settingsName;
//        DatabaseReference mDatabaseTotals = FirebaseDatabase.getInstance().getReference(totalsURL);
//        DecimalFormat df = new DecimalFormat("#.##");
//        Total total = new Total(settingsName, Double.valueOf(df.format(returnScoreFromHeartrate(averageHR))), Double.valueOf(df.format(geoAvgSpeed)));
//        mDatabaseTotals.setValue(total)
//                .addOnSuccessListener(new OnSuccessListener<Void>() {
//                    @Override
//                    public void onSuccess(Void aVoid) {
//                        // Write was successful!
//                        Log.i(TAG, "onSuccess: write TOTALS was successful");
//                    }
//                })
//                .addOnFailureListener(new OnFailureListener() {
//                    @Override
//                    public void onFailure(@NonNull Exception e) {
//                        // Write failed
//                        Log.i(TAG, "onFailure: write TOTALS failed");
//                    }
//                });
//
//
//        if ((currentRound - 1) == 1) {
//
//            //REQUEST ROUND SPD LEADER
//            mDatabase.limitToLast(1).orderByChild("fb_SPD").addValueEventListener(new ValueEventListener() {
//                @Override
//                public void onDataChange(DataSnapshot dataSnapshot) {
//                    Log.i(TAG, "onDataChange: ROUNDS");
//
//                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
//                        String name = ds.child("fb_timName").getValue(String.class);
//                        Double speed = ds.child("fb_SPD").getValue(Double.class);
//                        Log.i(TAG, "onDataChange: ROUND LEADER: " + (String.format("%s.  %s", String.format(Locale.US, "%.2f MPH", speed), name)));
//                        if (speed > 3) {
//                            //createTimeline("FASTEST \n" + (String.format("%s  %s", String.format(Locale.US, "%.2f MPH", speed), name)), "");
//                            //speakText("Fastest is now " + String.format(Locale.US, "%.1f ", speed) + " MPH.  " + "Recorded by " + name);
//                        }
////                        createTimeline("FASTEST \n" + (String.format("%s  %s", String.format(Locale.US, "%.2f MPH", speed), name)), "");
////                        speakText("Fastest  is now " + String.format(Locale.US, "%.1f ", speed) + " MPH.  " + "Recorded by " + name);
//                    }  //COMPLETED - READING EACH SNAP
//                }
//
//                @Override
//                public void onCancelled(DatabaseError databaseError) {
//                    // Failed to read value
//                    Log.i(TAG, "Failed to read value - ROUNDS", databaseError.toException());
//                }
//            });
//            //END READ ROUNDS FOR SPEED LEADER
//
//
//            //REQUEST TOTAL SPD LEADER
//            String totalsURLlistener = "totals/" + fbCurrentDate;
//            DatabaseReference mDatabaseTotalsListener = FirebaseDatabase.getInstance().getReference(totalsURLlistener);
//            mDatabaseTotalsListener.limitToLast(1).orderByChild("a_speedTotal").addValueEventListener(new ValueEventListener() {
//                @Override
//                public void onDataChange(DataSnapshot dataSnapshot) {
//                    Log.i(TAG, "onDataChange: TOTAL SPEED");
//
//                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
//                        String name = ds.child("fb_timName").getValue(String.class);
//                        Double speed = ds.child("a_speedTotal").getValue(Double.class);
//                        Log.i(TAG, "onDataChange: TOTAL LEADER SPEED:  " + (String.format("%s.  %s", String.format(Locale.US, "%.2f MPH", speed), name)));
//                        //createTimeline("DAILY SPEED LEADER\n" + (String.format("%s  %s", String.format(Locale.US, "%.2f MPH", speed), name)), "");
//                    }  //COMPLETED - READING EACH SNAP
//                }
//
//                @Override
//                public void onCancelled(DatabaseError databaseError) {
//                    // Failed to read value
//                    Log.i(TAG, "Failed to read value - TOTALS", databaseError.toException());
//                }
//            });
//            //END READ TOTALS FOR SPEED LEADER
//
//            //REQUEST ROUND SCORE LEADER
//            mDatabase.limitToLast(1).orderByChild("fb_RND").addValueEventListener(new ValueEventListener() {
//                @Override
//                public void onDataChange(DataSnapshot dataSnapshot) {
//                    Log.i(TAG, "onDataChange: ROUND SCORES");
//
//                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
//                        String name = ds.child("fb_timName").getValue(String.class);
//                        Double score = ds.child("fb_RND").getValue(Double.class);
//                        Log.i(TAG, "onDataChange: ROUND LEADER SCORES: " + (String.format("%s.  %s", String.format(Locale.US, "%.2f %%MAX", score), name)));
//
////                        if (score < 10) {
////                            Log.i(TAG, "onDataChange: score too low to publish");
////                            return;
////                        } else {
////                            createTimeline("BEST CRIT SCORE\n" + (String.format("%s  %s", String.format(Locale.US, "%.2f %%MAX", score), name)), "");
////                        }
//
//
//                    }  //COMPLETED - READING EACH SNAP
//                }
//
//                @Override
//                public void onCancelled(DatabaseError databaseError) {
//                    // Failed to read value
//                    Log.i(TAG, "Failed to read value - ROUNDS", databaseError.toException());
//                }
//            });
//            //END READ ROUNDS FOR SCORE LEADER
//
//            //REQUEST TOTALS SCORE LEADER
//            mDatabaseTotalsListener.limitToLast(1).orderByChild("a_scoreHRTotal").addValueEventListener(new ValueEventListener() {
//                @Override
//                public void onDataChange(DataSnapshot dataSnapshot) {
//                    Log.i(TAG, "onDataChange: TOTAL SCORE");
//
//                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
//                        String name = ds.child("fb_timName").getValue(String.class);
//                        Double score = ds.child("a_scoreHRTotal").getValue(Double.class);
//
//                        if (score < 10) {
//                            Log.i(TAG, "onDataChange: score too low to publish");
//                            return;
//                        }
//
//                        Log.i(TAG, "onDataChange: TOTAL LEADER SCORE:  " + (String.format("%s.  %s", String.format(Locale.US, "%.2f %%MAX", score), name)));
//                        //createTimeline("DAILY SCORE LEADER\n" + (String.format("%s  %s", String.format(Locale.US, "%.2f %%MAX", score), name)), "");
//                    }  //COMPLETED - READING EACH SNAP
//                }
//
//                @Override
//                public void onCancelled(DatabaseError databaseError) {
//                    // Failed to read value
//                    Log.i(TAG, "Failed to read value - TOTALS", databaseError.toException());
//                }
//            });
//            //END REQUEST TOTAL SCORE LEADER
//        } //ADD VALUE EVENT ONCE
    }  //END - ROUND END CALCULATE


    //TIMER
    Handler timerHandler = new Handler();
    Runnable timerRunnable = new Runnable() {
        @SuppressLint("DefaultLocale")
        @Override
        public void run() {
            final long totalMillis = System.currentTimeMillis() - startTime;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mValueTimer.setText(getTimeStringFromMilliSecondsToDisplay((int) totalMillis));

                    TextView t1 = findViewById(R.id.tvHeader1);
                    t1.setText(getTimeStringFromMilliSecondsToDisplay((int) totalMillis));

                    int a1 = (int) totalMillis / 1000;
                    int a2 = (currentRound - 1) * settingsSecondsPerRound;
                    int a3 = a1 - a2;
                    int togo = settingsSecondsPerRound - a3;
                    String s1 = getTimeStringFromMilliSecondsToDisplay(togo * 1000);
                    String s2 = " ROUND";
//                    rnd.setText(getTimeStringFromMilliSecondsToDisplay(togo * 1000));
                    //rnd.setText(s1+s2);
                }
            });


            if (totalMillis > (currentRound * settingsSecondsPerRound * 1000)) {
                currentRound += 1;
                Log.i(TAG, "round " + (currentRound - 1) + " complete");
                //setMessageText("ROUND " + (currentRound));
                //roundEndCalculate();
                //PROCESS NEW ROUND
                //no longer doing rounds...
            }

            if ((int) totalMillis / 1000 == 5) {
                Log.i(TAG, "at 5 sec: auto request permissions");
                checkAndSetPermissions();
                //mService.requestLocationUpdates();

            }

            if ((int) totalMillis / 1000 == 10) {
                Log.i(TAG, "at 10 sec: auto request updates");
                //checkAndSetPermissions();
                mService.requestLocationUpdates();
                setMessageText("STARTING LOCATION TRACKING");
            }

            if ((int) totalMillis / 1000 == 5) {
                Log.i(TAG, "at 5 sec: auto request updates");
                setMessageText("STARTING LOCATION TRACKING");
                makeToast("STARTING LOCATION TRACKING");
            }


            if ((int) totalMillis / 1000 > 12) {
                //EVERY 12 SECONDS
                //REALLY ONLY NEED TO DO THINGS WHILE PAUSED?
//                Log.i(TAG, "run: 12 SECOND UPDATE");

//                if ((int) totalMillis / 1000 % 12 == 0) {
//                    //EVERY 12, UPDATE MAP
//                    Log.i(TAG, "run: 12 SECOND UPDATE MAP");
//                    if (Timer.trackerCoords.size() > 2) {
//                        if (!isPaused) {
//                            setMapboxStreets();
//                        }
//
//                    }
//                }

                if ((int) totalMillis / 1000 % 3 == 0) {
                    //EVERY 3, PUBLISH TO FB IF NEEDED
                    //Log.i(TAG, "run: 3 SECOND UPDATE FB PUBLISH");
                    if (Timer.isTimeToPostRaceData) {
                        Log.i(TAG, "run: TIME TO PUBLISH DATA");
                        Log.i(TAG, "run: is RaceStarted, publish");
                        final Race r = Timer.publishMe;
                        postRaceProcessing(r);
                        Timer.isTimeToPostRaceData = false;
                    }
                }

                if ((int) totalMillis / 1000 % 5 == 0) {
                    //EVERY 5, TIMELINE AND SET MESSAGE
                    //Log.i(TAG, "run: 2 SECOND UPDATE PUBLISH");
                    //Log.i(TAG, "size of Timer.getStringForSetMessage + " + Timer.getStringForSetMessage().size());

                    if (Timer.getStringForSetMessage().size() > 0) {
                        final ArrayList<String> s = Timer.getStringForSetMessage();
                        setMessageText(s.get(s.size()-1));
                        Timer.setStringForSetMessage(new ArrayList<String>());
                    } else {
                        //Log.i(TAG, "run: NO MESAGE TO SET");
                        setMessageText(".");
                    }

                    //Log.i(TAG, "size of Timer.getStringForTimeline + " + Timer.getStringForTimeline().size());
                    if (Timer.getStringForTimeline().size() > 0) {
                        //Log.i(TAG, "run: PUBLISH TIMELINE");
                        final ArrayList<String> s2 = Timer.getStringForTimeline();
                        final ArrayList<String> s3 = Timer.getStringForTimelineTime();
                        Timer.setStringForTimeline(new ArrayList<String>());
                        Timer.setStringForTimelineTime(new ArrayList<String>());

                        //StringBuilder sxx = new StringBuilder();
                        for (String str2 : s2) {
                            //sxx.append(str2);
                            createTimeline(str2, s3.get(0));
                        }

//                        if (Objects.equals(s2.get(0), "")) {
//                            return;
//                        }
//                        createTimeline(sxx.toString(), s3.get(0));


                    } else {
                        //Log.i(TAG, "run: NO TIMELINE TO CREATE");
                    }




                }

                //ASSUME TTS QUEUE WILL WORK
                if ((int) totalMillis / 1000 % 5 == 0) {
                    //Log.i(TAG, "run: 5 SECOND UPDATE REFRESH FOR SPEAKER");
                    //FOR SPEAKER
                    if (Timer.getStringForSpeak().size() > 0) {
                        Log.i(TAG, "run: stringForSpeak " + Timer.getStringForSpeak().toString());
                        final ArrayList<String> s1 = Timer.getStringForSpeak();
                        Timer.setStringForSpeak(new ArrayList<String>());
                        //StringBuilder ns = new StringBuilder();
                        for (String str1 : s1) {
                            speakText(str1 + ".  ");
                            //ns.append(str1).append(".  ");
                        }
                        //speakText(ns.toString());

                    }

                }

                if ((int) totalMillis / 1000 == 30) {
                    Log.i(TAG, "run: 30 SECOND UPDATE ATTEMPT ENABLE MAPBOX LOCATIONS");
                    if (Timer.timerAllLocations.size() > 1) {
                        //TRY TO ENABLE MAPBOX LOCATIONS
                        Log.i(TAG, "WE HAVE LOCATIONS, ATTEMPT ENABLE MAPBOX LOCATION COMPONENT");
                        attemptToEnableMapboxLocationComponent();
                        makeToast("ATTEMPT LOCATION TRACKING");
                    }
                }

                if ((int) totalMillis / 1000 > 60 && (int) totalMillis / 1000 % 100 == 0)  {
                    Log.i(TAG, "run: IF TRACKING IS BROKE, TRY TO ENABLE ENABLE MAPBOX LOCATIONS");
                    if (isTrackingDisabled) {
                        //TRY TO ENABLE MAPBOX LOCATIONS
                        Log.i(TAG, "isTrackingDisabled, ATTEMPT ENABLE MAPBOX LOCATION COMPONENT..AGAIN");
                        attemptToEnableMapboxLocationComponent();
                        //makeToast("ATTEMPT LOCATION TRACKING AGAIN");
//                        isTrackingDisabled = false;
                    }
                }



            }



            timerHandler.postDelayed(this, 1000);
        }
    };


    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {

            ScrollView sv = findViewById(R.id.svSettings);
            LinearLayout ll = findViewById(R.id.llView);
            LinearLayout tl = findViewById(R.id.llTimeline);
            //MapView mv = findViewById(R.id.mapView);

            switch (item.getItemId()) {
                case R.id.navigation_home:
//                    mTextMessage.setVisibility(View.VISIBLE);
                    //mTextMessage.setVisibility(View.GONE);
                    //setMessageText("HOME");
                    ll.setVisibility(View.GONE);
                    tl.setVisibility(View.GONE);
                    sv.setVisibility(View.GONE);
                    return true;
                case R.id.navigation_dashboard:
                    ll.setVisibility(View.VISIBLE);
                    sv.setVisibility(View.GONE);
                    //mTextMessage.setVisibility(View.GONE);
                    tl.setVisibility(View.GONE);
                    return true;
                case R.id.navigation_notifications:
                    ll.setVisibility(View.GONE);
                    sv.setVisibility(View.GONE);
                    //mTextMessage.setVisibility(View.GONE);
                    tl.setVisibility(View.VISIBLE);
                    return true;
                case R.id.navigation_settings:
                    //setMessageText("SETTINGS");
                    ll.setVisibility(View.GONE);
                    tl.setVisibility(View.GONE);
                    sv.setVisibility(View.VISIBLE);
                    //mTextMessage.setVisibility(View.VISIBLE);
                    return true;
            }
            return false;
        }
    };


    private void checkAndSetPermissions() {
        Log.i(TAG, "checkAndSetPermissions: ");
        // Make sure we have access coarse location enabled, if not, prompt the user to enable it
        if (this.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            Log.i(TAG, "PROMPT FOR LOCATION ENABLED");
//            final AlertDialog.Builder builder = new AlertDialog.Builder(this);
//            builder.setTitle("This app needs location access");
//            builder.setMessage("Please grant location access so this app can detect peripherals and use GPS to calculate speed and distance.");
//            builder.setPositiveButton(android.R.string.ok, null);
//            builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
//                @Override
//                public void onDismiss(DialogInterface dialog) {
//                    requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
//                }
//            });
//            builder.show();

            ActivityCompat.requestPermissions(MainActivity.this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                    REQUEST_PERMISSIONS_REQUEST_CODE);

            //or
            //requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);

        } else {
            Log.i(TAG, "LOCATION IS ALREADY ENABLED");
        }
        
        
    }
    
    @SuppressLint("StaticFieldLeak")
    static MainActivity mn;

    @SuppressLint("DefaultLocale")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mn=MainActivity.this;

        Mapbox.getInstance(this, getString(R.string.access_token));
        setContentView(R.layout.activity_main);

        //Log.i(TAG, "onCreate: checkAndSetPermissions");


        myReceiver = new MyReceiver();
        // Check that the user hasn't revoked permissions by going to Settings.
//        if (Utils.requestingLocationUpdates(this)) {
//            if (!checkPermissions()) {
//                requestPermissions();
//            }
//        }



        mTextMessage = (TextView) findViewById(R.id.message);
        mValueTimer = findViewById(R.id.valueTimer);


        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

//        timerStart(getCurrentFocus());
        timerStart2();

        createTimeline("LET'S GET STARTED", Timer.getCurrentTimeStamp());
        setRandomUsernameOnStart();
        getSharedPrefs();

        engine = new TextToSpeech(this, this);
        //startGPS();

        int yearInt = Calendar.getInstance(Locale.ENGLISH).get(Calendar.YEAR);
        int monthInt = Calendar.getInstance(Locale.ENGLISH).get(Calendar.MONTH);
        int dayInt = Calendar.getInstance(Locale.ENGLISH).get(Calendar.DAY_OF_MONTH);
        fbCurrentDate = String.format("%02d%02d%02d", yearInt, monthInt + 1, dayInt);
        Crit.setRaceDate(Integer.valueOf(fbCurrentDate));

//        boolean b = checkLocationPermissions();
//        Log.i(TAG, "onCreate: checkLocationPermissions: " + checkLocationPermissions());

        mapView = findViewById(R.id.mapView);
        mapView.onCreate(savedInstanceState);
        //mapView.getMapAsync(this);
        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {

//                mapboxMap.setStyle(Style.LIGHT, new Style.OnStyleLoaded() {
                mapboxMap.setStyle(Style.MAPBOX_STREETS, new Style.OnStyleLoaded() {
                    @Override
                    public void onStyleLoaded(@NonNull Style style) {
                        Log.i(TAG, "onStyleLoaded: ");


                        mapboxMap.addOnMapClickListener(new OnMapClickListener() {
                            @Override
                            public boolean onMapClick(@NonNull LatLng point) {
                                Log.i(TAG, "onMapClick: " + point.getLatitude() + ", " + point.getLongitude());
                                //String string = String.format(Locale.US, "User clicked at: %s", point.toString());
                                //Toast.makeText(MainActivity.this, string, Toast.LENGTH_LONG).show();

                                if (collectCritPoints) {
                                    critBuilderLatLng.add(point);
                                    addAnotherMarkerCB(point.getLatitude(), point.getLongitude());
                                    llp += point.getLatitude() + "," + point.getLongitude() + ":";
                                    //get name from input
                                    inputWaypointName();
                                }
                                return false;
                            }
                        });



                    }
                });
            }
        });


    }

    //MULTIPLE MARKERS
    private boolean isRaceLoaded = false;
    private int raceNumber = 10;
    private boolean isTrackingDisabled = false;


    private boolean haveAttemptedToLoadMapboxLocationComponent = true;
    //START attemptToEnableMapboxLocationComponent
    private void attemptToEnableMapboxLocationComponent() {
        Log.i(TAG, "attemptToEnableMapboxLocationComponent");
        if (!haveAttemptedToLoadMapboxLocationComponent) {
            Log.i(TAG, "attemptToEnableMapboxLocationComponent: DON'T TRY AGAIN, OR MABYE TRY NEXT MINUTE...");
        }

        mapView.getMapAsync(new OnMapReadyCallback() {
            @SuppressLint("MissingPermission")
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {

                Style style = mapboxMap.getStyle();
                // Get an instance of the component
                LocationComponent locationComponent = mapboxMap.getLocationComponent();

                // Activate with options
                //locationComponent.activateLocationComponent(this, style);
                locationComponent.activateLocationComponent(mn, Objects.requireNonNull(style));

                // Enable to make component visible
                locationComponent.setLocationComponentEnabled(true);

                // Set the component's camera mode
                locationComponent.setCameraMode(CameraMode.TRACKING);
//                locationComponent.setCameraMode(CameraMode.TRACKING_GPS);
                isTrackingDisabled = false;

                // Set the component's render mode
                locationComponent.setRenderMode(RenderMode.COMPASS);

                haveAttemptedToLoadMapboxLocationComponent = false;

                locationComponent.addOnCameraTrackingChangedListener(new OnCameraTrackingChangedListener() {
                    @Override
                    public void onCameraTrackingDismissed() {
                        Log.i(TAG, "onCameraTrackingDismissed: ");
                        // Tracking has been dismissed
                        // Set the component's camera mode
                        isTrackingDisabled = true;
                    }

                    @Override
                    public void onCameraTrackingChanged(int currentMode) {
                        Log.i(TAG, "onCameraTrackingChanged: ");
                        // CameraMode has been updated
                    }
                });



            }
        });

    }
    //END attemptToEnableMapboxLocationComponent




    //start add line
    private void addMapboxLine() {
        Log.i(TAG, "addMapboxLine: ");
        mbLineId += 1;

        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {

                Objects.requireNonNull(mapboxMap.getStyle()).addImage("marker-icon-id", BitmapFactory.decodeResource(
                        MainActivity.this.getResources(), R.drawable.mapbox_marker_icon_default));


                List<Point> routeCoordinates = new ArrayList<>();


                for (LatLng x : critBuilderLatLng) {
                    routeCoordinates.add(Point.fromLngLat(x.getLongitude(), x.getLatitude()));
                }

                // Create the LineString from the list of coordinates and then make a GeoJSON
// FeatureCollection so we can add the line to our map as a layer.
                Style style = mapboxMap.getStyle();

//REMOVE IF THERE...
                if (mbLineId > 11) {
                    style.removeSource("line-source"+ String.valueOf(mbLineId-1));
                    style.removeLayer("linelayer" + String.valueOf(mbLineId-1));
                }



                style.addSource(new GeoJsonSource("line-source" + mbLineId,
                        FeatureCollection.fromFeatures(new Feature[] {Feature.fromGeometry(
                                LineString.fromLngLats(routeCoordinates)
                        )})));

                // The layer properties for our line. This is where we make the line dotted, set the
// color, etc.
                style.addLayer(new LineLayer("linelayer" + mbLineId, "line-source" + mbLineId).withProperties(
                        PropertyFactory.lineDasharray(new Float[] {0.01f, 2f}),
                        PropertyFactory.lineCap(Property.LINE_CAP_ROUND),
                        PropertyFactory.lineJoin(Property.LINE_JOIN_ROUND),
                        PropertyFactory.lineWidth(5f),
                        PropertyFactory.lineColor(Color.parseColor("#e55e5e"))
                ));
            }
        });

        addAllMarkers();
    }
    //end add line

    //start add all markers
    private void addAllMarkers() {

        raceNumber += 1;
        Log.i(TAG, "addAllMarkers: ");

        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {

                Objects.requireNonNull(mapboxMap.getStyle()).addImage("marker-icon-id", BitmapFactory.decodeResource(
                        MainActivity.this.getResources(), R.drawable.mapbox_marker_icon_default));

                List<Feature> markerCoordinates = new ArrayList<>();
//                markerCoordinates.add(Feature.fromGeometry(
//                        Point.fromLngLat(trkpts.get(trkpts.size() - 1).getLon(), trkpts.get(trkpts.size() - 1).getLat()))); // FINISH
//                markerCoordinates.add(Feature.fromGeometry(
//                        Point.fromLngLat(trkpts.get(0).getLon(), trkpts.get(0).getLat()))); // START

                for (LatLng n : critBuilderLatLng) {
                    markerCoordinates.add(Feature.fromGeometry(
                        Point.fromLngLat(n.getLongitude(), n.getLatitude())));
                }

                Style style = mapboxMap.getStyle();

                if (raceNumber > 10) {
                    Log.i(TAG, "onMapReady: remove source and layer");
                    style.removeSource("source-id2" + String.valueOf(raceNumber-1));
                    style.removeLayer("layer-id2" + String.valueOf(raceNumber-1));

                }

                style.addSource(new GeoJsonSource("source-id2" + String.valueOf(raceNumber),
                        FeatureCollection.fromFeatures(markerCoordinates)));

                SymbolLayer symbolLayer = new SymbolLayer("layer-id2" + String.valueOf(raceNumber), "source-id2" + String.valueOf(raceNumber));
                symbolLayer.withProperties(
                        PropertyFactory.iconImage("marker-icon-id")
                );
                style.addLayer(symbolLayer);
                isRaceLoaded = true;

            }

        });


    }
    //end add all markers

    //add marker only for CB
    private void addAnotherMarkerCB(final double markerLat, final double markerLon) {



        raceNumber += 1;
        Log.i(TAG, "addAnotherMarkerCB: ");


        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {

                Objects.requireNonNull(mapboxMap.getStyle()).addImage("marker-icon-id", BitmapFactory.decodeResource(
                        MainActivity.this.getResources(), R.drawable.mapbox_marker_icon_default));

                List<Feature> markerCoordinates = new ArrayList<>();

                markerCoordinates.add(Feature.fromGeometry(
                        Point.fromLngLat(markerLon, markerLat))); // START



                Style style = mapboxMap.getStyle();

                if (raceNumber > 10) {
                    Log.i(TAG, "onMapReady: remove source and layer");
                    style.removeSource("source-id2" + String.valueOf(raceNumber-1));
                    style.removeLayer("layer-id2" + String.valueOf(raceNumber-1));

                }

                style.addSource(new GeoJsonSource("source-id2" + String.valueOf(raceNumber),
                        FeatureCollection.fromFeatures(markerCoordinates)));

                SymbolLayer symbolLayer = new SymbolLayer("layer-id2" + String.valueOf(raceNumber), "source-id2" + String.valueOf(raceNumber));
                symbolLayer.withProperties(
                        PropertyFactory.iconImage("marker-icon-id")
                );
                style.addLayer(symbolLayer);
                isRaceLoaded = true;

            }

        });
    }
    //end add marker only for cb



    private void addAnotherMarker(final double markerLat, final double markerLon) {

        Log.i(TAG, "addAnotherMarker: ");
        raceNumber += 1;


        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {

                Objects.requireNonNull(mapboxMap.getStyle()).addImage("marker-icon-id", BitmapFactory.decodeResource(
                        MainActivity.this.getResources(), R.drawable.mapbox_marker_icon_default));

                List<Feature> markerCoordinates = new ArrayList<>();

                markerCoordinates.add(Feature.fromGeometry(
                        Point.fromLngLat(markerLon, markerLat))); // START



                Style style = mapboxMap.getStyle();

                if (raceNumber > 10) {
                    Log.i(TAG, "onMapReady: remove source and layer");
                    style.removeSource("source-id2" + String.valueOf(raceNumber-1));
                    style.removeLayer("layer-id2" + String.valueOf(raceNumber-1));

                }

                style.addSource(new GeoJsonSource("source-id2" + String.valueOf(raceNumber),
                        FeatureCollection.fromFeatures(markerCoordinates)));

                SymbolLayer symbolLayer = new SymbolLayer("layer-id2" + String.valueOf(raceNumber), "source-id2" + String.valueOf(raceNumber));
                symbolLayer.withProperties(
                        PropertyFactory.iconImage("marker-icon-id")
                );
                style.addLayer(symbolLayer);
                isRaceLoaded = true;

            }

        });
    }

    private int trkID = 750;
//    private ArrayList<LatLng> trackerCoords = new ArrayList<>();
    //set streets style

    private boolean doSetUserTrackingLine = false;
    private void setMapboxStreets() {

        trkID += 1;

        if (!doSetUserTrackingLine) {
            Log.i(TAG, "setMapboxStreets: doSetUserTrackingLine is false");
            return;
        }

        if (Timer.trackerCoords.size() < 10) {
            Log.i(TAG, "setMapboxStreets: NOT ENOUGH CORDS");
            return;
        }

        Log.i(TAG, "setMapboxStreets: ");
        Log.i(TAG, "addMapboxLine for user tracking: ");
        //albumID += 1;

        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(@NonNull final MapboxMap mapboxMap) {
//
//                Objects.requireNonNull(mapboxMap.getStyle()).addImage("marker-icon-id", BitmapFactory.decodeResource(
//                        MainActivity.this.getResources(), R.drawable.mapbox_marker_icon_default));


                List<Point> routeCoordinates = new ArrayList<>();


                for (LatLng x : Timer.trackerCoords) {
                    routeCoordinates.add(Point.fromLngLat(x.getLongitude(), x.getLatitude()));
                }

                // Create the LineString from the list of coordinates and then make a GeoJSON
// FeatureCollection so we can add the line to our map as a layer.
                Style style = mapboxMap.getStyle();

//REMOVE IF THERE...
//                if (!doSetUserTrackingLine) {
//                    style.removeSource("line-source"+ String.valueOf(trkID-1));
//                    style.removeLayer("linelayer" + String.valueOf(trkID-1));
//                }



                if (System.currentTimeMillis() - startTime < 15000) {
                    return;
                }

                style.addSource(new GeoJsonSource("line-source" + trkID,
                        FeatureCollection.fromFeatures(new Feature[] {Feature.fromGeometry(
                                LineString.fromLngLats(routeCoordinates)
                        )})));

                // The layer properties for our line. This is where we make the line dotted, set the
// color, etc.
                style.addLayer(new LineLayer("linelayer" + trkID, "line-source" + trkID).withProperties(
                        PropertyFactory.lineDasharray(new Float[] {0.001f, 1f}),
                        PropertyFactory.lineCap(Property.LINE_CAP_ROUND),
                        PropertyFactory.lineJoin(Property.LINE_JOIN_ROUND),
                        PropertyFactory.lineWidth(3f),
                        PropertyFactory.lineColor(Color.parseColor("#FF0000"))
                ));

//                mapbox:mapbox_cameraTargetLat="40.672216"
//                mapbox:mapbox_cameraTargetLng="-73.970615"


//                if (!collectCritPoints) {
//                    CameraPosition position = new CameraPosition.Builder()
////                        .target(new LatLng(51.50550, -0.07520)) // Sets the new camera position
//                            .target(Timer.trackerCoords.get(Timer.trackerCoords.size()-1)) // Sets the new camera position
////                        .zoom(17) // Sets the zoom
////                        .bearing(180) // Rotate the camera
////                            .tilt(30) // Set the camera tilt
//                            .build(); // Creates a CameraPosition from the builder
//
//                    mapboxMap.animateCamera(CameraUpdateFactory
//                            .newCameraPosition(position), 7000);
//                }



            }
        });

        doSetUserTrackingLine = false;
    }






    public void onMapReady(@NonNull final MapboxMap mapboxMap) {
        this.mapboxMap = mapboxMap;

        mapboxMap.setStyle(Style.MAPBOX_STREETS,
                new Style.OnStyleLoaded() {
                    @Override
                    public void onStyleLoaded(@NonNull Style style) {
                        //enableLocationComponent(style);
                    }
                });

        mapboxMap.addOnMapClickListener(new OnMapClickListener() {
            @Override
            public boolean onMapClick(@NonNull LatLng point) {
                Log.i(TAG, "onMapClick: " + point.getLatitude() + ", " + point.getLongitude());
                //String string = String.format(Locale.US, "User clicked at: %s", point.toString());
                //Toast.makeText(MainActivity.this, string, Toast.LENGTH_LONG).show();

                if (collectCritPoints) {
                    critBuilderLatLng.add(point);
                    addAnotherMarkerCB(point.getLatitude(), point.getLongitude());
                    llp += point.getLatitude() + "," + point.getLongitude() + ":";
                    //get name from input
                    inputWaypointName();
                }
                return false;
            }
        });
    }




private Boolean collectCritPoints = false;



    private void makeToast(String s) {
        Toast.makeText(getApplicationContext(),
                s, Toast.LENGTH_SHORT)
                .show();
    }

    private void toggleMapVisibility() {
        Log.i(TAG, "toggleMapVisibility: ");
        ScrollView sv = (ScrollView) findViewById(R.id.svSettings);

        if (sv.getVisibility() == View.GONE) {
            sv.setVisibility(View.VISIBLE);
        } else {
            sv.setVisibility(View.GONE);
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        mapView.onStart();


        PreferenceManager.getDefaultSharedPreferences(this)
                .registerOnSharedPreferenceChangeListener(this);

        mRequestLocationUpdatesButton = (Button) findViewById(R.id.btnStartGPS);
        mRemoveLocationUpdatesButton = (Button) findViewById(R.id.btnStopGPS);

        mRequestLocationUpdatesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mService.requestLocationUpdates();
                if (!checkPermissions()) {
                    requestPermissions();
                } else {
                    mService.requestLocationUpdates();
                }
            }
        });

        mRemoveLocationUpdatesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mService.removeLocationUpdates();
            }
        });

        // Restore the state of the buttons when the activity (re)launches.
        setButtonsState(Utils.requestingLocationUpdates(this));

        // Bind to the service. If the service is in foreground mode, this signals to the service
        // that since this activity is in the foreground, the service can exit foreground mode.
        bindService(new Intent(this, LocationUpdatesService.class), mServiceConnection,
                Context.BIND_AUTO_CREATE);



    }


    @Override
    public void onStop() {
        Log.i(TAG, "onStop: ");
        if (mBound) {
            // Unbind from the service. This signals to the service that this activity is no longer
            // in the foreground, and the service can respond by promoting itself to a foreground
            // service.
            unbindService(mServiceConnection);
            mBound = false;
        }
        PreferenceManager.getDefaultSharedPreferences(this)
                .unregisterOnSharedPreferenceChangeListener(this);

        super.onStop();
        mapView.onStop();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mapView.onLowMemory();
    }


    private Boolean isDestroyed = false;
    private Boolean isPaused = false;

    @Override
    protected void onDestroy() {
        super.onDestroy();
        timerHandler.removeCallbacks(timerRunnable);
        mService.removeLocationUpdates();
        isDestroyed = true;


        //Close the Text to Speech Library
        if(engine !=null){
            Log.i(TAG, "onDestroy: shutdown tts");
            engine.stop();
            engine.shutdown();
        }


//        if (locationEngine != null) {
//            locationEngine.removeLocationUpdates(callback);
//        }

        mapView.onDestroy();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mapView.onSaveInstanceState(outState);
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();

        Log.i(TAG, "onResume: ");
        loadSelectedGPX();

        LocalBroadcastManager.getInstance(this).registerReceiver(myReceiver,
                new IntentFilter(LocationUpdatesService.ACTION_BROADCAST));

        isPaused = false;



    }

    @Override
    protected void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(myReceiver);
        isPaused = true;
        super.onPause();
        mapView.onPause();

        Log.i(TAG, "onPause: ");
    }

    public void clickName(View view) {
        Log.i(TAG, "clickName: ");
        inputName();
    }

    public void clickEditSport(View view) {
        Log.i(TAG, "clickEditSport: " + settingsSport);
        switch (settingsSport) {
            case "BIKE":
                //b1.setText("RUN");
                settingsSport = "RUN";
                Timer.checkDistanceValue = 100;
                break;
            case "RUN":
                //b1.setText("ROW");
                settingsSport = "ROW";
                Timer.checkDistanceValue = 50;
                break;
            case "ROW":
                settingsSport = "BIKE";
                Timer.checkDistanceValue = 150;
                //b1.setText("BIKE");
                break;
        }



        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b1 = (Button) findViewById(R.id.valueEditSport);
                b1.setText(settingsSport);
            }
        });
        setSharedPrefs();
    }

    public void clickEditMaxHR(View view) {
        Log.i(TAG, "clickEditMaxHR: ");
        switch (settingsMaxHeartrate) {
            case 185:
                settingsMaxHeartrate = 190;
                break;
            case 190:
                settingsMaxHeartrate = 195;
                break;
            case 195:
                settingsMaxHeartrate = 200;
                break;
            case 200:
                settingsMaxHeartrate = 185;
                break;
        }

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b1 = (Button) findViewById(R.id.valueEditMaxHR);
                b1.setText(String.format("%s  MAX HR", String.valueOf(settingsMaxHeartrate)));
            }
        });
        setSharedPrefs();
    }

    public void displayName(final String n) {

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView mName = findViewById(R.id.valueName);
                mName.setText(n);
            }
        });

        try {
            getSupportActionBar().setTitle("VIRTUAL CRIT (" + settingsName + ")");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    //GET FINISHMESSAGE
    public void inputFinishMessage() {

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        AlertDialog dialog;
        builder.setTitle("FINISH MESSAGE");

// Set up the input
        final EditText input = new EditText(this);
// Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);


// Set up the buttons
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                settingsLeaderMessage = input.getText().toString();
                Crit.setLeaderMessage(settingsLeaderMessage);
                final String s = settingsLeaderMessage;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        TextView mMsg = findViewById(R.id.valueLeaderMessage);
                        mMsg.setText(s);
                    }
                });

                setSharedPrefs();
            }
        });
        builder.setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                //settingsName = "TIM";
                setSharedPrefs();
                dialog.cancel();
            }
        });

        builder.show();
    }
    //END FINISH MESSAGE


    public void inputName() {

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
                settingsName = input.getText().toString().toUpperCase();
                displayName(settingsName);
                setSharedPrefs();
                try {
                    getSupportActionBar().setTitle("VIRTUAL CRIT (" + settingsName + ")");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        builder.setNegativeButton("RANDOM", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                settingsName = "TIM";
                Random r = new Random();
                int i1 = r.nextInt(9999 - 1001);
                settingsName = settingsName + i1;
                displayName(settingsName);
                setSharedPrefs();
                try {
                    getSupportActionBar().setTitle("VIRTUAL CRIT (" + settingsName + ")");
                } catch (Exception e) {
                    e.printStackTrace();
                }
                dialog.cancel();
            }
        });

        builder.show();
    }


    public void inputWaypointName() {

        AlertDialog.Builder builder1 = new AlertDialog.Builder(this);
        AlertDialog dialog;
        builder1.setTitle("CRIT BUILDER, ENTER CHECKPOINT NAMES");
        builder1.setTitle("OPTIONAL");
        if (critBuilderLatLngNames.size() == 0) {
            builder1.setTitle("CRIT BUILDER, ENTER THE CRIT NAME");
            builder1.setMessage("3 CHECKPOINTS MINIMUM");
        }


// Set up the input
        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder1.setView(input);


// Set up the buttons

        if (critBuilderLatLngNames.size() > 0) {
            builder1.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    //input.setText("CHECKPOINT " + critBuilderLatLngNames.size() + ": ");
                    String wayName = input.getText().toString().toUpperCase();
                    critBuilderLatLngNames.add("Checkpoint " + wayName);
                    lln += ("Checkpoint " + wayName + ",");
                }
            });

        }
        if (critBuilderLatLngNames.size() == 0){
            builder1.setNeutralButton("START", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {

                    Random r = new Random();
                    int i1 = r.nextInt(9999 - 1001);
                    //input.setText("VC" + i1);
                    String wayName = "VC";
                    wayName = input.getText().toString().toUpperCase();

                    if (wayName.equals("")) {
                        lln += ("VC,");
                        critBuilderLatLngNames.add("VC" + fbCurrentDate);
                    } else {
                        lln += (wayName + ",");
                        critBuilderLatLngNames.add(wayName);
                    }

                }
            });
        }


        if (critBuilderLatLngNames.size() > 2) {
            builder1.setNegativeButton("FINISH", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    critBuilderLatLngNames.add("FINISH");
                    collectCritPoints = false;
                    isCritBuilderActive = true;
                    isCritBuilderIDActive = false;
                    lln += "FINISH";
                    Log.i(TAG, "collectCritPointName: FINISHED, POINTS:  " + critBuilderLatLngNames + critBuilderLatLng);

                    //CREATE LINE
                    Log.i(TAG, "onClick: create line from builder");
                    addMapboxLine();
                    
                    resetCritPointLocationArrays();
                    critPointLocationNames.addAll(critBuilderLatLngNames);
                    for (LatLng l : critBuilderLatLng) {
                        critPointLocationLats.add(l.getLatitude());
                        critPointLocationLats.add(l.getLongitude());
                    }




                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Button b1 = (Button) findViewById(R.id.clickButtonStartCritBuilder);
                            b1.setText("BUILDER");
                            TextView t1 = (TextView) findViewById(R.id.valueCritBuilderName);
                            t1.setText(critBuilderLatLngNames.get(0));
                        }
                    });

                    trkName = critBuilderLatLngNames.get(0).toUpperCase();
                    //postRaceProcessing(0);
                    //Race race = new Race(Crit.getRacerName(), Crit.getRaceName(), 0, Crit.getRaceDate(), "", )

                    startGpxFromCritBuilder();

                    Integer rd = Integer.valueOf(fbCurrentDate);
                    //have to make this 0
                    long longTime = 0;
                    Race postR = new Race("NEW", trkName.toUpperCase(),longTime, rd, waypointTimesTimString, llp, lln);
                    Log.i(TAG, "afterStartGPXFromCritBuilder: postRaceProcessing ");
                    postRaceProcessing(postR);
                    dialog.cancel();
                }
            });
        }


        builder1.show();

    }

    private int maxWaypointCB;
    private int currentWaypointCB = 0;
    private Boolean isCritBuilderActive = false;
    private Boolean isCritBuilderIDActive = false;

    public void startGpxFromCritBuilder() {
        Log.i(TAG, "startGpxFromCritBuilder: ");
        isCritBuilderActive = true;
        isCritBuilderIDActive = false;
        maxWaypointCB = critBuilderLatLng.size();

        //SHOWALERT
        Toast.makeText(getApplicationContext(),
                "CRITBUILDER LOADED", Toast.LENGTH_SHORT)
                .show();

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView t1 = (TextView) findViewById(R.id.valueCritBuilderName);
                t1.setText(critBuilderLatLngNames.get(0));
                setMessageText("GOTO THE START POINT");

                TextView mGPS = findViewById(R.id.valueGPS);
                mGPS.setText("ON");
                settingsGPS = "ON";

            }
        });
        //addAnotherMarker(critBuilderLatLng.get(0).getLatitude(), critBuilderLatLng.get(0).getLongitude());
        //createTimeline("CRIT LOADED: " + critBuilderLatLngNames.get(0).toUpperCase(), Timer.getCurrentTimeStamp());
        requestRaceData(critBuilderLatLngNames.get(0).toUpperCase());
        Log.i(TAG, "startGpxFromCritBuilder: critPointLocation arrays... " + critPointLocationNames + critPointLocationLons + critPointLocationLats);

    }


    public void startGpxFromCritID() {
        Log.i(TAG, "startGpxFromCritID: ");
        isCritBuilderIDActive = true;
        isCritBuilderActive = false;
        maxWaypointCB = namesTemp.size();

        //SHOWALERT
        Toast.makeText(getApplicationContext(),
                "CRITID LOADED", Toast.LENGTH_SHORT)
                .show();

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setMessageText("GOTO THE START POINT");

                TextView mGPS = findViewById(R.id.valueGPS);
                mGPS.setText("ON");
                settingsGPS = "ON";

            }
        });
        addAnotherMarker(latTemp.get(0), lonTemp.get(0));
        //createTimeline("CRIT LOADED: " + namesTemp.get(0).toUpperCase(), Timer.getCurrentTimeStamp());
        createRouteCoords();

    }

    //FROM latTemp, lonTemp
    public void createRouteCoords() {
        Log.i(TAG, "createRouteCoords: ADD TO critBuilderLatLng");

        if (namesTemp.size() < 3) {return;}

        critBuilderLatLng = new ArrayList<>();
        for (Double n : latTemp) {
            int i = latTemp.indexOf(n);
            LatLng e = new LatLng();
            e.setLatitude(latTemp.get(i));
            e.setLongitude(lonTemp.get(i));
            critBuilderLatLng.add(e);
        }

        Crit.critBuilderLatLngNames = new ArrayList<>();
        Crit.critBuilderLatLngNames = namesTemp;
        Crit.critBuilderLatLng = new ArrayList<>();
        Crit.critBuilderLatLng = critBuilderLatLng;

        Log.i(TAG, "createRouteCoords: critBuilderLatLng\n" + critBuilderLatLng.toString());
        addMapboxLine();

    }


    private int mbLineId = 10;

    private void setRandomUsernameOnStart() {
        Random r = new Random();
        int i1 = r.nextInt(9999 - 1001);
        settingsName = "TIM" + i1;
        displayName(settingsName);

    }




    public void clickAudio(View view) {
        Log.i(TAG, "clickAudio  " + settingsAudio);

        //listOnlineCrits();

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b = findViewById(R.id.valueAudio);
                if (!settingsAudio) {
                    b.setText("AUDIO:  ON");
                    settingsAudio = true;
                    Log.i(TAG, "AUDIO: ON " + settingsAudio);
                    speakText("AUDIO ENABLED");
                } else {
                    b.setText("AUDIO: OFF");
                    settingsAudio = false;
                    Log.i(TAG, "AUDIO: OFF" + settingsAudio);
                }
            }
        });
    }

    public void clickGPS(View view) {
        Log.i(TAG, "clickGPS: ");
    }

    private Boolean isTimerStarted = false;
    public void timerStart2() {
        if (!isTimerStarted) {
            isTimerStarted = true;
            Log.i(TAG, "Start Timer - First Time");
            //mValueTimer.setText("00:00:00");
            startTime = System.currentTimeMillis();
            timerHandler.postDelayed(timerRunnable, 0);
            manageTimer(0);
        }
    }

    public void timerStart(View view) {
        Log.i(TAG, "timerStart: ");

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
            startTime = System.currentTimeMillis();
            timerHandler.postDelayed(timerRunnable, 0);
            manageTimer(0);
        }


    }

    public void clickPause(View view) {
        Log.i(TAG, "clickPause: ");
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
                        "START", Toast.LENGTH_SHORT)
                        .show();
                return;
            case 1:
                Log.i(TAG, "manageTimer: Pause");
                Timer.setStatus(1);
                Toast.makeText(getApplicationContext(),
                        "PAUSE", Toast.LENGTH_SHORT)
                        .show();
                return;
            case 2:
                Log.i(TAG, "manageTimer: End");
                Timer.setStatus(2);
                Toast.makeText(getApplicationContext(),
                        "COMPLETE", Toast.LENGTH_SHORT)
                        .show();
        }


    }


    //BLUETOOTH

    public void clickBLE(View view) {
        Log.i(TAG, "clickBLE: SCAN FOR BLE DEVICES");
        onScanStart();

    }

    //    private int mapState = 1;
    public void clickMessageBar(View view) {
        Log.i(TAG, "clickMessageBar: ");
        //toggleMapVisibility();
    }


    public void onScanStart() {
        Log.i(TAG, "SCANNING HR");
        //deviceDiscovered = null;
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
            //BLE
            int REQUEST_ENABLE_BT = 1;
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        } else {
            mLEScanner = mBluetoothAdapter.getBluetoothLeScanner();
            ScanSettings settings = new ScanSettings.Builder()
                    .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                    .build();
            List<ScanFilter> filters = new ArrayList<>();
            ScanFilter scanFilter = new ScanFilter.Builder()
                    .setServiceUuid(ParcelUuid.fromString("0000180D-0000-1000-8000-00805f9b34fb"))
                    .build();
            filters.add(scanFilter);

            // Show Alert
            Toast.makeText(getApplicationContext(),
                    "SCANNING HR", Toast.LENGTH_SHORT)
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
                    //deviceDiscovered = null;
                    postScanPopup();
                }
            }, SCAN_PERIOD);

        }
    } //END HR SCAN


    //SCAN RESULT CB HR
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
                //Log.i(TAG, "onScanResult: Already in HR Device Array List, return");
                return;
            }

            //Log.i(TAG, "onScanResult: New HR device");
            devicesDiscoveredHR.add(deviceDiscovered);
            Log.i(TAG, "onScanResult added HR: " + deviceDiscovered.getName());
            setMessageText("FOUND:  " + deviceDiscovered.getName());
            //Log.i(TAG, "onScanResult: getSizeOfDevicesDiscoveredHR:  " + devicesDiscoveredHR.size());
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

        //Log.i(TAG, "postScanPopup");
        if (devicesDiscoveredHR.size() == 0) {
            //setMessageText("NO DEVICES FOUND");
            Toast.makeText(getApplicationContext(),
                    "NO FOUND DEVICES", Toast.LENGTH_SHORT)
                    .show();
            return;
        }

        for (final BluetoothDevice d : devicesDiscoveredHR) {
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
                            Log.i(TAG, "onClick: YES, connect to device " + d.getName());
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
                            Log.i(TAG, "onClick: Don't Connect");
                        }
                    }).show();
        }
    }


    private void setBluetoothDeviceNames(final String x) {
        Log.i(TAG, "setBluetoothDeviceNames: " + x);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView tv1 = MainActivity.this.findViewById(R.id.valueBluetoothDevice1);
//                TextView tv2 = MainActivity.this.findViewById(R.id.valueBluetoothDevice2);
//                TextView tv3 = MainActivity.this.findViewById(R.id.valueBluetoothDevice3);
                if (tv1.getText().equals("")) {
                    Log.i(TAG, "setBluetoothDeviceNames: tv1");
                    tv1.setText(x);
                    return;
                }
//                if (tv2.getText().equals("")) {
//
//                    tv2.setText(x);
//                    return;
//                }
//                if (tv3.getText().equals("")) {
//                    tv3.setText(x);
//                }
                Log.i(TAG, "setBluetoothDeviceNames: all name slots taken");

            }
        });
    }

    private void setMessageText(final String x) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTextMessage.setText(x);
            }
        });
    }

    private void setValueHR(final String x) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView h = findViewById(R.id.valueHeartrateBLE);
                h.setText(String.format("%s BPM", x));

                TextView t1 = findViewById(R.id.tvTop);
                t1.setText(x);

                TextView p2 = findViewById(R.id.tvTop_Label);
                p2.setText("BPM");

                TextView t3 = findViewById(R.id.tvFooter2);
                t3.setText(String.format("%.0f AVG", averageHR));

                TextView a1 = findViewById(R.id.valueHeartrateAverageBLE);
                a1.setText(String.format("%.0f AVG", averageHR));

            }
        });
    }


    private void connectHR(BluetoothDevice d) {
        Log.i(TAG, "connectHR " + d.getName());
        mBluetoothGatt = d.connectGatt(this, false, mGattCallback);
    }


    private void setReconnectRequest(BluetoothGatt g) {

        Log.i(TAG, "setReconnectRequest: attempt reconnect");
        deviceHR.connectGatt(this, true, mGattCallback);
        reconnect = false;
    }

    //Various callback methods defined by the BLE API.
    private final BluetoothGattCallback mGattCallback =
            new BluetoothGattCallback() {
                @Override
                public void onConnectionStateChange(BluetoothGatt gatt, int status,
                                                    int newState) {
                    //String intentAction;
                    int mConnectionState = STATE_DISCONNECTED;
                    if (newState == BluetoothProfile.STATE_CONNECTED) {
                        //intentAction = ACTION_GATT_CONNECTED;
                        mConnectionState = STATE_CONNECTED;
                        mBluetoothGatt = gatt;
                        String mBluetoothDeviceAddress = gatt.getDevice().getAddress();
//                        broadcastUpdate(intentAction);
                        setMessageText(gatt.getDevice().getName() + "  CONNECTED");
                        createTimeline(gatt.getDevice().getName() + "  CONNECTED", Timer.getCurrentTimeStamp());
                        Log.i(TAG, "Connected to GATT server. " + gatt.getDevice().getName());

                        Log.i(TAG, "Attempting to start service discovery: " +
                                gatt.discoverServices());

                    } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                        //intentAction = ACTION_GATT_DISCONNECTED;
                        mConnectionState = STATE_DISCONNECTED;
                        Log.i(TAG, "Disconnected from GATT server. " + gatt.getDevice().getName());
                        setMessageText(gatt.getDevice().getName() + "  DISCONNECTED");
                        createTimeline(gatt.getDevice().getName() + "  DISCONNECTED", Timer.getCurrentTimeStamp());
                        //broadcastUpdate(intentAction);
                        setValueHR("0");
                        close();
                        setReconnectRequest(gatt);
                    }
                }

                @Override
                // New services discovered
                public void onServicesDiscovered(BluetoothGatt gatt, int status) {

                    if (!reconnect) {
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
                        BluetoothGattCharacteristic valueCharacteristic = gatt.getService(HR_SERVICE_UUID).getCharacteristic(HR_CHARACTERISTIC_UUID);
                        boolean notificationSet = gatt.setCharacteristicNotification(valueCharacteristic, true);
                        Log.i(TAG, "registered for HR updates " + (notificationSet ? "successfully" : "unsuccessfully"));
                        BluetoothGattDescriptor descriptor = valueCharacteristic.getDescriptor(BTLE_NOTIFICATION_DESCRIPTOR_UUID);
                        descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        boolean writeDescriptorSuccess = gatt.writeDescriptor(descriptor);
                        Log.i(TAG, "wrote Descriptor for HR updates " + (writeDescriptorSuccess ? "successfully" : "unsuccessfully"));
                        if (writeDescriptorSuccess) {
                            setMessageText(gatt.getDevice().getName() + "  READY FOR HR UPDATES");
                        }
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
                    //Log.i(TAG, "onCharacteristicChanged: HR");

                    // This is special handling for the Heart Rate Measurement profile. Data
                    // parsing is carried out as per profile specifications.
                    if (HR_CHARACTERISTIC_UUID.equals(characteristic.getUuid())) {
                        int flag = characteristic.getProperties();
//                        int format = -1;
                        if ((flag & 0x01) != 0) {
                            format = BluetoothGattCharacteristic.FORMAT_UINT16;
                            //Log.d(TAG, "Heart rate format UINT16.");
                        } else {
                            format = BluetoothGattCharacteristic.FORMAT_UINT8;
                            //Log.d(TAG, "Heart rate format UINT8.");
                        }
                        final int heartRate = characteristic.getIntValue(format, 1);
                        //Log.i(TAG, String.format("%d BPM", heartRate));
                        //intent.putExtra(EXTRA_DATA, String.valueOf(heartRate));
                        onNewHeartrate(heartRate);
                    } else {
                        // For all other profiles, writes the data formatted in HEX.
                        Log.i(TAG, "onCharacteristicChanged: strangeval");
                    }
                }


            };


    @SuppressLint("DefaultLocale")
    private void onNewHeartrate(final int h) {
        //Log.i(TAG, "onNewHeartrate: " + h);

        calcAvgHR(h);
        if (h > 50 && h < 220) {
            //TOTAL
            totHR += h;
            countHR += 1;
            averageHR = (double) totHR / (double) countHR;
            //ROUND
            roundHeartrateTotal += h;
            roundHeartrateCount += 1;
            roundHeartrate = (double) roundHeartrateTotal / (double) roundHeartrateCount;
        }

        showHR = true;
        setValueHR(String.format("%d", h));
    }

    //PORT VS LANDSCAPE
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

        } else if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
            //Toast.makeText(this, "portrait", Toast.LENGTH_SHORT).show();
            ortTview.setVisibility(View.VISIBLE);
            ortTview2.setVisibility(View.VISIBLE);
        }
    }


    private void vibrator600() {
        Log.i(TAG, "Vibrator600: ");
        // Get instance of Vibrator from current Context
        Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

// Vibrate for 400 milliseconds
        v.vibrate(600);
    }

    private void close() {
        if (mBluetoothGatt == null) {
            return;
        }
        //mBluetoothGatt.disconnect();
        mBluetoothGatt.close();
        mBluetoothGatt = null;
    }


    //TIMELINE
    private ArrayList<TimelineRow> timelineRowsList = new ArrayList<>();

    private void createTimeline(String tlTitle, String tlDescription) {

        if (tlTitle.length() < 5) {
            Log.i(TAG, "createTimeline: too small, don't post");
            return;
        }

        // Create new timeline row (Row Id)
        TimelineRow myRow = new TimelineRow(0);

// To set the row Date (optional)
        myRow.setDate(new Date());
// To set the row Title (optional)
        myRow.setTitle(tlTitle);
// To set the row Description (optional)
        myRow.setDescription(tlDescription);
// To set the row bitmap image (optional)
        myRow.setImage(BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher));
// To set row Below Line Color (optional)
        myRow.setBellowLineColor(Color.argb(255, 0, 0, 0));
// To set row Below Line Size in dp (optional)
        myRow.setBellowLineSize(2);
// To set row Image Size in dp (optional)
        myRow.setImageSize(2);
// To set background color of the row image (optional)
        myRow.setBackgroundColor(Color.argb(255, 0, 0, 0));
// To set the Background Size of the row image in dp (optional)
        myRow.setBackgroundSize(10);
// To set row Date text color (optional)
        myRow.setDateColor(Color.argb(255, 0, 0, 0));
// To set row Title text color (optional)
        myRow.setTitleColor(Color.argb(255, 0, 0, 0));
// To set row Description text color (optional)
        myRow.setDescriptionColor(Color.argb(255, 0, 0, 0));

// Add the new row to the list
        timelineRowsList.add(myRow);

// Create the Timeline Adapter
        final ArrayAdapter<TimelineRow> myAdapter = new TimelineViewAdapter(this, 0, timelineRowsList,
                //if true, list will be sorted by date
                true);

// Get the ListView and Bind it with the Timeline Adapter

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ListView myListView = (ListView) findViewById(R.id.timeline_listView);
                myListView.setAdapter(myAdapter);
            }
        });
    }
    //END TIMELINE


    private static String calcPace(double mph) {

        double a = (60.0 / mph);
        if (a == 0 || a > 50) {
            return "00:00";
        }

        double m = a * 60.0 * 1000.0;
        long mill = (long) m;

        final String minutesPerMile = String.format(Locale.US, "%02d:%02d",
                TimeUnit.MILLISECONDS.toMinutes(mill) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(mill)),
                TimeUnit.MILLISECONDS.toSeconds(mill) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(mill)));

        return minutesPerMile;
    }

    @Override
    public void onBackPressed() {
        Log.i(TAG, "onBackPressed: do nothing, might show timeline later...");
    }


    public void clickRoundButton(View view) {
        Log.i(TAG, "clickRoundButton: ");
    }


    //GPX
    public void clickSelectGPX(View view) {
        Log.i(TAG, "clickSelectGPX: ");

        Intent intent = new Intent()
                .setType("*/*")
                .setAction(Intent.ACTION_GET_CONTENT);

        startActivityForResult(Intent.createChooser(intent, "Select a file"), 123);
        waitToLoadGPX = true;
        Log.i(TAG, "clickSelectGPX: selected");

    }

    private Uri selectedfile;

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 123 && resultCode == RESULT_OK) {
            selectedfile = data.getData(); //The uri with the location of the file
        }
    }


    private Boolean waitToLoadGPX = false;

    private void loadSelectedGPX() {
        if (waitToLoadGPX) {
            Log.i(TAG, "loadSelectedGPX: ");
            waitToLoadGPX = false;
            //isCritBuilderActive = false;
            startGPX();
        }
    }


    public void clickStartCritBuilder(View view) {
        Log.i(TAG, "clickStartCritBuilder: ");

        resetRace();

        //remove old to start new
        critBuilderLatLngNames = new ArrayList<>();
        critBuilderLatLng = new ArrayList<>();
        collectCritPoints = true;
        lln = "";llp = "";

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b1 = (Button) findViewById(R.id.clickButtonStartCritBuilder);
                b1.setText("...");
                TextView t1 = (TextView) findViewById(R.id.valueCritBuilderName);
                t1.setText("SET POINTS ON MAP");

                TextView t2 = (TextView) findViewById(R.id.valueCritIdName);
                t2.setText("SET POINTS ON MAP");

                TextView t3 = (TextView) findViewById(R.id.valueActiveCritName);
                t3.setText("SET POINTS ON MAP");

                makeToast("SET POINTS ON MAP TO CREATE CRIT");
            }
        });


    }

    public void startGpxFromID(View view) {
        Log.i(TAG, "startGpxFromID: ");


        //GET ID NAME
        Log.i(TAG, "GET CRIT ID TO LOAD: ");
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        AlertDialog dialog;
        builder.setTitle("CRIT ID TO LOAD");

// Set up the input
        final EditText input = new EditText(this);
// Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);


// Set up the buttons
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                final String s = input.getText().toString().toUpperCase();
                Log.i(TAG, "onClick: CRITID: " + s.toUpperCase());

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        TextView b1 = (TextView) findViewById(R.id.valueCritIdName);
                        b1.setText(s.toUpperCase());
                    }
                });
                resetRace();
                requestRaceData(s);

            }
        });
        builder.setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                Log.i(TAG, "onClick: CRITID, CANCEL");
                dialog.cancel();
            }
        });

        builder.show();
    }



    private void convertPointsNamesToCrit(String p, String n) {
        Log.i(TAG, "convertPointsNamesToCrit: n, p: " + n + "\n" + p);
        //"40.66068,-73.97738:40.652033131581746,-73.9708172236974:40.657608465972885,-73.96300766854665:40.671185505128406,-73.96951606153863:40.66331,-73.97495"
        //"Prospect Park, Brooklyn, Single Loop,PARADE GROUND,LAFREAK CENTER,GRAND ARMY PLAZA,FINISH"
        //convert string to ArrayList with splice
        latTemp = new ArrayList<Double>();
        lonTemp = new ArrayList<Double>();
        namesTemp = new ArrayList<String>(Arrays.asList(n.split(",")));

        ArrayList<String> pointsTemp = new ArrayList<String>(Arrays.asList(p.split(":")));
        for (String ll : pointsTemp) {
            ArrayList<String> llTemp = new ArrayList<String>(Arrays.asList(ll.split(",")));

            Double d1 = Double.valueOf(llTemp.get(0));
            latTemp.add(d1);

            Double d2 = Double.valueOf(llTemp.get(1));
            lonTemp.add(d2);
        }

        Log.i(TAG, "convertPointsNamesToCrit: names, latTemp, lonTemp\n" + namesTemp.toString() + latTemp.toString() + lonTemp.toString());
        final String nT = namesTemp.get(0);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TextView t1 = (TextView) findViewById(R.id.valueCritIdName);
                t1.setText(nT);
            }
        });
        Log.i(TAG, "convertPointsNamesToCrit: calling startGpxFromCritID");
        startGpxFromCritID();
    }



//
//    private class MainActivityLocationCallback
//            implements LocationEngineCallback<LocationEngineResult> {
//
//        private final WeakReference<MainActivity> activityWeakReference;
//
//        MainActivityLocationCallback(MainActivity activity) {
//            this.activityWeakReference = new WeakReference<>(activity);
//        }
//
//
////         The LocationEngineCallback interface's method which fires when the device's location has changed.
//
//        @Override
//        public void onSuccess(LocationEngineResult result) {
//            MainActivity activity = activityWeakReference.get();
//
//            if (activity != null) {
//                Location location = result.getLastLocation();
//
//                if (location == null) {
//                    return;
//                }
//
//
//                onMapboxLocationReceived(location);
//
//// Pass the new location to the Maps SDK's LocationComponent
//                if (activity.mapboxMap != null && result.getLastLocation() != null) {
//                    activity.mapboxMap.getLocationComponent().forceLocationUpdate(result.getLastLocation());
//                }
//
//            }
//        }
//
//
//
//
        private void mapBoxDisplaySpeedValues() {

            //Log.i(TAG, "mapBoxDisplaySpeedValues: RUN IN BACKGROUND???");

            //UPDATE UI WITH SPEED AND DISTANCE
            mn.runOnUiThread(new Runnable() {
                @SuppressLint("DefaultLocale")
                @Override
                public void run() {
                    TextView tvSpd = findViewById(R.id.valueSpeedGPS);
                    TextView t1 = findViewById(R.id.tvMiddle);
                    TextView p1 = findViewById(R.id.tvTop);
                    TextView p2 = findViewById(R.id.tvTop_Label);
                    TextView p3 = findViewById(R.id.tvFooter2);
                    TextView tvDst = findViewById(R.id.valueDistanceGPS);
                    TextView tx = findViewById(R.id.tvBottom);
                    TextView tvTime = findViewById(R.id.valueActiveTimeGPS);
                    TextView t4 = findViewById(R.id.tvFooter1);
                    TextView tvAvgSpd = (TextView) findViewById(R.id.valueAverageSpeedGPS);
                    TextView t2 = findViewById(R.id.tvHeader2);

                    //geoSpeed = Timer.getGeoSpeed();

                    if (!Double.isNaN(Timer.getGeoSpeed()) || Timer.getGeoSpeed() < 0) {
                        geoSpeed = Timer.getGeoSpeed();
                    }
                    if (!Double.isNaN(Timer.getGeoAvgSpeed()) || Timer.getGeoAvgSpeed() < 0) {
                        geoAvgSpeed = Timer.getGeoAvgSpeed();
                    }

                    geoDistance = Timer.getTimerGeoDistance();
                    final String hms = getTimeStringFromMilliSecondsToDisplay((int) Timer.gettimerTotalTimeGeo());


                    tvSpd.setText(String.format("%.1f MPH", geoSpeed));
                    t1.setText(String.format("%.1f", geoSpeed));

                    if (!showHR) {
                        p1.setText(calcPace(geoSpeed));
                        p2.setText("PACE");
                        p3.setText(String.format("%s AVG", calcPace(geoAvgSpeed)));
                    }

                    tvDst.setText(String.format("%.1f MILES", geoDistance));
                    tx.setText(String.format("%.2f", geoDistance));

                    tvTime.setText(hms);
                    t4.setText(hms);


                    tvAvgSpd.setText(String.format("%.1f MPH", geoAvgSpeed));
                    t2.setText(String.format("%.1f AVG", geoAvgSpeed));

                    try {
//                    getSupportActionBar().setTitle("VIRTUAL CRIT (" + settingsName + ")");

                        mn.getSupportActionBar().setTitle(String.format("%.1f MPH", geoSpeed) + "   " + Timer.metersTogo + "   " + String.format("%.1f MILES", geoDistance));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }


                }
            });

        }



    //FROM BROADCAST RECEIVER
        public void onTimerLocationReceived() {
            Log.i(TAG, "onTimerLocationReceived: ");
            mapBoxDisplaySpeedValues();
        }




}

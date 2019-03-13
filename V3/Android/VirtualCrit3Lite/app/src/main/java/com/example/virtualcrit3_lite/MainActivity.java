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
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
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
import android.os.ParcelUuid;
import android.os.Vibrator;
import android.speech.tts.TextToSpeech;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.TabLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.text.InputType;
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
import com.mapbox.geojson.Point;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.location.LocationComponent;
import com.mapbox.mapboxsdk.location.modes.CameraMode;
import com.mapbox.mapboxsdk.location.modes.RenderMode;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.MapboxMap.OnMapClickListener;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;
import com.mapbox.mapboxsdk.maps.Style;
import com.mapbox.mapboxsdk.style.layers.PropertyFactory;
import com.mapbox.mapboxsdk.style.layers.SymbolLayer;
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource;

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

public class MainActivity extends AppCompatActivity implements TextToSpeech.OnInitListener, PermissionsListener, OnMapReadyCallback {

    private final static String TAG = MainActivity.class.getSimpleName();

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

    private MainActivityLocationCallback callback = new MainActivityLocationCallback(this);



    private TextToSpeech engine;
    private TextView mTextMessage;
    private Button mValueTimer;


    //GPX
    private ArrayList<Wpt> wpts = new ArrayList<>();
    private ArrayList<Trkpt> trkpts = new ArrayList<>();
    private ArrayList<LatLng> critBuilderLatLng = new ArrayList<>();
    private ArrayList<String> critBuilderLatLngNames = new ArrayList<>();

    private long raceStartTime = 0;


    //TIMER
    private long startTime = 0;
    private String fbCurrentDate = "00000000";

    //SETTINGS
    private String settingsName = "TIM";
    private String settingsGPS = "OFF";
    private Boolean settingsAudio = true;
    private String settingsSport = "BIKE";
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
    SharedPreferences sharedpreferences;


    private void getSharedPrefs() {
        Log.i(TAG, "getSharedPrefs: ");
        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);

        settingsName = sharedpreferences.getString(Name, settingsName);
        settingsSport = sharedpreferences.getString(Sport, settingsSport);
        settingsMaxHeartrate = sharedpreferences.getInt(MaxHR, settingsMaxHeartrate);

        Log.i(TAG, "getSharedPrefs: " + settingsName + settingsMaxHeartrate + settingsSport);

        displayName(settingsName);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b1 = (Button) findViewById(R.id.valueEditMaxHR);
                b1.setText(String.format("%s  MAX HR", String.valueOf(settingsMaxHeartrate)));
                Button b2 = (Button) findViewById(R.id.valueEditSport);
                b2.setText(settingsSport);
            }
        });


    }

    private void setSharedPrefs() {
        Log.i(TAG, "setSharedPrefs: ");
        SharedPreferences.Editor editor = sharedpreferences.edit();

        editor.putString(Name, settingsName);
        editor.putString(Sport, settingsSport);
        editor.putInt(MaxHR, settingsMaxHeartrate);
        editor.commit();
    }





    private ArrayList<Double> critPointLocationLats = new ArrayList<>();
    private ArrayList<Double> critPointLocationLons = new ArrayList<>();
    private ArrayList<String> critPointLocationNames = new ArrayList<>();

    private void resetCritPointLocationArrays() {
        critPointLocationLats = new ArrayList<>();
        critPointLocationLons = new ArrayList<>();
        critPointLocationNames = new ArrayList<>();
    }

    private int currentWaypoint = 0;
    private int maxWaypoint;
    private int maxTrackpoint;
    private String trkName = "NONE";


    //GPX
    public void startGPX() {
        Log.i(TAG, "startGPX");
        resetRace();

        AssetManager assetManager = getAssets();
        GpxParser parser;
        Gpx gpx = null;

        try {


//            InputStream inputStream = getContentResolver().openInputStream(selectedfile);
            InputStream inputStream = assetManager.open("Prospect_Park_Brooklyn_Single_Loop.gpx");

            if (selectedfile != null) {
                inputStream = getContentResolver().openInputStream(selectedfile);
            }

            parser = new GpxParser(inputStream);
            gpx = parser.parse();

        } catch (IOException e) {
            e.printStackTrace();
        }

        assert gpx != null;
        wpts = gpx.getWpts();
        maxWaypoint = wpts.size();  //add start and finish as waypoints

        //Log.i(TAG, "NOW THE WAYPTS \n\n\n");

        //for (Wpt w : wpts) {
            //Log.i("Name of waypoint ", w.getName());
//            Log.i("Description ",w.getDesc());
//            Log.i("Symbol of waypoint ",w.getSym());
            //Log.i("Coordinates ", String.valueOf(w.getLatLon()));
        //}

        ArrayList<Trk> trks = gpx.getTrks();
        trkpts = trks.get(0).getTrkseg();
        trkName = trks.get(0).getName();
        Log.i(TAG, "startGPX: trkName  " + trkName);
        maxTrackpoint = trkpts.size();
        Log.i(TAG, "trkpts size: " + maxTrackpoint);

        //Log.i(TAG, "NOW THE TRKSEGS \n\n\n");

//        for (Trk t : trks) {
//            //Log.i(TAG, "TrkSegs, for loop");
//        }


//        for (Trkpt tk : trkpts) {
//            //Log.i(TAG, "Trkpt: Lat" + String.valueOf(tk.getLatLon()));
//        }


//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                TextView t1 = (TextView) findViewById(R.id.valueGPX);
//                t1.setText(trkName);
//                setMessageText("GOTO THE START POINT");
//            }
//        });

//        if (trkpts.size() > 0) {
//            addAnotherMarker(trkpts.get(0).getLat(), trkpts.get(0).getLon());
//        }



        //reset arrays
        resetCritPointLocationArrays();
        //add start point/name
        critPointLocationLats.add(trkpts.get(0).getLat());
        critPointLocationLons.add(trkpts.get(0).getLon());
        critPointLocationNames.add(trks.get(0).getName());
        //add waypoints/names
        for (Wpt w : wpts) {
            Log.i("Name of waypoint ", w.getName());
            //Log.i("Coordinates ", String.valueOf(w.getLatLon()));
            critPointLocationLats.add(w.getLat());
            critPointLocationLons.add(w.getLon());
            critPointLocationNames.add(w.getName());
        }

        if (critPointLocationNames.size() > 0) {
            addAnotherMarker(critPointLocationLats.get(0), critPointLocationLons.get(0));
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView t1 = (TextView) findViewById(R.id.valueGPX);
                    t1.setText(critPointLocationNames.get(0));
                    setMessageText("GOTO THE START POINT");

                    TextView mGPS = findViewById(R.id.valueGPS);
                    mGPS.setText("ON");
                    settingsGPS = "ON";
                }
            });
            createTimeline("CRIT LOADED: " + critPointLocationNames.get(0).toUpperCase(), Timer.getCurrentTimeStamp());
            requestRaceData(critPointLocationNames.get(0));



        }


        //Log.i(TAG, "startGPX: requestRaceData");
//        createTimeline("CRIT LOADED: " + trkName.toUpperCase(), Timer.getCurrentTimeStamp());
//        requestRaceData(trkName);

//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                TextView mGPS = findViewById(R.id.valueGPS);
//                //Button bGPS = findViewById(R.id.clickGPSButton);
//                if (settingsGPS.equals("OFF")) {
//                    mGPS.setText("ON");
//                    settingsGPS = "ON";
//                    //bGPS.setText("GPS STATUS");
//                    Log.i(TAG, "clickGPS: ON");
//                    //startGPS();
//                    // Show Alert
//                    Toast.makeText(getApplicationContext(),
//                            "GPS ON", Toast.LENGTH_SHORT)
//                            .show();
//                }
//            }
//        });

    }


    //TIMES FOR RACE

    private ArrayList<Long> raceTimesTim = new ArrayList<>();
    private long bestRaceTime = -1;
    private String bestRacerName = "";

    private ArrayList<Long> waypointTimesTim = new ArrayList<>();
    private ArrayList<Long> waypointTimesBest = new ArrayList<>();
    private String waypointTimesTimString;

    //CHECKPOINTS
    private long lastCheckpointTime = 0;
    private int distanceBetweenValue = 150;
    private Boolean isRaceStarted = false;


    //RACE FCTNS
    private void resetRace() {
        Log.i(TAG, "resetRace: ");
        int currentTrackpoint = 0;
        lastCheckpointTime = 0;
        raceStartTime = 0;
        isRaceStarted = false;

    }




    //START WAYPOINTTEST CB
    private void waypointTestCB(double gpsLa, double gpsLo) {
        Log.i(TAG, "waypointTestCB, currentWaypointCB, max: " + currentWaypointCB + ", " + maxWaypointCB);

        if (!isRaceStarted) {
            Log.i(TAG, "waypointTest CB: race not started, return");
        }

        if (currentWaypointCB >= maxWaypointCB) {
            Log.i(TAG, "waypointTestCB, currentWaypointCB > maxCB, SHOULDN'T HAPPEN, RETURN");
            return;
        }


        final double disBetw = distance_between(gpsLa, gpsLo, critBuilderLatLng.get(currentWaypointCB).getLatitude(), critBuilderLatLng.get(currentWaypointCB).getLongitude());
        Log.i(TAG, "waypointTestCB: waiting for waypoint match, distance: " + disBetw);
        //WAYPOINT MATCH
        if (disBetw < 1000) {
            setMessageText(String.valueOf((int) disBetw));
        }

        if (disBetw < distanceBetweenValue) {
            Log.i(TAG, "WAYPOINT MATCH CB " + (currentWaypointCB) + " OF " + (maxWaypointCB));
            if ((currentWaypointCB+1) < maxWaypointCB) {
                addAnotherMarker(critBuilderLatLng.get(currentWaypointCB+1).getLatitude(), critBuilderLatLng.get(currentWaypointCB+1).getLongitude());
            }

            setMessageText("CB RACE CHECKPOINT " + (currentWaypointCB) + " OF " + (maxWaypointCB));
            Log.i(TAG, "waypointTest CB: raceTime at WP: " + (System.currentTimeMillis() - raceStartTime));
            //EACH TIME IS ADDED
            waypointTimesTim.add(System.currentTimeMillis() - raceStartTime);
            waypointTimesTimString += String.valueOf(System.currentTimeMillis() - raceStartTime);
            waypointTimesTimString += ",";

            String s1 = "";
            String s2 = "";
            if (waypointTimesBest.isEmpty()) {
                Log.i(TAG, "waypointTimesBest is empty");
            } else {
                if (currentWaypointCB > 0) {

                    Log.i(TAG, "waypointTestCB: waypointTimesBest, " + waypointTimesBest);
                    Log.i(TAG, "waypointTestCB: waypointTimesTim, " + waypointTimesTim);

                    if ((waypointTimesBest.get(currentWaypointCB-1) > waypointTimesTim.get(currentWaypointCB-1))) {
                        long l = waypointTimesBest.get(currentWaypointCB-1) - waypointTimesTim.get(currentWaypointCB-1);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER" + bestRacerName;
                            s2 = "EVEN WITH THE LEADER" + bestRacerName;
                        } else {
                            s1 = getTimeStringFromMilliSecondsToDisplay(i) + " AHEAD OF " + bestRacerName;
                            s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " AHEAD OF " + bestRacerName;
                        }

                    } else {
                        long l = waypointTimesTim.get(currentWaypointCB-1) - waypointTimesBest.get(currentWaypointCB-1);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER";
                            s2 = "EVEN WITH THE LEADER";
                        } else {
                            s1 = getTimeStringFromMilliSecondsToDisplay(i) + " BEHIND";
                            s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " BEHIND";
                        }

                    }
                    Log.i(TAG, "waypointTest: s1:  " + s1);
                }
            }

            if ((currentWaypointCB + 1) == critBuilderLatLng.size()) {
                Log.i(TAG, "waypointTest: next stop is finish, currentWaypointCB " + currentWaypointCB);
                addAnotherMarker(critBuilderLatLng.get(critBuilderLatLng.size()-1).getLatitude(), critBuilderLatLng.get(critBuilderLatLng.size()-1).getLongitude());

                createTimeline("WAYPOINT " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + "\n" + critBuilderLatLngNames.get(currentWaypointCB) + "\n" + s1 + "\nHEAD TO FINISH", Timer.getCurrentTimeStamp());
                speakText("WAYPOINT " + critBuilderLatLngNames.get(currentWaypointCB) + ".  NUMBER " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + "...  " + s2 + ".  HEAD TO FINISH");
            } else {
                Log.i(TAG, "waypointTestCB: not finish, next wp cb, currentWaypointCB "+ currentWaypointCB);
                createTimeline("WAYPOINT " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + "\n" + critBuilderLatLngNames.get(currentWaypointCB) + "\n" + s1 + "\nHEAD TO " + critBuilderLatLngNames.get(currentWaypointCB+1), Timer.getCurrentTimeStamp());
                speakText("WAYPOINT " + critBuilderLatLngNames.get(currentWaypointCB) + ".  NUMBER " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + ".  " + s2 + ".  HEAD TO " + critBuilderLatLngNames.get(currentWaypointCB+1));
            }

            Log.i(TAG, "waypointTestCB: current " + currentWaypointCB);
            currentWaypointCB += 1;
            Log.i(TAG, "waypointTestCB: current " + currentWaypointCB);
        }
    }
    //END WAYPOINTTEST CB


    private void waypointTest(double gpsLa, double gpsLo) {
        Log.i(TAG, "WAYPOINT TEST, currentWaypoint, maxWP: " + currentWaypoint + ", " + maxWaypoint);

        if (!isRaceStarted) {
            Log.i(TAG, "waypointTest: race not started, return");
        }

        if (currentWaypoint >= maxWaypoint) {
            Log.i(TAG, "waypointTest, currentWaypoint > MAXWAYPOINT, SHOULDN'T HAPPEN, RETURN");
            return;
        }


        final double disBetw = distance_between(gpsLa, gpsLo, wpts.get(currentWaypoint).getLat(), wpts.get(currentWaypoint).getLon());
        Log.i(TAG, "waypointTest: waiting for waypoint match, distance: " + disBetw);
        //WAYPOINT MATCH
        if (disBetw < 1000) {
            setMessageText(String.valueOf((int) disBetw));
        }

        if (disBetw < distanceBetweenValue) {
            Log.i(TAG, "WAYPOINT MATCH " + (currentWaypoint+1) + " OF " + (maxWaypoint+1));
            if ((currentWaypoint+1) < maxWaypoint) {
                addAnotherMarker(wpts.get(currentWaypoint+1).getLat(), wpts.get(currentWaypoint+1).getLon());
            }

            setMessageText("RACE CHECKPOINT " + (currentWaypoint+1) + " OF " + (maxWaypoint+1));
            Log.i(TAG, "waypointTest: raceTime at WP: " + (System.currentTimeMillis() - raceStartTime));
            //EACH TIME IS ADDED
            waypointTimesTim.add(System.currentTimeMillis() - raceStartTime);
            waypointTimesTimString += String.valueOf(System.currentTimeMillis() - raceStartTime);
            waypointTimesTimString += ",";

            String s1 = "";
            String s2 = "";
            if (waypointTimesBest.isEmpty()) {
                Log.i(TAG, "waypointTimesBest is empty");
            } else {
                if (currentWaypoint >= 0) {

                    if ((waypointTimesBest.get(currentWaypoint) > waypointTimesTim.get(currentWaypoint))) {
                        long l = waypointTimesBest.get(currentWaypoint) - waypointTimesTim.get(currentWaypoint);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER" + bestRacerName;
                            s2 = "EVEN WITH THE LEADER" + bestRacerName;
                        } else {
                            s1 = getTimeStringFromMilliSecondsToDisplay(i) + " AHEAD OF " + bestRacerName;
                            s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " AHEAD OF " + bestRacerName;
                        }

                    } else {
                        long l = waypointTimesTim.get(currentWaypoint) - waypointTimesBest.get(currentWaypoint);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER";
                            s2 = "EVEN WITH THE LEADER";
                        } else {
                            s1 = getTimeStringFromMilliSecondsToDisplay(i) + " BEHIND";
                            s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " BEHIND";
                        }

                    }
                    Log.i(TAG, "waypointTest: s1:  " + s1);
                }
            }

            if ((currentWaypoint + 1) == wpts.size()) {
                Log.i(TAG, "waypointTest: next stop is finish");
                addAnotherMarker(trkpts.get(trkpts.size()-1).getLat(), trkpts.get(trkpts.size()-1).getLon());

                createTimeline("WAYPOINT " + (currentWaypoint + 1) + " OF " + (maxWaypoint + 1) + "\n" + wpts.get(currentWaypoint).getName() + "\n" + s1 + "\nHEAD TO FINISH", Timer.getCurrentTimeStamp());
                speakText("WAYPOINT " + wpts.get(currentWaypoint).getName() + ".  NUMBER " + (currentWaypoint + 1) + " OF " + (maxWaypoint + 1) + "...  " + s2 + ".  HEAD TO FINISH");
            } else {
                createTimeline("WAYPOINT " + (currentWaypoint + 1) + " OF " + (maxWaypoint + 1) + "\n" + wpts.get(currentWaypoint).getName() + "\n" + s1 + "\nHEAD TO " + wpts.get(currentWaypoint+1).getName(), Timer.getCurrentTimeStamp());
                speakText("WAYPOINT " + wpts.get(currentWaypoint).getName() + ".  NUMBER " + (currentWaypoint + 1) + " OF " + (maxWaypoint + 1) + ".  " + s2 + ".  HEAD TO " + wpts.get(currentWaypoint+1).getName());
            }


            currentWaypoint += 1;
        }
    }


    private String llp = "";
    private String lln = "";

    private void postRaceProcessing(final long rt) {
        Log.i(TAG, "postRaceProcessing: ");

        Integer raceDate = Integer.valueOf(fbCurrentDate);
        String raceName = trkName;

        Log.i(TAG, "trackpointTest: waypointTimesTimString: " + waypointTimesTimString);



        Race r = new Race(settingsName, raceName, rt, raceDate, waypointTimesTimString, llp, lln);
        Log.i(TAG, "postRaceProcessing: r  " + r.toString());

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
                        lln = "";
                        llp = "";
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

    private void requestRaceData(String raceDataName) {


        Log.i(TAG, "fb request race data for " + raceDataName);
        String raceURL = "race/" + raceDataName;
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference(raceURL);


        //REQUEST RACE DATA
        mDatabase.limitToFirst(1).orderByChild("raceTimeToComplete").addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                Log.i(TAG, "onDataChange: RACE");

                for (DataSnapshot ds : dataSnapshot.getChildren()) {
                    String raceName = ds.child("raceName").getValue(String.class);
                    String riderName = ds.child("riderName").getValue(String.class);
                    String raceWaypointTimes = ds.child("waypointTimes").getValue(String.class);
                    Integer raceTimeToComplete = ds.child("raceTimeToComplete").getValue(Integer.class);
                    //Log.i(TAG, "onDataChange: ROUND LEADER: " + (String.format("%s.  %s", String.format(Locale.US, "%.2f MPH", speed), name)));

                    Log.i(TAG, "onDataChange: RACE, LEADER, TIME: " + raceName + ",  " + riderName + ",  " + getTimeStringFromMilliSecondsToDisplay(raceTimeToComplete) + ".");
                    Log.i(TAG, "onDataChange: WAYPOINT Times: " + raceWaypointTimes);

                    String post = "RACE UPDATE:\n" + raceName.toUpperCase() + ".\nRACE LEADER IS: " + riderName + ",  " + getTimeStringFromMilliSecondsToDisplay(raceTimeToComplete) + ".";
                    speakText("RACE LEADER IS " + riderName + ".  FOR " + raceName);
                    createTimeline(post, Timer.getCurrentTimeStamp());

                    String dwnloadPoints = ds.child("llPoints").getValue(String.class);
                    String dwnloadNames = ds.child("llNames").getValue(String.class);
                    Log.i(TAG, "onDataChange: dwnloadPoints " + dwnloadPoints);
                    Log.i(TAG, "onDataChange: dwnloadNames " + dwnloadNames);

                    //CONVERT STRING TO ARR-BEST
                    //convert string to ArrayList with splice
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
                    Log.i(TAG, "onDataChange: waypointTimesBest: " + waypointTimesBest.toString());
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
        engine.speak(st, TextToSpeech.QUEUE_FLUSH, null, null);
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
        Log.i(TAG, "roundEndCalculate: ");
        double newDistance = geoDistance;
        double roundDistance = newDistance - oldDistance; //MILES
        double roundSpeed = roundDistance / ((double) settingsSecondsPerRound / 60.0 / 60.0);
        double pastRoundHeartrate = roundHeartrate;

        Log.i(TAG, "roundEndCalculate: roundHeartrate:  " + String.format("%.1f BPM", roundHeartrate));
        Log.i(TAG, "roundEndCalculate: roundSpeed:  " + String.format("%.2f MPH", roundSpeed));

        if (roundSpeed > bestRoundSpeed) {
            //vibrator600();
            bestRoundSpeed = roundSpeed;
            //createTimeline("MY FASTEST SPEED" + "\n[" + String.format("%.2f MPH", bestRoundSpeed) + "]", "");
        } else {
            //vibrator300();
            Log.i(TAG, "roundEndCalculate: not the best");
        }
        if (returnScoreFromHeartrate(roundHeartrate) > bestRoundScore) {
            bestRoundScore = returnScoreFromHeartrate(roundHeartrate);
//            createTimeline("HIGHEST SCORE" + "  [" + String.format("%.2f", bestRoundScore) + "]", "");
        } else {
            Log.i(TAG, "roundEndCalculate: not the best");
        }
        if (roundHeartrate > bestRoundHeartrate) {
            bestRoundHeartrate = roundHeartrate;
//            createTimeline("MY HIGHEST HR" + "  [" + String.format("%.1f BPM", bestRoundHeartrate) + "]", "");
            //createTimeline("MY HIGHEST SCORE" + "\n[" + String.format("%.2f %%MAX", returnScoreFromHeartrate(bestRoundHeartrate)) + "]", "");
        } else {
            Log.i(TAG, "roundEndCalculate: not the best");
        }
        String s1 = "COMPLETED ROUND: " + (currentRound - 1);
        String s2 = "\nSPEED: " + String.format("%.2f MPH", roundSpeed);
        String s2x = "  [" + String.format("%.2f MPH", bestRoundSpeed) + "]";
        String s3 = "\nHR:  " + String.format("%.1f BPM", roundHeartrate);
        String s3x = "  [" + String.format("%.1f BPM", bestRoundHeartrate) + "]";
        String s4 = "\nSCORE:  " + String.format("%.0f%%", returnScoreFromHeartrate(bestRoundHeartrate));
        String s4x = "  [" + String.format("%.0f%%", returnScoreFromHeartrate(bestRoundHeartrate)) + "]";
        //createTimeline("ROUND "+ currentRound + ":\nSPEED: " + String.format("%.2f MPH", roundSpeed)+ "\nHR:  " + String.format("%.1f BPM", roundHeartrate), Timer.getCurrentTimeStamp());

//        if (roundHeartrate > 50) {
//            createTimeline(s1 + s2 + s2x + s3 + s3x + s4 + s4x, Timer.getCurrentTimeStamp());
//        } else {
//            createTimeline(s1 + s2 + s2x, Timer.getCurrentTimeStamp());
//        }
//        setMessageText("R" + (currentRound - 1) + ": SPEED: " + String.format("%.1f MPH", roundSpeed) + ",  HR:  " + String.format("%.0f BPM", roundHeartrate));
        Log.i(TAG, "roundEndCalculate: \n" + s1 + s2 + s2x + s3 + s3x);

        if (roundHeartrateCount == 0) {
            showHR = false;
        } else {
            showHR = true;
        }

        //after...
        oldDistance = newDistance;
        roundHeartrateTotal = 0;
        roundHeartrateCount = 0;
        roundHeartrate = 0;

        //ROUNDS
        //WRITE END OF ROUND DATA
        Log.i(TAG, "fbWriteNewRound: ");
        String roundURL = "rounds/" + fbCurrentDate;
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference(roundURL);
        // Creating new user node, which returns the unique key value
        // new user node would be /users/$userid/
        String userId = mDatabase.push().getKey();
        // creating user object
        Round round = new Round(settingsName, roundSpeed, roundHeartrate, returnScoreFromHeartrate(pastRoundHeartrate), (currentRound - 1));
        // pushing user to 'users' node using the userId
        mDatabase.child(userId).setValue(round)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        // Write was successful!
                        Log.i(TAG, "onSuccess: write ROUNDS was successful");
                        //fbWriteNewTotal();
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        // Write failed
                        Log.i(TAG, "onFailure: write ROUNDS failed");
                    }
                });

        //TOTALS
        Log.i(TAG, "fbWriteNewTotal: ");
        //WRITE UPDATE TOTAL DATA
        String totalsURL = "totals/" + fbCurrentDate + "/" + settingsName;
        DatabaseReference mDatabaseTotals = FirebaseDatabase.getInstance().getReference(totalsURL);
        DecimalFormat df = new DecimalFormat("#.##");
        Total total = new Total(settingsName, Double.valueOf(df.format(returnScoreFromHeartrate(averageHR))), Double.valueOf(df.format(geoAvgSpeed)));
        mDatabaseTotals.setValue(total)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        // Write was successful!
                        Log.i(TAG, "onSuccess: write TOTALS was successful");
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        // Write failed
                        Log.i(TAG, "onFailure: write TOTALS failed");
                    }
                });


        if ((currentRound - 1) == 1) {

            //REQUEST ROUND SPD LEADER
            mDatabase.limitToLast(1).orderByChild("fb_SPD").addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    Log.i(TAG, "onDataChange: ROUNDS");

                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
                        String name = ds.child("fb_timName").getValue(String.class);
                        Double speed = ds.child("fb_SPD").getValue(Double.class);
                        Log.i(TAG, "onDataChange: ROUND LEADER: " + (String.format("%s.  %s", String.format(Locale.US, "%.2f MPH", speed), name)));
                        if (speed > 3) {
                            //createTimeline("FASTEST \n" + (String.format("%s  %s", String.format(Locale.US, "%.2f MPH", speed), name)), "");
                            //speakText("Fastest is now " + String.format(Locale.US, "%.1f ", speed) + " MPH.  " + "Recorded by " + name);
                        }
//                        createTimeline("FASTEST \n" + (String.format("%s  %s", String.format(Locale.US, "%.2f MPH", speed), name)), "");
//                        speakText("Fastest  is now " + String.format(Locale.US, "%.1f ", speed) + " MPH.  " + "Recorded by " + name);
                    }  //COMPLETED - READING EACH SNAP
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    // Failed to read value
                    Log.i(TAG, "Failed to read value - ROUNDS", databaseError.toException());
                }
            });
            //END READ ROUNDS FOR SPEED LEADER


            //REQUEST TOTAL SPD LEADER
            String totalsURLlistener = "totals/" + fbCurrentDate;
            DatabaseReference mDatabaseTotalsListener = FirebaseDatabase.getInstance().getReference(totalsURLlistener);
            mDatabaseTotalsListener.limitToLast(1).orderByChild("a_speedTotal").addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    Log.i(TAG, "onDataChange: TOTAL SPEED");

                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
                        String name = ds.child("fb_timName").getValue(String.class);
                        Double speed = ds.child("a_speedTotal").getValue(Double.class);
                        Log.i(TAG, "onDataChange: TOTAL LEADER SPEED:  " + (String.format("%s.  %s", String.format(Locale.US, "%.2f MPH", speed), name)));
                        //createTimeline("DAILY SPEED LEADER\n" + (String.format("%s  %s", String.format(Locale.US, "%.2f MPH", speed), name)), "");
                    }  //COMPLETED - READING EACH SNAP
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    // Failed to read value
                    Log.i(TAG, "Failed to read value - TOTALS", databaseError.toException());
                }
            });
            //END READ TOTALS FOR SPEED LEADER

            //REQUEST ROUND SCORE LEADER
            mDatabase.limitToLast(1).orderByChild("fb_RND").addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    Log.i(TAG, "onDataChange: ROUND SCORES");

                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
                        String name = ds.child("fb_timName").getValue(String.class);
                        Double score = ds.child("fb_RND").getValue(Double.class);
                        Log.i(TAG, "onDataChange: ROUND LEADER SCORES: " + (String.format("%s.  %s", String.format(Locale.US, "%.2f %%MAX", score), name)));

//                        if (score < 10) {
//                            Log.i(TAG, "onDataChange: score too low to publish");
//                            return;
//                        } else {
//                            createTimeline("BEST CRIT SCORE\n" + (String.format("%s  %s", String.format(Locale.US, "%.2f %%MAX", score), name)), "");
//                        }


                    }  //COMPLETED - READING EACH SNAP
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    // Failed to read value
                    Log.i(TAG, "Failed to read value - ROUNDS", databaseError.toException());
                }
            });
            //END READ ROUNDS FOR SCORE LEADER

            //REQUEST TOTALS SCORE LEADER
            mDatabaseTotalsListener.limitToLast(1).orderByChild("a_scoreHRTotal").addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    Log.i(TAG, "onDataChange: TOTAL SCORE");

                    for (DataSnapshot ds : dataSnapshot.getChildren()) {
                        String name = ds.child("fb_timName").getValue(String.class);
                        Double score = ds.child("a_scoreHRTotal").getValue(Double.class);

                        if (score < 10) {
                            Log.i(TAG, "onDataChange: score too low to publish");
                            return;
                        }

                        Log.i(TAG, "onDataChange: TOTAL LEADER SCORE:  " + (String.format("%s.  %s", String.format(Locale.US, "%.2f %%MAX", score), name)));
                        //createTimeline("DAILY SCORE LEADER\n" + (String.format("%s  %s", String.format(Locale.US, "%.2f %%MAX", score), name)), "");
                    }  //COMPLETED - READING EACH SNAP
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    // Failed to read value
                    Log.i(TAG, "Failed to read value - TOTALS", databaseError.toException());
                }
            });
            //END REQUEST TOTAL SCORE LEADER
        } //ADD VALUE EVENT ONCE
    }  //END - ROUND END CALCULATE


    //TIMER
    Handler timerHandler = new Handler();
    Runnable timerRunnable = new Runnable() {
        @SuppressLint("DefaultLocale")
        @Override
        public void run() {
            final long totalMillis = System.currentTimeMillis() - startTime;
            //Timer.setTotalMillis(totalMillis);
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
                    //Log.i(TAG, "run: a3, togo:  " + a3 + ", " +togo);
                    //String togoStr = Timer.getTimeStringFromSecondsToDisplay(togo);
                    //Button rnd = (Button) findViewById(R.id.valueRoundButton);
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
                roundEndCalculate();
                //PROCESS NEW ROUND
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
                    mTextMessage.setVisibility(View.VISIBLE);
                    //setMessageText("HOME");
                    ll.setVisibility(View.GONE);
                    tl.setVisibility(View.GONE);
                    sv.setVisibility(View.GONE);
                    return true;
                case R.id.navigation_dashboard:
                    ll.setVisibility(View.VISIBLE);
                    sv.setVisibility(View.GONE);
                    mTextMessage.setVisibility(View.GONE);
                    tl.setVisibility(View.GONE);
                    return true;
                case R.id.navigation_notifications:
                    ll.setVisibility(View.GONE);
                    sv.setVisibility(View.GONE);
                    mTextMessage.setVisibility(View.GONE);
                    tl.setVisibility(View.VISIBLE);
                    return true;
                case R.id.navigation_settings:
                    //setMessageText("SETTINGS");
                    ll.setVisibility(View.GONE);
                    tl.setVisibility(View.GONE);
                    sv.setVisibility(View.VISIBLE);
                    return true;
            }
            return false;
        }
    };


    @SuppressLint("StaticFieldLeak")
    static MainActivity mn;

    @SuppressLint("DefaultLocale")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mn=MainActivity.this;

        Mapbox.getInstance(this, getString(R.string.access_token));
        setContentView(R.layout.activity_main);

        timerStart(getCurrentFocus());
        mTextMessage = (TextView) findViewById(R.id.message);
        mValueTimer = findViewById(R.id.valueTimer);

        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        createTimeline("LET'S GET STARTED", Timer.getCurrentTimeStamp());
        setRandomUsernameOnStart();
        getSharedPrefs();

        engine = new TextToSpeech(this, this);
        //startGPS();

        int yearInt = Calendar.getInstance(Locale.ENGLISH).get(Calendar.YEAR);
        int monthInt = Calendar.getInstance(Locale.ENGLISH).get(Calendar.MONTH);
        int dayInt = Calendar.getInstance(Locale.ENGLISH).get(Calendar.DAY_OF_MONTH);
        fbCurrentDate = String.format("%02d%02d%02d", yearInt, monthInt + 1, dayInt);

//        boolean b = checkLocationPermissions();
        //Log.i(TAG, "onCreate: checkLocationPermissions: " + checkLocationPermissions());

        mapView = findViewById(R.id.mapView);
        mapView.onCreate(savedInstanceState);
        mapView.getMapAsync(this);


    }

    //MULTIPLE MARKERS
    private boolean isRaceLoaded = false;
    private int raceNumber = 10;



    private void addAnotherMarker(final double markerLat, final double markerLon) {

        raceNumber += 1;
        Log.i(TAG, "addAnotherMarker: ");
//        if (trkpts.size() <= 1) {
//            Log.i(TAG, "addAnotherMarker: no course loaded");
//            return;
//        }

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

//                for (Wpt w : wpts) {
//                    Log.i("Name of waypoint ", w.getName());
//                    markerCoordinates.add(Feature.fromGeometry(
//                            Point.fromLngLat(w.getLon(), w.getLat())));
//                }

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




    @Override
    public void onMapReady(@NonNull final MapboxMap mapboxMap) {
        this.mapboxMap = mapboxMap;

        mapboxMap.setStyle(Style.MAPBOX_STREETS,
                new Style.OnStyleLoaded() {
                    @Override
                    public void onStyleLoaded(@NonNull Style style) {
                        enableLocationComponent(style);
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
                    addAnotherMarker(point.getLatitude(), point.getLongitude());
                    llp += point.getLatitude() + "," + point.getLongitude() + ";";
                    //get name from input
                    inputWaypointName();
                }
                return false;
            }
        });
    }


private Boolean collectCritPoints = false;

//    Set up the LocationEngine and the parameters for querying the device's location

    @SuppressLint("MissingPermission")
    private void initLocationEngine() {
        locationEngine = LocationEngineProvider.getBestLocationEngine(this);

        LocationEngineRequest request = new LocationEngineRequest.Builder(DEFAULT_INTERVAL_IN_MILLISECONDS)
                .setPriority(LocationEngineRequest.PRIORITY_HIGH_ACCURACY)
                .setMaxWaitTime(DEFAULT_MAX_WAIT_TIME).build();

        locationEngine.requestLocationUpdates(request, callback, getMainLooper());
        locationEngine.getLastLocation(callback);
    }



    private boolean res = true;

    private boolean checkLocationPermissions() {
        Log.i(TAG, "enableLocationPermissions: ");

        // Make sure we have access coarse location enabled, if not, prompt the user to enable it
        if (this.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            Log.i(TAG, "PROMPT FOR LOCATION ENABLED");
            final AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("This app needs location access");
            builder.setMessage("Please grant so the app can capture distance and speed (for raceing), location (map display), and Bluetooth (finding devices))");
            builder.setPositiveButton(android.R.string.ok, null);
            builder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_REQUEST_COARSE_LOCATION);
                    res = false;
                }
            });
            builder.show();
        }

        return res;
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
    }


    @Override
    public void onStop() {
        super.onStop();
        mapView.onStop();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mapView.onLowMemory();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (locationEngine != null) {
            Log.i(TAG, "onDestroy: removeLocationUpdates");
            locationEngine.removeLocationUpdates(callback);
        }
        //mFusedLocationClient.removeLocationUpdates(mLocationCallback);

        //Close the Text to Speech Library
        if(engine !=null){
            Log.i(TAG, "onDestroy: shutdown tts");
            engine.stop();
            engine.shutdown();
        }

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

    }

    @Override
    protected void onPause() {
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
                break;
            case "RUN":
                //b1.setText("ROW");
                settingsSport = "ROW";
                break;
            case "ROW":
                settingsSport = "BIKE";
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
        builder1.setTitle("CRIT BUILDER");

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
                    critBuilderLatLngNames.add("CHECKPOINT " + " " + wayName);
                    lln += ("CHECKPOINT " + " " + wayName + ",");
                }
            });

        }
        if (critBuilderLatLngNames.size() == 0){
            builder1.setNeutralButton("START", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {

                    Random r = new Random();
                    int i1 = r.nextInt(99999 - 10001);

                    input.setText("VC" + i1);
                    String wayName = input.getText().toString().toUpperCase();
                    critBuilderLatLngNames.add(wayName);
                    lln += wayName + ",";
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
                    lln += "FINISH";
                    Log.i(TAG, "collectCritPointName: FINISHED, POINTS:  " + critBuilderLatLngNames + critBuilderLatLng);

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Button b1 = (Button) findViewById(R.id.clickButtonStartCritBuilder);
                            b1.setText("BUILDER");
                            TextView t1 = (TextView) findViewById(R.id.valueCritBuilderName);
                            t1.setText(critBuilderLatLngNames.get(0));
                            startGpxFromCritBuilder();
                        }
                    });

                    dialog.cancel();
                }
            });
        }


        builder1.show();

    }

    private int maxWaypointCB;
    private int currentWaypointCB = 0;
    private Boolean isCritBuilderActive = false;

    public void startGpxFromCritBuilder() {
        Log.i(TAG, "startGpxFromCritBuilder: ");
        isCritBuilderActive = true;
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

            }
        });
        addAnotherMarker(critBuilderLatLng.get(0).getLatitude(), critBuilderLatLng.get(0).getLongitude());
        createTimeline("CRIT LOADED: " + critBuilderLatLngNames.get(0).toUpperCase(), Timer.getCurrentTimeStamp());

        requestRaceData(critBuilderLatLngNames.get(0));

    }

    private void setRandomUsernameOnStart() {
        Random r = new Random();
        int i1 = r.nextInt(9999 - 1001);
        settingsName = "TIM" + i1;
        displayName(settingsName);

    }

    double distance_between(Double lat1, Double lon1, Double lat2, Double lon2) {
        double R = 6371; // km
        double dLat = (lat2 - lat1) * Math.PI / 180;
        double dLon = (lon2 - lon1) * Math.PI / 180;
        lat1 = lat1 * Math.PI / 180;
        lat2 = lat2 * Math.PI / 180;

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double d = R * c * 1000;

        return d;
    }






//    private void startGPS() {
//        Log.i(TAG, "startGPS: ");
//        createTimeline("STARTING GPS", Timer.getCurrentTimeStamp());
//    }

    public void clickAudio(View view) {
        Log.i(TAG, "clickAudio  " + settingsAudio);


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
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                TextView mGPS = findViewById(R.id.valueGPS);
//                Button bGPS = findViewById(R.id.clickGPSButton);
//                if (settingsGPS.equals("OFF")) {
//                    mGPS.setText("ON");
//                    settingsGPS = "ON";
//                    bGPS.setText("GPS STATUS");
//                    Log.i(TAG, "clickGPS: ON");
//                    startGPS();
//                    // Show Alert
//                    Toast.makeText(getApplicationContext(),
//                            "GPS ON", Toast.LENGTH_SHORT)
//                            .show();
//                } else {
//                    mGPS.setText("OFF");
//                    settingsGPS = "OFF";
//                    bGPS.setText("GPS STATUS");
//                    Log.i(TAG, "clickGPS: OFF");
//                    //STOP GPS
//                    try {
//                        mFusedLocationClient.removeLocationUpdates(mLocationCallback);
//                    } catch (Exception e) {
//                        Log.i(TAG, "Error,  DIDN'T STOP LOCATION");
//                    }
//                    //SHOWALERT
//                    Toast.makeText(getApplicationContext(),
//                            "GPS OFF", Toast.LENGTH_SHORT)
//                            .show();
//                }
//            }
//        });
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


    @SuppressWarnings({"MissingPermission"})
    private void enableLocationComponent(@NonNull Style loadedMapStyle) {
        Log.i(TAG, "enableLocationComponent: ");
// Check if permissions are enabled and if not request
        if (PermissionsManager.areLocationPermissionsGranted(this)) {
// Activate the MapboxMap LocationComponent to show user location
// Adding in LocationComponentOptions is also an optional parameter

            initLocationEngine();

            locationComponent = mapboxMap.getLocationComponent();
            locationComponent.activateLocationComponent(this, loadedMapStyle);
            locationComponent.setLocationComponentEnabled(true);
// Set the component's camera mode
            locationComponent.setCameraMode(CameraMode.TRACKING);
// Set the component's render mode
            locationComponent.setRenderMode(RenderMode.COMPASS);
        } else {
            permissionsManager = new PermissionsManager(this);
            permissionsManager.requestLocationPermissions(this);
        }


    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        permissionsManager.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void onExplanationNeeded(List<String> permissionsToExplain) {
        Toast.makeText(this, "Requires Permission to Use Location", Toast.LENGTH_LONG).show();
    }

    @Override
    public void onPermissionResult(boolean granted) {
        if (granted) {
            enableLocationComponent(Objects.requireNonNull(mapboxMap.getStyle()));
        } else {
            Toast.makeText(this, "Waiting for Location Permission", Toast.LENGTH_LONG).show();
            finish();
        }
    }

    public void clickStartCritBuilder(View view) {
        Log.i(TAG, "clickStartCritBuilder: ");

        //remove old to start new
        critBuilderLatLngNames = new ArrayList<>();
        critBuilderLatLng = new ArrayList<>();
        collectCritPoints = true;

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Button b1 = (Button) findViewById(R.id.clickButtonStartCritBuilder);
                b1.setText("...");
                TextView t1 = (TextView) findViewById(R.id.valueCritBuilderName);
                t1.setText("SET POINTS ON MAP");
                //mapboxMap.addOnMapClickListener, inputWaypointName
            }
        });


    }

    public void clickLoadFromOldCritBuilder(View view) {
        Log.i(TAG, "clickLoadFromOldCritBuilder: ");
        //get name and pull waypoints down from fb

    }


    private class MainActivityLocationCallback
            implements LocationEngineCallback<LocationEngineResult> {

        private final WeakReference<MainActivity> activityWeakReference;

        MainActivityLocationCallback(MainActivity activity) {
            this.activityWeakReference = new WeakReference<>(activity);
        }


//         The LocationEngineCallback interface's method which fires when the device's location has changed.

        @Override
        public void onSuccess(LocationEngineResult result) {
            MainActivity activity = activityWeakReference.get();
            Log.i(TAG, "onSuccess: Loc CB");

            if (activity != null) {
                Log.i(TAG, "onSuccess: new location");
                Location location = result.getLastLocation();

                if (location == null) {
                    Log.i(TAG, "onSuccess: location == null,return");
                    return;
                }


// Create a Toast which displays the new location's coordinates
//                Toast.makeText(activity, String.format(activity.getString(R.string.new_location),
//                        String.valueOf(result.getLastLocation().getLatitude()), String.valueOf(result.getLastLocation().getLongitude())),
//                        Toast.LENGTH_SHORT).show();

                onMapboxLocationReceived(location);

// Pass the new location to the Maps SDK's LocationComponent
                if (activity.mapboxMap != null && result.getLastLocation() != null) {
                    Log.i(TAG, "onSuccess: activity.mapboxMap != null && result.getLastLocation() != null");
                    activity.mapboxMap.getLocationComponent().forceLocationUpdate(result.getLastLocation());
                }

            }
        }




        private void mapBoxDisplaySpeedValues() {

            final String hms = getTimeStringFromMilliSecondsToDisplay((int) totalTimeGeo);
            
;
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
                        mn.getSupportActionBar().setTitle(String.format("%.1f MPH", geoSpeed) + "  (" + settingsName + ")  " + String.format("%.1f MILES", geoDistance));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }


                }
            });

        }




        private void mapboxEvaluateLocationsCritBuilder(final double gpsLa, final double gpsLo) {
            //start la,lo
            Log.i(TAG, "mapboxEvaluateLocationsCritBuilder: ");

            if (critBuilderLatLng.isEmpty() || critBuilderLatLng.size() < 3) {return;}

            double startLa = critBuilderLatLng.get(0).getLatitude();
            double startLo = critBuilderLatLng.get(0).getLongitude();
            double finishLa = critBuilderLatLng.get(critBuilderLatLng.size()-1).getLatitude();
            double finishLo = critBuilderLatLng.get(critBuilderLatLng.size()-1).getLongitude();

            if (currentWaypointCB == 0 && !isRaceStarted) {
                //we are waiting for start
                double disBetw = distance_between(gpsLa, gpsLo, startLa, startLo);
                Log.i(TAG, "mapboxEvaluateLocationsCB: waiting to start, distance: " + disBetw);
                if (disBetw < distanceBetweenValue) {
                    //race is starting
                    raceStartTime = System.currentTimeMillis();

                    Log.i(TAG, "CRITBUILDER, STARTRACE!");
                    isRaceStarted = true;
                    speakText("THE RACE HAS STARTED  HEAD TO " + critBuilderLatLngNames.get(currentWaypointCB+1));
                    addAnotherMarker(critBuilderLatLng.get(currentWaypointCB+1).getLatitude(), critBuilderLatLng.get(currentWaypointCB+1).getLongitude());
                    waypointTimesTim = new ArrayList<>();
                    waypointTimesTimString = "";
                    lastCheckpointTime = System.currentTimeMillis();

                    String startString = "";
                    if (bestRaceTime > 10000) {
                        startString = "\nTHE LEADER IS " + bestRacerName + " AT " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime);
                    }


                    createTimeline("RACE STARTING\n" + critBuilderLatLngNames.get(0).toUpperCase() + "\nHEAD TO " + critBuilderLatLngNames.get(currentWaypointCB + 1).toUpperCase() + startString, Timer.getCurrentTimeStamp());
                    setMessageText("RACE STARTING");
                    Toast.makeText(getApplicationContext(),
                            "RACE STARTING: " + critBuilderLatLngNames.get(0).toUpperCase(), Toast.LENGTH_LONG)
                            .show();

                    currentWaypointCB += 1;
                }
                return;
            }

            Log.i(TAG, "mapboxEvaluateLocationsCB: current currentWaypointCB and maxcWaypointCB: " + currentWaypointCB + ", " + maxWaypointCB);
            if (currentWaypointCB == maxWaypointCB && isRaceStarted) {
                //passed all waypoints, now looking for finish
                Log.i(TAG, "mapboxEvaluateLocationsCritBuilder: passed all waypoints, now looking for finish");
                double disBetwMax = distance_between(gpsLa, gpsLo, finishLa, finishLo);
                Log.i(TAG, "mapboxEvaluateLocationsCB: waiting to finish, distance: " + disBetwMax);
                if (disBetwMax < distanceBetweenValue) {
                    Log.i(TAG, "mapboxEvaluateLocationsCB: race finished");
                    isRaceStarted = false;
                    currentWaypointCB = 0;
                    long raceFinishTime = System.currentTimeMillis();
                    //raceTime is the duration of the race
                    long raceTime = raceFinishTime - raceStartTime;
                    Log.i(TAG, "CB raceTime: " + raceTime);
                    raceTimesTim.add(raceTime);
                    waypointTimesTim.add(raceTime);
                    waypointTimesTimString += String.valueOf(raceTime);
                    Log.i(TAG, "CB waypointTimesTimString:  " + waypointTimesTimString);
                    trkName = critBuilderLatLngNames.get(0);
                    postRaceProcessing(raceTime);

                    Log.i(TAG, "CB waypointTimesTim:  " + waypointTimesTim.toString());
                    Log.i(TAG, "CB waypointTimesBest:  " + waypointTimesBest.toString());

                    String s;
                    String ss;
                    if (bestRaceTime == -1) {
                        bestRaceTime = raceTime + 1;
                    }

                    if (raceTime < bestRaceTime && bestRaceTime > 10000){
                        bestRaceTime = raceTime;
                        //Log.i(TAG, "new best racetime: waypointTimesBest = waypointTimesTim;");
                        waypointTimesBest = waypointTimesTim;
                        s = "THE NEW FASTEST TIME BY " + getTimeStringFromMilliSecondsToDisplay((int) ((int) bestRaceTime - (int) raceTime));
                        ss = "THE NEW FASTEST TIME BY " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) ((int) bestRaceTime - (int) raceTime));
                    } else {
                        s = "THE FASTEST TIME IS " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime) + " BY " + bestRacerName;
                        ss = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) bestRaceTime) + " BY " + bestRacerName;
                    }
                    Log.i(TAG, "CB TRACKPOINT, RACE FINISHED  : " + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + ".  " + s);

                    createTimeline("RACE COMPLETE\n" + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + "\n" + s, Timer.getCurrentTimeStamp());
                    setMessageText("RACE FINISHED: " + getTimeStringFromMilliSecondsToDisplay((int) raceTime));
                    speakText("RACE COMPLETE, YOUR TIME IS.  " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) raceTime) + ".  " + ss);
                    Log.i(TAG, "trackpointTest: waypointTimesTim: " + waypointTimesTim.toString());
                    Log.i(TAG, "trackpointTest: raceTime: " + raceTime);
                    Toast.makeText(getApplicationContext(),
                            "RACE FINISHED " + getTimeStringFromMilliSecondsToDisplay((int) raceTime), Toast.LENGTH_LONG)
                            .show();
                    //reset
                    resetRace();
                }

            }
            Log.i(TAG, "CB evaluateLocations, pre-wptest: currentWaypointCB, maxWaypointCB " + currentWaypointCB +", "+ maxWaypointCB);
            if (isRaceStarted && currentWaypointCB < maxWaypointCB) {
                Log.i(TAG, "CB WAYPOINT TEST: race has started, check for waypoints");
                waypointTestCB(gpsLa, gpsLo);
            }


        }  //end eval locations CB




        private void mapboxEvaluateLocations(final double gpsLa, final double gpsLo) {
            //start la,lo
            Log.i(TAG, "mapboxEvaluateLocations: ");

            if (trkpts.isEmpty() || trkpts.size() < 3) {return;}

            double startLa = trkpts.get(0).getLat();
            double startLo = trkpts.get(0).getLon();
            double finishLa = trkpts.get(trkpts.size()-1).getLat();
            double finishLo = trkpts.get(trkpts.size()-1).getLon();

            if (currentWaypoint == 0 && !isRaceStarted) {
                //we are waiting for start
                double disBetw = distance_between(gpsLa, gpsLo, startLa, startLo);
                Log.i(TAG, "mapboxEvaluateLocations: waiting to start, distance: " + disBetw);
                if (disBetw < distanceBetweenValue) {
                    //race is starting
                    raceStartTime = System.currentTimeMillis();

                    Log.i(TAG, "TRACKPOINT, STARTRACE!");
                    isRaceStarted = true;
                    speakText("THE RACE IS NOW STARTING!  HEAD TO " + wpts.get(currentWaypoint).getName());
                    addAnotherMarker(wpts.get(0).getLat(), wpts.get(0).getLon());
                    //currentWaypoint = 1;
                    waypointTimesTim = new ArrayList<>();
                    waypointTimesTimString = "";
                    lastCheckpointTime = System.currentTimeMillis();

                    String startString = "";
                    if (bestRaceTime > 10000) {
                        startString = "\nTHE LEADER IS " + bestRacerName + " AT " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime);
                    }


                    createTimeline("RACE STARTING\n" + trkName.toUpperCase() + "\nHEAD TO " + wpts.get(currentWaypoint).getName().toUpperCase() + startString, Timer.getCurrentTimeStamp());
                    setMessageText("RACE STARTING");
                    Toast.makeText(getApplicationContext(),
                            "RACE STARTING: " + trkName, Toast.LENGTH_LONG)
                            .show();
                }
                return;
            }

            Log.i(TAG, "mapboxEvaluateLocations: current waypoint and maxWP: " + currentWaypoint + ", " + maxWaypoint);
            if (currentWaypoint == maxWaypoint && isRaceStarted) {
                //passed all waypoints, now looking for finish
                double disBetwMax = distance_between(gpsLa, gpsLo, finishLa, finishLo);
                Log.i(TAG, "mapboxEvaluateLocations: waiting to finish, distance: " + disBetwMax);
                if (disBetwMax < distanceBetweenValue) {
                    Log.i(TAG, "mapboxEvaluateLocations: race finished");
                    isRaceStarted = false;
                    currentWaypoint = 0;
                    long raceFinishTime = System.currentTimeMillis();
                    //raceTime is the duration of the race
                    long raceTime = raceFinishTime - raceStartTime;
                    Log.i(TAG, "trackpointTest: raceTime: " + raceTime);
                    raceTimesTim.add(raceTime);
                    waypointTimesTim.add(raceTime);
                    waypointTimesTimString += String.valueOf(raceTime);
                    Log.i(TAG, "waypointTimesTimString:  " + waypointTimesTimString);
                    postRaceProcessing(raceTime);

                    Log.i(TAG, "waypointTimesTim:  " + waypointTimesTim.toString());
                    Log.i(TAG, "waypointTimesBest:  " + waypointTimesBest.toString());

                    String s;
                    String ss;
                    if (bestRaceTime == -1) {
                        bestRaceTime = raceTime + 1;
                    }

                    if (raceTime < bestRaceTime && bestRaceTime > 10000){
                        bestRaceTime = raceTime;
                        //Log.i(TAG, "new best racetime: waypointTimesBest = waypointTimesTim;");
                        waypointTimesBest = waypointTimesTim;
                        s = "THE NEW FASTEST TIME BY " + getTimeStringFromMilliSecondsToDisplay((int) ((int) bestRaceTime - (int) raceTime));
                        ss = "THE NEW FASTEST TIME BY " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) ((int) bestRaceTime - (int) raceTime));
                    } else {
                        s = "THE FASTEST TIME IS " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime) + " BY " + bestRacerName;
                        ss = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) bestRaceTime) + " BY " + bestRacerName;
                    }
                    Log.i(TAG, "TRACKPOINT, RACE FINISHED  : " + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + ".  " + s);

                    createTimeline("RACE COMPLETE\n" + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + "\n" + s, Timer.getCurrentTimeStamp());
                    setMessageText("RACE FINISHED: " + getTimeStringFromMilliSecondsToDisplay((int) raceTime));
                    speakText("RACE COMPLETE, YOUR TIME IS.  " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) raceTime) + ".  " + ss);
                    Log.i(TAG, "trackpointTest: waypointTimesTim: " + waypointTimesTim.toString());
                    Log.i(TAG, "trackpointTest: raceTime: " + raceTime);
                    Toast.makeText(getApplicationContext(),
                            "RACE FINISHED " + getTimeStringFromMilliSecondsToDisplay((int) raceTime), Toast.LENGTH_LONG)
                            .show();
                    //reset
                    resetRace();
                }

            }
            Log.i(TAG, "evaluateLocations, pre-wptest: currentWaypoint, maxWP " + currentWaypoint +", "+ maxWaypoint);
            if (isRaceStarted && currentWaypoint < maxWaypoint) {
                Log.i(TAG, "trackpointTest: race has started, check for waypoints");
                waypointTest(gpsLa, gpsLo);
            }


        }  //end eval locations

        private Location oldLocation;
        @SuppressLint("DefaultLocale")
        public void onMapboxLocationReceived(final Location location) {

            Log.i(TAG, "onMapboxLocationReceived: ");
            
            arrLocations.add(location);
            double locationLat = location.getLatitude();
            double locationLon = location.getLongitude();
            long locationTime = location.getTime();

            double oldLocationLat;
            double oldLocationLon;
            long oldLocationTime;


            if (arrLocations.size() <= 2) {
                Log.i(TAG, "onMapboxLocationReceived: starterlocations " + arrLocations.size());
                oldLocation = location;

            } else {
                oldLocationLat = oldLocation.getLatitude();
                oldLocationLon = oldLocation.getLongitude();
                oldLocationTime = oldLocation.getTime();

                //float[] results = new float[2];

                //QUICK TEST
//                Location.distanceBetween(oldLocationLat, oldLocationLon, locationLat, locationLon, results);
//                if (results[0] == 0) {
//                    return;
//                }
//                if (results[0] * 0.000621371 <= 0) {
//                    return;
//                }

                //MORE ACCURATE DISTANCE CALC
                double result = mapBoxDistanceBetween(oldLocationLat, oldLocationLon, locationLat, locationLon);
                if (result  < 5) {
                    return;
                }

                if (locationTime - oldLocationTime > 30000) { //30 SECONDS
                    Log.i(TAG, "onLocationReceived: too much time has passed, ignore and wait for the next one " + (locationTime - oldLocationTime));
                    oldLocation = location;
                    return;
                }


                double gd = result * 0.000621371;
                geoDistance += gd;


                //MORE ACCURACE BUT NOT NECESSARY
                //long gt = (location.getTime() - oldTime);  //MILLI
                //double geoSpeed = gd / ((double) gt / 1000 / 60 / 60);

                //USING QUICK METHOD FOR DISPLAY PURPOSES
                geoSpeed = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr

                totalTimeGeo += (locationTime - oldLocationTime);  //MILLI
                double ttg = (double) totalTimeGeo;  //IN MILLI
                geoAvgSpeed = geoDistance / (ttg / 1000.0 / 60.0 / 60.0);

                mapBoxDisplaySpeedValues();

                if (isCritBuilderActive) {
                    mapboxEvaluateLocationsCritBuilder(locationLat, locationLon);
                } else {
                    mapboxEvaluateLocations(locationLat, locationLon);
                }



                oldLocation = location;
            }
        }


        double mapBoxDistanceBetween(Double lat1, Double lon1, Double lat2, Double lon2) {
            double R = 6371; // km
            double dLat = (lat2 - lat1) * Math.PI / 180;
            double dLon = (lon2 - lon1) * Math.PI / 180;
            lat1 = lat1 * Math.PI / 180;
            lat2 = lat2 * Math.PI / 180;

            double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                    Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
            double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            double d = R * c * 1000;

            return d;
        }


//         The LocationEngineCallback interface's method which fires when the device's location can not be captured
        @Override
        public void onFailure(@NonNull Exception exception) {
            Log.d("LocationChangeActivity", exception.getLocalizedMessage());
            MainActivity activity = activityWeakReference.get();
            if (activity != null) {
                Toast.makeText(activity, exception.getLocalizedMessage(),
                        Toast.LENGTH_SHORT).show();
            }
        }



    }



//
//    @Override
//    public void onMapReady(@NonNull MapboxMap mapboxMap) {
//
//        this.mapboxMap = mapboxMap;
//
//        mapboxMap.setStyle(Style.MAPBOX_STREETS, new Style.OnStyleLoaded() {
//
//            //        mapboxMap.setStyle(getString(R.string.navigation_guidance_day), new Style.OnStyleLoaded() {
//            @Override
//            public void onStyleLoaded(@NonNull Style style) {
//                enableLocationComponent(style);
//            }
//        });
//
//
//    }
}

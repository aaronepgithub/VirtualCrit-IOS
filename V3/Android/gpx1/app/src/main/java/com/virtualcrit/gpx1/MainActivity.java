package com.virtualcrit.gpx1;

import android.annotation.SuppressLint;
import android.content.res.AssetManager;
import android.location.Location;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.text.method.TextKeyListener;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;
import com.mapbox.mapboxsdk.maps.Style;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.security.auth.login.LoginException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import es.atrapandocucarachas.gpxparser.model.Gpx;
import es.atrapandocucarachas.gpxparser.model.Trk;
import es.atrapandocucarachas.gpxparser.model.Trkpt;
import es.atrapandocucarachas.gpxparser.model.Wpt;
import es.atrapandocucarachas.gpxparser.parser.GpxParser;

public class MainActivity extends AppCompatActivity {

    private final static String TAG = MainActivity.class.getSimpleName();
    //private MapView mapView;


    /**
     * The {@link android.support.v4.view.PagerAdapter} that will provide
     * fragments for each of the sections. We use a
     * {@link FragmentPagerAdapter} derivative, which will keep every
     * loaded fragment in memory. If this becomes too memory intensive, it
     * may be best to switch to a
     * {@link android.support.v4.app.FragmentStatePagerAdapter}.
     */
    private SectionsPagerAdapter mSectionsPagerAdapter;


    //GPS
    private LocationRequest mLocationRequest;
    private FusedLocationProviderClient mFusedLocationClient;
    private LocationCallback mLocationCallback;
    private Handler mServiceHandler;
    private Location mLocation;


    private ArrayList<Location> arrLocations = new ArrayList<>();
    private ArrayList<Double> arrLats = new ArrayList<>();
    private ArrayList<Double> arrLons = new ArrayList<>();
    private double oldLat = 0.0;
    private double oldLon = 0.0;
    private double geoSpeed = 0;
    private double geoDistance = 0.0;
    private double geoAvgSpeed = 0.0;
    private float[] results = new float[2];
    private long oldTime = 0;
    private long totalTimeGeo = 0;  //GPS MOVING TIME IN MILLI

    //GPX
//    private ArrayList<Wpt> wpts = gpx.getWpts();
//    private ArrayList<Trk> trks = gpx.getTrks();
//    private ArrayList<Trkpt> trkpts = trks.get(0).getTrkseg();

    private ArrayList<Wpt> wpts = new ArrayList<>();
    private ArrayList<Trk> trks = new ArrayList<>();
    private ArrayList<Trkpt> trkpts = new ArrayList<>();

    private long raceStartTime = 0;
    private long raceFinishTime = 0;

    /**
     * The {@link ViewPager} that will host the section contents.
     */
    private ViewPager mViewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Mapbox Access token
        //Mapbox.getInstance(getApplicationContext(), "pk.eyJ1IjoiYWFyb25lcHMiLCJhIjoiY2pzNHJwZTNvMDg1MjQzb2JrcGpuYjF6NyJ9.sCgbrB62gmXDCjfC4zXm-Q");


        setContentView(R.layout.activity_main);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        // Create the adapter that will return a fragment for each of the three
        // primary sections of the activity.
        mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        // Set up the ViewPager with the sections adapter.
        mViewPager = (ViewPager) findViewById(R.id.container);
        mViewPager.setAdapter(mSectionsPagerAdapter);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });





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



    //GPS
    private String settingsGPS = "OFF";
    public void clickB1(View view) {
        Log.i(TAG, "clickB1: GPS");

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView mGPS = findViewById(R.id.button1);
                    if (settingsGPS.equals("OFF")) {
                        mGPS.setText("GPS: ON");
                        settingsGPS = "ON";
                        Log.i(TAG, "run: GPS On");
                        startGPS();
                        // Show Alert
                        Toast.makeText(getApplicationContext(),
                                "GPS ON" , Toast.LENGTH_SHORT)
                                .show();
                    } else {
                        mGPS.setText("GPS: OFF");
                        settingsGPS = "OFF";
                        Log.i(TAG, "run: GPS Off");
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



    private double gpxLat1;
    private double gpxLon1;
    private int currentWaypoint = 0;
    private int maxWaypoint;

    //GPX
    public void clickB2(View view) {
        Log.i(TAG, "clickB2: GPX");
        AssetManager assetManager = getAssets();
        GpxParser parser;
        Gpx gpx = null;
        try {
//            InputStream inputStream = assetManager.open("prospectpark_ridewithgps.gpx");
            InputStream inputStream = assetManager.open("PP_LOOP_SS.gpx");
            parser = new GpxParser(inputStream);
            gpx = parser.parse();

        } catch (IOException e) {
            e.printStackTrace();
        }

// Get a List of waypoints
//        ArrayList<Wpt> wpts = gpx.getWpts();
        wpts = gpx.getWpts();
        maxWaypoint = wpts.size();

        Log.i(TAG, "NOW THE WAYPTS \n\n\n");

        for (Wpt w : wpts) {
            Log.i("Name of waypoint ", w.getName());
            Log.i("Description ",w.getDesc());
            Log.i("Symbol of waypoint ",w.getSym());
            Log.i("Coordinates ",String.valueOf(w.getLatLon()));
        }

        trks = gpx.getTrks();
        trkpts = trks.get(0).getTrkseg();

        Log.i(TAG, "NOW THE TRKSEGS \n\n\n");

        for (Trk t : trks) {
            Log.i(TAG, "TrkSegs, for loop");
        }




        Log.i(TAG, "NOW THE TRKPTS \n\n\n");

        for (Trkpt tk : trkpts) {
//            Log.i(TAG, "Trkpt: Lat" + tk.getLat());
//            Log.i(TAG, "Trkpt: Lat" + tk.getLon());
            Log.i(TAG, "Trkpt: Lat" + String.valueOf(tk.getLatLon()));
        }

        //SHOWALERT
        Toast.makeText(getApplicationContext(),
                "GPX LOADED" , Toast.LENGTH_SHORT)
                .show();

    }

    public void clickB3(View view) {
    }


    double distance_between(double lat1, double lon1, double lat2, double lon2)
    {
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



    private void waypointTest(double gpsLa, double gpsLo) {
        Log.i(TAG, "waypointTest: ");
        Log.i(TAG, "waypointTest: current " + currentWaypoint);
        Log.i(TAG, "waypointTest: max " + maxWaypoint);
        final int localWp = currentWaypoint;


        if (localWp >= maxWaypoint) {
            //Log.i(TAG, "\n\nwaypointTest: it's over, stop processing\n\n");
            return;
        }

        final double disBetw = distance_between(gpsLa, gpsLo, wpts.get(localWp).getLat(), wpts.get(localWp).getLon());
        Log.i(TAG, "waypointTest: disBetw  " + disBetw);

        runOnUiThread(new Runnable() {
            @SuppressLint("DefaultLocale")
            @Override
            public void run() {
                TextView v1 = findViewById(R.id.value1);
                v1.setText(String.format("%.2f", disBetw));
                TextView v2 = findViewById(R.id.value2);
                v2.setText(String.valueOf(localWp));

            }
        });

        if (disBetw < 100) {
            Log.i(TAG, "waypointTest: close enough, next point");

            if (currentWaypoint == 0) {
                Log.i(TAG, "waypointTest: STARTRACE");
                raceStartTime = oldTime;

                Toast.makeText(getApplicationContext(),
                        "RACE STARTING" , Toast.LENGTH_LONG)
                        .show();
            }

            if (currentWaypoint > 0 && currentWaypoint < maxWaypoint) {
                Toast.makeText(getApplicationContext(),
                        "NEXT CHECKPOINT" , Toast.LENGTH_LONG)
                        .show();
            }
            currentWaypoint += 1;

            runOnUiThread(new Runnable() {
                @SuppressLint("DefaultLocale")
                @Override
                public void run() {
                    TextView v1 = findViewById(R.id.value1);
                    v1.setText(String.format("%.2f", disBetw));
                    TextView v2 = findViewById(R.id.value2);
                    v2.setText(String.valueOf(localWp));

                }
            });

            if (currentWaypoint >= maxWaypoint) {
                Log.i(TAG, "\n\nwaypointTest: it's over, stop processing\n\n");

                raceFinishTime = oldTime;
                long raceTime = raceFinishTime - raceStartTime;

                Toast.makeText(getApplicationContext(),
                        "RACE FINISHED, TIME: " + (String.valueOf(raceTime/1000)) , Toast.LENGTH_LONG)
                        .show();

                runOnUiThread(new Runnable() {
                    @SuppressLint("DefaultLocale")
                    @Override
                    public void run() {
                        TextView v1 = findViewById(R.id.value1);
                        v1.setText("FINISH TIME:");
                        TextView v2 = findViewById(R.id.value2);
                        v2.setText("DISPLAY TIME");
                    }
                });


            }

        }

    }


    @SuppressLint("DefaultLocale")
    public void onLocationReceived(Location location) {
        Log.i(TAG, "onLocationReceived: ");
        Log.i(TAG, "onLocationReceived: " + location.getLatitude() + ", " + location.getLongitude());

        //TEST AGAINST CHECKPOINT

        //1.GET CURRENT CHECKPOINT
        //2.IF NEAR, RECORD TIME ELSE MOVE ON...
        //3. - IF NEAR, REMOVE CP AND MAKE NEXT CHECKPOINT ACTIVE
        //4. - SET TIME TO GET TO THE CHECKPOINT AND COMPARE AND REPORT

        arrLats.add(location.getLatitude());
        arrLons.add(location.getLongitude());
        arrLocations.add(location);


        if (arrLats.size() < 5) {
            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        } else {
            Location.distanceBetween(oldLat, oldLon, location.getLatitude(), location.getLongitude(), results);

            if (results.length > 0) {

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
                if (geoSpeedQuick > 35) {
                    Log.i(TAG, "onLocationReceived: too fast, wait for the next one...");
                    return;
                }
                //Log.i(TAG, "onLocationReceived: QuickSpeedCalc: " + geoSpeedQuick);


                //TRY DIRECT CALC FORMULA
                double result = distance_between(oldLat, oldLon, location.getLatitude(), location.getLongitude());

                //1/10th of a mile?
                if (result > 161) {
                    Log.i(TAG, "onLocationReceived: too big of a distance, ignore and wait for the next one...");
                    oldLat = location.getLatitude();
                    oldLon = location.getLongitude();
                    oldTime = location.getTime();
                    return;
                }

                Log.i(TAG, "onLocationReceived: calling waypointTest");
                waypointTest(location.getLatitude(), location.getLongitude());


                //OPT 2.  GEO SPEED, ACCURATE VERSION
                double gd = result * 0.000621371;
                geoDistance += gd;
                long gt = (location.getTime() - oldTime);  //MILLI


                double geoSpeedLong = gd / ((double) gt / 1000 / 60 / 60);
//                double geoSpeedQuick = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr
                //USING QUICK METHOD FOR DISPLAY PURPOSES
                geoSpeed = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr


                totalTimeGeo += (location.getTime() - oldTime);  //MILLI
                double ttg = totalTimeGeo;  //IN MILLI
                geoAvgSpeed = geoDistance / (ttg / 1000.0 / 60.0 / 60.0);
                //displaySpeedValues();

            }
            oldLat = location.getLatitude();
            oldLon = location.getLongitude();
            oldTime = location.getTime();
        }
    }




    private void displaySpeedValues() {
        //PASS VALUES TO FCTN TO ABSTRACT GPS VS BLE
        //Log.i(TAG, "displaySpeedValues: ");

        long millis = totalTimeGeo;

        @SuppressLint("DefaultLocale")
        final String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));

        Log.i(TAG, "displaySpeedValues: " + geoSpeed);
        Log.i(TAG, "displaySpeedValues: " + geoDistance);
    }

    private void startGPS() {
        Log.i(TAG, "startGPS: ");

        //START GPS
        LocationRequest mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(3000);
        mLocationRequest.setFastestInterval(2000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder().addLocationRequest(mLocationRequest);

        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(getApplicationContext());

        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                onNewLocation(locationResult.getLastLocation());
            }

            private void onNewLocation(Location lastLocation) {
                onLocationReceived(lastLocation);
            }
        };

        try {
            mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                    mLocationCallback, Looper.myLooper());
        } catch (SecurityException unlikely) {
            Log.e(TAG, "Lost location permission. Could not request updates. " + unlikely);
        }

    }














    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {
        /**
         * The fragment argument representing the section number for this
         * fragment.
         */
        private static final String ARG_SECTION_NUMBER = "section_number";

        public PlaceholderFragment() {
        }

        /**
         * Returns a new instance of this fragment for the given section
         * number.
         */
        public static PlaceholderFragment newInstance(int sectionNumber) {
            PlaceholderFragment fragment = new PlaceholderFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_main, container, false);
            TextView textView = (TextView) rootView.findViewById(R.id.section_label);
            textView.setText(getString(R.string.section_format, getArguments().getInt(ARG_SECTION_NUMBER)));
            return rootView;
        }
    }

    /**
     * A {@link FragmentPagerAdapter} that returns a fragment corresponding to
     * one of the sections/tabs/pages.
     */
    public class SectionsPagerAdapter extends FragmentPagerAdapter {

        public SectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int position) {
            // getItem is called to instantiate the fragment for the given page.
            // Return a PlaceholderFragment (defined as a static inner class below).
            return PlaceholderFragment.newInstance(position + 1);
        }

        @Override
        public int getCount() {
            // Show 3 total pages.
            return 3;
        }
    }
}

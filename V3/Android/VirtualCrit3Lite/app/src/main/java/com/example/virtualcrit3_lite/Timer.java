package com.example.virtualcrit3_lite;

import android.annotation.SuppressLint;
import android.location.Location;
import android.util.Log;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;


public final class Timer {

    private final static String TAG = Timer.class.getSimpleName();
    private static int status = 99;

    private static Location timerLocation;
    private static Double timerDistance = 0.0;

    public static int getStatus() {
        return status;
    }
    public static void setStatus(int status) {
        Timer.status = status;
    }

    @SuppressLint("DefaultLocale")
    public static String getTimeStringFromSecondsToDisplay(int s) {

        return String.format("%02d:%02d:%02d", s/(3600),
                s/(60*1000) % 60,
                s/1000 % 60);

    }

    //from milli
    @SuppressLint("DefaultLocale")
    public static String getTimeStringFromMilliSecondsToDisplay(int s) {

        return String.format("%02d:%02d:%02d", s/(3600*1000),
                s/(60*1000) % 60,
                s/1000 % 60);

    }

    //from milli
    @SuppressLint("DefaultLocale")
    public static String getTimeStringFromMilliSecondsToDisplayToSpeak(int s) {

        int hrs = s/(3600*1000);
        int min = s/(60*1000) % 60;
        int sec = s/1000 % 60;

        String h = "";
        String m = "";
        String se = "";

        if (hrs > 0) {
            h = String.valueOf(hrs) + " HOURS, ";
        }
        if (min > 0) {
            m = String.valueOf(min) + " MINUTES, ";
        }
        if (sec > 0) {
            se = String.valueOf(sec) + " SECONDS";
        }

        return h + m + se;


//        return String.format("%02d:%02d:%02d", s/(3600*1000),
//                s/(60*1000) % 60,
//                s/1000 % 60);

    }


    public static String getCurrentTimeStamp() {
//        return new SimpleDateFormat("HH:mm:ss").format(new Date());
        DateFormat dateFormat = new SimpleDateFormat("h:mm:ss a");
        return dateFormat.format(new Date());

    }

    public static Location getTimerLocation() {
        return timerLocation;
    }

    public static void setTimerLocation(Location timerLocation) {
        Log.i(TAG, "setTimerLocation: " + timerLocation.getProvider() + ", " + timerLocation.getLatitude() + ", " + timerLocation.getLongitude());
        Timer.timerLocation = timerLocation;
        double a = Timer.getTimerDistance();
        setTimerDistance(a += timerLocation.getAltitude());
        Log.i(TAG, "Timer.getTimerDistance" + Timer.getTimerDistance());
    }

    private Location timerOldLocation;
    private double timerGeoDistance;
    private double timerGeoSpeed;
    private double timerGeoAvgSpeed;
    private double timerTotalTimeGeo;

    public static Double getTimerDistance() {
        return timerDistance;
    }

    public static void setTimerDistance(Double timerDistance) {
        Timer.timerDistance = timerDistance;
    }

//    @SuppressLint("DefaultLocale")
//    private static void onTimerLocationReceived(Location location) {
//
//        Log.i(TAG, "onTimerLocationReceived: ");
//
//        //arrLocations.add(location);
//        double locationLat = location.getLatitude();
//        double locationLon = location.getLongitude();
//        long locationTime = location.getTime();
//
//        double oldLocationLat;
//        double oldLocationLon;
//        long oldLocationTime;
//
//
//        if (timerOldLocation != null) {
//            Log.i(TAG, "timerOldLocation: not null ");
//            timerOldLocation = location;
//
//        } else {
//            oldLocationLat = timerOldLocation.getLatitude();
//            oldLocationLon = timerOldLocation.getLongitude();
//            oldLocationTime = timerOldLocation.getTime();
//
//
//            //MORE ACCURATE DISTANCE CALC
//            double result = timerDistanceBetween(oldLocationLat, oldLocationLon, locationLat, locationLon);
//
//
//            Log.i(TAG, "onMapboxLocationReceived: result/time bet old and new: " + result + ", " + (locationTime - oldLocationTime));
//            //Log.i(TAG, "onMapboxLocationReceived: time bet old and new: " + (locationTime - oldLocationTime));
//            if (result  < 1 || (locationTime - oldLocationTime) < 1001) {
//                Log.i(TAG, "onMapboxLocationReceived: too quick, too short, just wait");
//                return;
//            }
//
//            if (locationTime - oldLocationTime > 30000 || result > 150) { //20 SECONDS or 50 meters
//                Log.i(TAG, "onLocationReceived: too much time has passed, set new *old* location and wait");
//                timerOldLocation = location;
//                return;
//            }
//
//
//            double gd = result * 0.000621371;
//            timerGeoDistance += gd;
//
//
//            //MORE ACCURACE BUT NOT NECESSARY
//            //long gt = (location.getTime() - oldTime);  //MILLI
//            //double geoSpeed = gd / ((double) gt / 1000 / 60 / 60);
//
//            //USING QUICK METHOD FOR DISPLAY PURPOSES
//            timerGeoSpeed = (double) location.getSpeed() * 2.23694;  //meters/sec to mi/hr
//
//            timerTotalTimeGeo += (locationTime - oldLocationTime);  //MILLI
//            double ttg = (double) timerTotalTimeGeo;  //IN MILLI
//            timerGeoAvgSpeed = timerGeoDistance / (ttg / 1000.0 / 60.0 / 60.0);
//            timerOldLocation = location;
//
//            Log.i(TAG, "onMapboxLocationReceived: timer Speed, AvgSpeed, Distance: " + timerGeoSpeed + ", " + timerGeoAvgSpeed + ", " + timerGeoDistance);
//        }
//
//
//    }


    double timerDistanceBetween(Double lat1, Double lon1, Double lat2, Double lon2) {
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

}

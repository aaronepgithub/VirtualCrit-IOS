package com.aaronep.andy;

import android.util.Log;

import java.util.Calendar;
import java.util.Locale;
import java.util.concurrent.TimeUnit;



public class Tim {

    private static final String TAG = "TIM";
    public Calendar startTime;

    public String name;
    private long totalTimeInSeconds;
    private String actualTotalTimeString;

    //FB ROUND OBJ
    private double roundSpeed = 0;
    private double roundHR = 0;
    private double roundScore = 0;
    private double roundCadence = 0;


    //ACTUAL TIME
    public long getTotalTimeInSeconds() {
        return totalTimeInSeconds;
    }

    public String getTotalTimeString() {
        return actualTotalTimeString;
    }

    public void setTotalTimeInSeconds(long totalTimeInSeconds) {
        this.totalTimeInSeconds = totalTimeInSeconds;
        if (totalTimeInSeconds == 30) {
            Log.i(TAG, "setTotalTimeInSeconds: 30");
        }
        if (totalTimeInSeconds % 60 == 0) {
            Log.i(TAG, "ANOTHER 60");
        }

        Calendar nowTime = Calendar.getInstance(Locale.ENGLISH);
        Long st = startTime.getTimeInMillis();
        Long nt = nowTime.getTimeInMillis();
        long millis_act = nt - st;
        String hms_act = String.format(Locale.US,"%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis_act),
                TimeUnit.MILLISECONDS.toMinutes(millis_act) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis_act)),
                TimeUnit.MILLISECONDS.toSeconds(millis_act) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis_act)));
        Log.i(TAG, hms_act);
        actualTotalTimeString = hms_act;

    }


    //BT
    double btTotalWheelRevolutions = 0;
    double btTotalTimeInSeconds = 0;
    double btTotalDistance;
    double btAvgSpeed;
    String btAvgPace;
    double btSpeed;
    String btPace;

    //GEO
    double geoTotalDistance;
    double geoAvgSpeed;
    long geoMovingTime;




    public Tim(String name) {
        this.name = name;
    }
    public String getName() {
        Log.i(TAG, "getName: name: " + name);
        return name;
    }
    public void setName(String name) {
        this.name = name;
        Log.i(TAG, "setName: name: " + name);
    }

    public void addWheelDiff(int w) {
        btTotalWheelRevolutions += (double) w;
        Log.i(TAG, "addWheelDiff: " + w);
    }

    public void addTimeDiff(int t) {
        btTotalTimeInSeconds += (double) t;
    }




    //BT
    public double getBtTotalDistance() {
        return btTotalDistance;
    }

    public void setBtTotalDistance(double btTotalDistance) {
        this.btTotalDistance = btTotalDistance;
    }

    public void addToBtDistance(double btSegmentInMiles) {
        btTotalDistance += btSegmentInMiles;
    }

    public double getBtAvgSpeed() {
        return btAvgSpeed;
    }

    public void setBtAvgSpeed(double btAvgSpeed) {
        this.btAvgSpeed = btAvgSpeed;
    }


    public String getBtAvgPace() {
        return btAvgPace;
    }

    public void setBtAvgPace(String btAvgPace) {
        this.btAvgPace = btAvgPace;
    }

    public double getBtSpeed() {
        return btSpeed;
    }

    public void setBtSpeed(double btSpeed) {
        this.btSpeed = btSpeed;
    }

    public String getBtPace() {
        return btPace;
    }

    public void setBtPace(String btPace) {
        this.btPace = btPace;
    }





    //GEO
    public double getGeoTotalDistance() {
        return geoTotalDistance;
    }

    public void setGeoTotalDistance(double geoTotalDistance) {
        this.geoTotalDistance = geoTotalDistance;
    }

    public double getGeoAvgSpeed() {
        return geoAvgSpeed;
    }

    public void setGeoAvgSpeed(double geoAvgSpeed) {
        this.geoAvgSpeed = geoAvgSpeed;
    }

    public long getGeoMovingTime() {
        return geoMovingTime;
    }

    public void setGeoMovingTime(long geoMovingTime) {
        this.geoMovingTime = geoMovingTime;
    }
}

package com.example.virtualcrit3_lite;

import android.util.Log;

import java.util.ArrayList;
import java.util.Date;

public class Race {

    private final static String TAG = Race.class.getSimpleName();

    public String raceName;
    public String riderName;
    public Long raceTimeToComplete;
    public Integer raceDate;
    public String waypointTimes;
    public String llPoints;
    public String llNames;


    public Race(String riderName, String raceName, Long raceTimeToComplete, Integer raceDate, String waypointTimes, String llPoints, String llNames) {
        this.raceName = raceName;
        this.riderName = riderName;


        if (raceTimeToComplete > 0) {
            this.raceTimeToComplete = raceTimeToComplete;
        } else {
            int l = 2147483646;
            this.raceTimeToComplete = (long) l;
        }
        Log.i(TAG, "Race: raceTimeToComplete: " + this.raceTimeToComplete);

        this.raceDate = raceDate;
        this.waypointTimes = waypointTimes;
        this.llPoints = llPoints;
        this.llNames = llNames;
    }

}

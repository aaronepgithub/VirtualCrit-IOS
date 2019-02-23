package com.example.virtualcrit3_lite;

import java.util.ArrayList;
import java.util.Date;

public class Race {

    private final static String TAG = Race.class.getSimpleName();

    public String raceName;
    public String riderName;
    public Long raceTimeToComplete;
    public Integer raceDate;
    public String waypointTimes;


    public Race(String riderName, String raceName, Long raceTimeToComplete, Integer raceDate, String waypointTimes) {
        this.raceName = raceName;
        this.riderName = riderName;
        this.raceTimeToComplete = raceTimeToComplete;
        this.raceDate = raceDate;
        this.waypointTimes = waypointTimes;
    }

}

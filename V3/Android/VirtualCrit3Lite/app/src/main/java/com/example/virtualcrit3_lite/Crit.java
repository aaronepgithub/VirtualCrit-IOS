package com.example.virtualcrit3_lite;

import android.location.Location;

import com.mapbox.mapboxsdk.geometry.LatLng;
import java.util.ArrayList;

public final class Crit {
    private final static String TAG = Crit.class.getSimpleName();

    public static ArrayList<LatLng> critBuilderLatLng = new ArrayList<>();
    public static ArrayList<String> critBuilderLatLngNames = new ArrayList<>();

    private static String racerName = "TIM";
    private static Integer raceDate = 0;
    private static String raceName = "RACE";
    private static String leaderMessage = "SORRY, YOU CAN'T BEAT ME";


    public static String getRacerName() {
        return racerName;
    }

    public static void setRacerName(String racerName) {
        Crit.racerName = racerName;
    }

    public static Integer getRaceDate() {
        return raceDate;
    }

    public static void setRaceDate(Integer raceDate) {
        Crit.raceDate = raceDate;
    }

    public static String getRaceName() {
        return raceName;
    }

    public static void setRaceName(String raceName) {
        Crit.raceName = raceName;
    }

    public static String getLeaderMessage() {
        return leaderMessage;
    }

    public static void setLeaderMessage(String leaderMessage) {
        Crit.leaderMessage = leaderMessage;
    }
}

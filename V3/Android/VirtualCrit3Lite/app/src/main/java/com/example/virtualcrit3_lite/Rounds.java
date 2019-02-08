package com.example.virtualcrit3_lite;

import java.util.ArrayList;

public final class Rounds {

    private final static String TAG = Rounds.class.getSimpleName();


    private static ArrayList<Double> arrRoundSpeeds = new ArrayList<>(); //SPEEDS
    private static ArrayList<Double> arrRoundScores = new ArrayList<>(); //SCORES
    private static ArrayList<Double> arrRoundHeartrates = new ArrayList<>(); //HEARTRATES


    public static ArrayList<Double> getArrRoundSpeeds() {
        return arrRoundSpeeds;
    }

    public static ArrayList<Double> getArrRoundScores() {
        return arrRoundScores;
    }

    public static ArrayList<Double> getArrRoundHeartrates() {
        return arrRoundHeartrates;
    }
}

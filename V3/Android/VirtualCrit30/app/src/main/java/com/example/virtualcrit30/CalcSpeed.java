package com.example.virtualcrit30;

import android.util.Log;

import java.util.LinkedList;

public final class CalcSpeed {

    private final static String TAG = CalcSpeed.class.getSimpleName();

    private static int mFirstWheelRevolutions = -1;
    private static int mLastWheelRevolutions = -1;
    private static int mLastWheelEventTime = -1;
    private static int mFirstCrankRevolutions = -1;
    private static int mLastCrankRevolutions = -1;
    private static int mLastCrankEventTime = -1;

    private static double totalWheelRevolutions = 0;
    private static double totalTimeInSeconds = 0;
    private static double tDistance = 0;
    private static double tAvgSpeed = 0;

    private static LinkedList<Integer> speedValuesLinkedList = new LinkedList<Integer>();

    private static Boolean hasSpeed = Boolean.TRUE;





    public static Boolean calcSpeed( final int revs, final int time) {
        //Log.i(TAG, "calcSpeed: " + revs + ", " + time);


        final int circumference = Variables.getWheelSizeInMM(); // [mm]

        speedValuesLinkedList.push(revs);
        if (speedValuesLinkedList.size() > 5) {
            speedValuesLinkedList.removeLast();
        }
        if (speedValuesLinkedList.peekFirst().equals(speedValuesLinkedList.peekLast())) {
            //Log.i(TAG, "SPD =  0");
            //adviseActivitySPD("0 S", String.format("%.2f MILES", tDistance), String.format("%.1f MPH", tAvgSpeed));
            Variables.setSpeed("0 MPH");
            return hasSpeed = Boolean.TRUE;
        }

        if (mFirstWheelRevolutions < 0) {
            mFirstWheelRevolutions = revs;
            mLastWheelRevolutions = revs;
            mLastWheelEventTime = time;
            return hasSpeed = Boolean.FALSE;
        }

        if (mLastWheelEventTime == time) {
            return hasSpeed = Boolean.FALSE;
        }

        final int timeDiff = do16BitDiff(time, mLastWheelEventTime);
        final int wheelDiff = do16BitDiff(revs, mLastWheelRevolutions);

        if (wheelDiff == 0 || wheelDiff > 35) {
            mLastWheelRevolutions = revs;
            mLastWheelEventTime = time;
            return hasSpeed = Boolean.FALSE;
        }

        if (timeDiff < 1000) {
            //LET'S NOT PROCESS SO MANY, IGNORE EVERY OTHER ONE?
            return hasSpeed = Boolean.FALSE;
        }

        if (timeDiff > 30000) {
            mLastWheelRevolutions = revs;
            mLastWheelEventTime = time;
            return hasSpeed = Boolean.FALSE;
        }


        totalWheelRevolutions += (double) wheelDiff;
        double localDistance = (totalWheelRevolutions * ( (((double) circumference) / 1000) * 0.000621371 ));
        totalTimeInSeconds += (double) timeDiff / 1024.0;

        mLastWheelRevolutions = revs;
        mLastWheelEventTime = time;

        final double wheelTimeInSeconds = timeDiff / 1024.0;
        final double wheelCircumference = (double) circumference;
        final double wheelCircumferenceCM = wheelCircumference / 10;
        final double wheelRPM = (double) wheelDiff / (wheelTimeInSeconds / 60.0);
        final double cmPerMi = 0.00001 * 0.621371;
        final double minsPerHour = 60.0;
        final double speed = wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour;  //MPH CURRENT
        final double totalDistance = totalWheelRevolutions * wheelCircumferenceCM * cmPerMi;

        final double btAvgSpeed = totalDistance / (totalTimeInSeconds / 60.0 / 60.0);
        //Log.d(TAG, "onWheelMeasurementReceived: btAvgSpeed = " + String.format("%.1f Avg Speed", btAvgSpeed));

        tDistance = totalDistance;
        tAvgSpeed = btAvgSpeed;


        Variables.setDistance(String.format("%.2f MILES", tDistance));
        Variables.setAvgSpeed(String.format("%.1f AVG", tAvgSpeed));
        Variables.setSpeed(String.format("%.2f MPH", speed));
        Variables.setvTotalTimeSeconds(Timer.getActiveTimeStringFromSeconds((int) totalTimeInSeconds));
        Variables.setWheelRevPerMile(revs);

        return hasSpeed = Boolean.TRUE;
    }



    private static int do16BitDiff(int a, int b) {
        if (a >= b)
            return a - b;
        else
            return (a + 65536) - b;
    }


}

package com.example.virtualcrit30;

import android.annotation.SuppressLint;
import android.util.Log;

import java.util.LinkedList;

public final class CalcCadence {

    private final static String TAG = CalcCadence.class.getSimpleName();


    private static int mFirstCrankRevolutions = -1;
    private static int mLastCrankRevolutions = -1;
    private static int mLastCrankEventTime = -1;

    private static LinkedList<Integer> cadValuesLinkedList = new LinkedList<Integer>();
    //private static Boolean hasCadence = Boolean.TRUE;


    @SuppressLint("DefaultLocale")
    public static Boolean calcCadence(final int revs, final int time ) {

        Log.i(TAG, "calcCadence: revs, time:  " + revs + ", " + time);

        cadValuesLinkedList.push(revs);

        if (cadValuesLinkedList.size() > 5) {
            cadValuesLinkedList.removeLast();
        }
        if (cadValuesLinkedList.peekFirst().equals(cadValuesLinkedList.peekLast())) {
            Variables.setCadence("0 RPM");
            return Boolean.TRUE;
        }


        if (mFirstCrankRevolutions < 0) {
            mFirstCrankRevolutions = revs;
            mLastCrankRevolutions = revs;
            mLastCrankEventTime = time;
            return Boolean.FALSE;
        }

        if (mLastCrankEventTime == time) {
            return Boolean.FALSE;
        }


        final int timeDiff = do16BitDiff(time, mLastCrankEventTime);
        final int crankDiff = do16BitDiff(revs, mLastCrankRevolutions);

        if (crankDiff == 0) {
            mLastCrankRevolutions = revs;
            mLastCrankEventTime = time;
            return Boolean.FALSE;
        }

        if (timeDiff < 2000) {
            return Boolean.FALSE;
        }

        if (timeDiff > 30000) {
            mLastCrankRevolutions = revs;
            mLastCrankEventTime = time;
            return Boolean.FALSE;
        }



        final double cadence = (double) crankDiff / ((((double) timeDiff) / 1024.0) / 60);
        if (cadence == 0) {
            return Boolean.FALSE;
        }
        if (cadence > 150) {
            return Boolean.FALSE;
        }


        //@SuppressLint("DefaultLocale") final String cadString = String.format("%.0f C", cadence);
        if (cadValuesLinkedList.peekFirst().equals(cadValuesLinkedList.peekLast())) {
            Variables.setCadence("0 C");
        } else {
            Variables.setCadence(String.format("%.0f C", cadence));
        }

        Log.i(TAG, "calcCadence: " + String.format("%.0f C", cadence));
        return Boolean.TRUE;

    }
    //END CAD CALC

    private static int do16BitDiff(int a, int b) {
        if (a >= b)
            return a - b;
        else
            return (a + 65536) - b;
    }


}  //END CALC CADENCE


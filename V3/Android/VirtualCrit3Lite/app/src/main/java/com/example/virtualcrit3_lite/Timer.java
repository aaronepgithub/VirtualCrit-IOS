package com.example.virtualcrit3_lite;

import android.annotation.SuppressLint;

import java.text.SimpleDateFormat;
import java.util.Date;


public final class Timer {

    private final static String TAG = Timer.class.getSimpleName();
    private static int status = 99;
    private static long activeMillis = 0;
    private static long totalMillis = 0;
    private static String currentTimeStamp;


    public static int getStatus() {
        return status;
    }

    public static void setStatus(int status) {
        Timer.status = status;
    }



    public static long getActiveMillis() {
        return activeMillis;
    }

    public static void setActiveMillis(long activeMillis) {
        Timer.activeMillis = activeMillis;
    }



    public static long getTotalMillis() {
        return totalMillis;
    }

    public static void setTotalMillis(long totalMillis) {
        Timer.totalMillis = totalMillis;
    }



    @SuppressLint("DefaultLocale")
    public static String getTotalTimeString() {
        return String.format("%02d:%02d:%02d", totalMillis/(3600*1000),
                totalMillis/(60*1000) % 60,
                totalMillis/1000 % 60);
    }

    @SuppressLint("DefaultLocale")
    public static String getActiveTimeString() {
        return String.format("%02d:%02d:%02d", activeMillis/(3600*1000),
                activeMillis/(60*1000) % 60,
                activeMillis/1000 % 60);
    }

    @SuppressLint("DefaultLocale")
    public static String getTimeStringFromSecondsToDisplay(int s) {
//        return String.format("%02d:%02d:%02d", s/(3600*1000),
//                s/(60*1000) % 60,
//                s/1000 % 60);

        return String.format("%02d:%02d:%02d", s/(3600*1000),
                s/(60*1000) % 60,
                s/1000 % 60);

    }

    public static String getCurrentTimeStamp() {

        return new SimpleDateFormat("HH:mm:ss").format(new Date());
    }
}

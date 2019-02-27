package com.example.virtualcrit3_lite;

import android.annotation.SuppressLint;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;


public final class Timer {

    private final static String TAG = Timer.class.getSimpleName();
    private static int status = 99;

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


    public static String getCurrentTimeStamp() {
//        return new SimpleDateFormat("HH:mm:ss").format(new Date());
        DateFormat dateFormat = new SimpleDateFormat("h:mm:ss a");
        return dateFormat.format(new Date());

    }
}

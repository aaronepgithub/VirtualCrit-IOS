package com.example.virtualcrit30;

import android.util.Log;

import java.security.Timestamp;
import java.util.LinkedList;

public final class Variables {

    private final static String TAG = Variables.class.getSimpleName();

    //BLE VARIABLES
    private static String vSpeed;
    private static String vDistance = "0.00 Miles";
    private static String vAvgSpeed = "0.0 MPH";
    private static String vTotalTimeSeconds;  //BLE
    private static int wheelSizeInMM = 2105;

    private static String statusHR = "0";
    private static String statusSC = "0";

    private static LinkedList<String> messageBarValues = new LinkedList<String>();
    private static String messageBarValue = "First";

    private static int wheelRevPerMile = 1;


    private static String vCadence;

    public static String getDistance(){
        return vDistance;
    }

    public static void setDistance( String vDistance ){
        Variables.vDistance = vDistance;
    }

    public static String getAvgSpeed(){
        return vAvgSpeed;
    }

    public static void setAvgSpeed( String vAvgSpeed ){
        Variables.vAvgSpeed = vAvgSpeed;
    }

    public static int getWheelSizeInMM() {
        return wheelSizeInMM;
    }

    public static void setWheelSizeInMM(int wheelSizeInMM) {
        Variables.wheelSizeInMM = wheelSizeInMM;
    }

    public static String getSpeed() {
        return vSpeed;
    }

    public static void setSpeed(String vSpeed) {
        Variables.vSpeed = vSpeed;
    }

    public static String getCadence() {
        return vCadence;
    }

    public static void setCadence(String vCadence) {
        Variables.vCadence = vCadence;
    }

    //BLE
    public static String getvTotalTimeSeconds() {
        return vTotalTimeSeconds;
    }

    //STRING
    public static void setvTotalTimeSeconds(String vTotalTimeSeconds) {
        Variables.vTotalTimeSeconds = vTotalTimeSeconds;
    }

    public static String getStatusHR() {
        return statusHR;
    }

    public static void setStatusHR(String statusHR) {
        Variables.statusHR = statusHR;
    }

    public static String getStatusSC() {
        return statusSC;
    }

    public static void setStatusSC(String statusSC) {
        Variables.statusSC = statusSC;
    }


    public static LinkedList<String> getMessageBarValues() {
        return messageBarValues;
    }

    public static void setMessageBarValues(LinkedList<String> messageBarValues) {
        Variables.messageBarValues = messageBarValues;
    }



    public static String getMessageBarValue() {
        String s = Variables.messageBarValues.pollFirst();
        Variables.messageBarValues.addLast(s);
        Log.i(TAG, "getMessageBarValue: " + s);
        return s;

    }


    public static void setMessageBarValue(String messageBarValue) {
        Log.i(TAG, "setMessageBarValue: " + messageBarValue);
        Variables.messageBarValue = messageBarValue;
        Variables.messageBarValues.push(Variables.messageBarValue + ",  " + Timer.getTotalTimeString());
    }

    public static int getWheelRevPerMile() {
        return wheelRevPerMile;
    }

    public static void setWheelRevPerMile(int wheelRevPerMile) {
        Variables.wheelRevPerMile = wheelRevPerMile;
    }
}

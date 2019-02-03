package com.example.virtualcrit30;

public final class Variables {

    //BLE VARIABLES
    private static String vSpeed;
    private static String vDistance = "0.00 Miles";
    private static String vAvgSpeed = "0.0 MPH";
    private static String vTotalTimeSeconds;
    private static int wheelSizeInMM = 2105;

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

    public static String getvTotalTimeSeconds() {
        return vTotalTimeSeconds;
    }

    //STRING
    public static void setvTotalTimeSeconds(String vTotalTimeSeconds) {
        Variables.vTotalTimeSeconds = vTotalTimeSeconds;
    }
}

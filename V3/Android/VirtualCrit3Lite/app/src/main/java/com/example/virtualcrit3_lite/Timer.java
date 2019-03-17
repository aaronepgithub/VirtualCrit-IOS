package com.example.virtualcrit3_lite;

import android.annotation.SuppressLint;
import android.location.Location;
import android.util.Log;
import android.widget.Toast;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;


public final class Timer {

    private final static String TAG = Timer.class.getSimpleName();
    private static int status = 99;

    private static Location timerLocation;
    private static Location timerOldLocation;
    private static double timerGeoDistance = 0.0;
    private static double timerGeoSpeed;
    private static double timerGeoAvgSpeed;
    private static double timerTotalTimeGeo = 0.0;
    private static ArrayList<Location> timerAllLocations = new ArrayList<>();

    //LOCATION PROVIDED BY SERVICE TO SETTIMERLOCATION
    public static Location getTimerLocation() {
        return timerLocation;
    }

    public static Location getTimerOldLocation() {
        return timerOldLocation;
    }

    public static double getGeoSpeed() {
        return timerGeoSpeed;
    }
    public static double getGeoAvgSpeed() {
        return timerGeoAvgSpeed;
    }
    public static double gettimerTotalTimeGeo() {
        return timerTotalTimeGeo;
    }
    public static double getTimerGeoDistance() {
        return timerGeoDistance;
    }

    static void setTimerLocation(Location timerLocation) {
        Log.i(TAG, "Location from Service: " + timerLocation.getProvider() + ", " + timerLocation.getLatitude() + ", " + timerLocation.getLongitude());
        Timer.timerLocation = timerLocation;
        calculateValues();
    }

    private static void calculateValues() {
        Log.i(TAG, "calculateValues: timerLocation " + timerLocation.getProvider());

        Timer.timerAllLocations.add(timerLocation);
        double locationLat = timerLocation.getLatitude();
        double locationLon = timerLocation.getLongitude();
        long locationTime = timerLocation.getTime();

        double oldLocationLat;
        double oldLocationLon;
        long oldLocationTime;


        if (timerOldLocation == null) {
            Log.i(TAG, "timerOldLocation: is null ");
            timerOldLocation = timerLocation;

        } else {
            oldLocationLat = timerOldLocation.getLatitude();
            oldLocationLon = timerOldLocation.getLongitude();
            oldLocationTime = timerOldLocation.getTime();


            //MORE ACCURATE DISTANCE CALC
            double result = timerDistanceBetween(oldLocationLat, oldLocationLon, locationLat, locationLon);


            Log.i(TAG, "onTimerLocationReceived: result/time bet old and new: " + result + ", " + (locationTime - oldLocationTime));
            //Log.i(TAG, "onMapboxLocationReceived: time bet old and new: " + (locationTime - oldLocationTime));
            if (result  < 1 || (locationTime - oldLocationTime) < 1001) {
                Log.i(TAG, "onTimerLocationReceived: too quick, too short, just wait");
                return;
            }

            if (locationTime - oldLocationTime > 30000 || result > 150) { //30 SECONDS or 150 meters
                Log.i(TAG, "onLocationReceived: too much time has passed, set new *old* location and wait");
                timerOldLocation = timerLocation;
                return;
            }

            double gd = result * 0.000621371;
            timerGeoDistance += gd;

            //MORE ACCURACE BUT NOT NECESSARY
            long gt = (timerLocation.getTime() - timerOldLocation.getTime());  //MILLI
            timerGeoSpeed = gd / ((double) gt / 1000 / 60 / 60);

            //USING QUICK METHOD FOR DISPLAY PURPOSES
            //timerGeoSpeed = (double) timerLocation.getSpeed() * 2.23694;  //meters/sec to mi/hr

            timerTotalTimeGeo += (locationTime - oldLocationTime);  //MILLI
            double ttg = (double) timerTotalTimeGeo;  //IN MILLI
            timerGeoAvgSpeed = timerGeoDistance / (ttg / 1000.0 / 60.0 / 60.0);
            timerOldLocation = timerLocation;

            Log.i(TAG, "onTimerLocationReceived: timer Speed, AvgSpeed, Distance, totalTime: " + timerGeoSpeed + ", " + timerGeoAvgSpeed + ", " + timerGeoDistance + ", " + timerTotalTimeGeo);
        }

        if (Crit.critBuilderLatLng.size() > 0) {
            evaluateLocation(locationLat, locationLon);
        }

//        if (isCritBuilderIDActive) {
//            Log.i(TAG, "onMapboxLocationReceived: isCritBuilderIDActive");
//            mapboxEvaluateLocationsCritID(locationLat, locationLon);
//            return;
//        }
//        if (isCritBuilderActive) {
//            Log.i(TAG, "onMapboxLocationReceived: isCritBuilderActive: " + isCritBuilderActive + " mapboxEvaluateLocationsCritBuilder");
//            mapboxEvaluateLocationsCritBuilder(locationLat, locationLon);
//        } else {
//            Log.i(TAG, "onMapboxLocationReceived: isCritBuilderActive: " + isCritBuilderActive + " mapboxEvaluateLocations");
//            mapboxEvaluateLocations(locationLat, locationLon);
//        }


    }

    private static int currentWaypointCB = 0;
    private static int maxWaypointCB = 0;
    private static Boolean isRaceStarted = false;
    private static long raceStartTime = 0;
    private static long raceFinishTime = 0;
    private static ArrayList<Long> waypointTimesTim = new ArrayList<>();
    private static String waypointTimesTimString;

    private static ArrayList<Long> waypointTimesBest = new ArrayList<>();
    private static long bestRaceTime = -1;
    private static String bestRacerName = "";
    private static String raceName = "";

    private static ArrayList<Long> raceTimesTim = new ArrayList<>();




    private static void evaluateLocation(final double gpsLa, final double gpsLo) {
        Log.i(TAG, "EVALUATE LOCATION");

        double startLa = Crit.critBuilderLatLng.get(0).getLatitude();
        double startLo = Crit.critBuilderLatLng.get(0).getLongitude();
        double finishLa = Crit.critBuilderLatLng.get(Crit.critBuilderLatLng.size()-1).getLatitude();
        double finishLo = Crit.critBuilderLatLng.get(Crit.critBuilderLatLng.size()-1).getLongitude();
        maxWaypointCB = Crit.critBuilderLatLng.size();
        raceName = Crit.critBuilderLatLngNames.get(0);


        //TEST FOR START
        if (currentWaypointCB == 0 && !isRaceStarted) {
            //NOT YET AT START
            double disBetw = timerDistanceBetween(gpsLa, gpsLo, startLa, startLo);
            Log.i(TAG, "TEST FOR START: " + disBetw);

            if (disBetw < 100) {  //WITHIN 100 METERS OF TARGET
                Log.i(TAG, "STARTRACE!");
                raceStartTime = System.currentTimeMillis();
                isRaceStarted = true;
                //speakText("THE RACE HAS STARTED  HEAD TO " + namesTemp.get(currentWaypointCB+1));

                //addAnotherMarker(latTemp.get(currentWaypointCB+1), lonTemp.get(currentWaypointCB+1));
                waypointTimesTim = new ArrayList<>();
                waypointTimesTimString = "";

                String startString = "";
                if (bestRaceTime > 10000) {
                    startString = "\nTHE LEADER IS " + bestRacerName + " AT " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime);
                }

//                createTimeline("RACE STARTING\n" + namesTemp.get(0).toUpperCase() + "\nHEAD TO " + namesTemp.get(currentWaypointCB + 1).toUpperCase() + startString, Timer.getCurrentTimeStamp());
//                setMessageText("RACE STARTING");
//                Toast.makeText(getApplicationContext(),
//                        "RACE STARTING: " + namesTemp.get(0).toUpperCase(), Toast.LENGTH_LONG)
//                        .show();

                currentWaypointCB += 1;
            }
            return;
        }
        //END TEST FOR START, NOW...

        //TEST FOR FINISH
        if (currentWaypointCB == maxWaypointCB && isRaceStarted) {

            double disBetwMax = timerDistanceBetween(gpsLa, gpsLo, finishLa, finishLo);
            Log.i(TAG, "TEST FOR FINISH: " + disBetwMax);

            if (disBetwMax < 100) {  //WITHIN 100 METERS
                Log.i(TAG, "RACE FINISHED!");
                isRaceStarted = false;
                currentWaypointCB = 0;
                raceFinishTime = System.currentTimeMillis();

                //raceTime is the duration of the race
                long raceTime = raceFinishTime - raceStartTime;
                Log.i(TAG, "CB raceTime: " + raceTime);

                raceTimesTim.add(raceTime);
                waypointTimesTim.add(raceTime);
                waypointTimesTimString += String.valueOf(raceTime);

                Log.i(TAG, "waypointTimesTimString:  " + waypointTimesTimString);

                //trkName = namesTemp.get(0);
            //TODO:  POST RACE PROCESSING, SEND TO FB
                //postRaceProcessing(raceTime);
                //Log.i(TAG, "CBID waypointTimesTim:  " + waypointTimesTim.toString());
                //Log.i(TAG, "CBID waypointTimesBest:  " + waypointTimesBest.toString());
                String s;
                String ss;
                if (bestRaceTime == -1) {
                    bestRaceTime = raceTime + 1;
                }
                if (raceTime < bestRaceTime && bestRaceTime > 10000){
                    waypointTimesBest = waypointTimesTim;
                    s = "THE NEW FASTEST TIME BY " + getTimeStringFromMilliSecondsToDisplay((int) ((int) bestRaceTime - (int) raceTime));
                    ss = "THE NEW FASTEST TIME BY " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) ((int) bestRaceTime - (int) raceTime));
                    bestRaceTime = raceTime;
                } else {
                    s = "THE FASTEST TIME IS " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime) + " BY " + bestRacerName;
                    ss = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) bestRaceTime) + " BY " + bestRacerName;
                }

                Log.i(TAG, "RACE FINISHED  : " + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + ".  " + s);

                //TODO: TIMELINE, MESSAGE, SPEAK
//                createTimeline("RACE COMPLETE\n" + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + "\n" + s, Timer.getCurrentTimeStamp());
//                setMessageText("RACE FINISHED: " + getTimeStringFromMilliSecondsToDisplay((int) raceTime));
//                speakText("RACE COMPLETE, YOUR TIME IS.  " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) raceTime) + ".  " + ss);
//                Log.i(TAG, "trackpointTest: waypointTimesTim: " + waypointTimesTim.toString());
//                Log.i(TAG, "trackpointTest: raceTime: " + raceTime);
//                Toast.makeText(getApplicationContext(),
//                        "RACE FINISHED " + getTimeStringFromMilliSecondsToDisplay((int) raceTime), Toast.LENGTH_LONG)
//                        .show();

                //RESET
                Log.i(TAG, "RESET RACE: ");
                currentWaypointCB = 0;
                raceStartTime = 0;
                isRaceStarted = false;
            }

        }
        //END TEST FOR FINISH


        //NOT START OR FINISH
        if (isRaceStarted && currentWaypointCB < maxWaypointCB) {
            Log.i(TAG, "NOT START OR FINISH: currentWaypointCB, maxWaypointCB " + currentWaypointCB +", "+ maxWaypointCB);
            waypointTest(gpsLa, gpsLo);
        }




    }
    //END EVALUATELOCATION


    //START WAYPOINTTEST
    private static void waypointTest(double gpsLa, double gpsLo) {
        Log.i(TAG, "waypointTest, currentWaypointCB, max: " + currentWaypointCB + ", " + maxWaypointCB);

        if (!isRaceStarted) {
            Log.i(TAG, "waypointTest, race not started, return");
            return;
        }
        if (currentWaypointCB >= maxWaypointCB) {
            Log.i(TAG, "waypointTest, currentWaypointCB > maxCB, SHOULDN'T HAPPEN, RETURN");
            return;
        }

        final double disBetw = timerDistanceBetween(gpsLa, gpsLo, Crit.critBuilderLatLng.get(currentWaypointCB).getLatitude(), Crit.critBuilderLatLng.get(currentWaypointCB).getLatitude());
        Log.i(TAG, "waypointTest, waiting for waypoint match, distance: " + disBetw);

        //WAYPOINT MATCH
//        if (disBetw < 1000) {
//            setMessageText(String.valueOf((int) disBetw));
//        }

        if (disBetw < 100) {
            Log.i(TAG, "WAYPOINT MATCH! " + (currentWaypointCB) + " OF " + (maxWaypointCB));
            if ((currentWaypointCB+1) < maxWaypointCB) {
                //addAnotherMarker(latTemp.get(currentWaypointCB+1), lonTemp.get(currentWaypointCB+1));
            }

//            setMessageText("CBID RACE CHECKPOINT " + (currentWaypointCB) + " OF " + (maxWaypointCB));
            Log.i(TAG, "waypointTest, raceTime at WP: " + (System.currentTimeMillis() - raceStartTime));
            //EACH TIME IS ADDED
            waypointTimesTim.add(System.currentTimeMillis() - raceStartTime);
            waypointTimesTimString += String.valueOf(System.currentTimeMillis() - raceStartTime);
            waypointTimesTimString += ",";

            String s1 = "";
            String s2 = "";
            if (waypointTimesBest.isEmpty()) {
                Log.i(TAG, "waypointTimesBest is empty");
            } else {
                if (currentWaypointCB > 0) {

                    Log.i(TAG, "waypointTestCB: waypointTimesBest, " + waypointTimesBest);
                    Log.i(TAG, "waypointTestCB: waypointTimesTim, " + waypointTimesTim);

                    if ((waypointTimesBest.get(currentWaypointCB-1) > waypointTimesTim.get(currentWaypointCB-1))) {
                        long l = waypointTimesBest.get(currentWaypointCB-1) - waypointTimesTim.get(currentWaypointCB-1);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER " + bestRacerName;
                            s2 = "EVEN WITH THE LEADER " + bestRacerName;
                        } else {
                            s1 = getTimeStringFromMilliSecondsToDisplay(i) + " AHEAD OF " + bestRacerName;
                            s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " AHEAD OF " + bestRacerName;
                        }

                    } else {
                        long l = waypointTimesTim.get(currentWaypointCB-1) - waypointTimesBest.get(currentWaypointCB-1);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER " + bestRacerName;
                            s2 = "EVEN WITH THE LEADER " + bestRacerName;
                        } else {
                            s1 = getTimeStringFromMilliSecondsToDisplay(i) + " BEHIND "+ bestRacerName;
                            s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " BEHIND "+ bestRacerName;
                        }

                    }
                    Log.i(TAG, "waypointTest: s1:  " + s1);
                }
            }

            if ((currentWaypointCB + 1) == Crit.critBuilderLatLngNames.size()) {
                Log.i(TAG, "waypointTest: next stop is finish, currentWaypointCB " + currentWaypointCB);
//                addAnotherMarker(latTemp.get(latTemp.size()-1), lonTemp.get(lonTemp.size()-1));
//                createTimeline("WAYPOINT " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + "\n" + namesTemp.get(currentWaypointCB) + "\n" + s1 + "\nHEAD TO FINISH", Timer.getCurrentTimeStamp());
//                speakText("WAYPOINT " + namesTemp.get(currentWaypointCB) + ".  NUMBER " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + "...  " + s2 + ".  HEAD TO FINISH");
            } else {
                Log.i(TAG, "waypointTestCB: not finish, next wp cb, currentWaypointCB "+ currentWaypointCB);
//                createTimeline("WAYPOINT " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + "\n" + namesTemp.get(currentWaypointCB) + "\n" + s1 + "\nHEAD TO " + namesTemp.get(currentWaypointCB+1), Timer.getCurrentTimeStamp());
//                speakText("WAYPOINT " + namesTemp.get(currentWaypointCB) + ".  NUMBER " + (currentWaypointCB + 1) + " OF " + (maxWaypointCB) + ".  " + s2 + ".  HEAD TO " + namesTemp.get(currentWaypointCB+1));
            }

            Log.i(TAG, "waypointTest, current " + currentWaypointCB);
            currentWaypointCB += 1;
            Log.i(TAG, "waypointTestCB, current " + currentWaypointCB);
        }
    }
    //END WAYPOINTTEST









    private static double timerDistanceBetween(Double lat1, Double lon1, Double lat2, Double lon2) {
        double R = 6371; // km
        double dLat = (lat2 - lat1) * Math.PI / 180;
        double dLon = (lon2 - lon1) * Math.PI / 180;
        lat1 = lat1 * Math.PI / 180;
        lat2 = lat2 * Math.PI / 180;

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double d = R * c * 1000;

        return d;
    }







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

    //from milli
    @SuppressLint("DefaultLocale")
    public static String getTimeStringFromMilliSecondsToDisplayToSpeak(int s) {

        int hrs = s/(3600*1000);
        int min = s/(60*1000) % 60;
        int sec = s/1000 % 60;

        String h = "";
        String m = "";
        String se = "";

        if (hrs > 0) {
            h = String.valueOf(hrs) + " HOURS, ";
        }
        if (min > 0) {
            m = String.valueOf(min) + " MINUTES, ";
        }
        if (sec > 0) {
            se = String.valueOf(sec) + " SECONDS";
        }

        return h + m + se;


    }


    public static String getCurrentTimeStamp() {
//        return new SimpleDateFormat("HH:mm:ss").format(new Date());
        DateFormat dateFormat = new SimpleDateFormat("h:mm:ss a");
        return dateFormat.format(new Date());

    }


    public static ArrayList<Long> getWaypointTimesBest() {
        return waypointTimesBest;
    }

    public static void setWaypointTimesBest(ArrayList<Long> waypointTimesBest) {
        Timer.waypointTimesBest = waypointTimesBest;
    }

    public static long getBestRaceTime() {
        return bestRaceTime;
    }
    public static String getBestRacerName() {
        return bestRacerName;
    }
    public static void setBestRaceTime(long l) {
        Timer.bestRaceTime = l;
    }
    public static void setBestRacerName(String s) {
        Timer.bestRacerName = s;
    }


}

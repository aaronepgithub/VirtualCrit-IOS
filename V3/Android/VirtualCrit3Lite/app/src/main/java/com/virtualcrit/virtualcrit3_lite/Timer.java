package com.virtualcrit.virtualcrit3_lite;

import android.annotation.SuppressLint;
import android.location.Location;
import android.util.Log;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;


public final class Timer {

    private final static String TAG = Timer.class.getSimpleName();
    private static int status = 99;

    public static int checkDistanceValue = 150;
    public static String checkSettingsSport = "BIKE";

    private static Location timerLocation;
    private static Location timerOldLocation;
    private static double timerGeoDistance = 0.0;
    private static double timerGeoSpeed = 0.0;
    private static double timerGeoAvgSpeed;
    private static double timerTotalTimeGeo = 0.0;
    public static ArrayList<Location> timerAllLocations = new ArrayList<>();
    public static ArrayList<LatLng> trackerCoords = new ArrayList<>();


//NOTIFY TIMER TO EXECUTE ON MAIN ACTIVITY
    private static ArrayList<String> stringForSpeak = new ArrayList<>();
    private static ArrayList<String> stringForSetMessage = new ArrayList<>();
    private static LatLng locationForNextMarker;
    private static ArrayList<String> stringForTimeline = new ArrayList<>();
    private static ArrayList<String> stringForTimelineTime = new ArrayList<>();
    private static String stringForPostRaceProcessing = "";



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

    public static String metersTogo = "";

    static void setTimerLocation(Location timerLocation) {
        Log.i(TAG, "Location from Service: " + timerLocation.getProvider() + ", " + timerLocation.getLatitude() + ", " + timerLocation.getLongitude());
        Timer.timerLocation = timerLocation;
        calculateValues();
    }

    private static void calculateValues() {
        Log.i(TAG, "calculateValues: timerLocation " + timerLocation.getProvider());

        Timer.timerAllLocations.add(timerLocation);

        LatLng e = new LatLng();
        e.setLatitude(timerLocation.getLatitude());
        e.setLongitude(timerLocation.getLongitude());
        Timer.trackerCoords.add(e);


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


            //Log.i(TAG, "onTimerLocationReceived: result/time bet old and new: " + result + ", " + (locationTime - oldLocationTime));
            //Log.i(TAG, "onMapboxLocationReceived: time bet old and new: " + (locationTime - oldLocationTime));
            if (result  < 1 || (locationTime - oldLocationTime) < 2001) {
                Log.i(TAG, "onTimerLocationReceived: too quick, too short, just wait");
                //evaluateLocation(locationLat, locationLon);
//                return;
                Log.i(TAG, "calculateValues: Crit.critBuilderLatLng.size() " + Crit.critBuilderLatLng.size());
                if (Crit.critBuilderLatLng.size() > 0) {
                    Log.i(TAG, "calculateValues: EVALUATE LOCATION");
                    evaluateLocation(locationLat, locationLon);
                    //stringForSetMessage.add(".");
                }
                return;
            }

            if (locationTime - oldLocationTime > 10000 || result > 150) { //10 SECONDS or 150 meters
                Log.i(TAG, "onLocationReceived: too much time has passed, set new *old* location and wait");
                timerOldLocation = timerLocation;
//                evaluateLocation(locationLat, locationLon);
                if (Crit.critBuilderLatLng.size() > 0) {
                    Log.i(TAG, "calculateValues: EVALUATE LOCATION");
                    evaluateLocation(locationLat, locationLon);
                    //stringForSetMessage.add(".");
                }
                return;
//                return;
            }



            Log.i(TAG, "calculateValues: checks cleared, calc values");
            double gd = result * 0.000621371;
            timerGeoDistance += gd;

            //MORE ACCURACE BUT NOT NECESSARY
            long gt = (timerLocation.getTime() - timerOldLocation.getTime());  //MILLI

//            if ((gd / ((double) gt / 1000 / 60 / 60)) < 0) {
//                Log.i(TAG, "calculateValues: too small - neg number, don't count, ");
//                timerOldLocation = timerLocation;
//                timerGeoDistance = timerGeoDistance - gd;
//                return;
//            }

            //timerGeoSpeed = gd / ((double) gt / 1000 / 60 / 60);
            //USING QUICK METHOD FOR DISPLAY PURPOSES
            double os = timerGeoSpeed;

            if (timerLocation.getAccuracy() < 20) {
                timerGeoSpeed = (double) timerLocation.getSpeed() * 2.23694;  //meters/sec to mi/hr
                if (timerGeoSpeed < 0) {
                    timerGeoSpeed = 0;
                }
                if (timerGeoSpeed > 40) {
                    timerGeoSpeed = 40;
                }
                if (timerGeoSpeed == 0) {
                    timerGeoSpeed = os;
                }
            }




            //USING QUICK METHOD FOR DISPLAY PURPOSES
            //timerGeoSpeed = (double) timerLocation.getSpeed() * 2.23694;  //meters/sec to mi/hr

            timerTotalTimeGeo += (locationTime - oldLocationTime);  //MILLI
            double ttg = (double) timerTotalTimeGeo;  //IN MILLI
            timerGeoAvgSpeed = timerGeoDistance / (ttg / 1000.0 / 60.0 / 60.0);
            timerOldLocation = timerLocation;
            Log.i(TAG, "onTimerLocationReceived: timer Speed, AvgSpeed, Distance, totalTime: " + timerGeoSpeed + ", " + timerGeoAvgSpeed + ", " + timerGeoDistance + ", " + timerTotalTimeGeo);
        }

        if (Crit.critBuilderLatLng.size() > 0) {
            Log.i(TAG, "calculateValues: EVALUATE LOCATION");
            evaluateLocation(locationLat, locationLon);
            //stringForSetMessage.add(".");
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

    public static int currentWaypointCB = 0;
    public static Boolean isRaceStarted = false;
    public static long raceStartTime = 0;
    private static int maxWaypointCB = 0;

    public static Boolean isTimeToPostRaceData = false;
    public static Race publishMe;


    private static long raceFinishTime = 0;
    private static ArrayList<Long> waypointTimesTim = new ArrayList<>();

    private static String waypointTimesTimString;
    private static String waypointNamesString;
    private static String waypointPointsString;


    private static ArrayList<Long> waypointTimesBest = new ArrayList<>();
    private static long bestRaceTime = -1;
    private static String bestRacerName = "";
    private static String bestRacerLeaderMessage = "";
    private static String raceName = "";

    private static ArrayList<Long> raceTimesTim = new ArrayList<>();




    private static void evaluateLocation(final double gpsLa, final double gpsLo) {
        Log.i(TAG, "EVALUATE LOCATION");
        stringForSetMessage.add(".");

        switch (checkSettingsSport) {
            case "BIKE":
                checkDistanceValue = 150;
                break;
            case "RUN":
                checkDistanceValue = 100;
                break;
            case "ROW":
                checkDistanceValue = 50;
                break;
        }

        double startLa = Crit.critBuilderLatLng.get(0).getLatitude();
        double startLo = Crit.critBuilderLatLng.get(0).getLongitude();
        double finishLa = Crit.critBuilderLatLng.get(Crit.critBuilderLatLng.size()-1).getLatitude();
        double finishLo = Crit.critBuilderLatLng.get(Crit.critBuilderLatLng.size()-1).getLongitude();
        maxWaypointCB = Crit.critBuilderLatLng.size() - 1;
        raceName = Crit.critBuilderLatLngNames.get(0);


        //TEST FOR START
        String postStart1 = "";
        String postStart2 = "";
        Log.i(TAG, "evaluateLocation");
        if (currentWaypointCB == 0 && !isRaceStarted) {
            //NOT YET AT START
            double disBetw = timerDistanceBetween(gpsLa, gpsLo, startLa, startLo);
            Log.i(TAG, "TEST FOR START: " + disBetw);
            metersTogo = String.valueOf((int) disBetw) + " MTG";

            if (disBetw < 100000) {
                stringForSetMessage.add(String.valueOf((int) disBetw) + " METERS REMAIN");
            }

            if (disBetw < checkDistanceValue) {  //WITHIN 150 METERS OF TARGET
                Log.i(TAG, "STARTRACE!");
                raceStartTime = System.currentTimeMillis();
                isRaceStarted = true;

                //speakText("THE RACE HAS STARTED  HEAD TO " + namesTemp.get(currentWaypointCB+1));
                //addAnotherMarker(latTemp.get(currentWaypointCB+1), lonTemp.get(currentWaypointCB+1));
                postStart1 = "ARRIVED AT THE START.  HEAD TO " + Crit.critBuilderLatLngNames.get(currentWaypointCB+1) + ".\n";
//                stringForSpeak.add("THE RACE HAS STARTED.  HEAD TO " + Crit.critBuilderLatLngNames.get(currentWaypointCB+1));
                locationForNextMarker = Crit.critBuilderLatLng.get(currentWaypointCB+1);

//                stringForSpeak.add(postStart1);
//                stringForSetMessage.add(raceName + ":  ARRIVED AT START");


                waypointTimesTim = new ArrayList<>();
                waypointTimesTimString = "";

                //String startString = "";
                if (bestRaceTime > 10000) {
                    postStart2 = "\nTHE LEADER IS " + bestRacerName + " AT " + getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime);
                }

                if (bestRaceTime == 2147483646) {
                    postStart2 = "YOU ARE THE FIRST CRIT RACER FOR " + raceName;
                }

//                stringForTimeline.add("RACE STARTING\n" + Crit.critBuilderLatLngNames.get(0).toUpperCase() + "\nHEAD TO " + Crit.critBuilderLatLngNames.get(currentWaypointCB + 1).toUpperCase() + startString);
                stringForSpeak.add(postStart1 + postStart2);
                stringForSetMessage.add(raceName + ":  ARRIVED AT START");
                stringForTimeline.add(postStart1 + postStart2);
                stringForTimelineTime.add(Timer.getCurrentTimeStamp());
                Log.i(TAG, "stringForTimeline " + stringForTimeline);

                currentWaypointCB += 1;
            }
            return;
        }
        //END TEST FOR START

        //TEST FOR FINISH
        if (currentWaypointCB == maxWaypointCB && isRaceStarted) {
            double disBetwMax = timerDistanceBetween(gpsLa, gpsLo, finishLa, finishLo);
            Log.i(TAG, "TEST FOR FINISH: " + disBetwMax);
            metersTogo = String.valueOf((int) disBetwMax) + " MTG";

            if (disBetwMax < 1000) {
                stringForSetMessage.add(String.valueOf((int) disBetwMax) + " METERS REMAIN");
            }

            if (disBetwMax < checkDistanceValue) {
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

                publishMe = new Race(Crit.getRacerName(), Crit.getRaceName(), raceTime, Crit.getRaceDate(), waypointTimesTimString, Timer.getWaypointPointsString(), Timer.getWaypointNamesString());
                isTimeToPostRaceData = true;

                String s;
                String ss;
                if (bestRaceTime == -1) {
                    bestRaceTime = raceTime + 1;
                }
                if (raceTime < bestRaceTime && bestRaceTime > 10000){
                    waypointTimesBest = waypointTimesTim;
                    s = "THE NEW FASTEST TIME BY " + Timer.getTimeStringFromMilliSecondsToDisplay((int) ((int) bestRaceTime - (int) raceTime));
                    ss = "THE NEW FASTEST TIME BY " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) ((int) bestRaceTime - (int) raceTime));
                    bestRaceTime = raceTime;
                } else {
                    s = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime) + " BY " + bestRacerName;
                    ss = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) bestRaceTime) + " BY " + bestRacerName;
                }

                if (bestRaceTime == 2147483646) {
                    s = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime) + " BY " + bestRacerName;
                    ss = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) bestRaceTime) + " BY " + bestRacerName;
                }

                if ( ((int) bestRaceTime - (int) raceTime) > (60*60*1000) ) {
                    Log.i(TAG, "evaluateLocation: greater than an hour, don't show");
                    s = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplay((int) bestRaceTime) + " BY " + bestRacerName;
                    ss = "THE FASTEST TIME IS " + Timer.getTimeStringFromMilliSecondsToDisplayToSpeak((int) bestRaceTime) + " BY " + bestRacerName;
                }

                //ADD FLAY STRING
                String lm = Crit.getLeaderMessage();
                //String lmLowerCase = Crit.getLeaderMessage();
                String x = "";
                if (Timer.getBestRaceTime() < raceTime && bestRaceTime < 2147000000 && Timer.getBestRacerLeaderMessage() != null && Timer.getBestRacerName() != null && !Timer.getBestRacerName().equals("NEW")) {
                    x = "Sorry, " + Timer.getBestRacerName() + " is the leader and says..." + Timer.getBestRacerLeaderMessage() + ".";
                }



                Log.i(TAG, "RACE FINISHED  : " + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + ".  " + s + ", " + x);
//                stringForSpeak.add("RACE COMPLETE. " + ss + ".  " + lm);
                stringForSpeak.add("RACE COMPLETE. " + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + x);
                stringForPostRaceProcessing = raceName;
                stringForTimeline.add("RACE COMPLETE\n" + getTimeStringFromMilliSecondsToDisplay((int) raceTime) + x);
                stringForTimelineTime.add(Timer.getCurrentTimeStamp());
                stringForSetMessage.add("RACE COMPLETE: " + getTimeStringFromMilliSecondsToDisplay((int) raceTime));

                //MAYBE CALL A ONETIME READ...

                //RESET
                Log.i(TAG, "RESET RACE: ");
                currentWaypointCB = 0;
                raceStartTime = 0;
                isRaceStarted = false;
            }

        }
        //END TEST FOR FINISH


        //NOT START OR FINISH
        if (isRaceStarted && currentWaypointCB > 0 && currentWaypointCB < maxWaypointCB) {
            Log.i(TAG, "NOT START OR FINISH, START WAYPOINT TEST: currentWaypointCB, maxWaypointCB " + currentWaypointCB +", "+ maxWaypointCB);
            waypointTest(gpsLa, gpsLo);
        }




    }
    //END EVALUATELOCATION


    //START WAYPOINTTEST
    private static void waypointTest(double gpsLa, double gpsLo) {
        Log.i(TAG, "waypointTest, current, max: " + currentWaypointCB + ", " + maxWaypointCB);

        if (!isRaceStarted) {
            Log.i(TAG, "waypointTest, race not started, return");
            return;
        }
        if (currentWaypointCB >= maxWaypointCB) {
            Log.i(TAG, "waypointTest, currentWaypointCB > maxCB, SHOULDN'T HAPPEN, RETURN");
            return;
        }

        final double disBetw = timerDistanceBetween(gpsLa, gpsLo, Crit.critBuilderLatLng.get(currentWaypointCB).getLatitude(), Crit.critBuilderLatLng.get(currentWaypointCB).getLongitude());
        Log.i(TAG, "WAYPOINT TEST, WAIT FOR MATCH: " + disBetw);
        metersTogo = String.valueOf((int) disBetw) + " MTG";

        //WAYPOINT MATCH
        if (disBetw < 1000) {
            stringForSetMessage.add(String.valueOf((int) disBetw) + " METERS REMAIN");
        }


        if (disBetw < checkDistanceValue) {
            Log.i(TAG, "WAYPOINT MATCH! " + (currentWaypointCB) + " OF " + (maxWaypointCB));
            Log.i(TAG, "WAYPOINT MATCH NAME: " + Crit.critBuilderLatLngNames.get(currentWaypointCB));
            final int next = currentWaypointCB + 1;

            Log.i(TAG, "NEW CURRENT WAYPOINTCB : " + currentWaypointCB);



            if ((currentWaypointCB) < maxWaypointCB) {
                Log.i(TAG, "waypointTest: currentWaypointCB < maxWaypointCB..." + (currentWaypointCB) + "  maxWaypointCB  " + maxWaypointCB);
                locationForNextMarker = Crit.critBuilderLatLng.get(next);
                Log.i(TAG, "waypointTest: WAYPOINT MATCH, NEXT NAME: " + Crit.critBuilderLatLngNames.get(next));
            }

            stringForSetMessage.add("RACE CHECKPOINT " + (currentWaypointCB) + " OF " + (maxWaypointCB));
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
                        Log.i(TAG, "waypointTest: long l " + l);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER " + bestRacerName;
                            s2 = "EVEN WITH THE LEADER " + bestRacerName;
                        } else {
                            if (i < (1 * 60 * 60 * 1000)) {
                                s1 = getTimeStringFromMilliSecondsToDisplay(i) + " AHEAD OF " + bestRacerName;
                                s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " AHEAD OF " + bestRacerName;
                            }
                        }

                    } else {
                        long l = waypointTimesTim.get(currentWaypointCB-1) - waypointTimesBest.get(currentWaypointCB-1);
                        int i = (int) l;
                        if (i < 2000) {
                            s1 = "EVEN WITH THE LEADER " + bestRacerName;
                            s2 = "EVEN WITH THE LEADER " + bestRacerName;
                        } else {
                            if (i < (1 * 60 * 60 * 1000)) {
                                s1 = getTimeStringFromMilliSecondsToDisplay(i) + " BEHIND "+ bestRacerName;
                                s2 = Timer.getTimeStringFromMilliSecondsToDisplayToSpeak(i) + " BEHIND "+ bestRacerName;
                            }
                        }

                    }
                    Log.i(TAG, "waypointTest: s1:  " + s1);
                }
            }

            if (currentWaypointCB == (maxWaypointCB-1)) {
                Log.i(TAG, "waypointTest: NEXT WAYPOINT IS FINISH " + Crit.critBuilderLatLngNames.get(next));
                Log.i(TAG, "waypointTest: next stop is finish, currentWaypointCB " + currentWaypointCB + " of " + maxWaypointCB);
                locationForNextMarker = Crit.critBuilderLatLng.get(currentWaypointCB);
                stringForTimelineTime.add(Timer.getCurrentTimeStamp());
                stringForTimeline.add("WAYPOINT " + (currentWaypointCB) + " OF " + (maxWaypointCB) + "\n" + Crit.critBuilderLatLngNames.get(currentWaypointCB) + "\n" + s1 + "\nHEAD TO FINISH");
                stringForSpeak.add("WAYPOINT " + Crit.critBuilderLatLngNames.get(currentWaypointCB) + ".  NUMBER " + (currentWaypointCB) + " OF " + (maxWaypointCB) + "...  " + s2 + ".  HEAD TO FINISH");

            } else {

                Log.i(TAG, "waypointTest: NEXT WAYPOINT IS NOT FINISH, currentwaypoint: " + currentWaypointCB);
                stringForTimelineTime.add(Timer.getCurrentTimeStamp());
                stringForTimeline.add("WAYPOINT " + (currentWaypointCB) + " OF " + (maxWaypointCB) + "\n" + Crit.critBuilderLatLngNames.get(currentWaypointCB) + "\n" + s1 + "\nHEAD TO " + Crit.critBuilderLatLngNames.get(next));
                stringForSpeak.add("WAYPOINT " + Crit.critBuilderLatLngNames.get(currentWaypointCB) + ".  NUMBER " + (currentWaypointCB) + " OF " + (maxWaypointCB) + ".  " + s2 + ".  HEAD TO " + Crit.critBuilderLatLngNames.get(next));

            }
            Log.i(TAG, "waypointTestCB, END OF MATCH PROCESSING " + currentWaypointCB);

            currentWaypointCB += 1;

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


    public static ArrayList<String> getStringForSpeak() {
        return stringForSpeak;
    }

    public static void setStringForSpeak(ArrayList<String> stringForSpeak) {
        Timer.stringForSpeak = stringForSpeak;
    }

    public static ArrayList<String> getStringForTimeline() {
        return stringForTimeline;
    }

    public static void setStringForTimeline(ArrayList<String> stringForTimeline) {
        Timer.stringForTimeline = stringForTimeline;
    }

    public static ArrayList<String> getStringForTimelineTime() {
        return stringForTimelineTime;
    }

    public static void setStringForTimelineTime(ArrayList<String> stringForTimelineTime) {
        Timer.stringForTimelineTime = stringForTimelineTime;
    }


    public static ArrayList<String> getStringForSetMessage() {
        return stringForSetMessage;
    }

    public static void setStringForSetMessage(ArrayList<String> stringForSetMessage) {
        Timer.stringForSetMessage = stringForSetMessage;
    }

//    public static String getStringForPostRaceProcessing() {
//        return stringForPostRaceProcessing;
//    }
//
//    public static void setStringForPostRaceProcessing(String stringForPostRaceProcessing) {
//        Timer.stringForPostRaceProcessing = stringForPostRaceProcessing;
//    }

    public static LatLng getLocationForNextMarker() {
        return locationForNextMarker;
    }

    public static void setLocationForNextMarker(LatLng locationForNextMarker) {
        Timer.locationForNextMarker = locationForNextMarker;
    }

    public static String getWaypointNamesString() {
        return waypointNamesString;
    }

    public static void setWaypointNamesString(String waypointNamesString) {
        Timer.waypointNamesString = waypointNamesString;
    }

    public static String getWaypointPointsString() {
        return waypointPointsString;
    }

    public static void setWaypointPointsString(String waypointPointsString) {
        Timer.waypointPointsString = waypointPointsString;
    }

    public static String getBestRacerLeaderMessage() {
        return bestRacerLeaderMessage;
    }

    public static void setBestRacerLeaderMessage(String bestRacerLeaderMessage) {
        Timer.bestRacerLeaderMessage = bestRacerLeaderMessage;
    }
}

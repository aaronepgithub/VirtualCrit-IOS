package com.aaronep.andy;

import com.google.firebase.database.IgnoreExtraProperties;

/**
 * Created by aaronep on 3/22/18.
 */
@IgnoreExtraProperties
public class Round {

    public Integer a_calcDurationPost;
    public Double a_scoreRoundLast;
    public Double a_speedRoundLast;
    public Double fb_CAD;
    public Integer fb_Date;
    public Integer fb_DateNow;
    public Double fb_HR;
    public Double fb_RND;
    public Double fb_SPD;
    public Integer fb_maxHRTotal;
    public Double fb_scoreHRRound;
    public Double fb_scoreHRRoundLast;
    public Double fb_scoreHRTotal;
    public Double fb_timAvgHRtotal;
    public Double fb_timAvgCADtotal;
    public Double fb_timAvgSPDtotal;
    public Double fb_timDistanceTraveled;
    public String fb_timGroup;
    public String fb_timName;
    public String fb_timTeam;

//    public String name;
//    public Double score;

    // Default constructor required for calls to
    // DataSnapshot.getValue(User.class)
    public Round() {
    }

    public Round(String fb_timName, Double fb_RND) {
//        this.name = name;
//        this.score = score;

        this.a_calcDurationPost = 1;
        this.a_scoreRoundLast = 1.0;
        this.a_speedRoundLast = 1.0;

        this.fb_RND = fb_RND;
        this.fb_timName = fb_timName;

        this.fb_timGroup = "tester";
        this.fb_timTeam = "tester";
        this.fb_CAD = 1.0;
        this.fb_Date = 20180322;
        this.fb_DateNow = 20180322;
        this.fb_HR = 1.0;
        this.fb_maxHRTotal = 185;
        this.fb_scoreHRRound = 1.0;
        this.fb_scoreHRRoundLast = 1.0;
        this.fb_scoreHRTotal = 1.0;
        this.fb_SPD = 1.0;
        this.fb_timAvgSPDtotal = 1.0;
        this.fb_timAvgCADtotal = 1.0;
        this.fb_timAvgHRtotal = 1.0;
        this.fb_timDistanceTraveled = 1.0;



    }

}

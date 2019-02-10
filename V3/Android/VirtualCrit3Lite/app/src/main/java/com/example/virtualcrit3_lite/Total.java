package com.example.virtualcrit3_lite;
import com.google.firebase.database.IgnoreExtraProperties;

@IgnoreExtraProperties
public class Total {


    public String fb_timName;
    public String a_calcDurationPost;
    public Double a_scoreHRRoundLast;
    public Double a_scoreHRTotal;
    public Double a_speedLast;
    public Double a_speedTotal;
    public Integer fb_Date;
    public Integer fb_DateNow;
    public Integer fb_maxHRTotal;
    public Double fb_scoreHRRoundLast;
    public Double fb_scoreHRTotal;

    public Double fb_timAvgCADtotal;
    public Double fb_timAvgSPDtotal;
    public Double fb_timDistanceTraveled;
    public String fb_timGroup;
    public Double fb_timLastSPD;
    public String fb_timTeam;



    public Total(String fb_timName, Double a_scoreHRTotal, Double a_speedTotal) {

        this.fb_timName = fb_timName;
        this.a_scoreHRTotal = a_scoreHRTotal;
        this.a_speedTotal = a_speedTotal;

        this.a_calcDurationPost = "1";
        this.a_scoreHRRoundLast = a_scoreHRTotal;
        this.a_speedLast = a_speedTotal;

        this.fb_Date = 1;
        this.fb_DateNow = 1;
        this.fb_maxHRTotal = 1;
        this.fb_scoreHRRoundLast = a_scoreHRTotal;
        this.fb_scoreHRTotal = a_scoreHRTotal;
        this.fb_timAvgCADtotal = 1.0;
        this.fb_timAvgSPDtotal = a_speedTotal;
        this.fb_timDistanceTraveled = 1.0;
        this.fb_timGroup = "ANDY";
        this.fb_timLastSPD = a_speedTotal;
        this.fb_timTeam = "Square Pizza";
    }

}

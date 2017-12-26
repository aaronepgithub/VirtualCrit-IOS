var rt = {
  hr: 0,
  speed: 0,
  cadence: 0,
  score: 0
};

var name = "TIM";
var maxHeartRate = 185;
var wheelCircumference = 2105;
var wheelCircumferenceCM = 210.5;
var cmPerMi = 0.00001 * 0.621371;
var minsPerHour = 60.0;

var totalMiles = 0;

var interval = {
  arrDistance: [],
  arrHeartRate: []
};

var rounds = {
  HeartRate: 0,
  WheelRevs: 0,
  CrankRevs: 0,
  Distance: 0,

  arrHeartRate: [],
  arrSpeed: [],
  arrCadence: [],
  arrScore: [],

  avgHeartRate: 0,
  avgSpeed: 0,
  avgCadence: 0,
  avgScore: 0,

  totalRoundCount: 0
};

var veloS = 0;
var veloC = 0;
var veloH = 0;

function calcInterval() {
  //console.log("calcInterval");
  var dist = interval.arrDistance[interval.arrDistance.length - 1] - interval.arrDistance[interval.arrDistance.length - refreshInterval];
  // for (i = refreshInterval; i > 0; i--) {
  //   if (interval.arrDistance[i] >= 0) {dist += interval.arrDistance[interval.arrDistance.length - i];} else {dist += 0;}
  //   }
  var speedInterval = dist / (refreshInterval / 60 / 60);
  //console.log("speedInterval:  " + speedInterval);

  var hr = 0;
  for (i = refreshInterval; i > 0; i--) {
    if (interval.arrHeartRate[i] >= 0) {hr += interval.arrHeartRate[interval.arrHeartRate.length - i];} else {hr += 0;}
    }
  var heartrateInterval = hr / (refreshInterval);
  //console.log("heartrateInterval:  " + heartrateInterval);


  if (time % 5 == 0) {
    var h = $$(".rtHR").text();
    var s = $$(".rtSPD").text();
    var c = $$(".rtCAD").text();

    if (h == veloH) {$$(".rtHR").text(0.00);}
    if (s == veloS) {$$(".rtSPD").text(0.00);}
    if (c == veloC) {$$(".rtCAD").text(0.00);}

    veloH = h;
    veloS = s;
    veloC = c;
  }

}

function midRound(time) {
  rounds.avgHeartRate = rounds.HeartRate / time;
  rounds.avgScore = (rounds.avgHeartRate / maxHeartRate) * 100;
  rounds.avgSpeed = (rounds.WheelRevs / (time / 60)) * wheelCircumferenceCM * cmPerMi * minsPerHour;
  rounds.avgCadence = rounds.CrankRevs / (time / 60);

  //console.log("rounds.avgSpeed:  " + rounds.avgSpeed);
  //console.log("rounds.avgHeartRate:  " + rounds.avgHeartRate);

  if (time == 300) {
    rounds.totalRoundCount = endRound();
  }

  calcInterval();

  // if (time % refreshInterval == 0) {
  //   calcInterval();
  // }
}

function endRound() {
  rounds.arrHeartRate.push(rounds.avgHeartRate);
  rounds.arrSpeed.push(rounds.avgSpeed);
  rounds.arrCadence.push(rounds.avgCadence);
  rounds.arrScore.push(rounds.avgScore);

  console.log("End of Round:  \n" +
    rounds.arrHeartRate[length-1] + "\n" +
    rounds.arrSpeed[length-1] + "\n " +
    rounds.arrCadence[length-1] + "\n" +
    rounds.arrScore[length-1] + "\n"
  );

  rounds.WheelRevs = 0;
  rounds.HeartRate = 0;
  rounds.CrankRevs = 0;
  rounds.Distance = 0;
  time = 0;
  return(rounds.arrScore.length - 1);
}



function onDataHR(data) {
  //console.log(data[1]);
  rt.hr = data[1];
  rt.score = (rt.hr / maxHeartRate) * 100;
  $$(".rtHR").text(rt.hr);
  $$("#blinker").text("Pull to Refresh (HR)");
  $$(".iconNumber").text(rt.hr);
}

function decodeUint32(bytes) {
  return bytes[0] + bytes[1] * 256 + bytes[2] * 256 * 256 + bytes[3] * 256 * 256 * 256;
}

function decodeUint16(bytes) {
  return bytes[0] + bytes[1] * 256;
}

function decodeUint8(bytes) {
  return bytes[0];
}



function onDataCSC(data) {

  //console.log("onDataCSC");
  var WHEEL_REVOLUTION_FLAG = 0x01;
  var CRANK_REVOLUTION_FLAG = 0x02;
  //var value = data;
  var flag = data[0];

  if ((flag & WHEEL_REVOLUTION_FLAG) == 1) {
    //console.log("SPD data[1]:  " + data[1]);
    //rt.speed = data[1];
    processWheelData(data);
    if ((flag & CRANK_REVOLUTION_FLAG) == 2) {
      //console.log("CAD CSC data[7]:  " + data[7]);
      //rt.cadence = data[7];
      processCrankData(data, 7);
    }
  } else {
    if ((flag & CRANK_REVOLUTION_FLAG) == 2) {
      //console.log("\n CAD SA data[1]:  " + data[1] + "\n");
      //rt.cadence = data[1];
      processCrankData(data, 1);
    }
  }
}

var oldWheelRevolution = 0;
var oldWheelEventTime = 0;
var rt_WheelRevs = 0;
var rt_WheelTime = 0;
var total_moving_time_seconds = 0;

var single_read_speed = 0;
var single_read_cad = 0;


function processWheelData(data) {

  wheelRevolution = (data[2] * 256) + data[1];
  wheelEventTime = (data[6] * 256) + data[5] + 1.0;

  if (oldWheelRevolution == 0) {
    oldWheelRevolution = wheelRevolution;
    oldWheelEventTime = wheelEventTime;
  } else {

    var deltaW = wheelRevolution - oldWheelRevolution;
    var deltaT = wheelEventTime - oldWheelEventTime;

    if (deltaW < 0) {
      deltaW += 65535;
    }
    if (deltaT < 0) {
      deltaT += 65535;
    }

    if (deltaW == 0 || deltaW > 10) {
      wheelRevolution = oldWheelRevolution;
      wheelEventTime = oldWheelEventTime;
      //velo should test, might not need to update display
      single_read_speed = 0;
      rt.speed = single_read_speed.toFixed(1);
      // $$(".rtSPD").text(rt.speed);
      // $$("#blinker").text("Pull to Refresh (SPD)");
      return;
    }
    if (deltaT < 750 && deltaT > 0) {
      wheelRevolution = oldWheelRevolution;
      wheelEventTime = oldWheelEventTime;
      return;
    }

    //         //single read
    var wheelTimeSeconds = deltaT / 1024;
    if (wheelTimeSeconds > 0) {
      // var wheelCircumferenceCM = wheelCircumference / 10;
      var wheelRPM = deltaW / (wheelTimeSeconds / 60);
      // var cmPerMi = 0.00001 * 0.621371;
      // var minsPerHour = 60.0;
      single_read_speed = wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour;
      rt.speed = single_read_speed.toFixed(1);
      $$(".rtSPD").text(rt.speed);
      $$("#blinker").text("Pull to Refresh (SPD)");


      if (single_read_speed > 0) {
        rt_WheelRevs += deltaW;
        rt_WheelTime += deltaT;
        total_moving_time_seconds += (deltaT / 1024);
        //convert to display as moving time
      }
      rounds.WheelRevs += deltaW;
      rounds.Distance += deltaW * wheelCircumferenceCM * cmPerMi;
      //total miles
      totalMiles = rt_WheelRevs * wheelCircumferenceCM * cmPerMi;
      $$(".rtMILES").text((totalMiles).toFixed(2));
      //avg speed
      var avgSpeed = (rt_WheelRevs / ((rt_WheelTime / 1024) / 60)) * wheelCircumferenceCM * cmPerMi * minsPerHour;

      var date = new Date(null);
      date.setSeconds(rt_WheelTime / 1024); // specify value for SECONDS here
      var result = date.toISOString().substr(11, 8);

      $$(".rtMOVING").text(result);
      $$(".rtAVGSPD").text(avgSpeed.toFixed(1));


      $$(".rtSPD").text(rt.speed);
      $$("#blinker").text("Pull to Refresh (SPD)");

    } else {
      //velo should test, might not need to update display
      single_read_speed = 0;
      rt.speed = single_read_speed.toFixed(1);
      $$(".rtSPD").text(rt.speed);
      $$("#blinker").text("Pull to Refresh (SPD)");
    }
    //console.log("SPD:  " + single_read_speed);
    oldWheelRevolution = wheelRevolution;
    oldWheelEventTime = wheelEventTime;
  }
}


var rt_crank_revs = 0;
var rt_crank_time = 0;
var oldCrankRevolution = 0;
var oldCrankEventTime = 0;

function processCrankData(data, index) {

  var crankRevolution = ((data[index + 1]) * 256) + (data[index]);
  var crankEventTime = ((data[index + 3]) * 256) + (data[index + 2]) + 1.0;

  if (oldCrankRevolution == 0) {
    oldCrankRevolution = crankRevolution;
    oldCrankEventTime = wheelEventTime;
  } else {
    var deltaW = crankRevolution - oldCrankRevolution;
    var deltaT = crankEventTime - oldCrankEventTime;

    if (deltaW < 0) {
      deltaW += 65535;
    }
    if (deltaT < 0) {
      deltaT += 65535;
    }

    if (deltaW == 0 || deltaW > 5) {
      crankRevolution = oldCrankRevolution;
      crankEventTime = oldCrankEventTime;
      //single_read_cad = 0;
      //rt.cadence = single_read_cad.toFixed(0);
      //$$(".rtCAD").text(rt.cadence);
      //$$("#blinker").text("Pull to Refresh (CAD)");
      return;
    }

    if (deltaT < 750 && deltaT > 0) {
      crankRevolution = oldCrankRevolution;
      crankEventTime = oldCrankEventTime;
      return;
    }

    // if (deltaT > 2000) {
    //   crankRevolution = oldCrankRevolution;
    //   crankEventTime = oldCrankEventTime;
    //   single_read_cad = 0;
    //   rt.cadence = single_read_cad.toFixed(0);
    //   $$(".rtCAD").text(rt.cadence);
    //   $$("#blinker").text("Pull to Refresh (CAD)");
    //   return;
    // }

    // if (deltaT == 0) {
    //   oldCrankRevolution = crankRevolution;
    //   oldCrankEventTime = crankEventTime;
    //   // single_read_cad = 0;
    //   // rt.cadence = single_read_cad.toFixed(0);
    //   // $$(".rtCAD").text(rt.cadence);
    //   // $$("#blinker").text("Pull to Refresh (CAD)");
    //   return;
    // }

    //single read
    var crankTimeSeconds = deltaT / 1024;
    single_read_cad = deltaW / (crankTimeSeconds / 60);
    rounds.CrankRevs += deltaW;
    rt_crank_revs += deltaW;
    rt_crank_time += deltaT; //still in 1/1024 of a sec

    rt.cadence = single_read_cad.toFixed(0);
    $$(".rtCAD").text(rt.cadence);
    $$("#blinker").text("Pull to Refresh (CAD)");
    //console.log("CAD:  " + single_read_cad);

    oldCrankRevolution = crankRevolution;
    oldCrankEventTime = crankEventTime;
  }

}

Date.dateDiffReturnSeconds = function(datepart, fromdate, todate) {
  datepart = datepart.toLowerCase();
  var diff = todate - fromdate;
  var divideBy = {
    w: 604800000,
    d: 86400000,
    h: 3600000,
    n: 60000,
    s: 1000
  };

  return Math.floor(diff / divideBy[datepart]);

  //var deltaSeconds = Math.floor(diff / divideBy[datepart]);

  // var date = new Date(null);
  // date.setSeconds(deltaSeconds); // specify value for SECONDS here
  // var result = date.toISOString().substr(11, 8);
  // return Math.floor( diff/divideBy[datepart]);
  //return result;
};

Date.dateDiff = function(datepart, fromdate, todate) {
  datepart = datepart.toLowerCase();
  var diff = todate - fromdate;
  var divideBy = {
    w: 604800000,
    d: 86400000,
    h: 3600000,
    n: 60000,
    s: 1000
  };

  var deltaSeconds = Math.floor(diff / divideBy[datepart]);

  var date = new Date(null);
  date.setSeconds(deltaSeconds); // specify value for SECONDS here
  var result = date.toISOString().substr(11, 8);
  // return Math.floor( diff/divideBy[datepart]);
  return result;
};
//Set the two dates
//var y2k  = new Date(2000, 0, 1);
//var rightNow = new Date();
//console.log('Seconds Since Start: ' + Date.dateDiff('s', startTime, rightNow));

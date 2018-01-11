var secInRound = 300;

var inRoundHR = 0;
var inRoundSPD = 0;
var inRoundCAD = 0;

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
  arrHeartRate: [],
  arrCadence: [],
  arrSpeed: [],
  arrCurrentIntervals: []
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

function calcInterval(t) {
  //var t = localT;
  console.log("calcInterval:  "+ t);
  var dist = interval.arrDistance[interval.arrDistance.length - 1] - interval.arrDistance[interval.arrDistance.length - refreshInterval];
  var speedInterval = Number(dist / (refreshInterval / 60 / 60));
  //console.log("speedInterval:  " + speedInterval);

  var hr = 0;
  for (i = refreshInterval; i > 0; i--) {
    if (interval.arrHeartRate[i] >= 0) {
      hr += interval.arrHeartRate[interval.arrHeartRate.length - i];
    } else {
      hr += 0;
    }
  }
  var heartrateInterval = Number(hr / (refreshInterval));
  //console.log("heartrateInterval:  " + heartrateInterval);

  var cad = 0;
  for (i = refreshInterval; i > 0; i--) {
    if (interval.arrCadence[i] >= 0) {
      cad += interval.arrCadence[interval.arrCadence.length - i];
    } else {
      cad += 0;
    }
  }
  var cadenceInterval = Number(cad / (refreshInterval));

  interval.arrCurrentIntervals = [speedInterval, cadenceInterval, heartrateInterval];
  // $$('.intervalSPD').text(Number(speedInterval.toFixed(1)));
  // $$('.intervalCAD').text(Number(cadenceInterval.toFixed(0)));
  // $$('.intervalHR').text(Number(heartrateInterval.toFixed(0)));
  // var sc = Number((heartrateInterval / maxHeartRate) * 100);
  // $$('.intervalSCORE').text(Number(sc.toFixed(0)));
  if (speedInterval >= 0 ) {  $$('.rtSPDi').text(Number(speedInterval.toFixed(1))); } else {$$('.rtSPDi').text(0);}
  // $$('.rtSPDi').text(Number(speedInterval.toFixed(1)));
  $$('.rtCADi').text(Number(cadenceInterval.toFixed(0)));
  $$('.rtHRi').text(Number(heartrateInterval.toFixed(0)));
  var sc = Number((heartrateInterval / maxHeartRate) * 100);
  $$('.rtSCOREi').text(Number(sc.toFixed(0)));


  // if (t % Number(refreshInterval) === 0) {
  //   console.log("Intervals:  " + speedInterval + " MPH  - " + cadenceInterval + " RPM   - " + heartrateInterval + " BPM  - " + sc + " % ");
  //   console.log("rounds.avgSpeed:  " + rounds.avgSpeed);
  //   console.log("rounds.avgCadence:  " + rounds.avgCadence);
  //   console.log("rounds.avgHeartRate:  " + rounds.avgHeartRate);
  //   console.log("rounds.avgScore:  " + rounds.avgScore);
  // }

//used to rem zeros
  if (t % 13 === 0) {
    var h = $$(".rtHR").text();
    var s = $$(".rtSPD").text();
    var c = $$(".rtCAD").text();

    if (h == veloH) { $$(".rtHR").text(0); rt.score = 0; $$(".rtSCORE").text("HR " + rt.score.toFixed(0) + "%"); }
    if (s == veloS) { $$(".rtSPD").text(0); }
    if (c == veloC) { $$(".rtCAD").text(0); }

    rt.speed = 0;rt.cadence = 0;


    veloH = h;
    veloS = s;
    veloC = c;
  }


}

function actionEndofRound() {

  var buttons1 = [{
      text: '<h2>ROUND COMPLETE</h2>',
      bold: true,
      color: 'black',
      label: true
    },
    {
      text: '<h2>' + rounds.avgSpeed.toFixed(2) + ' (SPEED)</h2>',
      bold: false,
      label: true
    },
    {
      text: '<h2>' + rounds.avgScore.toFixed(2) + ' (SCORE)</h2>',
      bold: false,
      label: true
    }
  ];
  var buttons2 = [

    {
      text: '<h2>' + rounds.avgHeartRate.toFixed(2) + ' (HR)</h2>',
      bold: false,
      label: true
    },
    {
      text: '<h2>' + rounds.avgCadence.toFixed(2) + ' (CAD)</h2>',
      bold: false,
      label: true
    }
  ];
  var buttons3 = [{
    text: 'DISMISS',
    color: 'red'
  }];
  var groups = [buttons1, buttons2, buttons3];
  myApp.actions(groups);

}

function roundEnd(t) {
  console.log("roundEnd, t:  " + t);
  console.log("roundTimer:  " + roundTimer + "/n");
  rounds.arrHeartRate.push(Number(undefTest(rounds.avgHeartRate)));
  rounds.arrSpeed.push(Number(undefTest(rounds.avgSpeed)));
  rounds.arrCadence.push(Number(undefTest(rounds.avgCadence)));
  rounds.arrScore.push(Number(undefTest(rounds.avgScore)));

  roundTimer = 1;
  rounds.WheelRevs = 0;
  rounds.HeartRate = 0;
  rounds.CrankRevs = 0;
  rounds.Distance = 0;

  $$('#rightPcontent').prepend(rounds.arrSpeed[rounds.arrSpeed.length - 1] + ' MPH</p>');
  $$('#leftPcontent').html('<p>AVG SCORE:  ' + rounds.arrScore + ' %MAX </p><p>AVG SPEED:  ' + rounds.arrSpeed + ' MPH</p><p>AVG HR:  ' + rounds.arrHeartRate + ' BPM </p><p>AVG CAD:  ' + rounds.arrCadence + ' RPM </p>');

  console.log("End of Round Arrays:\n" +
    rounds.arrHeartRate + "\n" +
    rounds.arrSpeed + "\n" +
    rounds.arrCadence + "\n" +
    rounds.arrScore + "\n");

  var leng = rounds.arrSpeed.length;
  if (leng > 0) {
    actionEndofRound();

    setTimeout(function() {
      myApp.closeModal();
    }, 5000);
  }
}

function midRound(t) {
  console.log("midRound, t:  " + t);
  console.log("roundTimer, but using t for calc:  " + roundTimer);

  // if (t % secInRound === 0) {
  //   roundEnd(t);
  // }

  rounds.avgHeartRate = Number(rounds.HeartRate / t);
  rounds.avgScore = Number((rounds.avgHeartRate / maxHeartRate) * 100);
  rounds.avgCadence = Number(rounds.CrankRevs / t * 60);



  var a = rounds.WheelRevs;
  var b = (Number(wheelCircumference) / Number(1000)) * 0.000621371;
  var c = Number(t) / Number(60) / Number(60);
  rounds.avgSpeed = (Number(a) * Number(b)) / Number(c);
  console.log("t, avg.speed:  " + t, rounds.avgSpeed );


  if (roundTimer > 1) {
    $$('.rtSPDr').text(Number(rounds.avgSpeed.toFixed(1)));
    $$('.rtCADr').text(Number(rounds.avgCadence.toFixed(0)));
    $$('.rtHRr').text(Number(rounds.avgHeartRate.toFixed(0)));
    var scr = Number((rounds.avgHeartRate / maxHeartRate) * 100);
    $$('.rtSCOREr').text(Number(scr.toFixed(0)));
  }

  // console.log("rounds.avgSpeed:  " + rounds.avgSpeed);
  // console.log("rounds.avgCadence:  " + rounds.avgCadence);
  // console.log("rounds.avgHeartRate:  " + rounds.avgHeartRate);
  // console.log("rounds.avgScore:  " + rounds.avgScore);

  calcInterval(t);
  roundTimer++;

}

function undefTest(myVar) {
  if (myVar === void 0) {
    console.log(0);
    return 0;
  } else {
    return Number(myVar);
  }
}

function endRound() {


}

// var simData = [0, 100];
//   var hrID = window.setInterval(onDataHR(simData), 1000);

function onDataHR(data) {
  //console.log(data[1]);
  rt.hr = Number(data[1]);
  rt.score = Number((rt.hr / maxHeartRate) * 100);
  $$(".rtHR").text(rt.hr);
  $$(".rtSCORE").text(rt.score.toFixed(0) + "%");
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

// var counter = 1;
// var simCSC = [1, 1, 1, 1, 1, 1];
//
// var cscID = window.setInterval(function(){
//   $$.each(simCSC, function(val){
//     simCSC[val] = counter ;
//   });
//   simCSC[0] = 0;
//   simCSC[6] = 1;
//   simCSC[2] = 1;
//   processWheelData(simCSC);
//       counter += 3;
// }, 1000);

function processWheelData(data) {

  wheelRevolution = (data[2] * 256) + data[1];
  wheelEventTime = (data[6] * 256) + data[5] + 1.0;

  if (oldWheelRevolution === 0) {
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

    if (deltaW === 0 || deltaW > 15) {
      wheelRevolution = oldWheelRevolution;
      wheelEventTime = oldWheelEventTime;
      //velo should test, might not need to update display
      single_read_speed = 0;
      rt.speed = Number(single_read_speed.toFixed(1));
      // $$(".rtSPD").text(rt.speed);
      // $$("#blinker").text("Pull to Refresh (SPD)");
      return;
    }
    if (deltaT < 950 && deltaT > 0) {
      wheelRevolution = oldWheelRevolution;
      wheelEventTime = oldWheelEventTime;
      return;
    }

    //         //single read
    var wheelTimeSeconds = Number(deltaT / 1024);
    if (wheelTimeSeconds > 0) {
      // var wheelCircumferenceCM = wheelCircumference / 10;
      var wheelRPM = Number(deltaW / (wheelTimeSeconds / 60));
      // var cmPerMi = 0.00001 * 0.621371;
      // var minsPerHour = 60.0;
      single_read_speed = Number(wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour);
      rt.speed = Number(single_read_speed.toFixed(1));
      $$(".rtSPD").text(rt.speed.toFixed(1));
      $$("#blinker").text("Pull to Refresh (SPD)");


      if (single_read_speed > 0) {
        rt_WheelRevs += deltaW;
        rt_WheelTime += deltaT;
        total_moving_time_seconds += Number((deltaT / 1024));
        //convert to display as moving time
      }
      rounds.WheelRevs += Number(deltaW);
      rounds.Distance += Number(deltaW * wheelCircumferenceCM * cmPerMi);
      //total miles
      totalMiles = Number(rt_WheelRevs * wheelCircumferenceCM * cmPerMi);
      $$(".rtMILES").text((totalMiles).toFixed(2));
      //avg speed
      var avgSpeed = Number((rt_WheelRevs / ((rt_WheelTime / 1024) / 60)) * wheelCircumferenceCM * cmPerMi * minsPerHour);

      var date = new Date(null);
      date.setSeconds(Number(rt_WheelTime / 1024)); // specify value for SECONDS here
      var result = date.toISOString().substr(11, 8);

      $$(".rtMOVING").text(result);
      $$(".rtAVGSPD").text(avgSpeed.toFixed(1));
    } else {
      single_read_speed = 0;
      rt.speed = Number(single_read_speed.toFixed(1));
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

  if (oldCrankRevolution === 0) {
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

    if (deltaW === 0 || deltaW > 15) {
      crankRevolution = oldCrankRevolution;
      crankEventTime = oldCrankEventTime;
      //single_read_cad = 0;
      //rt.cadence = single_read_cad.toFixed(0);
      //$$(".rtCAD").text(rt.cadence);
      //$$("#blinker").text("Pull to Refresh (CAD)");
      return;
    }

    if (deltaT < 950 && deltaT > 0) {
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
    var crankTimeSeconds = Number(deltaT / 1024);
    single_read_cad = Number(deltaW / (crankTimeSeconds / 60));
    rounds.CrankRevs += deltaW;
    rt_crank_revs += deltaW;
    rt_crank_time += deltaT; //still in 1/1024 of a sec

    rt.cadence = Number(single_read_cad.toFixed(0));
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

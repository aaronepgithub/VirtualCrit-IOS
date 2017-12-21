var rt = {
  hr: 0,
  speed: 0,
  cadence: 0
};

var wheelCircumference = 2105;

function onDataHR(data) {
  //console.log(data[1]);
  rt.hr = data[1];
  $$(".rtHR").text(rt.hr);
  $$("#blinker").text("Pull to Refresh (HR)");
  $$("#iconNumber").text(rt.hr);
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

var arr_srs = [];
var arr_src = [];
var srseconds = 0;

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

    //         //single read
    var wheelTimeSeconds = deltaT / 1024;
    if (wheelTimeSeconds > 0) {
      var wheelCircumferenceCM = wheelCircumference / 10;
      var wheelRPM = deltaW / (wheelTimeSeconds / 60);
      var cmPerMi = 0.00001 * 0.621371;
      var minsPerHour = 60.0;
      single_read_speed = wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour;

      if (single_read_speed > 0) {
        rt_WheelRevs += deltaW;
        rt_WheelTime += deltaT;
        total_moving_time_seconds += (deltaT / 1024);
        //convert to display as moving time
      } else {
        single_read_speed = 0;
      }

      //total miles
      var totalMiles = rt_WheelRevs * wheelCircumferenceCM * cmPerMi;
      $$(".rtMILES").text((rt_WheelRevs * wheelCircumferenceCM * cmPerMi).toFixed(2));
      //avg speed
      var avgSpeed = (rt_WheelRevs / ((rt_WheelTime / 1024) / 60)) * wheelCircumferenceCM * cmPerMi * minsPerHour;

      var date = new Date(null);
      date.setSeconds(rt_WheelTime / 1024); // specify value for SECONDS here
      var result = date.toISOString().substr(11, 8);

      $$(".rtMOVING").text(result);
      $$(".rtAVGSPD").text(avgSpeed.toFixed(1));
      //$$(".rtMOVING_AVG").append('<div class="center">' + result + 'MVT' +  avgSpeed.toFixed(1) + 'AVG MPH </div>');

      rt.speed = single_read_speed.toFixed(1);
      $$(".rtSPD").text(rt.speed);
      $$("#blinker").text("Pull to Refresh (SPD)");

      var now = new Date();
      $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds());

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

    //single read
    var crankTimeSeconds = deltaT / 1024;
    if (crankTimeSeconds > 0) {
      single_read_cad = deltaW / (crankTimeSeconds / 60);
      if (deltaW < 10) { //filter out bad readings
        rt_crank_revs += deltaW;
        rt_crank_time += deltaT; //still in 1/1024 of a sec
      }
    } else {
      single_read_cad = 0;
    }

    rt.cadence = single_read_cad.toFixed(0);
    $$(".rtCAD").text(rt.cadence);
    $$("#blinker").text("Pull to Refresh (CAD)");
    //console.log("CAD:  " + single_read_cad);

    oldCrankRevolution = crankRevolution;
    oldCrankEventTime = crankEventTime;
  }


}

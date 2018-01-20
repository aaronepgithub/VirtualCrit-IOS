var myApp = new Framework7();

// Export selectors engine
var $$ = Dom7;

var currentTab = 0;
var currentOrientation = "";

var heartRate = {
  service: '180D',
  measurement: '2A37'
};

var speedCadence = {
  service: '1816',
  measurement: '2A5B'
};

var startTime;



// Handle Cordova Device Ready Event
$$(document).on('deviceready', function() {
  console.log("Device is ready!");
  var now = new Date();
  startTime = new Date();
  if (now.getHours() > 12) {
    $$(".TIME").text((now.getHours() - 12) + ":" + now.getMinutes() + ":" + now.getSeconds() + " PM");
  } else {
    $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + " AM");
  }
  console.log("StartTime:  " + startTime);

  $$('.forthRow').hide();
  $$('.landRow').hide();
  $$('.landRowHR').hide();
  $$('.landRowSPD').hide();
  $$('.landRowGEO').hide();
  $$('.landscapeLabels').hide();
  $$('.landscapeLabelsHR').hide();
  $$('.landscapeLabelsSPD').hide();

  var intervalID = window.setInterval(myCallback, 1000);
});

//remove
// var time = 0;
// var roundTimer = 1;


var timeSinceStartInSeconds = 0;
var totalRoundsCompleted = 0;
var timeSinceRoundStartInSeconds = 0;

//each second
function myCallback() {

  var rightNow = new Date();
  timeSinceStartInSeconds = Date.dateDiffReturnSeconds('s', startTime, rightNow);
  //console.log("timeSinceStartInSeconds:  " + timeSinceStartInSeconds);
  timeSinceRoundStartInSeconds = timeSinceStartInSeconds - (totalRoundsCompleted * secInRound);
  //console.log("timeSinceRoundStartInSeconds:  " + timeSinceRoundStartInSeconds);




  if (timeSinceStartInSeconds % secInRound === 0 && timeSinceStartInSeconds > 1) {
    console.log("Calling roundEnd, timeSinceStartInSeconds:  " + timeSinceStartInSeconds);
    totalRoundsCompleted += 1;
    console.log("RoundsCompleted:  " + totalRoundsCompleted);
    roundEnd();
  }

  //fallback
  if (timeSinceRoundStartInSeconds > 300 || timeSinceRoundStartInSeconds < 0 ) {
    console.log("Calling roundEnd fallback, timeSinceStartInSeconds:  " + timeSinceStartInSeconds);
    totalRoundsCompleted += 1;
    console.log("RoundsCompleted:  " + totalRoundsCompleted);
    roundEnd();
  }



  $$(".ACTUAL_TIME").text( "(" + (299-timeSinceRoundStartInSeconds) + ")  " + dataToDisplayString + "  " + Date.dateDiff('s', startTime, rightNow) );
  $$(".rndSec").text(300-timeSinceRoundStartInSeconds-1);


  //JUST TO DISPLAY THE TIME
  // var rightNow = new Date();
  if (rightNow.getHours() > 12) {
    if (rightNow.getMinutes() < 10) {
      $$(".TIME").text((rightNow.getHours() - 12) + ":0" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " PM");
    } else {
      $$(".TIME").text((rightNow.getHours() - 12) + ":" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " PM");
    }
  } else {
    if (rightNow.getMinutes() < 10) {
      $$(".TIME").text((rightNow.getHours()) + ":0" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " AM");
    } else {
      $$(".TIME").text((rightNow.getHours()) + ":" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " AM");
    }
  }


  //Adding a value each second
  rounds.HeartRate += rt.hr;
  interval.arrHeartRate.push(rt.hr);
  interval.arrCadence.push(Number(rt.cadence));
  interval.arrSpeed.push(Number(rt.speed));
  interval.arrDistance.push(totalMiles);

  interval.arrGeoDistance.push(geoDistanceInMiles);

  // timeSinceRoundStartInSeconds = timeSinceStartInSeconds - (totalRoundsCompleted * secInRound);
  midRound(timeSinceRoundStartInSeconds);

}


function addTl(x) {
  $$('#timelineUL').prepend('<li class="in-view"><div><time>NAME CHANGE</time>NICE TO MEET YOU,' + x + ' </div></li>');
}






$$('#NAME').on('click', function(e) {
  addTl();
  myApp.prompt('ENTER YOUR RIDER NAME', 'WELCOME', function(value) {
    //myApp.alert('Your name is "' + value + '". You clicked Ok button');
    if (value !== "") {
    $$('#NAME').find('.item-after').text(value.toUpperCase());
    name = value.toUpperCase();
    addTl(name);
    }

  });
});

$$('#MAXHR').on('click', function(e) {
  // $$(this).addClass('ani');
  $$('#MAXHR').css('color', 'darkgray');
  var current = maxHeartRate;
  if (current == 185) {
    $$(this).find('.item-after').text(190);
    maxHeartRate = 190;
  }
  if (current == 190) {
    $$(this).find('.item-after').text(195);
    maxHeartRate = 195;
  }
  if (current == 195) {
    $$(this).find('.item-after').text(200);
    maxHeartRate = 200;
  }
  if (current == 200) {
    $$(this).find('.item-after').text(205);
    maxHeartRate = 205;
  }
  if (current == 205) {
    $$(this).find('.item-after').text(185);
    maxHeartRate = 185;
  }
  setTimeout(function() {
    // $$('#MAXHR').removeClass('ani');
        $$('#MAXHR').css('color', 'white');
  }, 300);
});

var audio = "OFF";
$$('#AUDIO').on('click', function(e) {
$$('#AUDIO').css('color', 'darkgray');
  if (audio == "ON") {
    $$(this).find('.item-after').text('OFF');
    audio = "OFF";
  } else {
    $$(this).find('.item-after').text('ON');
    audio = "ON";
  }

  setTimeout(function() {
    $$('#AUDIO').css('color', 'white');
    // $$('#AUDIO').removeClass('ani');
  }, 300);

});


var activity = "BIKE";
$$('#ACTIVITY').on('click', function(e) {
$$('#ACTIVITY').css('color', 'darkgray');
  if (activity == "BIKE") {
    $$(this).find('.item-after').text('RUN');
    activity = "RUN";
    $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + 'NOW YOU ARE A RUNNER!' + ' </time></div></li>');
  } else {
    $$(this).find('.item-after').text('BIKE');
    activity = "BIKE";
        $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + 'NOW YOU ARE A BIKER!' + ' </time></div></li>');
  }

  setTimeout(function() {
    $$('#ACTIVITY').css('color', 'white');
  }, 300);

});


var geoEnabled = "NO";
$$('#GEO').on('click', function(e) {
$$('#GEO').css('color', 'darkgray');
  if (geoEnabled == "YES") {
    $$(this).find('.item-after').text('NO');
    geoEnabled = "NO";
  } else {
    $$(this).find('.item-after').text('YES');
    geoEnabled = "YES";

    startGeo();
  }

  setTimeout(function() {
    $$('#GEO').css('color', 'white');
  }, 300);

});

$$('#TIRESIZE').on('click', function(e) {
  //$$(this).addClass('ani');
  $$('#TIRESIZE').css('color', 'darkgray');
  var current = wheelCircumference;
  if (current == 2105) {
    $$(this).find('.item-after').text('700X26');
    wheelCircumference = 2115;
    wheelCircumferenceCM = wheelCircumference / 10;
  }
  if (current == 2115) {
    $$(this).find('.item-after').text('700X32');
    wheelCircumference = 2155;
    wheelCircumferenceCM = wheelCircumference / 10;
  }
  if (current == 2155) {
    $$(this).find('.item-after').text('700X25');
    wheelCircumference = 2105;
    wheelCircumferenceCM = wheelCircumference / 10;
  }
  setTimeout(function() {
    // $$('#TIRESIZE').removeClass('ani');
    $$('#TIRESIZE').css('color', 'white');
  }, 300);
});



var refreshInterval = 30;
$$('#REFRESH').on('click', function(e) {
  // $$(this).addClass('ani');
      $$('#REFRESH').css('color', 'darkgray');
  var current = refreshInterval;

  if (current == 10) {
    $$(this).find('.item-after').text('30');
    refreshInterval = 30;
  }

  if (current == 30) {
    $$(this).find('.item-after').text('60');
    refreshInterval = 60;
  }

  if (current == 60) {
    $$(this).find('.item-after').text('300');
    refreshInterval = 300;

  }

  if (current == 300) {
    $$(this).find('.item-after').text('10');
    refreshInterval = 10;
  }

  setTimeout(function() {
    $$('#REFRESH').css('color', 'white');
    // $$('#REFRESH').removeClass('ani');
  }, 300);
});


$$('#RESTART').on('click', function(e) {

  $$('#RESTART').css('color', 'darkgray');
  console.log("RESTART");

  console.log("arrPeripherals restart");
  arrPeripherals.forEach(function(element) {
    // console.log('element:  ' + element);
    console.log('element.id:  ' + element.id);
    console.log('element.name:  ' + element.name);
  });


  console.log("arrConnectedPeripherals  " + arrConnectedPeripherals);
  console.log("arrConnectedPeripheralsNames  " + arrConnectedPeripheralsNames);
  console.log("arrDisconnectedIDs  " + arrDisconnectedIDs);
  console.log("arrDisconnectedNames  " + arrDisconnectedNames);


    arrConnectedPeripheralsHR.forEach(function(h) {
      ble.stopNotification(h, heartRate.service, heartRate.measurement, function() {
        console.log(h + " hr stop notify success");
        ble.disconnect(h, function() {
          console.log(h + " disconnect success");
        }, function() {
          console.log(h +   "  disconnect failed");
        });
      }, function() {
        console.log(h +   "  hr stop notify failed");
      });
    });

    arrConnectedPeripheralsCSC.forEach(function(c) {
      ble.stopNotification(c, speedCadence.service, speedCadence.measurement, function() {
        console.log(c + " csc stop notify success");
        ble.disconnect(c, function() {
          console.log(c + " csc disconnect success");
        }, function() {
          console.log(c +   "  csc disconnect failed");
        });
      }, function() {
        console.log(c +   "  csc stop notify failed");
      });
    });


  $$('.chip-media').css('color', 'white');

  setTimeout(function() {
    // $$('#RESTART').removeClass('ani');
    $$('#RESTART').css('color', 'white');
  }, 300);

});  //end restart





var arrPeripherals = [];
var y = [];

//ios version
function scan() {
  //remove all chips
  // arrPeripherals = [];
  // $$('.blechip').remove();

  function onScan(peripheral) {
    myApp.pullToRefreshDone();

    var shouldReturn = 0;

    arrPeripherals.forEach(function(element) {
      if (peripheral.id == element.id) {
        shouldReturn = 1;
        console.log("Duplicate"); //check all with for each
      }
    });
    if (shouldReturn == 1) {
      console.log("return");
      return;
    }

    console.log("Found " + JSON.stringify(peripheral) + "\n");
    if (peripheral.name === undefined) {
      console.log("undefined");
      return;
    }

    if (arrPeripherals.length === 0) { //knowing that I am going to add one now
      $$('.blechip').remove();
    }

    arrPeripherals.push(peripheral);
    $$('.blelist').append('<div id="blechip" class="chip-added chip chip-extended blechip"><div class="chip-media bg-blue">' + (arrPeripherals.length - 1) + '</div><div class="chip-label">' + peripheral.name + '</div>' + '</div><div class="chip-uuid">' + peripheral.id + '</div>');

  }

  function scanFailure(reason) {
    console.log("scanFailure" + reason);
  }

  console.log("scanning");
  ble.scan([], 5, onScan, scanFailure);

}

// Pull to refresh content
var ptrContent = $$('.pull-to-refresh-content');

// Add 'refresh' listener on it
ptrContent.on('ptr:refresh', function(e) {

  // //remove all chips
  // arrPeripherals = [];
  // $$('.blechip').remove();

  scan();

  setTimeout(function() {
    myApp.pullToRefreshDone();

    //console.log(JSON.stringify(arrPeripherals));
    console.log("Scan Complete");
  }, 5000);
});


var arrConnectedPeripherals = [];
var arrConnectedPeripheralsNames = [];
var arrConnectedPeripheralsService = [];
var arrConnectedPeripheralsChar = [];
var arrDisconnectedIDs = [];
var arrDisconnectedNames = [];
var arrConnectedPeripheralsCSC = [];
var arrConnectedPeripheralsHR = [];


function connect(peripheral) {


  function onConnect() {

    var serviceType = "none";

    console.log(peripheral.id + " " + peripheral.name + "  connected");
    var x = peripheral.id;

    var y = [];
    //phonegap plugin add cordova-plugin-device
    var devicePlatform = device.platform;
    if (devicePlatform == "iOS") {
      //ios specific start
      y = peripheral.advertising.kCBAdvDataServiceUUIDs; //array of service uuids
      //console.log("Advertising:  " + y);
      //ios specific end
    } else {

      // android start
      var z = translate_advertisement(peripheral);
      y = [];

      peripheral.advertisement.serviceUuids.forEach(function(element) {
        if (element == "18D") {
          y.push("180D");
        }
        if (element == "1816") {
          y.push("1816");
        }
      });
      //android end
    }


    y.forEach(function(element) {
      if (element == "180D") {
        console.log(peripheral.id + " " + peripheral.name + "  Identified as HR, calling Notify");
        serviceType = "180D";
        serviceChar = heartRate.measurement;
        arrConnectedPeripherals.push(peripheral.id);
        arrConnectedPeripheralsNames.push(peripheral.name);
        arrConnectedPeripheralsService.push(serviceType);
        arrConnectedPeripheralsChar.push(serviceChar);
        arrConnectedPeripheralsHR.push(peripheral.id);
        ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
          var data = new Uint8Array(buffer);
          onDataHR(data);
        }, function(reason) {
          console.log(peripheral.id + " " + peripheral.name + " start notify failure " + reason);
        });
      }
    });


    y.forEach(function(element) {
      if (element == "1816") {
        console.log(peripheral.id + " " + peripheral.name +  "Identified as CSC, calling Notify");
        serviceType = "1816";
        serviceChar = speedCadence.measurement;
        arrConnectedPeripherals.push(peripheral.id);
        arrConnectedPeripheralsNames.push(peripheral.name);
        arrConnectedPeripheralsCSC.push(peripheral.id);
        arrConnectedPeripheralsService.push(serviceType);
        arrConnectedPeripheralsChar.push(serviceChar);
        ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
          var data = new Uint8Array(buffer);
          onDataCSC(data);
        }, function(reason) {
          console.log(peripheral.id + " " + peripheral.name + " notify failure" + reason);
        });
      }
    });

  } //end onConnect

  function onDisconnect(peripheral) {
    console.log(peripheral.id + " " + peripheral.name + " onDisconnect");
    $$("#blinker").text("DISCONNECT:  " + peripheral.name);
    arrDisconnectedIDs.push(peripheral.id);
    arrDisconnectedNames.push(peripheral.name);

    console.log("arrPeripherals onDisconnect");


    arrPeripherals.forEach(function(element) {
      console.log('element.id:  ' + element.id);
      console.log('element.name:  ' + element.name);
    });

    console.log("od arrConnectedPeripherals  " + arrConnectedPeripherals);
    console.log("od arrConnectedPeripheralsNames  " + arrConnectedPeripheralsNames);
    console.log("od arrDisconnectedIDs  " + arrDisconnectedIDs);
    console.log("od arrDisconnectedNames  " + arrDisconnectedNames);

    rt.speed = 0;
    displaySPD();
    rt.cadence = 0;
    displayCAD();
    rt.hr = 0;
    rt.score = 0;
    displayHR();


    ble.connect(peripheral.id, onConnect, onDisconnect);

  }

  ble.connect(peripheral.id, onConnect, onDisconnect);
}

$$('.blelist').on('touchstart', '#blechip', function(e) {

  myApp.showIndicator();
  setTimeout(function() {
    myApp.hideIndicator();
  }, 1500);

  e.preventDefault();
  var chipUUID;

  var chipname = $$(this).find('.chip-label').text();
  var chipIndex = $$(this).find('.chip-media').text();
  if (arrPeripherals.length > 0) {
    chipUUID = arrPeripherals[chipIndex].id;
  }


  $$(this).find('.chip-media').css('color', 'red');
  // $$(this).find('.chip-label').css('color', 'red');
  console.log(chipname);
  console.log(chipIndex);
  console.log(chipUUID);
  if (arrPeripherals.length > 0) {
    connect(arrPeripherals[chipIndex]);
    //call to connect
  }


});

$$('#view-4').on('tab:show', function() {
  // myApp.alert('Tab/View 4 is visible');
  currentTab = 4;
  //console.log(currentTab);
});

$$('#view-3').on('tab:show', function() {
  // myApp.alert('Tab/View 3 is visible');
  currentTab = 3;
  //console.log(currentTab);
});

$$('#view-2').on('tab:show', function() {
  // myApp.alert('Tab/View 2 is visible');
  currentTab = 2;
  // $$(".iconNumber").text("00");
  //console.log(currentTab);
});
$$('#view-1').on('tab:show', function() {
  // myApp.alert('Tab/View 2 is visible');
  currentTab = 1;
  //console.log(currentTab);
});



translate_advertisement = function(peripheral) {
  var advertising = peripheral.advertising;

  // common advertisement interface is created as a new field
  //  This format follows the nodejs BLE library, noble
  //  https://github.com/sandeepmistry/noble#peripheral-discovered
  peripheral.advertisement = {
    localName: undefined,
    txPowerLevel: undefined,
    manufacturerData: undefined,
    serviceUuids: [],
    serviceData: [],
    channel: undefined, // ios only
    isConnectable: undefined, // ios only
    flags: undefined, // android only
  };

  // we are on android
  var scanRecord = new Uint8Array(advertising);
  var index = 0;
  while (index < scanRecord.length) {
    // first is length of the field, length of zero indicates advertisement
    //  is complete
    var length = scanRecord[index++];
    if (length === 0) {
      break;
    }

    // next is type of field and then field data (if any)
    var type = scanRecord[index];
    var data = scanRecord.subarray(index + 1, index + length);

    // determine data based on field type
    switch (type) {
      case 0x01: // Flags
        peripheral.advertisement.flags = data[0] & 0xFF;
        break;

      case 0x02: // Incomplete List of 16-Bit Service UUIDs
      case 0x03: // Complete List of 16-Bit Service UUIDs
        for (var n = 0; n < data.length; n += 2) {
          peripheral.advertisement.serviceUuids.push(uuid(data.subarray(n, n + 2)));
          console.log("serviceUuid:  " + peripheral.advertisement.serviceUuids[peripheral.advertisement.serviceUuids.length - 1]);
        }
        break;

      case 0x04: // Incomplete List of 32-Bit Service UUIDs
      case 0x05: // Complete List of 32-Bit Service UUIDs
        for (var n1 = 0; n1 < data.length; n1 += 4) {
          peripheral.advertisement.serviceUuids.push(uuid(data.subarray(n1, n1 + 4)));
          console.log("serviceUuid:  " + peripheral.advertisement.serviceUuids[peripheral.advertisement.serviceUuids.length - 1]);
        }
        break;

      case 0x06: // Incomplete List of 128-Bit Service UUIDs
      case 0x07: // Complete List of 128-Bit Service UUIDs
        for (var n2 = 0; n2 < data.length; n2 += 16) {
          peripheral.advertisement.serviceUuids.push(uuid(data.subarray(n2, n2 + 16)));
          console.log("serviceUuid:  " + peripheral.advertisement.serviceUuids[peripheral.advertisement.serviceUuids.length - 1]);
        }
        break;

      case 0x08: // Short Local Name
      case 0x09: // Complete Local Name
        peripheral.advertisement.localName = String.fromCharCode.apply(null, data);
        break;

      case 0x0A: // TX Power Level
        peripheral.advertisement.txPowerLevel = data[0] & 0xFF;
        break;

      case 0x16: // Service Data
        peripheral.advertisement.serviceData.push({
          uuid: uuid(data.subarray(0, 2)),
          data: new Uint8Array(data.subarray(2)),
        });
        break;

      case 0xFF: // Manufacturer Specific Data
        peripheral.advertisement.manufacturerData = new Uint8Array(data);
        break;
    }

    // move to next advertisement field
    index += length;
  }
};

// convert an array of bytes representing a UUID into a hex string
//    Note that all arrays need to be reversed before presenting to the user
uuid = function(id) {
  if (id.length == 16) {
    // 128-bit UUIDs should be formatted specially
    return hex(id.subarray(12, 16)) + '-' +
      hex(id.subarray(10, 12)) + '-' +
      hex(id.subarray(8, 10)) + '-' +
      hex(id.subarray(6, 8)) + '-' +
      hex(id.subarray(0, 6));

  } else {
    console.log("hex(id):  " + hex(id));
    return hex(id);
  }
};

// convert an array of bytes into hex data
//    assumes data needs to be in reverse order
hex = function(byte_array) {
  var hexstr = '';
  for (var i = (byte_array.length - 1); i >= 0; i--) {
    hexstr += byte_array[i].toString(16).toUpperCase();
  }
  return hexstr;
};

function displayHR() {
  $$(".e3").text(rt.hr.toFixed(0));
  $$(".e18").text(rt.score.toFixed(0) + "%");
  $$(".e11").text(rounds.avgHeartRate.toFixed(0));
  $$(".e20").text(rounds.avgScore.toFixed(0) + "%");
  $$(".e7").text(interval.avgHeartRate.toFixed(0));
  $$(".e19").text(interval.avgScore.toFixed(0) + "%");

  if (dataToDisplay == "CURRENT") {
    $$(".rtHR").text(rt.hr.toFixed(0));
    $$(".rtSCORE").text(rt.score.toFixed(0) + "%");
    $$(".labHR").html("HR<br>"+rt.score.toFixed(0) + "%");
    $$(".headerStatus").text(dataToDisplay);

  }
  if (dataToDisplay == "ROUND") {
    $$(".rtHR").text(rounds.avgHeartRate.toFixed(0));
    $$(".rtSCORE").text(rounds.avgScore.toFixed(0) + "%");
    $$(".labHR").html("HR<br>"+rounds.avgScore.toFixed(0) + "%");

  }
  if (dataToDisplay == "INTERVAL") {
    $$(".rtHR").text(interval.avgHeartRate.toFixed(0));
    $$(".rtSCORE").text(interval.avgScore.toFixed(0) + "%");
    $$(".labHR").html("HR<br>"+interval.avgScore.toFixed(0) + "%");


  }
}

function displaySPD() {
  if (dataToDisplay == "CURRENT" && geoEnabled == "NO") {
    $$(".rtSPD").text(rt.speed.toFixed(1));

  }
  if (geoEnabled == "YES" && dataToDisplay == "CURRENT" && !isNaN(rt.geoSpeed) && rt.geoSpeed >= 0) {
    $$(".rtSPD").text(rt.geoSpeed.toFixed(1));

  }

  if (dataToDisplay == "ROUND" && geoEnabled == "NO") {
    $$(".rtSPD").text(rounds.avgSpeed.toFixed(1));

  }

  if (dataToDisplay == "ROUND" && geoEnabled == "YES"  && !isNaN(rt.geoSpeed) ) {
    $$(".rtSPD").text(rounds.avgGeoSpeed.toFixed(1));

  }

  if (dataToDisplay == "INTERVAL" && geoEnabled == "NO") {
    $$(".rtSPD").text(interval.avgSpeed.toFixed(1));

  }

  if (dataToDisplay == "INTERVAL" && geoEnabled == "YES"  && !isNaN(rt.geoSpeed) ) {
    $$(".rtSPD").text(interval.avgGeoSpeed.toFixed(1));

  }
  $$(".e1").text(rt.speed.toFixed(1));
  $$(".e4").text(rt.geoSpeed.toFixed(1));
  $$(".e9").text(rounds.avgSpeed.toFixed(1));
  $$(".e12").text(rounds.avgGeoSpeed.toFixed(1));
  $$(".e5").text(interval.avgSpeed.toFixed(1));
  $$(".e7").text(interval.avgGeoSpeed.toFixed(1));

}

function displayCAD() {

  $$(".e2").text(rt.cadence.toFixed(0));
  $$(".e10").text(rounds.avgCadence.toFixed(0));
  $$(".e6").text(interval.avgCadence.toFixed(0));

  if (activity == "RUN") {
    $$(".rtCAD").text(rt.geoPace.toFixed(1));
    $$(".labCAD").text('PACE');
  } else {

    if (dataToDisplay == "CURRENT") {
      $$(".rtCAD").text(rt.cadence.toFixed(0));
    }
    if (dataToDisplay == "ROUND") {
      $$(".rtCAD").text(rounds.avgCadence.toFixed(0));
    }
    if (dataToDisplay == "INTERVAL") {
      $$(".rtCAD").text(interval.avgCadence.toFixed(0));
    }

  }
}

function animateDataChange() {
  $$('[class*="col-"]').css({
    color: 'darkgray'
  });

  setTimeout(function() {
    $$('[class*="col-"]').css({
      color: 'white'
    });
  }, 200);



}

var dataToDisplay = "CURRENT";
var dataToDisplayString = "";

function changeDataToDisplay() {
  animateDataChange();
  var x = dataToDisplay;

  if (x == "CURRENT") {
    dataToDisplay = "INTERVAL";
    dataToDisplayString = "INTERVAL";
    // $$(".headerStatus").text(dataToDisplay);
  }



  if (x == "INTERVAL") {
    dataToDisplay = "ROUND";
    dataToDisplayString = " CRIT ";
    // $$(".headerStatus").text(dataToDisplay);
  }


  if (x == "ROUND") {
    dataToDisplay = "CURRENT";
    dataToDisplayString = "";
    // $$(".headerStatus").text(dataToDisplay);
  }

}



var displayDataOption = 0;
$$('#view3pagecontent').on('click', function(e) {
  console.log("#view3pagecontent clicked");
  changeDataToDisplay();
});

$$('.firstRow').addClass('row-bottom-border');
$$('.secondRow').addClass('row-bottom-border');


var page3info = 0;
var landToggle = 0;

// $$('#view3nav').on('click', function(e) {
//   console.log("view3nav clicked");
//   var x = landToggle;
//   if (currentOrientation == "portrait") {
//     return;
//   } else {
//     if (x === 0) {
//       $$('.landRow').hide();
//       $$('.landscapeLabels').hide();
//       $$('.landRowSPD').hide();
//       $$('.landscapeLabelsSPD').hide();
//       $$('.landRowHR').show();
//       $$('.landscapeLabelsHR').show();
//       landToggle += 1;
//     }
//
//     if (x === 1) {
//       $$('.landRow').hide();
//       $$('.landRowHR').hide();
//       $$('.landRowSPD').show();
//       $$('.landscapeLabels').hide();
//       $$('.landscapeLabelsSPD').show();
//       $$('.landscapeLabelsHR').hide();
//       landToggle += 1;
//     }
//
//     if (x === 2) {
//       $$('.landRowSPD').hide();
//       $$('.landRowHR').hide();
//       $$('.landRow').show();
//       $$('.landscapeLabels').show();
//       $$('.landscapeLabelsSPD').hide();
//       $$('.landscapeLabelsHR').hide();
//       landToggle = 0;
//     }
//   }  //end of if-landscape
//
// });

function ifLandscapeSwipe() {
  var x = landToggle;
  console.log("ifLandscapeSwipe");
  if (x === 0) {
    $$('.landRow').hide();
    $$('.landscapeLabels').hide();
    $$('.landRowSPD').hide();
    $$('.landscapeLabelsSPD').hide();
    $$('.landRowHR').show();
    $$('.landscapeLabelsHR').show();
    landToggle += 1;
  }

  if (x === 1) {
    $$('.landRow').hide();
    $$('.landRowHR').hide();
    $$('.landRowSPD').show();
    $$('.landscapeLabels').hide();
    $$('.landscapeLabelsSPD').show();
    $$('.landscapeLabelsHR').hide();
    landToggle += 1;
  }

  if (x === 2) {
    $$('.landRowSPD').hide();
    $$('.landRowHR').hide();
    $$('.landRow').show();
    $$('.landscapeLabels').show();
    $$('.landscapeLabelsSPD').hide();
    $$('.landscapeLabelsHR').hide();
    landToggle = 0;
  }

}

function aSwipe() {
  console.log("aSwipe");

  if (currentOrientation == "landscape") {
    ifLandscapeSwipe();
    return;
  }
  console.log("Portrait Swipe");
  animateDataChange();
  console.log("#view3nav clicked, current p3info:  " + page3info);
  var currentPage = page3info;
  if (currentPage === 0) {
    $$('.firstRow').hide();
    $$('.rtCAD').removeClass('smallFont');
    $$('.rtCAD').addClass('bigFont');

    page3info = 1;
    console.log("page3info:  " + page3info);
  }
  if (currentPage == 1) {
    $$('.firstRow').show();
    $$('.rtHR').removeClass('smallFont');
    $$('.rtHR').addClass('bigFont');
    $$('.secondRow').hide(); //spd
    $$('.thirdRow').hide(); //cad
    $$('.rtCAD').removeClass('smallFont');
    $$('.rtCAD').addClass('bigFont');
    $$('.forthRow').show(); //already has bigfont
    page3info = 2;
    console.log("page3info:  " + page3info);
  }
  if (currentPage == 2) {
    //back to all start
    $$('.rtHR').removeClass('bigFont');
    $$('.rtHR').addClass('smallFont');
    $$('.secondRow').show();
    $$('.rtCAD').removeClass('bigFont');
    $$('.rtCAD').addClass('smallFont');
    $$('.thirdRow').show(); //cad
    $$('.forthRow').hide();
    page3info = 0;
    console.log("page3info:  " + page3info);
  }
}
detectswipe('view3pagecontent', aSwipe);

var mql = window.matchMedia("(orientation: portrait)");
//Add a media query change listener

mql.addListener(function(m) {
  if (m.matches) {
    console.log("portrait");
    currentOrientation = "portrait";
    $$('.landRow').hide();
    $$('.landRowHR').hide();
    $$('.landRowSPD').hide();
    $$('.landscapeLabels').hide();
    $$('.landscapeLabelsHR').hide();
    $$('.landscapeLabelsSPD').hide();
    if (page3info === 1) {
      //show only SPD/CAD
      $$('.firstRow').hide();
      $$('.secondRow').show();
      $$('.thirdRow').show();
      $$('.forthRow').hide();
      $$('.rtCAD').removeClass('smallFont');
      $$('.rtCAD').addClass('bigFont');
    }
    if (page3info == 2) {
      //show only hr/score
      $$('.firstRow').show();
      $$('.rtHR').removeClass('smallFont');
      $$('.rtHR').addClass('bigFont');
      $$('.secondRow').hide(); //spd
      $$('.thirdRow').hide(); //cad
      $$('.rtCAD').removeClass('smallFont');
      $$('.rtCAD').addClass('bigFont');
      $$('.forthRow').show(); //already has bigfont
    }
    if (page3info === 0) {
      //back to all start
      $$('.rtHR').removeClass('bigFont');
      $$('.rtHR').addClass('smallFont');
      $$('.firstRow').show();
      $$('.secondRow').show();
      $$('.rtCAD').removeClass('bigFont');
      $$('.rtCAD').addClass('smallFont');
      $$('.thirdRow').show(); //cad
      $$('.forthRow').hide();
    }



  } else {
    console.log("landscape");
    currentOrientation = "landscape";
    $$('.firstRow').hide();
    $$('.secondRow').hide();
    $$('.thirdRow').hide();
    $$('.forthRow').hide();
    $$('.landRow').show();
    $$('.landRow').addClass('smallerFont');
    $$('.landRowHR').hide();
    $$('.landRowSPD').hide();
    $$('.landscapeLabelsHR').hide();
    $$('.landscapeLabelsSPD').hide();
    $$('.landscapeLabels').show();

  }
});


// Add views
var view1 = myApp.addView('#view-1');
var view2 = myApp.addView('#view-2', {
  // Because we use fixed-through navbar we can enable dynamic navbar
  dynamicNavbar: true
});
var view3 = myApp.addView('#view-3');
var view4 = myApp.addView('#view-4');




function detectswipe(el, func) {
  // swipe_det = new Object();
    swipe_det = {};
  swipe_det.sX = 0;
  swipe_det.sY = 0;
  swipe_det.eX = 0;
  swipe_det.eY = 0;
  var min_x = 30; //min x swipe for horizontal swipe
  var max_x = 30; //max x difference for vertical swipe
  var min_y = 50; //min y swipe for vertical swipe
  var max_y = 60; //max y difference for horizontal swipe
  var direc = "";
  ele = document.getElementById(el);
  ele.addEventListener('touchstart', function(e) {
    var t = e.touches[0];
    swipe_det.sX = t.screenX;
    swipe_det.sY = t.screenY;
  }, false);
  ele.addEventListener('touchmove', function(e) {
    e.preventDefault();
    var t = e.touches[0];
    swipe_det.eX = t.screenX;
    swipe_det.eY = t.screenY;
  }, false);
  ele.addEventListener('touchend', function(e) {
    //horizontal detection
    if ((((swipe_det.eX - min_x > swipe_det.sX) || (swipe_det.eX + min_x < swipe_det.sX)) && ((swipe_det.eY < swipe_det.sY + max_y) && (swipe_det.sY > swipe_det.eY - max_y) && (swipe_det.eX > 0)))) {
      if (swipe_det.eX > swipe_det.sX) direc = "r";
      else direc = "l";
    }
    //vertical detection
    else if ((((swipe_det.eY - min_y > swipe_det.sY) || (swipe_det.eY + min_y < swipe_det.sY)) && ((swipe_det.eX < swipe_det.sX + max_x) && (swipe_det.sX > swipe_det.eX - max_x) && (swipe_det.eY > 0)))) {
      if (swipe_det.eY > swipe_det.sY) direc = "d";
      else direc = "u";
    }

    if (direc !== "") {
      if (typeof func == 'function') func(el, direc);
    }
    direc = "";
    swipe_det.sX = 0;
    swipe_det.sY = 0;
    swipe_det.eX = 0;
    swipe_det.eY = 0;
  }, false);

}

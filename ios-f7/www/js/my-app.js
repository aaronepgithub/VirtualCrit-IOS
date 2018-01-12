var myApp = new Framework7();

// Export selectors engine
var $$ = Dom7;

var currentTab = 0;
var currentOrientation = "";

var heartRate = {
  service: '180d',
  measurement: '2a37'
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
  var intervalID = window.setInterval(myCallback, 1000);
});

//remove
// var time = 0;
// var roundTimer = 1;
$$('.forthRow').hide();
$$('.landRow').hide();
$$('.landscapeLabels').hide();

var timeSinceStartInSeconds = 0;
var totalRoundsCompleted = 0;
var timeSinceRoundStartInSeconds = 0;

//each second
function myCallback() {

  var rightNow = new Date();
  timeSinceStartInSeconds = Date.dateDiffReturnSeconds('s', startTime, rightNow);
  //console.log("timeSinceStartInSeconds:  " + timeSinceStartInSeconds)

  if (timeSinceStartInSeconds % secInRound === 0 && timeSinceStartInSeconds > 1) {
    console.log("Calling roundEnd, timeSinceStartInSeconds:  " + timeSinceStartInSeconds);
    totalRoundsCompleted += 1;
    console.log("RoundsCompleted:  " + totalRoundsCompleted);
    roundEnd();
  }

  $$(".ACTUAL_TIME").text(Date.dateDiff('s', startTime, rightNow) + "  " + dataToDisplay);

  //JUST TO DISPLAY THE TIME
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

  timeSinceRoundStartInSeconds = timeSinceStartInSeconds - (totalRoundsCompleted * secInRound);
  midRound(timeSinceRoundStartInSeconds);

}


$$('#NAME').on('click', function(e) {
  myApp.prompt('What is your name?', 'WELCOME', function(value) {
    //myApp.alert('Your name is "' + value + '". You clicked Ok button');
    $$('#NAME').find('.item-after').text(value);
    name = value;
  });
});

$$('#MAXHR').on('click', function(e) {
  $$(this).addClass('ani');
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
    $$('#MAXHR').removeClass('ani');
  }, 300);
});

var audio = "OFF";
$$('#AUDIO').on('click', function(e) {
  $$(this).addClass('ani');

  if (audio == "ON") {
    $$(this).find('.item-after').text('OFF');
    audio = "OFF";
  } else {
    $$(this).find('.item-after').text('ON');
    audio = "ON";
  }

  setTimeout(function() {
    $$('#AUDIO').removeClass('ani');
  }, 300);

});

$$('#TIRESIZE').on('click', function(e) {
  $$(this).addClass('ani');
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
    $$('#TIRESIZE').removeClass('ani');
  }, 300);
});



var refreshInterval = 30;
$$('#REFRESH').on('click', function(e) {
  $$(this).addClass('ani');
  var current = refreshInterval;

  if (current == 30) {
    $$(this).find('.item-after').text('60');
    refreshInterval = 60;
  }

  if (current == 60) {
    $$(this).find('.item-after').text('300');
    refreshInterval = 300;
    secInRound = 30;
  }

  if (current == 300) {
    $$(this).find('.item-after').text('30');
    refreshInterval = 30;
  }

  setTimeout(function() {
    $$('#REFRESH').removeClass('ani');
  }, 300);
});


var h1;
var h = 0;
$$('#RESTART').on('click', function(e) {
  h1 = h;
  $$(this).addClass('ani');
  console.log("RESTART");

  // var x = $$(".speedRow");
  // if (h1==0) {
  //   x.hide();
  //   h = 1;
  // }
  // if (h1 == 1) {
  //   x.show();
  //   h = 0;
  // }

  arrConnectedPeripherals.forEach(function(element) {
    ble.disconnect(element, function() {
      console.log("disconnect success");
    }, function() {
      console.log("disconnect failed");
    });
  });
  $$('.chip-media').css('color', 'white');
  $$('.chip-label').css('color', 'white');

  setTimeout(function() {
    $$('#RESTART').removeClass('ani');
  }, 300);

});





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
var arrConnectedPeripheralsService = [];
var arrConnectedPeripheralsChar = [];

function connect(peripheral) {


  function onConnect() {

    var serviceType = "none";

    console.log("connected");
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
        console.log("Identified as HR, calling Notify");
        serviceType = "180D";
        serviceChar = heartRate.measurement;
        arrConnectedPeripherals.push(peripheral.id);
        arrConnectedPeripheralsService.push(serviceType);
        arrConnectedPeripheralsChar.push(serviceChar);
        ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
          var data = new Uint8Array(buffer);
          onDataHR(data);
        }, function(reason) {
          console.log("failure" + reason);
        });
      }
    });


    y.forEach(function(element) {
      if (element == "1816") {
        console.log("Identified as CSC, calling Notify");
        serviceType = "1816";
        serviceChar = speedCadence.measurement;
        arrConnectedPeripherals.push(peripheral.id);
        arrConnectedPeripheralsService.push(serviceType);
        arrConnectedPeripheralsChar.push(serviceChar);
        ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
          var data = new Uint8Array(buffer);
          onDataCSC(data);
        }, function(reason) {
          console.log("failure" + reason);
        });
      }
    });

  } //end onConnect

  function onDisconnect(peripheral) {
    console.log("onDisconnect:  " + peripheral.name);
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
  $$(this).find('.chip-label').css('color', 'red');
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
  if (dataToDisplay == "CURRENT") {
    $$(".rtHR").text(rt.hr.toFixed(0));
    $$(".rtSCORE").text(rt.score.toFixed(0) + "%");
    //$$(".headerRow").html('CURRENT &nbsp&nbsp<span class="ACTUAL_TIME"></span>');
    $$(".headerStatus").text(dataToDisplay);
  }
  if (dataToDisplay == "ROUND") {
    $$(".rtHR").text(rounds.avgHeartRate.toFixed(0));
    $$(".rtSCORE").text(rounds.avgScore.toFixed(0) + "%");
    //$$(".headerRow").html('ROUND &nbsp&nbsp<span class="ACTUAL_TIME"></span>');
  }
  if (dataToDisplay == "INTERVAL") {
    $$(".rtHR").text(interval.avgHeartRate.toFixed(0));
    $$(".rtSCORE").text(interval.avgScore.toFixed(0) + "%");
    //$$(".headerRow").html('INTERVAL &nbsp&nbsp<span class="ACTUAL_TIME"></span>');
  }
}

function displaySPD() {
  if (dataToDisplay == "CURRENT") {
    $$(".rtSPD").text(rt.speed.toFixed(1));
    //$$(".headerRow").html('CURRENT &nbsp&nbsp<span class="ACTUAL_TIME"></span>');

  }
  if (dataToDisplay == "ROUND") {
    $$(".rtSPD").text(rounds.avgSpeed.toFixed(1));
    //$$(".headerRow").html('ROUND &nbsp&nbsp<span class="ACTUAL_TIME"></span>');

  }
  if (dataToDisplay == "INTERVAL") {
    $$(".rtSPD").text(interval.avgSpeed.toFixed(1));
    //$$(".headerRow").html('INTERVAL &nbsp&nbsp<span class="ACTUAL_TIME"></span>');

  }
}

function displayCAD() {
  if (dataToDisplay == "CURRENT") {
    $$(".rtCAD").text(rt.cadence.toFixed(0));
    //$$(".headerRow").html('CURRENT &nbsp&nbsp<span class="ACTUAL_TIME"></span>');

  }
  if (dataToDisplay == "ROUND") {
    $$(".rtCAD").text(rounds.avgCadence.toFixed(0));
    //$$(".headerRow").html('ROUND &nbsp&nbsp<span class="ACTUAL_TIME"></span>');

  }
  if (dataToDisplay == "INTERVAL") {
    $$(".rtCAD").text(interval.avgCadence.toFixed(0));
    //$$(".headerRow").html('INTERVAL &nbsp&nbsp<span class="ACTUAL_TIME"></span>');

  }
}

function animateDataChange() {
  $$('[class*="col-"]').css({
    color: 'darkgray'
  });

  setTimeout(function() {
    $$('[class*="col-"]').css({
      color: '#000'
    });
  }, 200);



}

var dataToDisplay = "CURRENT";

function changeDataToDisplay() {
  animateDataChange();
  var x = dataToDisplay;

  if (x == "CURRENT") {
    dataToDisplay = "INTERVAL";
    // $$(".headerStatus").text(dataToDisplay);
  }



  if (x == "INTERVAL") {
    dataToDisplay = "ROUND";
    // $$(".headerStatus").text(dataToDisplay);
  }


  if (x == "ROUND") {
    dataToDisplay = "CURRENT";
    // $$(".headerStatus").text(dataToDisplay);
  }

}


//var displayDataOption = 0;
$$('#view3pagecontent').on('click', function(e) {
  console.log("#view3pagecontent clicked");
  changeDataToDisplay();

});

$$('.firstRow').addClass('row-bottom-border');
$$('.secondRow').addClass('row-bottom-border');


var page3info = 0;
$$('#view3nav').on('click', function(e) {
  animateDataChange();
  console.log("#view3nav clicked, current p3info:  " + page3info);
  var currentPage = page3info;
  if (currentPage === 0) {
    //$$('#view3pagecontent').html(page3option4);
    //show only SPD/CAD
    $$('.firstRow').hide();
    $$('.rtCAD').removeClass('smallFont');
    $$('.rtCAD').addClass('bigFont');

    page3info = 1;
    console.log("page3info:  " + page3info);
  }
  if (currentPage == 1) {
    //$$('#view3pagecontent').html(page3option5);
    //show only hr/score
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
    //$$('#view3pagecontent').html(page3option3);
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
});

function aSwipe() {
  console.log("a Swipe");
  animateDataChange();
  console.log("#view3nav clicked, current p3info:  " + page3info);
  var currentPage = page3info;
  if (currentPage === 0) {
    //$$('#view3pagecontent').html(page3option4);
    //show only SPD/CAD
    $$('.firstRow').hide();
    $$('.rtCAD').removeClass('smallFont');
    $$('.rtCAD').addClass('bigFont');

    page3info = 1;
    console.log("page3info:  " + page3info);
  }
  if (currentPage == 1) {
    //$$('#view3pagecontent').html(page3option5);
    //show only hr/score
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
    //$$('#view3pagecontent').html(page3option3);
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
    $$('.landscapeLabels').hide();
    if (page3info === 1) {
      //$$('#view3pagecontent').html(page3option4);
      //show only SPD/CAD
      $$('.firstRow').hide();
      $$('.secondRow').show();
      $$('.thirdRow').show();
      $$('.forthRow').hide();
      $$('.rtCAD').removeClass('smallFont');
      $$('.rtCAD').addClass('bigFont');
    }
    if (page3info == 2) {
      //$$('#view3pagecontent').html(page3option5);
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
    if (page3info == 0) {
      //$$('#view3pagecontent').html(page3option3);
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

    // $$('.firstRow').show();
    // $$('.rtHR').addClass('smallFont');
    // $$('.secondRow').show(); //spd
    // $$('.thirdRow').show();  //cad
    // $$('.rtCAD').removeClass('bigFont');
    // $$('.rtCAD').addClass('smallFont');
    // $$('.forthRow').hide(); //already has bigfont
    // page3info = 2;
    // console.log("page3info:  " + page3info);



  } else {
    console.log("landscape");
    currentOrientation = "landscape";
    $$('.firstRow').hide();
    $$('.secondRow').hide();
    $$('.thirdRow').hide();
    $$('.forthRow').hide();
    $$('.landRow').show();
    $$('.landRow').addClass('smallerFont');
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
  swipe_det = new Object();
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

    if (direc != "") {
      if (typeof func == 'function') func(el, direc);
    }
    direc = "";
    swipe_det.sX = 0;
    swipe_det.sY = 0;
    swipe_det.eX = 0;
    swipe_det.eY = 0;
  }, false);

}

//CURRENT
// var page3option3 = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em"><span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt">HR<br></div>' +
//   '<div class="col-90 rtHR" style="font-size: 6em"></div>' +
//   // '<div class="col-10" style="font-size: 1em; padding-top: 6em; padding-right: 2em;">BPM</div>'+
//   '</div><hr>' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">SPD<br>MPH</div>' +
//   '<div class="col-90 rtSPD speedRow" style="font-size: 7.5em"></div>' +
//   // '<div class="col-10 speedRow" style="font-size: 1em; padding-top: 6em; padding-right: 2em;">MPH</div>'+
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">CAD<br>RPM</div>' +
//   '<div class="col-90 rtCAD" style="font-size: 6em"></div>' +
//   // '<div class="col-10" style="font-size: 1em; padding-top: 7em; padding-right: 2em;">RPM</div>'+
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES"></span></div></div>' +
//   '</div>';



// var page3option4 = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em"><span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">SPD<br>MPH</div>' +
//   '<div class="col-90 rtSPD speedRow" style="font-size: 9em"></div>' +
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">CAD<br>RPM</div>' +
//   '<div class="col-90 rtCAD" style="font-size: 9em"></div>' +
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES"></span></div></div>' +
//   '</div>';




// var page3option5 = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
// '<div class="col-100 headerRow" style="font-size: 2em"><span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">HR<br>BPM</div>' +
//   '<div class="col-90 rtHR speedRow" style="font-size: 9em"></div>' +
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">%<br>MAX</div>' +
//   '<div class="col-90 rtSCORE" style="font-size: 9em"></div>' +
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES"></span></div></div>' +
//   '</div>';









// var page3option1 = '  <div class="myContentBlock content-block vertride"> ' +
//   '<div class="row">' +
//   '    <div class="ACTUAL_TIME col-100" style="font-size: 3em">00:00:00</div> ' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="col-100" style="font-size: 1em">SPEED</div>' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="rtSPD col-100" style="font-size: 9em">0</div>' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="col-100" style="font-size: 1em">CAD</div>' +
//   // '    <div class="col-50" style="font-size: 1em">CAD</div>' +
//   '  </div>' +
//
//   '<div class="row">' +
//   // '    <div class="rtHR col-50" style="font-size: 6em">000</div>' +
//   '    <div class="rtCAD col-100" style="font-size: 9em">0</div>' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="col-100" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div>' +
//   '  </div>' +
//   '</div>   ';



// var page3option2 = '  <div class="myContentBlock content-block vertride"> ' +
//   '<div class="row">' +
//   '    <div class="ACTUAL_TIME col-100" style="font-size: 3em">00:00:00</div> ' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="col-100" style="font-size: 1.5em">CAD INTERVAL</div>' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="intervalCAD col-100" style="font-size: 8.5em">0</div>' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="col-100" style="font-size: 1.5em">HR INTERVAL</div>' +
//   // '    <div class="col-50" style="font-size: 1em">CAD</div>' +
//   '  </div>' +
//
//   '<div class="row">' +
//   // '    <div class="rtHR col-50" style="font-size: 6em">000</div>' +
//   '    <div class="intervalHR col-100" style="font-size: 8.5em">0</div>' +
//   '  </div>' +
//
//   '  <div class="row">' +
//   '    <div class="col-100" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div>' +
//   '  </div>' +
//   '</div>   ';

//
// var page4default = ' <div content-block horizride> ' +
//   '             <div class="row row1">' +
//   '                <div class="col-30 rtSCORE">HR</div>' +
//   '                <div class="col-40">SPEED</div>' +
//   '                <div class="col-30">CAD</div>' +
//   '              </div>' +
//   '              <div class="row row2">' +
//   '                <div class="rtHR hrcad col-30">0</div>' +
//   '                <div class="rtSPD spd col-40">0</div>' +
//   '                <div class="rtCAD hrcad col-30">0</div>' +
//   '              </div>' +
//   '              <div class="row row3">' +
//   '                <div class="ACTUAL_TIME col-50">00:00:00</div>' +
//   '                <div class="col-50" style="font-size: 1em"><span class="rtMILES">00.00</span> MILES</div>' +
//   '              </div>' +
//   '            </div>';
//
// var page4option1 = ' <div content-block horizride> ' +
//   '             <div class="row row1">' +
//   // '                <div class="col-30 rtSCORE">HR</div>' +
//   '                <div class="col-50">SPEED</div>' +
//   '                <div class="col-50">CAD</div>' +
//   '              </div>' +
//   '              <div class="row row2">' +
//   // '                <div class="rtHR hrcad col-30">0</div>' +
//   '                <div class="rtSPD spd col-50">0</div>' +
//   '                <div class="rtCAD spd col-50">0</div>' +
//   '              </div>' +
//   '              <div class="row row3">' +
//   '                <div class="ACTUAL_TIME col-50">00:00:00</div>' +
//   '                <div class="col-50" style="font-size: 1em"><span class="rtMILES">00.00</span> MILES</div>' +
//   '              </div>' +
//   '            </div>';
//
//
// //view4 html
// var view4HTML = '<div id="view4nav" class="navbar">' +
//   '<div class="navbar-inner">' +
//   '  <div class="center"><span class="rtMOVING">00:00:00</span> &nbsp; MOVING &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="rtAVGSPD">00.0</span> &nbsp; AVG &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="TIME">12:00:00 PM</span></div>' +
//   '</div>' +
//   '</div>' +
//   '<div class="pages navbar-through">' +
//   '<div data-page="index-4" class="page">' +
//   '  <div class="navbar">' +
//   '    <div class="navbar-inner">' +
//   '      <div class="center"><span class="rtMOVING">00:00:00</span> &nbsp; MOVING &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="rtAVGSPD">00.0</span> &nbsp; AVG &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="TIME">12:00:00 PM</span></div>' +
//   '    </div>' +
//   '  </div>' +
//   '  <div id="view4pagecontent" class="page-content" style="margin-top: 20px;">' +
//   '    <div content-block horizride>' +
//   '      <div class="row row1">' +
//   '        <div class="col-30 rtSCORE">HR</div>' +
//   '        <div class="col-40">SPEED</div>' +
//   '        <div class="col-30">CAD</div>' +
//   '      </div>' +
//   '      <div class="row row2">' +
//   '        <div class="rtHR hrcad col-30">0</div>' +
//   '        <div class="rtSPD spd col-40">0</div>' +
//   '        <div class="rtCAD hrcad col-30">0</div>' +
//   '      </div>' +
//   '      <div class="row row3">' +
//   '        <div class="ACTUAL_TIME col-50">00:00:00</div>' +
//   '        <div class="col-50" style="font-size: 1em"><span class="rtMILES">00.00</span> MILES</div>' +
//   '      </div>' +
//   '    </div>' +
//   '  </div>' +
//   '</div>' +
//   '</div>';



//var page3default = '<div class="myContentBlock content-block vertride"><div class="row"><div class="col-100 headerRow" style="font-size: 3em"><span class="ACTUAL_TIME">00:00:00</span></div></div><div id="centerRows" class="centerRows"><div class="row"><div class="col-100" style="font-size: 1em">SPEED</div></div><div class="row"><div class="rtSPD col-100" style="font-size: 6em">19.9</div></div><div class="row"><div class="col-100 rtSCORE" style="font-size: 1em">HR 0%</div><div class="rtHR col-100" style="font-size: 6em">123</div></div><div class="row"><div class="col-100" style="font-size: 1em">CAD</div></div><div class="row"><div class="rtCAD col-100" style="font-size: 6em">88</div></div></div><div class="row"><div class="col-100 footerRow" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div></div></div>';


//var page3option1 = '<div class="myContentBlock content-block vertride"><div class="row"><div class="col-100 headerRow" style="font-size: 3em"><span class="ACTUAL_TIME">00:00:00</span></div></div><div id="centerRows" class="centerRows"><div class="row"><div class="col-100 rtSCORE" style="font-size: 1em">HR 0%</div><div class="rtHR col-100" style="font-size: 9em">0</div></div><div class="row"><div class="col-100" style="font-size: 1em">CAD</div></div><div class="row"><div class="rtCAD col-100" style="font-size: 9em">0</div></div></div><div class="row"><div class="col-100 footerRow" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div></div></div>';

// var page3option2 = '<div class="myContentBlock content-block vertride"><div class="row"><div class="col-100 headerRow" style="font-size: 3em"><span class="ACTUAL_TIME">00:00:00</span></div></div><div id="centerRows" class="centerRows"><div class="row"><div class="col-100 rtSCORE" style="font-size: 3em">HR 0%</div><div class="rtHR col-100" style="font-size: 11em">0</div></div></div><div class="row"><div class="col-100 footerRow" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div></div></div>';


// $$('.footerRow').on('click', function (e) {
//   console.log("footerRow Clicked");
//   var x = document.getElementById("speedRow");
// if (x.style.display === "none") {
//     x.style.display = "block";
// } else {
//     x.style.display = "none";
// }
// });


// var page3option5r = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em">ROUND &nbsp&nbsp<span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">HR<br>BPM</div>' +
//   '<div class="col-90 rtHRr speedRow" style="font-size: 9em"></div>' +
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">%<br>MAX</div>' +
//   '<div class="col-90 rtSCOREr" style="font-size: 9em"></div>' +
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES">00.00</span> MILES</div></div>' +
//   '</div>';
//
// var page3option5i = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em">INTERVAL &nbsp&nbsp<span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">HR<br>BPM</div>' +
//   '<div class="col-90 rtHRi speedRow" style="font-size: 9em"></div>' +
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">%<br>MAX</div>' +
//   '<div class="col-90 rtSCOREi" style="font-size: 9em"></div>' +
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES">00.00</span> MILES</div></div>' +
//   '</div>';


// //INTERVAL
// var page3option3i = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em">INTERVAL &nbsp&nbsp<span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt">HR<br>%</div>' +
//   '<div class="col-90 rtHRi" style="font-size: 6em"></div>' +
//   // '<div class="col-10" style="font-size: 1em; padding-top: 6em; padding-right: 2em;">BPM</div>'+
//   '</div><hr>' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">SPD<br>MPH</div>' +
//   '<div class="col-90 rtSPDi speedRow" style="font-size: 7.5em"></div>' +
//   // '<div class="col-10 speedRow" style="font-size: 1em; padding-top: 6em; padding-right: 2em;">MPH</div>'+
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">CAD<br>RPM</div>' +
//   '<div class="col-90 rtCADi" style="font-size: 6em"></div>' +
//   // '<div class="col-10" style="font-size: 1em; padding-top: 7em; padding-right: 2em;">RPM</div>'+
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES">00.00</span> MILES</div></div>' +
//   '</div>';
//
// //ROUND
// var page3option3r = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em">ROUND &nbsp&nbsp<span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt">HR<br>%</div>' +
//   '<div class="col-90 rtHRr" style="font-size: 6em"></div>' +
//   // '<div class="col-10" style="font-size: 1em; padding-top: 6em; padding-right: 2em;">BPM</div>'+
//   '</div><hr>' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">SPD<br>MPH</div>' +
//   '<div class="col-90 rtSPDr speedRow" style="font-size: 7.5em"></div>' +
//   // '<div class="col-10 speedRow" style="font-size: 1em; padding-top: 6em; padding-right: 2em;">MPH</div>'+
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">CAD<br>RPM</div>' +
//   '<div class="col-90 rtCADr" style="font-size: 6em"></div>' +
//   // '<div class="col-10" style="font-size: 1em; padding-top: 7em; padding-right: 2em;">RPM</div>'+
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES">00.00</span> MILES</div></div>' +
//   '</div>';


// var page3option4r = '<div class="myContentBlock content-block vertride">' +
//   '<div class="row">' +
//   '<div class="col-100 headerRow" style="font-size: 2em">ROUND &nbsp&nbsp<span class="ACTUAL_TIME">00:00:00</span></div></div>' +
//   '<div id="centerRows" class="centerRows lh16">' +
//   '<div class="row">' +
//   '<div class="col-10 rt speedRow">SPD<br>MPH</div>' +
//   '<div class="col-90 rtSPDr speedRow" style="font-size: 9em"></div>' +
//   '</div><hr>' +
//   '<div class="row"><div class="col-10 rt">CAD<br>RPM</div>' +
//   '<div class="col-90 rtCADr" style="font-size: 9em"></div>' +
//   '</div>' +
//   '</div></div></div>' +
//   '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES">00.00</span> MILES</div></div>' +
//   '</div>';
//
// var page3option4i = '<div class="myContentBlock content-block vertride">' +
// '<div class="row">' +
// '<div class="col-100 headerRow" style="font-size: 2em">INTERVAL &nbsp&nbsp<span class="ACTUAL_TIME">00:00:00</span></div></div>' +
// '<div id="centerRows" class="centerRows lh16">' +
// '<div class="row">' +
// '<div class="col-10 rt speedRow">SPD<br>MPH</div>' +
// '<div class="col-90 rtSPDi speedRow" style="font-size: 9em"></div>' +
// '</div><hr>' +
// '<div class="row"><div class="col-10 rt">CAD<br>RPM</div>' +
// '<div class="col-90 rtCADi" style="font-size: 9em"></div>' +
// '</div>' +
// '</div></div></div>' +
// '<div class="row"><div id="footerRow" class="col-100 footerRow" style="font-size: 2em"><span class="rtMILES">00.00</span> MILES</div></div>' +
// '</div>';



// var page4info = 0;
// $$('#view4nav').on('click', function(e) {
//   var currentPage = page4info;
//   if (currentPage === 0) {
//     $$('#view4pagecontent').html(page4option1);
//     page4info = 1;
//   }
//
//   if (currentPage == 1) {
//     $$('#view4pagecontent').html(page4default);
//     page4info = 0;
//   }
// });



//var dopt = displayDataOption;
//console.log("dopt:  " + dopt);
// switch (dopt) {
//   case 0:
//     displayDataOption = 1;
//     console.log("switch to Interval");
//     if (page3info == 0) {
//       $$('#view3pagecontent').html(page3option5i);
//     }
//     if (page3info == 1) {
//       $$('#view3pagecontent').html(page3option3i);
//     }
//     if (page3info == 2) {
//       $$('#view3pagecontent').html(page3option4i);
//     }
//     break;
//     case 1:
//       displayDataOption = 2;
//             console.log("switch to Round");
//             if (page3info == 0) {
//               $$('#view3pagecontent').html(page3option5r);
//             }
//             if (page3info == 1) {
//               $$('#view3pagecontent').html(page3option3r);
//             }
//             if (page3info == 2) {
//               $$('#view3pagecontent').html(page3option4r);
//             }
//       break;
//       case 2:
//         displayDataOption = 0;
//               console.log("switch to RT");
//               if (page3info == 0) {
//                 $$('#view3pagecontent').html(page3option5);
//               }
//               if (page3info == 1) {
//                 $$('#view3pagecontent').html(page3option3);
//               }
//               if (page3info == 2) {
//                 $$('#view3pagecontent').html(page3option4);
//               }
//         break;
//   default:
//               console.log("default");
// }

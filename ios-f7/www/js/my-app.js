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

var now;
var startTime;


// Handle Cordova Device Ready Event
$$(document).on('deviceready', function () {
  console.log("Device is ready!");
  var now = new Date();
  startTime = now;
  if (now.getHours() > 12) {
    $$(".TIME").text((now.getHours() - 12) + ":" + now.getMinutes() + ":" + now.getSeconds() + " PM");
  } else {
    $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + " AM");
  }

  var intervalID = window.setInterval(myCallback, 1000);
});

var time = 0;
var localT = time;
//each second
function myCallback() {
  localT = time;


  //get actual time
  var rightNow = new Date();
  $$(".ACTUAL_TIME").text(Date.dateDiff('s', startTime, rightNow));
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

  //console.log((rightNow.getHours()) + ":" + rightNow.getMinutes() + ":" + rightNow.getSeconds());


  //Adding a value each second
  rounds.HeartRate += rt.hr;
  interval.arrHeartRate.push(rt.hr);
  interval.arrCadence.push(Number(rt.cadence));
  interval.arrSpeed.push(Number(rt.speed));
  interval.arrDistance.push(totalMiles);
  midRound(localT);
  time++;
}


$$('#NAME').on('click', function (e) {
  myApp.prompt('What is your name?', 'WELCOME', function (value) {
    //myApp.alert('Your name is "' + value + '". You clicked Ok button');
    $$('#NAME').find('.item-after').text(value);
    name = value;
  });
});

$$('#MAXHR').on('click', function (e) {
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
  setTimeout(function () {
    $$('#MAXHR').removeClass('ani');
  }, 300);
});

var audio = "OFF";
$$('#AUDIO').on('click', function (e) {
  $$(this).addClass('ani');

  if (audio == "ON") {
    $$(this).find('.item-after').text('OFF');
    audio = "OFF";
  } else {
    $$(this).find('.item-after').text('ON');
    audio = "ON";
  }

  setTimeout(function () {
    $$('#AUDIO').removeClass('ani');
  }, 300);

});

$$('#TIRESIZE').on('click', function (e) {
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
  setTimeout(function () {
    $$('#TIRESIZE').removeClass('ani');
  }, 300);
});



var refreshInterval = 30;
$$('#REFRESH').on('click', function (e) {
  $$(this).addClass('ani');
  var current = refreshInterval;

  if (current == 30) {
    $$(this).find('.item-after').text('60');
    refreshInterval = 60;
  }

  if (current == 60) {
    $$(this).find('.item-after').text('300');
    refreshInterval = 300;
  }

  if (current == 300) {
    $$(this).find('.item-after').text('30');
    refreshInterval = 30;
  }

  setTimeout(function () {
    $$('#REFRESH').removeClass('ani');
  }, 300);
});



$$('#RESTART').on('click', function (e) {
  $$(this).addClass('ani');
  console.log("RESTART");

  arrConnectedPeripherals.forEach(function (element) {
    ble.disconnect(element, function () {
      console.log("disconnect success");
    }, function () {
      console.log("disconnect failed");
    });
  });
  $$('.chip-media').css('color', 'white');
  $$('.chip-label').css('color', 'white');

  setTimeout(function () {
    $$('#RESTART').removeClass('ani');
  }, 300);

});



var mql = window.matchMedia("(orientation: portrait)");
// Add a media query change listener

mql.addListener(function (m) {
  if (m.matches) {
    console.log("portrait");
    currentOrientation = "portrait";


    // if (currentTab == 4) {
    //   //myApp.showTab('#view-3');
    //   currentTab = 3;
    //   //myApp.closeModal('.popup4', false);
    // }
  } else {
    console.log("landscape");
    currentOrientation = "landscape";
    // if (currentTab == 3) {
    //   //myApp.showTab('#view-4');
    //   currentTab = 4;
      //myApp.popup('.popup4', false, false);
      //$$('#view-3').html(view4HTML);
    // }
  }
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

    arrPeripherals.forEach(function (element) {
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
ptrContent.on('ptr:refresh', function (e) {

  // //remove all chips
  // arrPeripherals = [];
  // $$('.blechip').remove();

  scan();

  setTimeout(function () {
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

      peripheral.advertisement.serviceUuids.forEach(function (element) {
        if (element == "18D") {
          y.push("180D");
        }
        if (element == "1816") {
          y.push("1816");
        }
      });
      //android end
    }


    y.forEach(function (element) {
      if (element == "180D") {
        console.log("Identified as HR, calling Notify");
        serviceType = "180D";
        serviceChar = heartRate.measurement;
        arrConnectedPeripherals.push(peripheral.id);
        arrConnectedPeripheralsService.push(serviceType);
        arrConnectedPeripheralsChar.push(serviceChar);
        ble.startNotification(peripheral.id, serviceType, serviceChar, function (buffer) {
          var data = new Uint8Array(buffer);
          onDataHR(data);
        }, function (reason) {
          console.log("failure" + reason);
        });
      }
    });


    y.forEach(function (element) {
      if (element == "1816") {
        console.log("Identified as CSC, calling Notify");
        serviceType = "1816";
        serviceChar = speedCadence.measurement;
        arrConnectedPeripherals.push(peripheral.id);
        arrConnectedPeripheralsService.push(serviceType);
        arrConnectedPeripheralsChar.push(serviceChar);
        ble.startNotification(peripheral.id, serviceType, serviceChar, function (buffer) {
          var data = new Uint8Array(buffer);
          onDataCSC(data);
        }, function (reason) {
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

$$('.blelist').on('touchstart', '#blechip', function (e) {

  myApp.showIndicator();
  setTimeout(function () {
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

$$('#view-4').on('tab:show', function () {
  // myApp.alert('Tab/View 4 is visible');
  currentTab = 4;
  console.log(currentTab);
});

$$('#view-3').on('tab:show', function () {
  // myApp.alert('Tab/View 3 is visible');
  currentTab = 3;
  console.log(currentTab);
});

$$('#view-2').on('tab:show', function () {
  // myApp.alert('Tab/View 2 is visible');
  currentTab = 2;
  // $$(".iconNumber").text("00");
  console.log(currentTab);
});
$$('#view-1').on('tab:show', function () {
  // myApp.alert('Tab/View 2 is visible');
  currentTab = 1;
  console.log(currentTab);
});



translate_advertisement = function (peripheral) {
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
uuid = function (id) {
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
hex = function (byte_array) {
  var hexstr = '';
  for (var i = (byte_array.length - 1); i >= 0; i--) {
    hexstr += byte_array[i].toString(16).toUpperCase();
  }
  return hexstr;
};

var page3info = 0;
$$('#view3nav').on('click', function (e) {
  var currentPage = page3info;
  //page3option1 or page3default
  if (currentPage === 0) {
    $$('#view3pagecontent').html(page3option1);
    page3info = 1;
  }
  if (currentPage == 1) {
    $$('#view3pagecontent').html(page3option2);
    page3info = 2;
  }
  if (currentPage == 2) {
    $$('#view3pagecontent').html(page3default);
    page3info = 0;
  }
});

var page4info = 0;
$$('#view4nav').on('click', function (e) {
  var currentPage = page4info;
  if (currentPage === 0) {
    $$('#view4pagecontent').html(page4option1);
    page4info = 1;
  }

  if (currentPage == 1) {
    $$('#view4pagecontent').html(page4default);
    page4info = 0;
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


var page3default = '  <div class="myContentBlock content-block vertride"> ' +
  '<div class="row">' +
  '    <div class="ACTUAL_TIME col-100" style="font-size: 3em">00:00:00</div> ' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 1em">SPEED</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="rtSPD col-100" style="font-size: 9em">0</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-50 rtSCORE" style="font-size: 1.5em">HR 0%</div>' +
  '    <div class="col-50" style="font-size: 1.5em">CAD</div>' +
  '  </div>' +

  '<div class="row">' +
  '    <div class="rtHR col-50" style="font-size: 8em">0</div>' +
  '    <div class="rtCAD col-50" style="font-size: 8em">0</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div>' +
  '  </div>' +
  '</div>   ';

var page3option1 = '  <div class="myContentBlock content-block vertride"> ' +
  '<div class="row">' +
  '    <div class="ACTUAL_TIME col-100" style="font-size: 3em">00:00:00</div> ' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 1em">SPEED</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="rtSPD col-100" style="font-size: 9em">0</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 1em">CAD</div>' +
  // '    <div class="col-50" style="font-size: 1em">CAD</div>' +
  '  </div>' +

  '<div class="row">' +
  // '    <div class="rtHR col-50" style="font-size: 6em">000</div>' +
  '    <div class="rtCAD col-100" style="font-size: 9em">0</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div>' +
  '  </div>' +
  '</div>   ';



var page3option2 = '  <div class="myContentBlock content-block vertride"> ' +
  '<div class="row">' +
  '    <div class="ACTUAL_TIME col-100" style="font-size: 3em">00:00:00</div> ' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 1.5em">CAD INTERVAL</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="intervalCAD col-100" style="font-size: 8.5em">0</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 1.5em">HR INTERVAL</div>' +
  // '    <div class="col-50" style="font-size: 1em">CAD</div>' +
  '  </div>' +

  '<div class="row">' +
  // '    <div class="rtHR col-50" style="font-size: 6em">000</div>' +
  '    <div class="intervalHR col-100" style="font-size: 8.5em">0</div>' +
  '  </div>' +

  '  <div class="row">' +
  '    <div class="col-100" style="font-size: 3em"><span class="rtMILES">00.00</span> MILES</div>' +
  '  </div>' +
  '</div>   ';


var page4default = ' <div content-block horizride> ' +
  '             <div class="row row1">' +
  '                <div class="col-30 rtSCORE">HR</div>' +
  '                <div class="col-40">SPEED</div>' +
  '                <div class="col-30">CAD</div>' +
  '              </div>' +
  '              <div class="row row2">' +
  '                <div class="rtHR hrcad col-30">0</div>' +
  '                <div class="rtSPD spd col-40">0</div>' +
  '                <div class="rtCAD hrcad col-30">0</div>' +
  '              </div>' +
  '              <div class="row row3">' +
  '                <div class="ACTUAL_TIME col-50">00:00:00</div>' +
  '                <div class="col-50" style="font-size: 1em"><span class="rtMILES">00.00</span> MILES</div>' +
  '              </div>' +
  '            </div>';

var page4option1 = ' <div content-block horizride> ' +
  '             <div class="row row1">' +
  // '                <div class="col-30 rtSCORE">HR</div>' +
  '                <div class="col-50">SPEED</div>' +
  '                <div class="col-50">CAD</div>' +
  '              </div>' +
  '              <div class="row row2">' +
  // '                <div class="rtHR hrcad col-30">0</div>' +
  '                <div class="rtSPD spd col-50">0</div>' +
  '                <div class="rtCAD spd col-50">0</div>' +
  '              </div>' +
  '              <div class="row row3">' +
  '                <div class="ACTUAL_TIME col-50">00:00:00</div>' +
  '                <div class="col-50" style="font-size: 1em"><span class="rtMILES">00.00</span> MILES</div>' +
  '              </div>' +
  '            </div>';


  //view4 html
var view4HTML = '<div id="view4nav" class="navbar">' +
'<div class="navbar-inner">' +
'  <div class="center"><span class="rtMOVING">00:00:00</span> &nbsp; MOVING &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="rtAVGSPD">00.0</span> &nbsp; AVG &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="TIME">12:00:00 PM</span></div>' +
'</div>' +
'</div>'+
'<div class="pages navbar-through">'+
'<div data-page="index-4" class="page">'+
'  <div class="navbar">'+
'    <div class="navbar-inner">'+
'      <div class="center"><span class="rtMOVING">00:00:00</span> &nbsp; MOVING &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="rtAVGSPD">00.0</span> &nbsp; AVG &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span class="TIME">12:00:00 PM</span></div>' +
'    </div>'+
'  </div>'+
'  <div id="view4pagecontent" class="page-content" style="margin-top: 20px;">'+
'    <div content-block horizride>'+
'      <div class="row row1">'+
'        <div class="col-30 rtSCORE">HR</div>'+
'        <div class="col-40">SPEED</div>'+
'        <div class="col-30">CAD</div>'+
'      </div>'+
'      <div class="row row2">'+
'        <div class="rtHR hrcad col-30">0</div>'+
'        <div class="rtSPD spd col-40">0</div>'+
'        <div class="rtCAD hrcad col-30">0</div>'+
'      </div>'+
'      <div class="row row3">'+
'        <div class="ACTUAL_TIME col-50">00:00:00</div>'+
'        <div class="col-50" style="font-size: 1em"><span class="rtMILES">00.00</span> MILES</div>'+
'      </div>'+
'    </div>'+
'  </div>'+
'</div>'+
'</div>';


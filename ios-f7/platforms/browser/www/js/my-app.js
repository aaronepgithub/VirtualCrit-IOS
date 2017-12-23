var myApp = new Framework7();

// Export selectors engine
var $$ = Dom7;

var currentTab = 0;
var currentOrientation = "portrait";

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
$$(document).on('deviceready', function() {
  console.log("Device is ready!");
  var now = new Date();
  startTime = now;
  if (now.getHours() > 12) {
    $$(".TIME").text((now.getHours() - 12) + ":" + now.getMinutes() + ":" + now.getSeconds() + " PM");
  } else {
    $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + " AM");
  }
});


$$('#TIRESIZE').on('click', function(e) {
  if (wheelCircumference == 2105) {
    $$(this).html('<div class="item-media"><i class="f7-icons color-red">settings_fill</i></div><div class="item-inner"><div class="item-title">TIRE SIZE</div><div class="item-after">700X32</div></div>');
    wheelCircumference = 2155;
  } else {
    $$(this).html('<div class="item-media"><i class="f7-icons color-red">settings_fill</i></div><div class="item-inner"><div class="item-title">TIRE SIZE</div><div class="item-after">700X25</div></div>');
    wheelCircumference = 2105;
  }
});

var refreshInterval = 0;

$$('#REFRESH').on('click', function(e) {
  var current = refreshInterval;

  if (current == 0) {
    $$(this).html('<div class="item-media"><i class="f7-icons color-red">timer_fill</i></div><div class="item-inner"><div class="item-title">REFRESH INTERVAL</div><div class="item-after">1</div></div>');
    refreshInterval = 1;
  }

  if (current == 1) {
    $$(this).html('<div class="item-media"><i class="f7-icons color-red">timer_fill</i></div><div class="item-inner"><div class="item-title">REFRESH INTERVAL</div><div class="item-after">2</div></div>');
    refreshInterval = 2;
  }

  if (current == 2) {
    $$(this).html('<div class="item-media"><i class="f7-icons color-red">timer_fill</i></div><div class="item-inner"><div class="item-title">REFRESH INTERVAL</div><div class="item-after">3</div></div>');
    refreshInterval = 3;
  }

  if (current == 3) {
    $$(this).html('<div class="item-media"><i class="f7-icons color-red">timer_fill</i></div><div class="item-inner"><div class="item-title">REFRESH INTERVAL</div><div class="item-after">0</div></div>');
    refreshInterval = 0;
  }


});

$$('#RESTART').on('click', function(e) {
  console.log("RESTART");
  // arrConnectedPeripherals.forEach(function(element, index) {
  //   ble.stopNotification(arrConnectedPeripherals[index], arrConnectedPeripheralsService[index], arrConnectedPeripheralsChar[index], function() {console.log("stop notify success");}, function() {console.log("stop notify failed");});
  //   ble.disconnect(element, function() {console.log("disconnect success");}, function() {console.log("disconnect failed");});
  // });
  arrConnectedPeripherals.forEach(function(element) {
    ble.disconnect(element, function() {console.log("disconnect success");}, function() {console.log("disconnect failed");});
  });
  $$('.chip-media').css('color', 'white');
  $$('.chip-label').css('color', 'white');
});



var mql = window.matchMedia("(orientation: portrait)");
// Add a media query change listener
mql.addListener(function(m) {
  if (m.matches) {
    console.log("portrait");
    currentOrientation = "portrait";

    if (currentTab == 4) {
      // myApp.showTab('#view-3');
      currentTab = 3;
      myApp.closeModal('.popup4');
    }
  } else {
    console.log("landscape");
    currentOrientation = "landscape";
    if (currentTab == 3) {
      //myApp.showTab('#view-4');
      currentTab = 4;
      myApp.popup('.popup4');
    }

    //if in ride view, change to hz view
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


    if (arrPeripherals.length == 0) { //knowing that I am going to add one now
      $$('.blechip').remove();
    }


    arrPeripherals.push(peripheral);
    $$('.blelist').append('<div id="blechip" class="chip-added chip chip-extended blechip"><div class="chip-media bg-blue">' + (arrPeripherals.length - 1) + '</div><div class="chip-label">' + peripheral.name + '</div>');
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
          //console.log("Notify Success HR");
          var data = new Uint8Array(buffer);
          now = new Date();
          if (now.getHours() > 12) {
            $$(".TIME").text((now.getHours() - 12) + ":" + now.getMinutes() + ":" + now.getSeconds() + " PM");
          } else {
            $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + " AM");
          }
          var rightNow = new Date();
          $$(".ACTUAL_TIME").text(Date.dateDiff('s', startTime, rightNow));
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
          //console.log("Notify Success CSC");
          var data = new Uint8Array(buffer);
          now = new Date();
          if (now.getHours() > 12) {
            $$(".TIME").text((now.getHours() - 12) + ":" + now.getMinutes() + ":" + now.getSeconds() + " PM");
          } else {
            $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + " AM");
          }
          var rightNow = new Date();
          // console.log('Time Since Start: ' + Date.dateDiff('s', startTime, rightNow));
          $$(".ACTUAL_TIME").text(Date.dateDiff('s', startTime, rightNow));
          onDataCSC(data);
        }, function(reason) {
          console.log("failure" + reason);
        });
      }
    });




  } //end onConnect

  function onDisconnect() {
    console.log("Disconnected");
  }

  ble.connect(peripheral.id, onConnect, onDisconnect);
}






$$('.blelist').on('touchstart', '#blechip', function(e) {

  e.preventDefault();

  var chipname = $$(this).find('.chip-label').text();
  var chipIndex = $$(this).find('.chip-media').text();
  var chipUUID = arrPeripherals[chipIndex].id;

  $$(this).find('.chip-media').css('color', 'red');
  $$(this).find('.chip-label').css('color', 'red');
  // console.log(chipname);
  // console.log(chipIndex);
  // console.log(chipUUID);
  connect(arrPeripherals[chipIndex]);

  //call to connect

});

$$('#view-4').on('tab:show', function() {
  // myApp.alert('Tab/View 4 is visible');
  currentTab = 4;
  // console.log(currentTab);
});

$$('#view-3').on('tab:show', function() {
  // myApp.alert('Tab/View 3 is visible');
  currentTab = 3;
  // console.log(currentTab);
});

$$('#view-2').on('tab:show', function() {
  // myApp.alert('Tab/View 2 is visible');
  currentTab = 2;
  $$(".iconNumber").text("00");
  // console.log(currentTab);
});

// // Add views
// var view1 = myApp.addView('#view-1');
// var view2 = myApp.addView('#view-2', {
//   // Because we use fixed-through navbar we can enable dynamic navbar
//   dynamicNavbar: true
// });
// var view3 = myApp.addView('#view-3');
// var view4 = myApp.addView('#view-4');

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
    if (length == 0) {
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

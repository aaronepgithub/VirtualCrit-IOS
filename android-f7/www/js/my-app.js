var myApp = new Framework7();

// Export selectors engine
var $$ = Dom7;

var currentTab = 0;
var currentOrientation = "portrait";

var heartRate = {
  service: '180D',
  measurement: '2A37'
};

var speedCadence = {
  service: '1816',
  measurement: '2A5B'
};

// Handle Cordova Device Ready Event
$$(document).on('deviceready', function() {
  console.log("Device is ready!");
  var now = new Date();
  $$(".TIME").text(now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds());
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

function scan() {
  //remove all chips
  arrPeripherals = [];
  $$('.blechip').remove();

  function onScan(peripheral) {
    console.log("On Scan");
    if (peripheral.id == arrPeripherals[arrPeripherals.length - 1]) {
      console.log("Duplicate");
      return;
    }

    // if (peripheral.name === "") {
    //   console.log("No Name");
    //   return;
    // }

    if (typeof peripheral.name == "undefined") {
      console.log("No Name");
      return;
    } else {
      console.log("Found " + JSON.stringify(peripheral) + "\n");
      arrPeripherals.push(peripheral);
      $$('.blelist').append('<div id="blechip" class="chip-added chip chip-extended blechip"><div class="chip-media bg-blue">' + (arrPeripherals.length - 1) + '</div><div class="chip-label">' + peripheral.name + '</div>');
    }

    }

  function scanFailure(reason) {
    console.log("scanFailure");
  }

  console.log("scanning");
  // ble.scan(["180D", "1816"], 5, onScan, scanFailure);

  //create array containing the service uuids and pass that arr into the scn ommand
  ble.scan([], 5, onScan, scanFailure);

}

// Pull to refresh content
var ptrContent = $$('.pull-to-refresh-content');

// Add 'refresh' listener on it
ptrContent.on('ptr:refresh', function(e) {

  //remove all chips
  arrPeripherals = [];
  $$('.blechip').remove();

  scan();

  setTimeout(function() {
    myApp.pullToRefreshDone();

    //console.log(JSON.stringify(arrPeripherals));
    console.log("Scan Complete");
  }, 5000);
});



function connect(peripheral) {



  function onConnect() {

    var serviceType = "none";
    //https://github.com/lab11/blees/blob/7f2e77e59b576d851448001ce0fcc86a807927fb/summon/blees-demo/js/bluetooth.js
    //CREATE ANDROID VERSION
    console.log("Peripheral Data after Connecting");
    console.log(JSON.stringify(peripheral));

    //var scanRecord = new Uint8Array(peripheral);
    var scanRecord = new Uint8Array(peripheral.advertising);
    console.log("scanRecord:  " + JSON.stringify(scanRecord));

    // if ios

    console.log("connected");
    var x = peripheral.id;
    // var y = peripheral.advertising.kCBAdvDataServiceUUIDs; //array of service uuids
    //peripheral.advertising.kCBAdvDataServiceUUIDs

    var z = translate_advertisement(peripheral);

    console.log("peripheral.advertisement.serviceUuids");
    console.log(peripheral.advertisement.serviceUuids);
    // var y = [];

    if (peripheral.advertisement.serviceUuids[0] == "18D") {
      y.push("180D");
    }

    if (peripheral.advertisement.serviceUuids[1] == "18D") {
      y.push("180D");
    }

    if (peripheral.advertisement.serviceUuids[2] == "18D") {
      y.push("180D");
    }

    if (peripheral.advertisement.serviceUuids[0] == "1816") {
      y.push("1816");
    }

    if (peripheral.advertisement.serviceUuids[1] == "1816") {
      y.push("1816");
    }

    if (peripheral.advertisement.serviceUuids[2] == "1816") {
      y.push("1816");
    }



    console.log("y:  " + y);

    // need this for android...
    //var y = serviceUuids; //array of service uuids
    //console.log("Advertising:  " + y);

//start test
    // console.log("Identified as HR, calling Notify");
    // serviceType = "180D";
    // serviceChar = heartRate.measurement;
    // ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
    //   //console.log("Notify Success HR");
    //   var data = new Uint8Array(buffer);
    //   //console.log("HR " + data[1]);
    //   onDataHR(data);
    // }, function(reason) {
    //   console.log("failure" + reason);
    // });
    //end test

    // if android, get array of services into var y

    if (y[0] == "180D" || y[1] == "180D" || y[2] == "180D") {
      console.log("Identified as HR, calling Notify");
      serviceType = "180D";
      serviceChar = heartRate.measurement;
      ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
        //console.log("Notify Success HR");
        var data = new Uint8Array(buffer);
        //console.log("HR " + data[1]);
        onDataHR(data);
      }, function(reason) {
        console.log("failure" + reason);
      });



    }

    if (y[0] == "1816" || y[1] == "1816" || y[2] == "1816") {
      console.log("Identified as CSC, calling Notify");
      serviceType = "1816";
      serviceChar = speedCadence.measurement;
      ble.startNotification(peripheral.id, serviceType, serviceChar, function(buffer) {
        //console.log("Notify Success CSC");
        var data = new Uint8Array(buffer);
        //console.log("CSC 1" + data[1]);  //need to do complete array
        onDataCSC(data);
      }, function(reason) {
        console.log("failure" + reason);
      });
    }


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
  console.log(currentTab);
});

$$('#view-3').on('tab:show', function() {
  // myApp.alert('Tab/View 3 is visible');
  currentTab = 3;
  console.log(currentTab);
});

$$('#view-2').on('tab:show', function() {
  // myApp.alert('Tab/View 2 is visible');
  currentTab = 2;
  console.log(currentTab);
});

// Add views
var view1 = myApp.addView('#view-1');
var view2 = myApp.addView('#view-2', {
  // Because we use fixed-through navbar we can enable dynamic navbar
  dynamicNavbar: true
});
var view3 = myApp.addView('#view-3');
var view4 = myApp.addView('#view-4');




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
    channel: undefined,       // ios only
    isConnectable: undefined, // ios only
    flags: undefined,         // android only
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
          var data = scanRecord.subarray(index+1, index+length);

          // determine data based on field type
          switch (type) {
            case 0x01: // Flags
              peripheral.advertisement.flags = data[0] & 0xFF;
              break;

            case 0x02: // Incomplete List of 16-Bit Service UUIDs
            case 0x03: // Complete List of 16-Bit Service UUIDs
              for (var n=0; n<data.length; n+=2) {
                peripheral.advertisement.serviceUuids.push(uuid(data.subarray(n,n+2)));
                console.log("serviceUuid:  " + peripheral.advertisement.serviceUuids[peripheral.advertisement.serviceUuids.length - 1]);
              }
              break;

            case 0x04: // Incomplete List of 32-Bit Service UUIDs
            case 0x05: // Complete List of 32-Bit Service UUIDs
              for (var n=0; n<data.length; n+=4) {
                peripheral.advertisement.serviceUuids.push(uuid(data.subarray(n,n+4)));
                                console.log("serviceUuid:  " + peripheral.advertisement.serviceUuids[peripheral.advertisement.serviceUuids.length - 1]);
              }
              break;

            case 0x06: // Incomplete List of 128-Bit Service UUIDs
            case 0x07: // Complete List of 128-Bit Service UUIDs
              for (var n=0; n<data.length; n+=16) {
                peripheral.advertisement.serviceUuids.push(uuid(data.subarray(n,n+16)));
                console.log("serviceUuid:  " + peripheral.advertisement.serviceUuids[peripheral.advertisement.serviceUuids.length - 1]);
              }
              break;

            case 0x08: // Short Local Name
            case 0x09: // Complete Local Name
              peripheral.advertisement.localName = String.fromCharCode.apply(null,data);
              break;

            case 0x0A: // TX Power Level
              peripheral.advertisement.txPowerLevel = data[0] & 0xFF;
              break;

            case 0x16: // Service Data
              peripheral.advertisement.serviceData.push({
                uuid: uuid(data.subarray(0,2)),
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
             hex(id.subarray( 8, 10)) + '-' +
             hex(id.subarray( 6,  8)) + '-' +
             hex(id.subarray( 0,  6));

    } else {
      console.log("hex(id):  " + hex(id));
        return hex(id);
    }
  };

  // convert an array of bytes into hex data
  //    assumes data needs to be in reverse order
  hex = function (byte_array) {
      var hexstr = '';
      for (var i=(byte_array.length-1); i>=0; i--) {
          hexstr += byte_array[i].toString(16).toUpperCase();
      }
      return hexstr;
  };

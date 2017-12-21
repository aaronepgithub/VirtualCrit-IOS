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

function scan() {
  //remove all chips
  arrPeripherals = [];
  $$('.blechip').remove();

  function onScan(peripheral) {

    if (peripheral.id == arrPeripherals[arrPeripherals.length - 1]) {
      console.log("Duplicate");
      return;
    }
    console.log("Found " + JSON.stringify(peripheral) + "\n");

    arrPeripherals.push(peripheral);

    $$('.blelist').append('<div id="blechip" class="chip-added chip chip-extended blechip"><div class="chip-media bg-blue">' + (arrPeripherals.length - 1) + '</div><div class="chip-label">' + peripheral.name + '</div>');
  }

  function scanFailure(reason) {
    console.log("scanFailure");
  }

  console.log("scanning");
  ble.scan(["180D", "1816"], 5, onScan, scanFailure);

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

// if ios

    console.log("connected");
    var x = peripheral.id;
    var y = peripheral.advertising.kCBAdvDataServiceUUIDs; //array of service uuids
    //peripheral.advertising.kCBAdvDataServiceUUIDs
    console.log("Advertising:  " + y);

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

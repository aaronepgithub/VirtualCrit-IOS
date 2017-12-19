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

var arrPeripheralIDs = [];
var arrPeripherals = [];

function scan() {
  //remove all chips
  arrPeripherals = [];
  $$('.blechip').remove();

  function onScan(peripheral) {

    console.log("Found " + JSON.stringify(peripheral) + "\n");
    //console.log(peripheral.id)
    // arrPeripherals.push(peripheral.id);
    arrPeripheralIDs.push(peripheral.id);
    arrPeripherals.push(peripheral);

    $$('.blelist').append('<div id="blechip" class="chip-added chip chip-extended blechip"><div class="chip-media bg-blue">'+ (arrPeripherals.length - 1) +'</div><div class="chip-label">' + peripheral.name + '</div>');
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

    console.log(JSON.stringify(arrPeripherals));
  }, 3000);
});




function connect(peripheral) {
  function onConnect() {

    function onNotifySuccessHR() {
      print("Notify Success HR");
      var onData = function(buffer) {
        // Decode the ArrayBuffer into a typed Array based on the data you expect
      var data = new Uint8Array(buffer);
      console.console.log("Button state changed to " + data[0]);
    };

    }

    function onNotifySuccessCSC() {
      print("Notify Success CSC");
    }

    function onNotifyFailure() {
      print("Notify Failure");
    }

//https://github.com/lab11/blees/blob/7f2e77e59b576d851448001ce0fcc86a807927fb/summon/blees-demo/js/bluetooth.js


    console.log("connected");
    var x = peripheral.id;
    var y = peripheral.advertising.kCBAdvDataServiceUUIDs;  //array of service uuids
    //peripheral.advertising.kCBAdvDataServiceUUIDs

    if (y[0] == "180D" || y[1] == "180D" || y[2] == "180D")  {
        ble.startNotification(peripheral.id, heartRate.service, heartRate.measurement, onNotifySuccessHR, onNotifyFailure);
    }

    if (y[0] == "1816" || y[1] == "1816" || y[2] == "1816")  {
        ble.startNotification(peripheral.id, speedCadence.service , speedCadence.measurement, onNotifySuccessCSC, onNotifyFailure);
    }



    //ble.startNotification(device_id, service_uuid, characteristic_uuid, success, failure);
  }

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
console.log(chipname);console.log(chipIndex);console.log(chipUUID);
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

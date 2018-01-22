var filterOutInitial = 0;

var geoStartTime;
var geoMovingTime = 0;
var geoDistanceInMiles = 0;
var geoActualTimeSpeed = 0;
var geoMovingTimeSpeed = 0;
var geoMovingTimePace = 0;
var geoMovingTimeInSeconds = 0;
var la1, lo1, la2, lo2, ti1, ti2;

function dispTime() {
    var rightNow = new Date();
    if (rightNow.getHours() > 12) {
        if (rightNow.getMinutes() < 10) {
          return (rightNow.getHours() - 12) + ":0" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " PM";
        } else {
          return ((rightNow.getHours() - 12) + ":" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " PM");
        }
      } else {
        if (rightNow.getMinutes() < 10) {
          return ((rightNow.getHours()) + ":0" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " AM");
        } else {
          return ((rightNow.getHours()) + ":" + rightNow.getMinutes() + ":" + rightNow.getSeconds() + " AM");
        }
      }
}

function calculateDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // km
    var dLat = (lat2 - lat1).toRad();
    var dLon = (lon2 - lon1).toRad();
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1.toRad()) * Math.cos(lat2.toRad()) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    la2 = lat1;
    lo2 = lon1;
    return d;
}
Number.prototype.toRad = function () {
    return this * Math.PI / 180;
};

function addGeoTl() {
    var x = dispTime();
    $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + x + ' </time>GEO TRACKER STARTED</div></li>');
  }


function startGeo() {
    console.log("btn1");
    geoEnabled = "YES";

    var x = dispTime();
    $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + x + ' </time>GEO TRACKER START ATTEMPT</div></li>');

    var callbackFn = function (location) {

        filterOutInitial += 1;
        if (filterOutInitial <= 3) {

                la2 = location.latitude;
                lo2 = location.longitude;
                ti2 = new Date();

                var x = dispTime();
                $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + x + ' </time>' + lo2 + ' <br> ' + lo2 + '</div></li>');

                if (filterOutInitial == 3) {
                    geoStartTime = new Date();
                    var gs = dispTime();
                    $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + gs + ' </time> GEO MOVING TIME STARTS NOW </div></li>');
                }

            backgroundGeolocation.finish();
            console.log('End callbackFn');
        } else {

            //console.log('Start of callbackFn');
            //console.log('[js] BackgroundGeolocation callback:  ' + location.latitude + ',' + location.longitude);

            var y = dispTime();
            var z = (location.speed * 2.23694).toFixed(2);
            ti1 = new Date();
            la1 = location.latitude;
            lo1 = location.longitude;

            var distInKiloMeters = calculateDistance(la1, lo1, la2, lo2);
            var distInMiles = (distInKiloMeters * 0.621371 * 100) / 100;

            var rn = new Date();
            // geoMovingTimeInSeconds = Date.dateDiffReturnSeconds('s', geoStartTime, rn);

            if (distInMiles >0) {
                geoMovingTimeInSeconds += Date.dateDiffReturnSeconds('s', ti2, rn);
            }


            geoDistanceInMiles += distInMiles;
            geoActualTimeSpeed = geoDistanceInMiles / (timeSinceStartInSeconds / 60 / 60);
            geoMovingTimeSpeed = geoDistanceInMiles / (geoMovingTimeInSeconds / 60 / 60);
            geoMovingTimePace = 60 / geoMovingTimeSpeed;

            rounds.geoDistance += distInMiles;

            var date = new Date(null);
            date.setSeconds(geoMovingTimeInSeconds);
            var result = date.toISOString().substr(11, 8);

            rt.geoSpeed = location.speed * 2.23694;
            rt.geoDistance = geoDistanceInMiles;
            rt.geoMovingTime = geoMovingTimeInSeconds;
            rt.geoAvgSpeed = geoMovingTimeSpeed;

            if (isFinite(geoMovingTimePace) == true) {
              var d0 = new Date(null);
              d0.setSeconds(60 / geoMovingTimeSpeed); // specify value for SECONDS here
              d0.toISOString().substr(11, 8);
            rt.geoAvgPace = d0;
            }

            if (isFinite(60 / rt.geoSpeed)) {
              var d1 = new Date(null);
              d1.setSeconds(60 / rt.geoSpeed); // specify value for SECONDS here
              d1.toISOString().substr(11, 8);
            rt.geoPace = d1;
            }

            displaySPD();

            if (geoEnabled == "YES") {
              $$(".rtMOVING").text(result);
              $$(".rtAVGSPD").text(geoMovingTimeSpeed.toFixed(1));
              $$(".rtMILES").text(geoDistanceInMiles.toFixed(2) + " MILES");
            }

            $$(".e4").text(rt.geoSpeed.toFixed(1));
            $$(".e15").text(rt.geoAvgPace);
            $$(".e15b").text(rt.geoPace);
            $$(".e14").text(rt.geoDistance.toFixed(2));
            $$(".e17").text(rt.geoAvgSpeed.toFixed(1));


            $$('#btn1').text(geoMovingTimeSpeed.toFixed(0) + ' avg mph');
            $$('#btn2').text(geoDistanceInMiles.toFixed(0) + ' mi');
            $$('#btn3').text(rt.geoAvgPace + ' avg min/mi');
            // $$('#btn4').text(geoMovingTimePace.toFixed(1) + ' min/mi');

            backgroundGeolocation.finish();
            console.log('End callbackFn');

        }


    };  //end callbackFn

    var failureFn = function (error) {
        console.log('BackgroundGeolocation error');
        var x = dispTime();
        $$('#timelineUL').prepend('<li class="in-view"><div><time> ' + x + ' </time>NO GEOLOCATION</div></li>');

    };


    backgroundGeolocation.configure(callbackFn, failureFn, {
        desiredAccuracy: 5,
        stationaryRadius: 10,
        distanceFilter: 10,
        interval: 3000,
        fastestInterval: 1000,
        locationProvider: 1,
        saveBatteryOnBackground: false,
        stopOnTerminate: true
    });

    console.log('backGeoStart - waiting for cb');
    backgroundGeolocation.start();

// });
}

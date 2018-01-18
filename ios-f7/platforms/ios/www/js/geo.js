var filterOutFirstFive = 0;
var distInMilesTotal = 0;



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



function addGeoTl() {
    var x = dispTime();
    $$('#timelineUL').append('<li class="in-view"><div><time> ' + x + ' </time>GEO TRACKER STARTED</div></li>');
  }

$$('#btn1').on('click', function (e) {
    console.log("btn1")
    var x = dispTime();
    $$('#timelineUL').append('<li class="in-view"><div><time> ' + x + ' </time>GEO TRACKER START ATTEMPT</div></li>');

    var callbackFn = function (location) {

        filterOutFirstFive += 1;
        if (filterOutFirstFive < 5) {
            
                la2 = location.latitude;
                lo2 = location.longitude;

                var x = dispTime();
                $$('#timelineUL').append('<li class="in-view"><div><time> ' + x + ' </time>' + lo2 + ' <br> ' + lo2 + '</div></li>');


            backgroundGeolocation.finish();
            console.log('End callbackFn');
        } else {

            console.log('Start of callbackFn');
            console.log('[js] BackgroundGeolocation callback:  ' + location.latitude + ',' + location.longitude);
            console.log('BackgroundGeoSpeed:  ' + location.speed);
    
    
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
    
    
            la1 = location.latitude;
            lo1 = location.longitude;

            var distInKiloMeters = calculateDistance(la1, lo1, la2, lo2);
            var distInMiles = Math.round(distInKiloMeters * 0.621371 * 100) / 100;
            var locationSpeedMph = location.speed * 2.23694;
    
            distInMilesTotal = distInMilesTotal + distInMiles;
            llTotalAvgSpeed = distInMilesTotal / (timeSinceStartInSeconds / 60 / 60);

            $$('#btn1').text(locationSpeedMph.toFixed(2));
            $$('#btn2').text(distInMilesTotal.toFixed(2));
            $$('#btn3').text(llTotalAvgSpeed.toFixed(2));

    
            backgroundGeolocation.finish();
            console.log('End callbackFn');

        }


    }  //end callbackFn

    var failureFn = function (error) {
        console.log('BackgroundGeolocation error');
        var x = dispTime();
        $$('#timelineUL').append('<li class="in-view"><div><time> ' + x + ' </time>NO GEOLOCATION</div></li>');

    };


    backgroundGeolocation.configure(callbackFn, failureFn, {
        desiredAccuracy: 10,
        stationaryRadius: 20,
        distanceFilter: 30,
        interval: 10000,
        stopOnTerminate: true
    });

    console.log('backGeoStart - waiting for cb');
    backgroundGeolocation.start();

});

// Initialize your app
var myApp = new Framework7();

// Export selectors engine
var $$ = Dom7;

var currentTab = 0;
var currentOrientation = "portrait"



// Handle Cordova Device Ready Event
$$(document).on('deviceready', function() {
    console.log("Device is ready!");
});

var mql = window.matchMedia("(orientation: portrait)");
// Add a media query change listener
mql.addListener(function(m) {
	if(m.matches) {
		console.log("portrait")
        currentOrientation = "portrait"

        if (currentTab == 4) {
            myApp.showTab('#view-3');
        }
	}
	else {
		console.log("landscape")
        currentOrientation = "landscape"

        if (currentTab == 3) {
            myApp.showTab('#view-4');
        }

		//if in ride view, change to hz view
	}
});


// Pull to refresh content
var ptrContent = $$('.pull-to-refresh-content');
 
// Add 'refresh' listener on it
ptrContent.on('ptr:refresh', function (e) {
    // Emulate 1s loading
    setTimeout(function () {
		myApp.pullToRefreshDone();
		// alert("Done")
//remove all chips
$$('.blechip').remove();
$$('.blelist').append('<div class="chip chip-extended blechip"><div class="chip-media bg-blue">CSC</div><div class="chip-label">NewBLE</div></div>');

    	}, 750);
});



$$('.chip-label').on('click', function (e) {
    e.preventDefault();
    var chipname = $$(this).attr("class", "chip-label").html();
    console.log(chipname);
    console.log(currentTab);
    // myApp.confirm('Selected - ' + chipname, function () {
    //     console.log(chipname);
    // });
});


$$('#view-4').on('tab:show', function () {
    // myApp.alert('Tab/View 4 is visible');
    currentTab = 4;
    console.log(currentTab)
});  

$$('#view-3').on('tab:show', function () {
    // myApp.alert('Tab/View 3 is visible');
    currentTab = 3;
    console.log(currentTab)
});  

$$('#view-2').on('tab:show', function () {
    // myApp.alert('Tab/View 2 is visible');
    currentTab = 2;
    console.log(currentTab)
});  

// Add views
var view1 = myApp.addView('#view-1');
var view2 = myApp.addView('#view-2', {
    // Because we use fixed-through navbar we can enable dynamic navbar
    dynamicNavbar: true
});
var view3 = myApp.addView('#view-3');
var view4 = myApp.addView('#view-4');


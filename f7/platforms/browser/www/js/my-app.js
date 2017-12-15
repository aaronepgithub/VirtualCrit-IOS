// Initialize your app
var myApp = new Framework7();

// Export selectors engine
var $$ = Dom7;

// Listen for orientation changes
// window.addEventListener("orientationchange", function() {
// 	// Announce the new orientation number
// 	alert(screen.orientation);
// }, false);

var mql = window.matchMedia("(orientation: portrait)");

// If there are matches, we're in portrait
if(mql.matches) {  
	// alert("portrait1")
} else {  
	// alert("landscape1")
}

// Add a media query change listener
mql.addListener(function(m) {
	if(m.matches) {
		alert("portrait2")
	}
	else {
		alert("landscape2")
		//if in ride view, change to hz view
	}
});

// $$('.chip-delete').on('click', function (e) {
//     e.preventDefault();
//     var chip = $$(this).parents('.chip');
//     var chipname = $$(this).siblings().attr("class", "chip-label").html();
//     console.log(chipname);
//     myApp.confirm('Selected - ' + chipname, function () {
//         chip.remove();
//     });
// });

// Pull to refresh content
var ptrContent = $$('.pull-to-refresh-content');
 
// Add 'refresh' listener on it
ptrContent.on('ptr:refresh', function (e) {
    // Emulate 2s loading
    setTimeout(function () {
		myApp.pullToRefreshDone();
		// alert("Done")
    	}, 1000);
});



$$('.chip-label').on('click', function (e) {
    e.preventDefault();
    // var chip = $$(this).parents('.chip');
    // var chipname = $$(this).siblings().attr("class", "chip-label").html();
    var chipname = $$(this).attr("class", "chip-label").html();
    console.log(chipname);
    myApp.confirm('Selected - ' + chipname, function () {
        console.log(chipname);
    });
});

// Add views
var view1 = myApp.addView('#view-1');
var view2 = myApp.addView('#view-2', {
    // Because we use fixed-through navbar we can enable dynamic navbar
    dynamicNavbar: true
});
var view3 = myApp.addView('#view-3');
var view4 = myApp.addView('#view-4');


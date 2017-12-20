var rt = {
  hr: 0,
  speed: 0
};

function onDataHR(data) {
  //console.log(data[1]);
  rt.hr = data[1];
  $$(".rtHR").text(rt.hr);
  $$("#blinker").text("Pull to Refresh (HR)");
  $$("#iconNumber").text(rt.hr);
}

function onDataCSC(data) {

//SOLVED HERE
//https://github.com/Psygraph/pg/blob/4ae63b774dab56a3d3435ed4845675add881eef4/www/js/bluetooth.js


//if data[0] = 3, blueCSC
//data[0] = 1, Wahoo Speed
//anything else must be standalone cad?

  //console.log(data[1]);
//flag is data[0]
console.log("data[0]:  " + data[0]);
if (data[0] == 1) {
  //wheel rev is 1-4, wheel rev time is 5-6, cad is 7-8, cadtime is 9-10
  console.log("cad at data[7]:  " + data[7]);
} else {
  //cadence at [data1]
  console.log("cad at data[1]:  " + data[1]);
}

  //change if cadence only
  rt.speed = data[1];
  $$(".rtSPD").text(rt.speed);
  $$("#blinker").text("Pull to Refresh (CSC)");
}

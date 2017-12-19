var rt = {
  hr        :  0,
  speed     :  0
};

function onDataHR(data) {
  console.log(data[1]);
  rt.hr = data[1];
  $$(".rtHR").text(rt.hr);
$$("#blinker").text("Pull to Refresh (HR)");
$$("#iconNumber").text(rt.hr);
}

function onDataCSC(data) {
  console.log(data[1]);
  rt.speed = data[1];
  $$(".rtSPD").text(rt.speed);
  $$("#blinker").text("Pull to Refresh (CSC)");
}

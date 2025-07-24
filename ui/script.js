
$(document).ready(function () {
  var fuel = 0;
  var speed = 0.0;
  var show = false;
  window.addEventListener("message", function (event) {
    if (event.data.showhud == undefined) {
      fuel = event.data.fuel;
      speed = event.data.speed;
      setFuel(fuel, '.progress-fuel');
      // setFuelGauge(fuel, '.gauge-fuel-needle');
      setSpeed(speed, '.progress-speed');
    }
    if (event.data.showhud == true || event.data.showhud == false) {
      show = event.data.showhud;
    }
    if (show == true) {
      $('#choochoo-hud').show();
      setFuel(fuel, '.progress-fuel');
      // setFuelGauge(fuel, '.gauge-fuel-needle');
      setSpeed(speed, '.progress-speed');
    } else {
      $('#choochoo-hud').hide();
    }
  });

  // Functions
  function setFuel(amount, element) {
    var html = $(element);
    html.text(amount.toFixed(0));
  }
  // function setFuelGauge(amount, element) {
  //   var html = $(element);
  //   var base = -163;
  //   var deg = base - (amount * 10);
  //   html.css("transform", "rotate("+deg+"deg)");
  // }
  function setSpeed(amount, element) {
    var html = $(element);
    html.text(amount.toFixed(1));
  }


});

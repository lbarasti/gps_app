import 'babel-polyfill';
import $script from 'scriptjs'

$script("https://maps.googleapis.com/maps/api/js", () => {
  let map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -34.397, lng: 150.644},
    zoom: 8
  });
})

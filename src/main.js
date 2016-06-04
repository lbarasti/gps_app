import 'babel-polyfill';
import $script from 'scriptjs'

let map_centre = {lat: 51.767, lng: -0.230}

let places = [
  {label: 'Hatfield Station', position: {lat: 51.76373, lng: -0.215564}},
  {label: 'Titan Court', position: {lat: 51.762488, lng: -0.243518}},
  {label: 'Hatfield CFC', position: {lat: 51.771179, lng: -0.242043}} 
];

$script("https://maps.googleapis.com/maps/api/js", () => {
  let map = new google.maps.Map(document.getElementById('map'), {
    center: map_centre,
    zoom: 14
  });
  
  places.map(place => Object.assign({map: map}, place))
    .forEach(placeMarker => new google.maps.Marker(placeMarker));

})

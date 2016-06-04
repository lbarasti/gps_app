import 'babel-polyfill';
import $script from 'scriptjs'

let map_centre = {lat: 51.767, lng: -0.230}
let state = {markers: []}

let setMarkers = (markers) => {
  console.log("setting state.markers", markers);
  state.markers.forEach(marker => marker.setMap(null));
  state.markers = markers;
}

let formatTime = millis => new Date(millis).toLocaleString().split(',')[1]

// TODO: read channel from url query
let fetchMarkerData = () => fetch('/api/channel/ocado/data').then((response) => response.json()).then(positions => {
  return positions.map(({route, serverTime, latitude, longitude}) => {
    return {
      title: `${route} - ${formatTime(serverTime)}`,
      position: {lat: latitude, lng: longitude},
      icon: '/png/black.png'
    }
  });
});

let newMarker = (marker, map) => new google.maps.Marker(Object.assign({map: map}, marker));

let places = [
  {label: 'S', title: 'Hatfield Station', position: {lat: 51.76373, lng: -0.215564}},
  {label: 'T', title: 'Titan Court', position: {lat: 51.762488, lng: -0.243518}},
  {label: 'C', title: 'Hatfield CFC', position: {lat: 51.771179, lng: -0.242043}}
];

$script("https://maps.googleapis.com/maps/api/js", () => {
  let map = new google.maps.Map(document.getElementById('map'), {
    center: map_centre,
    zoom: 14
  });
  let placeMarkers = places.map(marker => newMarker(marker, map))
  
  setInterval(
    () => fetchMarkerData().then(data => setMarkers(data.map(marker => newMarker(marker, map)))), 10000
  )
})

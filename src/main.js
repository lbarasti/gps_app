import 'babel-polyfill';
import _ from 'underscore'
import $script from 'scriptjs'

const MAX_POSITIONS = 4;
let map_centre = {lat: 51.767, lng: -0.230}
let state = {markers: []}

let setMarkers = (map, data) => {
  console.log("setting state.markers", data);
  let newMarkers = data.map(marker => newMarker(marker, map));
  state.markers.forEach(marker => marker.setMap(null));
  state.markers = newMarkers;
}

let fetchAndSet = map => {
  fetchMarkerData().then(data => {
    let dataByRoute = _.groupBy(data, datum => datum.route);
    let markerData = _.map(dataByRoute, positions => _.sortBy(positions, p => -p.timestamp).slice(0, MAX_POSITIONS))
      .map(route => {
        let icons = ['','75','50','25'].map(alpha => `/png/black${alpha}.png`).slice(0, route.length);
        return _.zip(route, icons).map(([{route, serverTime, position}, icon]) => {
          return {
            title: `${route} - ${formatTime(serverTime)}`,
            position: position,
            icon: icon
          }
        })
      });

    setMarkers(map, _.flatten(markerData));
  });
}

let formatTime = millis => new Date(millis).toLocaleString().split(',')[1]

// TODO: read channel from url query
let fetchMarkerData = () => fetch('/api/channel/ocado/data').then((response) => response.json()).then(positions => {
  return positions.map(({route, timestamp, serverTime, latitude, longitude}) => {
    return {
      route: route,
      serverTime: serverTime,
      timestamp: timestamp,
      position: {lat: latitude, lng: longitude},
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
  places.forEach(marker => newMarker(marker, map));
  fetchAndSet(map);
  setInterval(() => fetchAndSet(map), 10000);
})

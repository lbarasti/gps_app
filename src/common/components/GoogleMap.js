import React from "react";
import _ from 'underscore';
import $script from 'scriptjs';

class GoogleMap extends React.Component {
  constructor(props) {
    super(props);
    this.state = { map: null, mapping: null };
  }

  shouldComponentUpdate(nextProps, nextState) {
    // TODO: Check that nextState != this.state
    return true;
  }

  componentWillUpdate(nextProps, nextState) {
    if(nextState.map && nextState.mapping)
      fetchAndSet(nextState.map, nextState.mapping, nextProps.routesData);
  }

  componentDidMount() {
    $script("https://maps.googleapis.com/maps/api/js", () => {
      fetch('/api/channel/ocado/routes-mapping').then((response) => response.json()).then(mapping => {
        this.setState({
          map: new google.maps.Map(document.getElementById('map'), {
            center: this.props.center,
            zoom: 14
          }),
          mapping: mapping
        }, this.drawPlaces);
      });
    })
  }

  drawPlaces() {
    this.props.places.forEach(marker => newMarker(marker, this.state.map));
  }

  render() { // renders an empty div
    return <div></div>;
  }
}

const MAX_POSITIONS = 4;

let state = {markers: [], polylines: []};

let setMarkers = (map, data) => {
  // console.log("setting state.markers", data);
  let newMarkers = data.map(marker => newMarker(marker, map));
  state.markers.forEach(marker => marker.setMap(null));
  state.markers = newMarkers;
}
let setPolyline = (map, data) => {
  // console.log("setting state.polyline", data)
  let newPolylines = data.map(polyline => newPolyline(polyline, map));
  state.polylines.forEach(pl => pl.setMap(null));
  state.polylines = newPolylines;
}

let fetchAndSet = (map, mapping, data) => {
  let dataByRoute = _.groupBy(data, datum => datum.route);
  let routesData = _.map(dataByRoute, positions => _.sortBy(positions, p => -p.timestamp).slice(0, MAX_POSITIONS))
  let markerData = routesData.map(route => {
    let iconOpacity = [1.0 , 0.75 , 0.50 , 0.25].slice(0, route.length);
    return _.zip(route, iconOpacity).map(([{route, serverTime, position}, opacity]) => {
      return {
        title: `${(mapping[route] || {}).name || route} - ${formatTime(serverTime)}`,
        position: position,
        icon: `/png/${(mapping[route] || {}).color || 'black'}.png`,
        opacity: opacity
      }
    })
  });
  let polylineData = routesData.map(route => {
    return {
      path: route.map(({position}) => position),
      geodesic: true,
      strokeColor: 'green',
      strokeOpacity: 0.3,
      strokeWeight: 2
    }
  });

  setMarkers(map, _.flatten(markerData));
  setPolyline(map, polylineData);
}

let formatTime = millis => new Date(millis).toLocaleString().split(',')[1]

let newMarker = (marker, map) => new google.maps.Marker(Object.assign({map: map}, marker));
let newPolyline = (marker, map) => new google.maps.Polyline(Object.assign({map: map}, marker));

export default GoogleMap;
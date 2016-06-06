import React from "react";
import _ from 'underscore';
import $script from 'scriptjs';

class GoogleMap extends React.Component {
  constructor(props) {
    super(props);
    this.state = { map: null };
  }

  shouldComponentUpdate(nextProps, nextState) {
    // TODO: Check that nextState != this.state
    console.log("should update?", !!(nextState.map && nextProps.mapping));
    return !!(nextState.map && nextProps.mapping);
  }

  componentDidMount() {
    $script("https://maps.googleapis.com/maps/api/js", () => {
      this.setState({
        map: new google.maps.Map(document.getElementById('map'), {
          center: this.props.center,
          zoom: 14
        })
      }, this.drawPlaces);
    });
  }

  drawPlaces() {
    this.props.places.forEach(marker => newMarker(marker, this.state.map));
  }

  getColor(route) {
    return (this.props.mapping[route] || {}).color || 'black';
  }

  update() {
    let dataByRoute = _.groupBy(this.props.routesData, datum => datum.route);
    let routesData = _.map(dataByRoute, positions => _.sortBy(positions, p => -p.timestamp).slice(0, MAX_POSITIONS));
    let markerData = routesData.map(routeData => {
      return routeData.map(({route, serverTime, position}, idx) => {
        return {
          title: `${(this.props.mapping[route] || {}).name || route} - ${formatTime(serverTime)}`,
          position: position,
          icon: `/png/${this.getColor(route)}.png`,
          opacity: 1 - idx * 0.25
        }
      })
    });
    let polylineData = routesData.map(routeData => {
      return {
        path: routeData.map(({position}) => position),
        geodesic: true,
        strokeColor: this.getColor(routeData[0].route),
        strokeOpacity: 0.3,
        strokeWeight: 2
      }
    });

    setMarkers(this.state.map, _.flatten(markerData));
    setPolyline(this.state.map, polylineData);
  }

  render() {
    this.update();
    return <div></div>;
  }
}

const MAX_POSITIONS = 4;

let _state = {markers: [], polylines: []};

let setMarkers = (map, data) => {
  // console.log("setting _state.markers", data);
  let newMarkers = data.map(marker => newMarker(marker, map));
  _state.markers.forEach(marker => marker.setMap(null));
  _state.markers = newMarkers;
}
let setPolyline = (map, data) => {
  // console.log("setting _state.polyline", data)
  let newPolylines = data.map(polyline => newPolyline(polyline, map));
  _state.polylines.forEach(pl => pl.setMap(null));
  _state.polylines = newPolylines;
}

let formatTime = millis => new Date(millis).toLocaleString().split(',')[1]

let newMarker = (marker, map) => new google.maps.Marker(Object.assign({map: map}, marker));
let newPolyline = (marker, map) => new google.maps.Polyline(Object.assign({map: map}, marker));

export default GoogleMap;
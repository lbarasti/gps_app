import React from "react";
import styles from "./style.css";
import GoogleMap from '../../common/components/GoogleMap';

const DIV_ID = 'map';

class HomePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {routesData: []};
  }

  componentDidMount() {
    this.fetchMarkerData().then(data => this.setState({routesData: data}));
    setInterval(() => this.fetchMarkerData().then(data => this.setState({routesData: data})), 10000);
  }

  // TODO: read channel from this.props.params
  fetchMarkerData() {
    return fetch('/api/channel/ocado/data').then((response) => response.json()).then(positions => {
      return positions.map(({route, timestamp, serverTime, latitude, longitude}) => {
        return {
          route: route,
          serverTime: serverTime,
          timestamp: timestamp,
          position: {lat: latitude, lng: longitude},
        }
      })
    })
  }

  render() {
    let places = [
      {label: 'S', title: 'Hatfield Station', position: {lat: 51.76373, lng: -0.215564}},
      {label: 'T', title: 'Titan Court', position: {lat: 51.762488, lng: -0.243518}},
      {label: 'C', title: 'Hatfield CFC', position: {lat: 51.771179, lng: -0.242043}}
    ];
    let map_center = {lat: 51.767, lng: -0.230};

    return <div id={DIV_ID}>
      <GoogleMap center={map_center}
                 places={places}
                 routesData={this.state.routesData} />
    </div>;
  }
}

export default HomePage;
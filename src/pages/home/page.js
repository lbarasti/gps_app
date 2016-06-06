import React from "react";
import styles from "./style.css";
import API from '../../api.js';
import GoogleMap from '../../common/components/GoogleMap';

const DIV_ID = 'map';

class HomePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {routesData: [], mappingData: {}};
  }

  componentDidMount() {
    API.fetchMappingData().then(mapping => this.setState({mappingData: mapping}));
    API.fetchMarkerData().then(data => this.setState({routesData: data}));
    setInterval(() => API.fetchMarkerData().then(data => this.setState({routesData: data})), 10000);
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
                 mapping={this.state.mappingData}
                 routesData={this.state.routesData} />
    </div>;
  }
}

export default HomePage;
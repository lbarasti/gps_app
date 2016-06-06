import 'babel-polyfill';

let fetchMappingData = () =>
  fetch('/api/channel/ocado/routes-mapping').then((response) => response.json());

// TODO: read channel from this.props.params
let fetchMarkerData = () =>
  fetch('/api/channel/ocado/data').then((response) => response.json());

export default {
  fetchMappingData: fetchMappingData,
  fetchMarkerData: fetchMarkerData
}
import express from 'express';
const app = express();


/************************************************************
 *
 * Express routes for:
 *   - app.js
 *   - style.css
 *   - index.html
 *
 ************************************************************/

const MAX_POSITIONS = 10;
let state = {channels: {}}

// Serve application file depending on environment
app.get('/app.js', (req, res) => {
  if (process.env.PRODUCTION) {
    res.sendFile(__dirname + '/build/app.js');
  } else {
    res.redirect('//localhost:9090/build/app.js');
  }
});

// Serve aggregate stylesheet depending on environment
app.get('/style.css', (req, res) => {
  if (process.env.PRODUCTION) {
    res.sendFile(__dirname + '/build/style.css');
  } else {
    res.redirect('//localhost:9090/build/style.css');
  }
});

// Serve images
app.use(express.static('public'));

app.get('/api/channel/:channelId/data', (req, res) => {
  res.send(state.channels[req.params.channelId] || [])
});

app.post('/post/:channelId', (req, res) => {
  // TODO: validate req.query
  let gpsData = Object.assign({serverTime: (new Date()).getTime()}, req.query)
  gpsData.latitude = Number.parseFloat(gpsData.latitude);
  gpsData.longitude = Number.parseFloat(gpsData.longitude);
  let chState = state.channels[req.params.channelId];

  let newState = chState ? chState.concat(gpsData) : [gpsData];
  state.channels[req.params.channelId] = (newState.length > MAX_POSITIONS) ? newState.slice(1) : newState
  
  res.send('OK')
});


// Serve index page
app.get('*', (req, res) => {
  res.sendFile(__dirname + '/build/index.html');
});


/*************************************************************
 *
 * Webpack Dev Server
 *
 * See: http://webpack.github.io/docs/webpack-dev-server.html
 *
 *************************************************************/

if (!process.env.PRODUCTION) {
  const webpack = require('webpack');
  const WebpackDevServer = require('webpack-dev-server');
  const config = require('./webpack.local.config');

  new WebpackDevServer(webpack(config), {
    publicPath: config.output.publicPath,
    hot: true,
    noInfo: true,
    historyApiFallback: true
  }).listen(9090, 'localhost', (err, result) => {
    if (err) {
      console.log(err);
    }
  });
}


/******************
 *
 * Express server
 *
 *****************/

const port = process.env.PORT || 8080;
const server = app.listen(port, () => {
  const host = server.address().address;
  const port = server.address().port;

  console.log('Essential React listening at http://%s:%s', host, port);
});

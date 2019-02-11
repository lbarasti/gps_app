/* html for info:
https://jsfiddle.net/sfLjk9da/11/
<div><canvas id="busmap" height=340 width=800>no canvas :(</canvas></div>
*/

/*
  busmap.png data Nov 2018
  if top left = 0,0 then:
  left -0.25 (0) to right -0.21 (800)
  top 51.775 (0) to 51.758
*/
function getWidth(){return 800}
function getHeight(){return 340}
function getRefreshMs(){return 3000}
const dataUrl = "/gethistory/ocado";

var canvas;
var ctx;
var background = new Image();
background.src = "/png/busmap.png";

// Make sure the image is loaded first otherwise nothing will draw.
window.onload = function(){
  canvas = document.getElementById('busmap');
  ctx = canvas.getContext('2d');
  console.log("started");
  startTracker();
}

function startTracker(){
  ctx.drawImage(background,0,0);
  updateData();
}

function updateData(){
  $.getJSON(dataUrl,updateCanvas);

  //test data instead of 
  //var data = makeDemoData(3);
  //updateCanvas(data);
}

function updateCanvas(serverData){
  console.log("updating...",serverData);
  //ctx.clearRect(0,0,getWidth(),getHeight()); // not necessary?
  ctx.drawImage(background,0,0);
  var posData = convertServerToPosData(serverData);
  posData.forEach(function(p){draw(ctx,p)});
  setTimeout(updateData, getRefreshMs());
}

function drawLines(ctx, pos) {
    ctx.beginPath();
  var a = 0;
  pos.forEach( function (p) {
    if (a < 1) {
        ctx.moveTo(p.x, p.y);   
    } else {
        ctx.lineTo(p.x, p.y);
      ctx.strokeStyle = p.c;
            ctx.stroke();
    }
    a++;
  });
}

function getBusPointsR(x0, y0) {
    return [
    {x: x0+10, y: y0},
    {x: x0+10, y: y0+5},
    {x: x0+5, y: y0+5},
    {x: x0+5, y: y0+7},
    {x: x0+3, y: y0+7},
    {x: x0+3, y: y0+5},
    {x: x0-5, y: y0+5},
    {x: x0-5, y: y0+7},
    {x: x0-7, y: y0+7},
    {x: x0-7, y: y0+5},
    {x: x0-10, y: y0+5},
    {x: x0-10, y: y0-5},
    {x: x0, y: y0-5},
    {x: x0+5, y: y0}
  ];
}

function getBusPointsL(x0, y0) {
    return [
    {x: x0-10, y: y0},
    {x: x0-10, y: y0+5},
    {x: x0-5, y: y0+5},
    {x: x0-5, y: y0+7},
    {x: x0-3, y: y0+7},
    {x: x0-3, y: y0+5},
    {x: x0+5, y: y0+5},
    {x: x0+5, y: y0+7},
    {x: x0+7, y: y0+7},
    {x: x0+7, y: y0+5},
    {x: x0+10, y: y0+5},
    {x: x0+10, y: y0-5},
    {x: x0, y: y0-5},
    {x: x0-5, y: y0}
  ];
}

function drawBuses(ctx, pos) {
    ctx.beginPath();
  pos.forEach( function (p) {
    var bus = getBusPointsR(p.x, p.y);
    ctx.moveTo(p.x,p.y)
    bus.forEach( function(q) {
        ctx.lineTo(q.x, q.y);
    })
    ctx.fillStyle = p.c;
    ctx.fill();
  });
}

function draw(ctx,pos) {
    drawLines(ctx, pos);
    drawBuses(ctx, pos);
}

function convertLngLat(lng, lat, w, h) {
  var x = Math.floor(((Number(lng) + 0.25) * w) / 0.04);
  var y = Math.floor(((51.775 - lat) * h) / 0.017);
  return {"x":x,"y":y};
}

function getColour(busId){
  var rgb;
  switch(busId){
    case "ZY322QQM5T":
      rgb = {r:221, g:17, b:17};
      break;
    case "HBEDU18322003635":
      rgb = {r:17, g:221, b:17};
      break;
    case "51af0d8e":
      rgb = {r:17, g:17, b:17};
      break;
    case "ZTDAHMJZ7DZ5MNY5":
      rgb = {r:221, g:187, b:17};
      break;
    case "ZY32363XV4":
      rgb = {r:255, g:153, b:0};
      break;
    default:
      rgb = {
        r: Math.floor(Math.random() * 100),
        g: Math.floor(Math.random() * 100),
        b: 100 + Math.floor(Math.random() * 150)
      };
  }
  return rgb;
}

function convertServerToPosData(serverData){
  return Array.from(Object.keys(serverData), function(busId){
    var col = getColour(busId);
    var dataPoints = serverData[busId].slice(0,4);
    return Array.from(dataPoints, function(entry, index) {
      var xy = convertLngLat(entry.longitude,entry.latitude,getWidth(),getHeight());
      var alpha = (index === 0) ? 1 : ((index < 4) ? (60 - index * 15)/100 : 0);
      var rgba = `rgba(${col.r}, ${col.g}, ${col.b}, ${alpha})`;
      return {x: xy.x, y: xy.y, c:rgba};
    })
  })
}

//DEMO and TEST functionality below:

function makeDemoData(n){
  function makeDemoLocationArray(){
    var t0 = Date.now();
    return Array.from([0,30,60,90,120],x => {
      var ms = t0 - x*1000;
      return {"longitude": Number(Math.random() * 0.04 - 0.25).toFixed(3),
        "latitude": Number(Math.random() * 0.017 + 51.758).toFixed(3),
        "timestamp": new Date(ms).toISOString(),
        "serverseconds": ms,
        "age": x}
      })
  }
  var data = {};
  for (i = 1; i <= n; i++) {
    data[`bus${i}`] = makeDemoLocationArray()
  }
  return data;
}


//TODO: extract server uri to config/setings
//TODO: add phone id:colour mapping (allow driver/sender app to set colour/id)
//TODO: calculate L or R facing bus
//TODO: handle out of bounds (arrow?)
//TODO: add second bit for Remus strip
//TODO: add click detectors at points to send data back to server {id,place}
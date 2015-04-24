LatLng = google.maps.LatLng
Marker = google.maps.Marker
Map = google.maps.Map
LatLngBounds = google.maps.LatLngBounds
Polyline = google.maps.Polyline

#mode = 'ocado'
mode = 'demo'

class Bus
  constructor: (png, clr) ->
    @getPng = -> png
    @getClr = -> clr

black = new Bus 'black', '#111'
red = new Bus 'red', '#D11'
red = new Bus 'green', '#1D1'

getBusForPhone = (phone) ->
  switch phone
    when "HTC Desire C" then black
    when "GT-I8190N" then black
    when "blackberry" then black
    when "HTC Desire S" then red
    when "strawberry" then red
    else green

# cfg
maxLat = 51.7757
minLat = 51.755117
maxLng = -0.208826
minLng = -0.251999
#minLng = -0.235 # for testing

stationX = 51.76373
stationY = -0.215564
titanX = 51.762488
titanY = -0.243518
centerX = 51.764
centerY = -0.230
maxTrail = 5
jsonRefreshInterval = 11500
msPerSecond = 1000
dataUrl = "http://agile-journey-4782.herokuapp.com/gethistory/#{encodeURIComponent mode}?callback=?"

llStation = new LatLng stationX, stationY
llTitan = new LatLng titanX, titanY
center = new LatLng centerX, centerY
bl = new LatLng minLat, minLng
tr = new LatLng maxLat, maxLng
normalBounds = new LatLngBounds bl, tr

getRouteImage = (deviceId, n) ->
  (getBusForPhone(deviceId).getPng() or 'green') + getAlphaString(n) + '.png'

#polyfill
zip = (left, right) -> [a, right[i]] for a, i in left

jsonHdlr = (jd, map, markers, lines, old) ->

  $('#last-checked').text new Date
  myObject = eval jd
  totlength = myObject.length
  outsideArray = for unsortedArray in myObject
    array = unsortedArray.sort((r0, r1) -> r1.timestamp.localeCompare(r0.timestamp))
    zippedArray = zip array, [undefined, array...]
    relevant = zippedArray.slice 0, maxTrail
    for [myInnerObject, oldObject], nr in relevant
      rlabel = myInnerObject.route
      ll = new LatLng myInnerObject.latitude, myInnerObject.longitude
      delta = myInnerObject.age
      console.log "checking for age: " + delta
      image = getRouteImage rlabel, nr
      route = rlabel + nr
      marker = (markers[route] ?=
        new Marker
          position: ll
          map: map
          title: route
          icon: image)
      marker.setPosition ll
      marker.setMap map
      if oldObject?
        oldLl = new LatLng oldObject.latitude, oldObject.longitude
        lines[route]?.setMap(null) # TODO investigate dangling lines
        op = getOpacity nr
        color = getBusForPhone(rlabel).getClr()
        line = new Polyline
          path: [oldLl, ll]
          strokeColor: color
          strokeOpacity: op
          strokeWeight: 2
          map: map
        lines[route] = line
      [delta, not normalBounds.contains ll]

    if (lastRlabel = relevant[relevant.length - 1][0].route)
      markersLines = zip(lines, markers).slice((start = array.length), start + maxTrail)
      for [line, marker] in markersLines
        marker?.setMap(null)
        line?.setMap(null)

  flattenedOutsideArray = outsideArray.reduce ((a, b) -> a.concat(b)), []
  oneIsOutside = flattenedOutsideArray.some(([_, b]) -> b)
  reductor = (last, [next, _]) ->
    if last and next
      Math.max(last, next)
    else
      last or next
    
  recent = flattenedOutsideArray.reduce reductor

  if lastRlabel and recent and recent > 60
    image = getRouteImage lastRlabel, 0
    #TODO injection...
    $('#info')
      .append('<img src='+image+'> last reported '+formatinHMS(recent)+' ago...<br>')

initialize = ->
  mapOptions =
    zoom: 14
    center: center
  
  map = new Map $('#mapcanvas').get(0), mapOptions
  now = new Date
  $.getJSON dataUrl, ((jd) -> jsonHdlr jd, map, [], [], now)

howLongSeconds = (tsString) -> ~~((Date.now() - Date.parse(tsString)) / msPerSecond)
  
# XXX is there a better way?
formatInHMS = (seconds) ->
  hms = [~~(seconds / 3600), ~~((seconds / 60) % 60), seconds % 60]
  [hstr, mstr, sstr] = (("0" + n).slice(-2) for n in hms)
  hstr + ':' + mstr + ':' + sstr

getAlphaString = (n) ->
  switch n
    when n < 1 then ''
    when n < 2 then '75'
    when n < 3 then '50'
    else '25'

getOpacity = (n) ->
  switch n
    when n < 2 then 0.4
    when n < 3 then 0.3
    when n < 4 then 0.2
    else 0.1

#google.maps.event.addDomListener window, 'load', initialize
window.onload = initialize



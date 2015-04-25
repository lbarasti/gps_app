LatLng = google.maps.LatLng
Marker = google.maps.Marker
Map = google.maps.Map
LatLngBounds = google.maps.LatLngBounds
Polyline = google.maps.Polyline

#mode = 'ocado'
mode = 'demo'

class Route
  constructor: (routeId, colorHex) ->

    throw new Error "No route ID set!" unless routeId

    markers = []
    lines = []
    
    delaySelector = "##{encodeURIComponent routeId}"

    getRouteImage = (n) ->
      "/png#{encodeURIComponent routeId}#{encodeURIComponent getAlphaString n}.png"

    warnAboutDelayedBuses = (recent) ->
      if recent and recent > 60
        image = getRouteImage 0
        $(delaySelector).addClass('late').removeClass('on-time')
        $(delaySelector).find('.time').text(formatInHms recent)
      else
        $(delaySelector).addClass('on-time').removeClass('late')

    removeOldLinesAndMarkers = ->
      # I don't think this is correct. one fewer line than marker?
      linesMarkers = zip(lines, markers)
      oldLinesMarkers = linesMarkers.slice((start = array.length), start + maxTrail)
      for [line, marker] in markersLines
        marker?.setMap(null)
        line?.setMap(null)


    drawLineBetweenMarkers = (oldState, fromTo, index) ->
      [oldDelta, oldOneIsOutside, map] = oldState
      [fromPosition, toPosition] = fromTo
      toLl = new LatLng toPosition.latitude, toPosition.longitude
      # What are the units of toPosition.age ?
      routeSegmentId = routeId + index
      marker =
        new Marker
          position: toLl
          map: map
          title: routeSegmentId
          icon: getRouteImage index
      marker.setPosition toLl
      marker.setMap map
      markers.unshift marker
  
      if fromPosition?
        fromLl = new LatLng fromPosition.latitude, fromPosition.longitude
        line = new Polyline
          path: [fromLl, toLl]
          strokeColor: colorHex
          strokeOpacity: getOpacity index
          strokeWeight: 2
          map: map

        lines.unshift(line)

      newDelta = if oldDelta and (age = toPosition.age)
        Math.max(oldDelta, age)
      else
        oldDelta or age

      newOneIsOutside = oldOneIsOutside or not normalBounds.contains toLl

      [newDelta, newOneIsOutside, map]

    @render = (routeUnsorted, map) ->
      route = routeUnsorted.sort((r0, r1) -> r1.timestamp.localeCompare(r0.timestamp))
      routeFromTo = zip [undefined, route...], route
      relevantRouteFromTo = routeFromTo.slice 0, maxTrail
      initState = [0, false, map]
      finalState = relevantRouteFromTo.reduce(drawLineBetweenMarkers, initState)
      [recent, oneIsOutside, _] = finalState
      warnAboutDelayedBuses recent
      [oneIsOutside, relevantRouteFromTo.length]

  @black = new Route 'black', '#111'
  @red = new Route 'red', '#D11'
  @green = new Route 'green', '#1D1'

  @getRouteForPhone = (phoneId) ->
    switch phoneId
      when "HTC Desire C" then @black
      when "GT-I8190N" then @black
      when "blackberry" then @black
      when "HTC Desire S" then @red
      when "strawberry" then @red
      else @green

# cfg
maxLat = 51.7757
minLat = 51.755117
maxLng = -0.208826
minLng = -0.251999
#minLng = -0.235 # for testing

normalZone = new google.maps.Rectangle
  strokeColor: '#22DD22'
  strokeOpacity: 0.7
  strokeWeight: 2
  fillColor: '#22DD22'
  fillOpacity: 0.1
  bounds: normalBounds

stationX = 51.76373
stationY = -0.215564
titanX = 51.762488
titanY = -0.243518
centerX = 51.764
centerY = -0.230
maxTrail = 5
jsonRefreshInterval = 11500
msPerSecond = 1000
dataUrl = "/gethistory/#{encodeURIComponent mode}?callback=?"

llStation = new LatLng stationX, stationY
llTitan = new LatLng titanX, titanY
center = new LatLng centerX, centerY
bl = new LatLng minLat, minLng
tr = new LatLng maxLat, maxLng
normalBounds = new LatLngBounds bl, tr

#polyfill
zip = (left, right) -> [left[i], a] for a, i in right

jsonHdlr = (routes, map, oldValidity) ->

  $('#last-checked').text new Date

  warnings = for phoneId, routeContent of routes
    route = Route.getRouteForPhone phoneId
    route.render routeContent, map

  oneIsOutside = warnings.some(([oneIsOutside, _]) -> oneIsOutside)
  totLength = warnings.some(([_, length]) -> length)
  

  if totLength
    $("#missing-bus-info").addClass("hide").removeClass("show")
    if oneIsOutside
      normalZone.setMap map
      $("#one-is-outside").addClass("show").removeClass("hide")
    else
      normalZone.setMap null
      $("#one-is-outside").addClass("hide").removeClass("show")
  else
    $("#missing-bus-info").addClass("show").removeClass("hide")

  newValidity = new Date

  delay = Math.max(jsonRefreshInterval - (newValidity - oldValidity), 0)
  setTimeout (-> $.getJSON dataUrl, (d) -> jsonHdlr d, map, newValidity), delay


initialize = ->
  mapOptions =
    zoom: 14
    center: center
  
  map = new Map $('#mapcanvas').get(0), mapOptions
  now = new Date
  new Marker
    position: llStation
    map: map
    title: 'Station'

  new Marker
    position: llTitan
    map: map
    title: 'Titan'

  $.getJSON dataUrl, ((jd) -> jsonHdlr jd, map, now)


# XXX is there a better way?
# eg Date::toLocaleString ?
formatInHms = (seconds) ->
  hms = [~~(seconds / 3600), ~~((seconds / 60) % 60), seconds % 60]
  [hstr, mstr, sstr] = (("0" + n).slice(-2) for n in hms)
  hstr + ':' + mstr + ':' + sstr

getAlphaString = (n) ->
  switch
    when n < 1 then ''
    when n < 2 then '75'
    when n < 3 then '50'
    else '25'

getOpacity = (n) ->
  switch
    when n < 2 then 0.4
    when n < 3 then 0.3
    when n < 4 then 0.2
    else 0.1

window.onload = initialize



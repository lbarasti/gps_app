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

    lines = []
    markers = []
    
    delaySelector = "##{encodeURIComponent routeId}"

    getRouteImage = (n) ->
      "/png/#{encodeURIComponent routeId}#{encodeURIComponent getAlphaString n}.png"

    warnAboutDelayedBuses = (recent) ->
      if recent and recent > 60
        image = getRouteImage 0
        $(delaySelector).addClass('late').removeClass('on-time')
        $(delaySelector).find('.time').text(formatInHms recent)
      else
        $(delaySelector).addClass('on-time').removeClass('late')

    removeOldLinesAndMarkers = ->
      linesMarkers = zip(lines, markers)
      for [line, marker] in linesMarkers
        marker?.setMap(null)
        line?.setMap(null)


    drawLineBetweenMarkers = (oldState, fromTo, index) ->
      [oldDelta, oldOneIsOutside, oldLines, oldMarkers, map] = oldState
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
  
      line = if fromPosition?
        fromLl = new LatLng fromPosition.latitude, fromPosition.longitude
        new Polyline
          path: [fromLl, toLl]
          strokeColor: colorHex
          strokeOpacity: getOpacity index
          strokeWeight: 2
          map: map

      newDelta = if (age = toPosition.age) and oldDelta
        Math.max(oldDelta, age)
      else
        oldDelta or age

      newOneIsOutside = oldOneIsOutside or not normalBounds.contains toLl

      [newDelta, newOneIsOutside, [oldLines..., line], [oldMarkers..., marker], map]

    @render = (routeUnsorted, map) ->
      route = routeUnsorted.sort((r0, r1) -> r1.timestamp.localeCompare(r0.timestamp))
      routeFromTo = zip [undefined, route...], route
      relevantRouteFromTo = routeFromTo.slice 0, maxTrail
      initState = [0, false, [], [], map]
      finalState = relevantRouteFromTo.reduce(drawLineBetweenMarkers, initState)
      [recent, oneIsOutside, newLines, newMarkers, _] = finalState
      warnAboutDelayedBuses recent
      removeOldLinesAndMarkers()

      # TODO can we get rid of the destructive assignation here?
      lines = newLines
      markers = newMarkers

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
secondsPerHour = 3600
secondsPerMinute = 60
minutesPerHour = 60
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


# TODO is there a better way?
# eg Date::toLocaleString ?
# Also what if the delay is more than 100h?
formatInHms = (seconds) ->
  h = ~~(seconds / secondsPerHour)
  m = ~~((seconds / secondsPerMinute) % minutesPerHour)
  s = seconds % secondsPerMinute
  [hstr, mstr, sstr] = (("0" + n).slice(-2) for n in [h, m, s])
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



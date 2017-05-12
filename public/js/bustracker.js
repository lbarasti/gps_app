(function() {
  var validChannelHandler,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  validChannelHandler = function(channels, pathname, cb) {
    var _, i, modeHint, ref;
    ref = pathname.split('/'), _ = 2 <= ref.length ? slice.call(ref, 0, i = ref.length - 1) : (i = 0, []), modeHint = ref[i++];
    return this.mode = indexOf.call(channels, modeHint) >= 0 ? cb(modeHint) : $(function() {
      return document.write("You are not supposed to be on this page.");
    });
  };

  this.getMode = function(cb) {
    var pathname;
    if ((pathname = document.location.pathname) === '/') {
      return cb('ocado');
    } else {
      return $.getJSON('/channels', function(d) {
        return validChannelHandler(d, pathname, cb);
      });
    }
  };

}).call(this);

(function() {
  var LatLng, LatLngBounds, Map, Marker, Polyline, bl, center, centerX, centerY, cfcX, cfcY, defaultZoom, formatInHms, getGetRouteForPhone, getRouteForPhone, handleMissingAndDubiousBusInfo, initialize, jsonHdlr, jsonRefreshInterval, llCfc, llStation, llTitan, llTrident, maxLat, maxLatenessSeconds, maxLng, maxTrail, minLat, minLng, minutesPerHour, modeHandler, msPerSecond, normalBounds, normalZone, secondsPerHour, secondsPerMinute, stationX, stationY, titanX, titanY, tr, tridentX, tridentY, zip,
    slice = [].slice;

  LatLng = google.maps.LatLng;

  Marker = google.maps.Marker;

  Map = google.maps.Map;

  LatLngBounds = google.maps.LatLngBounds;

  Polyline = google.maps.Polyline;

  getGetRouteForPhone = function() {
    var Route, black, green, red;
    Route = (function() {
      function Route(routeId, colorHex) {
        var delaySelector, drawLineBetweenMarkers, encodedRouteId, getRouteImage, lines, markers, removeOldLinesAndMarkers, warnAboutDelayedBuses;
        if (!routeId) {
          throw new Error("No route ID set!");
        }
        lines = [];
        markers = [];
        encodedRouteId = encodeURIComponent(routeId);
        delaySelector = "#" + encodedRouteId;
        getRouteImage = function(n) {
          var getAlphaString;
          getAlphaString = function(n) {
            switch (false) {
              case !(n < 1):
                return '';
              case !(n < 2):
                return '75';
              case !(n < 3):
                return '50';
              default:
                return '25';
            }
          };
          return "/png/" + encodedRouteId + (encodeURIComponent(getAlphaString(n))) + ".png";
        };
        warnAboutDelayedBuses = function(latenessSeconds) {
          if (latenessSeconds && latenessSeconds > maxLatenessSeconds) {
            $(delaySelector).addClass('late').removeClass('on-time');
            return $(delaySelector).find('.time').text(formatInHms(latenessSeconds));
          } else {
            return $(delaySelector).addClass('on-time').removeClass('late');
          }
        };
        removeOldLinesAndMarkers = function() {
          var j, len, line, linesMarkers, marker, ref, results;
          linesMarkers = zip(lines, markers);
          results = [];
          for (j = 0, len = linesMarkers.length; j < len; j++) {
            ref = linesMarkers[j], line = ref[0], marker = ref[1];
            if (marker != null) {
              marker.setMap(null);
            }
            results.push(line != null ? line.setMap(null) : void 0);
          }
          return results;
        };
        drawLineBetweenMarkers = function(oldState, fromTo, index) {
          var age, fromLl, fromPosition, getOpacity, line, map, marker, newLatenessSeconds, oldIsDubious, oldLatenessSeconds, oldLines, oldMarkers, routeSegmentId, toLl, toPosition;
          getOpacity = function(n) {
            switch (false) {
              case !(n < 2):
                return 0.4;
              case !(n < 3):
                return 0.3;
              case !(n < 4):
                return 0.2;
              default:
                return 0.1;
            }
          };
          oldLatenessSeconds = oldState[0], oldIsDubious = oldState[1], oldLines = oldState[2], oldMarkers = oldState[3], map = oldState[4];
          fromPosition = fromTo[0], toPosition = fromTo[1];
          toLl = new LatLng(toPosition.latitude, toPosition.longitude);
          routeSegmentId = routeId + index;
          marker = new Marker({
            position: toLl,
            map: map,
            title: routeSegmentId,
            icon: getRouteImage(index)
          });
          marker.setPosition(toLl);
          marker.setMap(map);
          line = fromPosition != null ? (fromLl = new LatLng(fromPosition.latitude, fromPosition.longitude), new Polyline({
            path: [fromLl, toLl],
            strokeColor: colorHex,
            strokeOpacity: getOpacity(index),
            strokeWeight: 2,
            map: map
          })) : void 0;
          newLatenessSeconds = (age = toPosition.age) && oldLatenessSeconds ? Math.min(oldLatenessSeconds, age) : oldLatenessSeconds || age;
          return [newLatenessSeconds, oldIsDubious || !normalBounds.contains(toLl), slice.call(oldLines).concat([line]), slice.call(oldMarkers).concat([marker]), map];
        };
        this.render = function(routeUnsorted, map) {
          var _, finalState, initState, isDubious, latenessSeconds, newLines, newMarkers, relevantRouteFromTo, route, routeFromTo;
          route = routeUnsorted.sort(function(r0, r1) {
            return r1.timestamp.localeCompare(r0.timestamp);
          });
          routeFromTo = zip([void 0].concat(slice.call(route)), route);
          relevantRouteFromTo = routeFromTo.slice(0, maxTrail);
          initState = [0, false, [], [], map];
          finalState = relevantRouteFromTo.reduce(drawLineBetweenMarkers, initState);
          latenessSeconds = finalState[0], isDubious = finalState[1], newLines = finalState[2], newMarkers = finalState[3], _ = finalState[4];
          warnAboutDelayedBuses(latenessSeconds);
          removeOldLinesAndMarkers();
          lines = newLines;
          markers = newMarkers;
          return [isDubious, relevantRouteFromTo.length];
        };
      }

      return Route;

    })();
    black = new Route('black', '#111');
    red = new Route('red', '#D11');
    green = new Route('green', '#1D1');
    return function(phoneId) {
      switch (phoneId) {
        case "8c514cdf":
          return red;
        case "61a13865":
          return green;
        case "51af0d8e":
          return black;
        case "HTC Desire C":
          return black;
        case "GT-I8190N":
          return black;
        case "blackberry":
          return black;
        case "HTC Desire S":
          return red;
        case "strawberry":
          return red;
        default:
          return green;
      }
    };
  };

  getRouteForPhone = getGetRouteForPhone();

  normalZone = new google.maps.Rectangle({
    strokeColor: '#22DD22',
    strokeOpacity: 0.7,
    strokeWeight: 2,
    fillColor: '#22DD22',
    fillOpacity: 0.1,
    bounds: normalBounds
  });

  stationX = 51.76373;

  stationY = -0.215564;

  titanX = 51.762488;

  titanY = -0.243518;

  tridentX = 51.768939;

  tridentY = -0.235301;

  cfcX = 51.770482;

  cfcY = -0.244763;

  centerX = 51.764;

  centerY = -0.230;

  maxTrail = 5;

  jsonRefreshInterval = 11500;

  defaultZoom = 14;

  maxLat = 51.7757;

  minLat = 51.755117;

  maxLng = -0.208826;

  minLng = -0.251999;

  maxLatenessSeconds = 60;

  msPerSecond = 1000;

  secondsPerMinute = 60;

  secondsPerHour = 3600;

  minutesPerHour = 60;

  llStation = new LatLng(stationX, stationY);

  llTitan = new LatLng(titanX, titanY);

  llTrident = new LatLng(tridentX, tridentY);

  llCfc = new LatLng(cfcX, cfcY);

  center = new LatLng(centerX, centerY);

  bl = new LatLng(minLat, minLng);

  tr = new LatLng(maxLat, maxLng);

  normalBounds = new LatLngBounds(bl, tr);

  handleMissingAndDubiousBusInfo = function(isDubious, isMissing, map) {
    if (isMissing) {
      return $("#missing-bus-info").removeClass("hidden");
    } else {
      $("#missing-bus-info").addClass("hidden");
      if (isDubious) {
        normalZone.setMap(map);
        return $("#one-is-outside").removeClass("hidden");
      } else {
        normalZone.setMap(null);
        return $("#one-is-outside").addClass("hidden");
      }
    }
  };

  zip = function(left, right) {
    var a, i, j, len, results;
    results = [];
    for (i = j = 0, len = right.length; j < len; i = ++j) {
      a = right[i];
      results.push([left[i], a]);
    }
    return results;
  };

  jsonHdlr = function(routes, map, oldValidity, dataUrl) {
    var delay, isDubious, isMissing, newValidity, phoneId, route, routeContent, warnings;
    $('#last-checked').text(new Date);
    warnings = (function() {
      var results;
      results = [];
      for (phoneId in routes) {
        routeContent = routes[phoneId];
        route = getRouteForPhone(phoneId);
        results.push(route.render(routeContent, map));
      }
      return results;
    })();
    isDubious = warnings.some(function(arg) {
      var _, isDubious;
      isDubious = arg[0], _ = arg[1];
      return isDubious;
    });
    isMissing = !warnings.some(function(arg) {
      var _, length;
      _ = arg[0], length = arg[1];
      return length;
    });
    handleMissingAndDubiousBusInfo(isDubious, isMissing, map);
    newValidity = new Date;
    delay = Math.max(jsonRefreshInterval - (newValidity - oldValidity), 0);
    return setTimeout((function() {
      return $.getJSON(dataUrl, function(d) {
        return jsonHdlr(d, map, newValidity, dataUrl);
      });
    }), delay);
  };

  initialize = function(dataUrl) {
    var map, mapOptions, now;
    mapOptions = {
      zoom: defaultZoom,
      center: center
    };
    map = new Map($('#mapcanvas').get(0), mapOptions);
    now = new Date;
    new Marker({
      position: llStation,
      map: map,
      title: 'Station'
    });
    new Marker({
      position: llTitan,
      map: map,
      title: 'Titan'
    });
    new Marker({
      position: llTrident,
      map: map,
      title: 'Trident'
    });
    new Marker({
      position: llCfc,
      map: map,
      title: 'CFC'
    });
    return $.getJSON(dataUrl, (function(jd) {
      return jsonHdlr(jd, map, now, dataUrl);
    }));
  };

  formatInHms = function(seconds) {
    var h, m, n, s;
    h = ~~(seconds / secondsPerHour);
    m = ~~((seconds / secondsPerMinute) % minutesPerHour);
    s = seconds % secondsPerMinute;
    return ((function() {
      var j, len, ref, results;
      ref = [h, m, s];
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        n = ref[j];
        results.push(("0" + n).slice(-2));
      }
      return results;
    })()).join(':');
  };

  modeHandler = function(mode) {
    var dataUrl;
    dataUrl = "/gethistory/" + (encodeURIComponent(mode));
    return $(function() {
      return initialize(dataUrl);
    });
  };

  getMode(modeHandler);

}).call(this);

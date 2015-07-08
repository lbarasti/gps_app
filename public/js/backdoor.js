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
  getMode(function(mode) {
    return $(function() {
      return $('form').attr('action', "/post/" + (encodeURIComponent(mode)));
    });
  });

}).call(this);

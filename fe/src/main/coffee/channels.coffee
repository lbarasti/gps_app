
validChannelHandler = (channels, pathname, cb) ->
  [_..., modeHint] = pathname.split '/'
  @mode = if modeHint in channels
    cb modeHint
  else
    $ -> document.write "You are not supposed to be on this page."

@getMode = (cb) ->
  #special case
  if (pathname = document.location.pathname) is '/'
    cb 'ocado'
  else
    $.getJSON '/channels', (d) -> validChannelHandler d, pathname, cb

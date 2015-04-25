
channels = ['ocado', 'demo']
[_..., modeHint] = document.location.pathname.split '/'
@mode = if modeHint in channels
  modeHint
else
  $ -> document.write "You are not supposed to be on this page."


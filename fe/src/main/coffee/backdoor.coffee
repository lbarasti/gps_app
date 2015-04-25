# TODO shared with bustracker.coffee - move to common location
channels = ['ocado', 'demo']
[_..., modeHint] = document.location.pathname.split '/'
mode = if modeHint in channels then modeHint else 'ocado'
@onload = -> $('form').attr('action', "/post/#{encodeURIComponent mode}")

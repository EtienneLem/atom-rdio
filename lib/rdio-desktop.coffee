applescript = require 'applescript'

module.exports =
class RdioDesktop
  @COMMANDS = [
    { name: 'add',      function: 'execute', action: 'add to collection' }
    { name: 'next',     function: 'execute', action: 'next track' }
    { name: 'pause',    function: 'execute', action: 'pause' }
    { name: 'play',     function: 'execute', action: 'play' }
    { name: 'previous', function: 'execute', action: 'previous track' }
    { name: 'remove',   function: 'execute', action: 'remove form collection' }
    { name: 'sync',     function: 'execute', action: 'sync to mobile' }
    { name: 'toggle',   function: 'execute', action: 'playpause' }
    { name: 'unsync',   function: 'execute', action: 'remove from mobile' }
  ]

  # States methods
  currentState:  (callback) -> this.get('player state', callback)

  currentAlbum:  (callback) -> this.getCurrent('album',    callback)
  currentArtist: (callback) -> this.getCurrent('artist',   callback)
  currentTrack:  (callback) -> this.getCurrent('name',     callback)
  currentUrl:    (callback) -> this.getCurrent('rdio url', callback)

  # Dynamic commands methods
  constructor: ->
    for command in RdioDesktop.COMMANDS
      do (command) ->
        RdioDesktop::[command.name] = ->
          this[command.function](command.action)

  currentlyPlaying: (callback) ->
    this.currentArtist (artist) =>
      this.currentTrack (track) =>
        this.currentUrl (url) =>
          callback
            artist: artist
            track: track
            url: url

  # AppleScript helpers
  getCurrent: (data, callback) ->
    this.get("#{data} of the current track", callback)

  get: (data, callback) ->
    this.execute("get the #{data}", callback)

  execute: (action, callback) ->
    # Data is always undefined without this setTimeout
    setTimeout =>
      command = "if application \"Rdio\" is running then tell application \"Rdio\" to #{action}"
      applescript.execString command, (err, data) =>
        callback?(data)
    , 0

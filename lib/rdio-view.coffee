{View} = require 'atom'
open = require 'open'
RdioDesktop = require './rdio-desktop'

module.exports =
class RdioView extends View
  @content: ->
    @div class: 'rdio inline-block', =>
      @div outlet: 'container', class: 'rdio-container', =>
        @span outlet: 'soundBars', class: 'rdio-sound-bars', =>
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'

        @a outlet: 'currentlyPlaying', href: 'javascript:',''

  initialize: ->
    @currentTrack = {}
    @currentState = null
    @initiated = false
    @rdioDesktop = new RdioDesktop

    this.addCommands()

    # Make sure the view gets added last
    this.subscribe atom.packages.once 'activated', =>
      setTimeout this.attach, 1

  # Commands
  addCommands: ->
    for command in RdioDesktop.COMMANDS
      do (command) =>
        atom.workspaceView.command "rdio:#{command.name}", '.editor', => @rdioDesktop[command.name]()

  # Attach the view to the farthest right of the status bar
  attach: =>
    atom.workspaceView.statusBar.appendRight(this)

    # Navigate to current track inside Rdio
    @currentlyPlaying.on 'click', (e) ->
      open(this.href)

  afterAttach: =>
    setInterval =>
      @rdioDesktop.currentState (state) =>
        if state isnt @currentState
          @currentState = state
          @soundBars.attr('data-state', state)

        # Rdio is closed
        if state is undefined
          if @initiated
            @initiated = false
            @container.removeAttr('data-initiated')
          return

        # Rdio is paused, but we know about the current track
        return if state is 'paused' and @initiated

        # Get current track data
        @rdioDesktop.currentlyPlaying (data) =>
          return unless data.artist and data.track
          return if data.artist is @currentTrack.artist and data.track is @currentTrack.track
          @currentlyPlaying.text "#{data.artist} - #{data.track}"
          @currentlyPlaying.attr 'href', "rdio://www.rdio.com#{data.url}"
          @currentTrack = data

          # Display container when hidden
          return if @initiated
          @initiated = true
          @container.attr('data-initiated', true)
    , 1500

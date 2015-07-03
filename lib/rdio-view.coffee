{$, View} = require 'atom-space-pen-views'
open = require 'open'
md5 = require 'MD5'
RdioDesktop = require './rdio-desktop'

module.exports =
class RdioView extends View
  @content: ->
    @div class: 'rdio', =>
      @div outlet: 'container', class: 'rdio-container inline-block', =>
        @span outlet: 'soundBars', class: 'rdio-sound-bars', =>
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'
          @span class: 'rdio-sound-bar'

        @a outlet: 'currentlyPlaying', href: 'javascript:',''

  initialize: (statusBar) ->
    @statusBar = statusBar
    @currentTrack = {}
    @currentState = null
    @initiated = false
    @rdioDesktop = new RdioDesktop

    @addCommands()
    @attach()

  destroy: ->
    @detach()

  # Commands
  addCommands: ->
    # Defaults
    for command in RdioDesktop.COMMANDS
      do (command) =>
        atom.commands.add 'atom-workspace', "rdio:#{command.name}", => @rdioDesktop[command.name]()

    # Open current track with Rdio.app
    atom.commands.add 'atom-workspace', 'rdio:open-current-track', => @openWithRdio(@currentlyPlaying.attr('href'))

    # Play song based on current file or selection
    atom.commands.add 'atom-workspace', 'rdio:play-code-mood', @currentMood

  # Current mood
  currentMood: =>
    editor = atom.workspaceView.getActivePaneItem()
    content = (editor.getSelectedText() || editor.getText()).replace(/(\n)/gm, '')

    # Get the first 7 digits of the md5 string
    digits = md5(content).replace(/\D/g, '').substring(0, 6)
    console.log "Rdio Code Mood: See http://rdioconsole.appspot.com/#keys%3Dt#{digits}%26method%3Dget for more track info."
    @rdioDesktop.playTrack(digits)

  # Attach the view to the farthest right of the status bar
  attach: =>
    @statusBarTile = @statusBar.addRightTile(item: this, priority: 100)

    # Navigate to current track inside Rdio
    @currentlyPlaying.on 'click', (e) =>
      @openWithRdio(e.currentTarget.href)

    # Toggle equalizer on config change
    atom.config.observe 'Rdio.showEqualizer', (value) =>
      @toggleEqualizer(value)

  openWithRdio: (href) ->
    open(href)

  toggleEqualizer: (show) ->
    if show
      @soundBars.removeAttr('data-hidden')
    else
      @soundBars.attr('data-hidden', true)

  attached: =>
    setInterval =>
      @rdioDesktop.currentState (state) =>
        if state isnt @currentState
          @currentState = state
          @soundBars.attr('data-state', state)

        # Rdio is closed
        if state is undefined
          if @initiated
            @initiated = false
            @currentTrack = {}
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

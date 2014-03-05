{View} = require 'atom'
open = require 'open'
md5 = require 'MD5'
RdioDesktop = require './rdio-desktop'

module.exports =
class RdioView extends View
  @CONFIGS = {
    showEqualizer:
      key: 'showEqualizer (WindowResizePerformanceIssue )'
      action: 'toggleEqualizer'
      default: true
  }

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
    if atom.workspaceView.statusBar
      this.attach()
    else
      this.subscribe atom.packages.once 'activated', =>
        setTimeout this.attach, 1

  destroy: ->
    this.detach()

  # Commands
  addCommands: ->
    # Defaults
    for command in RdioDesktop.COMMANDS
      do (command) =>
        atom.workspaceView.command "rdio:#{command.name}", '.editor', => @rdioDesktop[command.name]()

    # Open current track with Rdio.app
    atom.workspaceView.command 'rdio:open-current-track', '.editor', =>
      this.openWithRdio(@currentlyPlaying.attr('href'))

    # Play song based on current file or selection
    atom.workspaceView.command 'rdio:play-code-mood', '.editor', this.currentMood

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
    atom.workspaceView.statusBar.appendRight(this)

    # Navigate to current track inside Rdio
    @currentlyPlaying.on 'click', (e) =>
      this.openWithRdio(e.currentTarget.href)

    # Toggle equalizer on config change
    showEqualizerKey = "rdio.#{RdioView.CONFIGS.showEqualizer.key}"
    this.subscribe atom.config.observe showEqualizerKey, callNow: true, =>
      if atom.config.get(showEqualizerKey)
        @soundBars.removeAttr('data-hidden')
      else
        @soundBars.attr('data-hidden', true)

  openWithRdio: (href) ->
    open(href)

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

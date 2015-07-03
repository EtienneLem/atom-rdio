RdioView = require './rdio-view'

module.exports =
  config:
    showEqualizer:
      title: 'Show Equalizer'
      description: 'May cause window resize performance issues'
      type: 'boolean'
      default: true

  consumeStatusBar: (statusBar) ->
    @rdioView = new RdioView(statusBar)

  deactivate: ->
    @rdioView?.destroy()

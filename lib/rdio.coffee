RdioView = require './rdio-view'

module.exports =
  activate: (state) ->
    @rdioView = new RdioView(state.rdioViewState)

  deactivate: ->
    @rdioView.destroy()

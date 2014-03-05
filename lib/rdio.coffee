RdioView = require './rdio-view'

module.exports =
  configDefaults: do ->
    configs = {}
    for configName, configData of RdioView.CONFIGS
      configs[configData.key] = configData.default

    configs

  activate: (state) ->
    @rdioView = new RdioView(state.rdioViewState)

  deactivate: ->
    @rdioView.destroy()

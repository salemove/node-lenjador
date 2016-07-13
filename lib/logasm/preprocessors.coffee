module.exports.getPreprocessor = (type, args) ->
  Preprocessor = require "./preprocessors/#{type}"
  new Preprocessor(args)

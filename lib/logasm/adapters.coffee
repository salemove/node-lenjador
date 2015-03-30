module.exports.getAdapter = (type, serviceName, args) ->
  Adapter = require "./adapters/#{type}_adapter"
  level = args['level'] || 'debug'
  new Adapter(level, serviceName, args)

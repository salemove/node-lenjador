_  = require 'underscore'
adaptersFactory = require('./logasm/adapters')

class Logasm
  @build: (serviceName, loggersConfig) ->
    loggersConfig = {stdout: {}} if loggersConfig is undefined
    adapters = for type, args of loggersConfig
      adaptersFactory.getAdapter(type, serviceName, args)

    new Logasm(adapters)

  constructor:(adapters) ->
    @adapters = adapters

  silly: ->
    @log 'silly', arguments

  debug: ->
    @log 'debug', arguments

  verbose: ->
    @log 'verbose', arguments

  info: ->
    @log 'info', arguments

  warn: ->
    @log 'warn', arguments

  error: ->
    @log 'error', arguments

  log: (level, args) =>
    data = @parseLogData.apply(@, args)
    for adapter in @adapters
      adapter.log level, data

  parseLogData: (message, metadata) ->
    if @isHash(message)
      message
    else
      data = {}

      if metadata instanceof Error
        data['error'] = metadata.toString()
        data['error.stack_trace'] = metadata.stack if metadata.stack
      else
        _.extend(data, metadata)

      if message instanceof Error
        data['error'] = message.toString()
        data['error.stack_trace'] = message.stack if message.stack

      data['message'] = message
      data

  isHash: (obj) =>
    return false unless obj instanceof Object
    if Object.keys(obj).length then true else false

module.exports = Logasm

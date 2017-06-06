winston = require('winston')
buildEvent = require('../event')

class StdoutAdapter
  constructor:(level, _serviceName, options) ->
    @logger = new winston.Logger
    @logger.add winston.transports.Console,
      json: Boolean(options.json)
      timestamp: !Boolean(options.json) # Json adds @timestamp manually
      level: level
      colorize: true
      stringify: (obj) -> JSON.stringify(obj)

  log: (level, args) ->
    event = buildEvent(args)
    message = event['message']

    if message
      delete event['message']
      @logger.log level, message, event
    else
      @logger.log level, event

module.exports = StdoutAdapter

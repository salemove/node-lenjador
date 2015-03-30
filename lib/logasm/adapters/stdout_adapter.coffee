winston = require('winston')
_  = require 'underscore'

class StdoutAdapter
  constructor:(level) ->
    @logger = new winston.Logger
    @logger.add winston.transports.Console,
      timestamp: ->
        "#{new Date().toISOString()} ##{process.pid}"
      level: level
      colorize: true

  log:(level, args) ->
    args = _.extend({}, args)
    message = args['message']

    if message
      delete args['message']
      @logger.log level, message, args
    else
      @logger.log level, args

module.exports = StdoutAdapter

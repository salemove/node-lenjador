winston = require('winston')
_  = require 'underscore'
LogstashUDP = require('winston-logstash-udp').LogstashUDP

class LogstashAdapter
  constructor:(level, service, {host, port}) ->
    @logger = new winston.Logger

    options =
      port: port or 5229
      appName: service if service
      host: host or "127.0.0.1"
      level: level or 'info'
      timestamp: winston.timestamp

    @logger.add LogstashUDP, options

  log:(level, args) ->
    args = _.extend({}, args)
    message = args['message']

    if message
      delete args['message']
      @logger.log level, message, args
    else
      @logger.log level, args

module.exports = LogstashAdapter

winston = require('winston')
_  = require 'underscore'
LogstashUDP = require('winston-logstash-udp').LogstashUDP
buildEvent = require('./logstash_adapter/event')

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
    event = buildEvent(args)
    message = event['message']

    if message
      delete event['message']
      @logger.log level, message, event
    else
      @logger.log level, args

module.exports = LogstashAdapter

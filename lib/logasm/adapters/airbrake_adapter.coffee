_  = require 'underscore'
airbrake = require('airbrake')
errorLogToErrorObject = require('./../error_log_to_error_object')

class AirbrakeAdapter
  constructor:(level, service, {clientId, host, environments}) ->
    @logger = airbrake.createClient(clientId)
    @logger.serviceHost = host || 'airbrake.io'
    @logger.developmentEnvironments = environments || ['development']
    @level = level
    @service = service

  log:(level, args) ->
    if @level == level
      args = _.extend({}, args, {service: @service})
      message = args['message']

      errorObject =
        if message
          delete args['message']
          errorLogToErrorObject(message, args)
        else
          errorLogToErrorObject(args)

      @logger.notify errorObject

module.exports = AirbrakeAdapter

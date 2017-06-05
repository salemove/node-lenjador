{isObject} = require('../object_helpers')

class Blacklist

  DEFAULT_ACTION = 'exclude'
  MASK_SYMBOL = '*'

  constructor: (config) ->
    @fieldActions = {}
    for field in config.fields
      action = field.action || DEFAULT_ACTION
      @fieldActions[field.key] = @_getActionMethodName(action)

  process: (data) ->
    if Array.isArray(data)
      @_processArray(data)
    else if isObject(data)
      @_processObject(data)
    else
      data

  _getActionMethodName: (action) ->
    actionMethodName = @_actionMethodName(action)
    if typeof @[actionMethodName] != 'function'
      throw Error("Action: #{action} is not supported")
    actionMethodName

  _processArray: (array) ->
    array.reduce((mem, value) =>
      mem.push(@process(value))
      mem
    , [])

  _processObject: (obj) ->
    Object.entries(obj).reduce((mem, [key, value]) =>
      if key of @fieldActions
        mem = @_callAction(@fieldActions[key], mem, key, value)
      else
        mem[key] = @process(value)
      mem
    , {})

  _callAction: (actionMethodName, data, key, value) ->
    @[actionMethodName](data, key, value)

  _actionMethodName: (action) ->
    "_#{action}Field"

  _excludeField: (data) ->
    data

  _maskField: (data, key, value) ->
    data[key] =
      if typeof value == 'object' || typeof value == 'boolean'
        MASK_SYMBOL
      else
        value.toString().replace(/./g, MASK_SYMBOL)
    data

module.exports = Blacklist

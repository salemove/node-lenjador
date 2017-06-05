{isObject} = require('../object_helpers')

addToWhitelist = (whitelist, pointerPaths) ->
  whitelist[pointerPaths[0]] ?= {}
  if pointerPaths.length > 0
    addToWhitelist(whitelist[pointerPaths[0]], pointerPaths.splice(1))

class Whitelist

  MASKED_VALUE = '*****'
  WILDCARD_SYMBOL = '~'

  constructor: (config) ->
    pointers = config.pointers || []

    @whitelistedFields = {}

    for pointer in pointers
      @_validatePointer(pointer)
      pointerPaths = pointer.split('/').splice(1)
      addToWhitelist(@whitelistedFields, pointerPaths)

  process: (data) ->
    @processData([], data)

  _validatePointer: (pointer) ->
    if pointer.charAt(pointer.length - 1) == '/'
      throw Error('Pointer should not contain trailing slash')

  processData: (parentPointer, data) ->
    if Array.isArray(data)
      @_processArray(parentPointer, data)
    else if isObject(data)
      @_processObject(parentPointer, data)
    else
      @_processValue(parentPointer, data)

  _processArray: (parentPointer, array) ->
    array.reduce((mem, value, index) =>
      pointer = parentPointer.concat([index])
      processedValue = @processData(pointer, value)
      mem.push(processedValue)
      mem
    , [])

  _processObject: (parentPointer, obj) ->
    Object.entries(obj).reduce((mem, [key, value]) =>
      pointer = parentPointer.concat([key])
      processedValue = @processData(pointer, value)
      mem[key] = processedValue
      mem
    , {})

  _processValue: (parentPointer, value) ->
    location = @whitelistedFields
    for pointer in parentPointer
      location = location[pointer] || location[WILDCARD_SYMBOL]
      unless location
        return MASKED_VALUE

    value

module.exports = Whitelist

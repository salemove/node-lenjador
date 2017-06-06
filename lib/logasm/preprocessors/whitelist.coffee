{isObject} = require('../object_helpers')

addToWhitelist = (whitelist, pointerPaths) ->
  path = pointerPaths[0]
    .replace(/~0/g, '~') # ~ is encoded as ~0
    .replace(/~1/g, '/') # / is encoded as ~1

  whitelist[path] ?= {}
  if pointerPaths.length > 1
    addToWhitelist(whitelist[path], pointerPaths.splice(1))

class Whitelist

  MASKED_VALUE = '*****'
  WILDCARD_SYMBOL = '~'

  constructor: (config) ->
    pointers = config.pointers || []

    # Winston logs the first argument as `message` field. Making sure this is
    # always whitelisted.
    pointers.push('/message')

    @whitelistedFields = {}

    for pointer in pointers
      @_validatePointer(pointer)
      pointerPaths = pointer.split('/').splice(1)
      addToWhitelist(@whitelistedFields, pointerPaths)

  process: (data, path = []) ->
    if Array.isArray(data)
      @_processArray(data, path)
    else if isObject(data)
      @_processObject(data, path)
    else
      @_processValue(data, path)

  _validatePointer: (pointer) ->
    if pointer.charAt(pointer.length - 1) == '/'
      throw Error('Pointer should not contain trailing slash')

  _processArray: (array, path) ->
    array.reduce((mem, value, index) =>
      processedValue = @process(value, path.concat([index]))
      mem.push(processedValue)
      mem
    , [])

  _processObject: (obj, path) ->
    Object.entries(obj).reduce((mem, [key, value]) =>
      processedValue = @process(value, path.concat([key]))
      mem[key] = processedValue
      mem
    , {})

  _processValue: (value, path) ->
    location = @whitelistedFields
    for pointer in path
      location = location[pointer] || location[WILDCARD_SYMBOL]
      unless location
        return MASKED_VALUE

    value

module.exports = Whitelist

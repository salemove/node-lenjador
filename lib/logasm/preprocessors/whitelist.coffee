{isObject} = require('../object_helpers')

isWildcardPointer = (pointer) ->
  pointer.match(/\/\~\/|\~$/)

class Whitelist

  MASKED_VALUE = '*****'

  constructor: (config) ->
    pointers = config.pointers || []

    @exactComparisonFields = {}
    @regexComparisonFields = []

    for pointer in pointers
      @_validatePointer(pointer)

      if isWildcardPointer(pointer)
        wildcardMatcher = RegExp("^#{pointer.replace(/\/~/g, '/[^/]+')}$")
        @regexComparisonFields.push(wildcardMatcher)
      else
        @exactComparisonFields[pointer] = true

  process: (data) ->
    @processData('', data)

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
      pointer = "#{parentPointer}/#{index}"
      processedValue = @processData(pointer, value)
      mem.push(processedValue)
      mem
    , [])

  _processObject: (parentPointer, obj) ->
    Object.entries(obj).reduce((mem, [key, value]) =>
      pointer = "#{parentPointer}/#{key}"
      processedValue = @processData(pointer, value)
      mem[key] = processedValue
      mem
    , {})

  _processValue: (parentPointer, value) ->
    if (parentPointer of @exactComparisonFields) || @_matchesWildcard(parentPointer)
      value
    else
      MASKED_VALUE

  _matchesWildcard: (parentPointer) ->
    @regexComparisonFields.some (wildcardMatcher) ->
      parentPointer.match(wildcardMatcher)

module.exports = Whitelist

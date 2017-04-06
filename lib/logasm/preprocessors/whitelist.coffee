_ = require('underscore')

class Whitelist

  DEFAULT_WHITELIST = ['/id', '/message', '/correlation_id', '/queue']
  MASK_SYMBOL = '*'

  constructor: (config) ->
    pointers = _.union((config.pointers || []), DEFAULT_WHITELIST)
    @fieldsToInclude = {}
    for pointer in pointers
      @_validatePointer(pointer)
      @fieldsToInclude[@_decodePointer(pointer)] = true

  process: (data) ->
    @processData('', data)

  _validatePointer: (pointer) ->
    if pointer.charAt(pointer.length - 1) == '/'
      throw Error('Pointer should not contain trailing slash')

  _decodePointer: (pointer) ->
    pointer
      .replace(/~0/g, '~')
      .replace(/~1/g, '/')

  processData: (parentPointer, data) ->
    if _.isArray(data)
      @_processArray(parentPointer, data)
    else if _.isObject(data)
      @_processObject(parentPointer, data)
    else
      @_processValue(parentPointer, data)

  _processArray: (parentPointer, array) ->
    _.reduce(array, (mem, value, index) =>
      pointer = "#{parentPointer}/#{index}"
      processedValue = @processData(pointer, value)
      mem.push(processedValue)
      mem
    , [])

  _processObject: (parentPointer, obj) ->
    _.reduce(_.pairs(obj), (mem, [key, value]) =>
      pointer = "#{parentPointer}/#{key}"
      processedValue = @processData(pointer, value)
      mem[key] = processedValue
      mem
    , {})

  _processValue: (parentPointer, value) ->
    if (parentPointer of @fieldsToInclude) || @_matchesWildcard(parentPointer)
      value
    else
      @_mask(value)

  _matchesWildcard: (parentPointer) ->
    Object.keys(@fieldsToInclude).some((fieldToInclude) ->
      wildcardMatcher = RegExp("^#{fieldToInclude.replace(/\/~/g, '/[^/]+')}$")
      parentPointer.match(wildcardMatcher)
    )

  _mask: (value) ->
    if value && _.isFunction(value['toString']) && !_.isBoolean(value)
      value.toString().replace(/./g, MASK_SYMBOL)
    else
      MASK_SYMBOL

module.exports = Whitelist

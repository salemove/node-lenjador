isObject = (obj) ->
  type = typeof obj
  type == 'function' || type == 'object' && Boolean(obj)

module.exports = {isObject}

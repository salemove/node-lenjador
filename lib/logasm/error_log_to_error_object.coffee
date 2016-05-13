stringifyOrError = (object, errorMessage) ->
  try
    JSON.stringify(object)
  catch
    errorMessage

stringifyAnything = (anything, errorMessage) ->
  if typeof anything == "object"
    stringifyOrError(anything, errorMessage)
  else
    "" + anything

module.exports = (error, params) ->
  if error instanceof Error
    error
  else
    errorString = stringifyAnything(error, "Unable to stringify error object")

    message =
      if params
        errorString + ": " + stringifyAnything(params, "Unable to stringify error params")
      else
        errorString

    new Error(message)

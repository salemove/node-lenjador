module.exports = (args) ->
  args = Object.assign({}, args)

  unless args['@timestamp']
    args['@timestamp'] = new Date().toISOString()

  args

errorLogToErrorObject = require '../lib/logasm/error_log_to_error_object'
expect = require('chai').expect

createCircularObject = ->
  object = {}
  object.value = object
  object

describe 'errorLogToErrorObject', ->
  it 'keeps error object as is', ->
    error = new Error('bad news')
    expect(errorLogToErrorObject(error)).to
      .eq(error)

  it 'sets string as error object message', ->
    expect(errorLogToErrorObject('bad news')).to
      .be.instanceof(Error).and
      .have.property('message', 'bad news')

  it 'adds params object to error object message', ->
    expect(errorLogToErrorObject('bad news', reason: 'bad weather')).to
      .be.instanceof(Error).and
      .have.property('message', 'bad news: {"reason":"bad weather"}')

  it 'stringifies error object as error object message', ->
    expect(errorLogToErrorObject(message: 'bad news', reason: 'bad weather')).to
      .be.instanceof(Error).and
      .have.property('message', '{"message":"bad news","reason":"bad weather"}')

  it 'stringifies unstringifiable error object', ->
    expect(errorLogToErrorObject(createCircularObject())).to
      .be.instanceof(Error).and
      .have.property('message', 'Unable to stringify error object')

  it 'stringifies unstringifiable error params', ->
    expect(errorLogToErrorObject("bad news", createCircularObject())).to
      .be.instanceof(Error).and
      .have.property('message', 'bad news: Unable to stringify error params')

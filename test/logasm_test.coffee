Logasm = require '../lib/logasm'
StdoutAdapter = require '../lib/logasm/adapters/stdout_adapter'
LogstashAdapter = require '../lib/logasm/adapters/logstash_adapter'
AirbrakeAdapter = require '../lib/logasm/adapters/airbrake_adapter'

describe 'Logasm', ->
  it 'creates stdout logger', (done) ->
    logasm = Logasm.build "My service", {stdout: {}}

    logasm.adapters.should.have.length(1)
    logasm.adapters[0].should.be.an.instanceof(StdoutAdapter)
    done()

  it 'creates logstash logger', (done) ->
    logasm = Logasm.build "My service", {logstash: {host: 'localhost', port: 5229}}

    logasm.adapters.should.have.length(1)
    logasm.adapters[0].should.be.an.instanceof(LogstashAdapter)
    done()

  it 'creates airbrake logger', (done) ->
    logasm = Logasm.build "My service", {
      airbrake: {host: "salemove.io", clientId: 'clientId', environments : ['development']}
    }

    logasm.adapters.should.have.length(1)
    logasm.adapters[0].should.be.an.instanceof(AirbrakeAdapter)
    done()

  it 'creates multiple loggers', (done) ->
    logasm = Logasm.build "My service", {stdout: {}, logstash: {host: 'localhost', port: 5229}}

    logasm.adapters.should.have.length(2)
    logasm.adapters[0].should.be.an.instanceof(StdoutAdapter)
    logasm.adapters[1].should.be.an.instanceof(LogstashAdapter)
    done()

  it 'creates stdout logger when no loggers are specified', (done) ->
    logasm = Logasm.build "My service", undefined

    logasm.adapters.should.have.length(1)
    logasm.adapters[0].should.be.an.instanceof(StdoutAdapter)
    done()

  context 'when parsing log data', ->
    beforeEach ->
      @logasm = Logasm.build ''

    it 'parses empty string with no metadata', (done) ->
      result = @logasm.parseLogData('')

      result.should.eql({message: ''})
      done()

    it 'parses undefined as metadata', (done) ->
      result = @logasm.parseLogData(undefined)

      result.should.eql({message: undefined})
      done()

    it 'parses only message', (done) ->
      result = @logasm.parseLogData('test message')

      result.should.eql({message: 'test message'})
      done()

    it 'message and metadata', (done) ->
      result = @logasm.parseLogData('test message', {test: 'data', more: 'testing'})

      result.should.eql({message: 'test message', test: 'data', more: 'testing'})
      done()

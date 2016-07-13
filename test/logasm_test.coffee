Logasm = require '../lib/logasm'
StdoutAdapter = require '../lib/logasm/adapters/stdout_adapter'
LogstashAdapter = require '../lib/logasm/adapters/logstash_adapter'
Blacklist = require '../lib/logasm/preprocessors/blacklist'

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

  it 'creates preprocessor when defined', (done) ->
    logasm = Logasm.build "My service", undefined, {blacklist: {fields: []}}

    logasm.preprocessors.should.have.length(1)
    logasm.preprocessors[0].should.be.an.instanceof(Blacklist)
    done()

  context 'when preprocessor defined', ->
    preprocessor = {
      process: sinon.spy()
    }
    adapter = {
      log: sinon.spy()
    }

    beforeEach ->
      @logasm = new Logasm([adapter], [preprocessor])

    it 'preprocesses data before logging', ->
      @logasm.info('Received message', {data: 'data'})

      expect(preprocessor.process).to.be.calledWith({data: 'data', message: 'Received message'})
      expect(adapter.log).to.be.called

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

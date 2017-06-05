Logasm = require '../lib/logasm'
StdoutAdapter = require '../lib/logasm/adapters/stdout_adapter'
Blacklist = require '../lib/logasm/preprocessors/blacklist'

describe 'Logasm', ->
  it 'creates stdout logger', (done) ->
    logasm = Logasm.build "My service", {stdout: {}}

    expect(logasm.adapters).to.have.length(1)
    expect(logasm.adapters[0]).to.be.an.instanceof(StdoutAdapter)
    done()

  it 'creates stdout logger when no loggers are specified', (done) ->
    logasm = Logasm.build "My service", undefined

    expect(logasm.adapters).to.have.length(1)
    expect(logasm.adapters[0]).to.be.an.instanceof(StdoutAdapter)
    done()

  it 'creates preprocessor when defined', (done) ->
    logasm = Logasm.build "My service", undefined, {blacklist: {fields: []}}

    expect(logasm.preprocessors).to.have.length(1)
    expect(logasm.preprocessors[0]).to.be.an.instanceof(Blacklist)
    done()

  context 'when preprocessor defined', ->
    preprocessor = {
      process: sinon.stub().returns({data:'processed', message: 'Received message'})
    }
    adapter = {
      log: sinon.spy()
    }

    beforeEach ->
      @logasm = new Logasm([adapter], [preprocessor])

    it 'preprocesses data before logging', ->
      @logasm.info('Received message', {data: 'data'})

      expect(preprocessor.process).to.be.calledWith({data: 'data', message: 'Received message'})
      expect(adapter.log).to.be.calledWith("info", {data:'processed', message: 'Received message'})

  context 'when parsing log data', ->
    beforeEach ->
      @logasm = Logasm.build ''

    it 'parses empty string with no metadata', (done) ->
      result = @logasm.parseLogData('')

      expect(result).to.eql({message: ''})
      done()

    it 'parses undefined as metadata', (done) ->
      result = @logasm.parseLogData(undefined)

      expect(result).to.eql({message: undefined})
      done()

    it 'parses only message', (done) ->
      result = @logasm.parseLogData('test message')

      expect(result).to.eql({message: 'test message'})
      done()

    it 'message and metadata', (done) ->
      result = @logasm.parseLogData('test message', {test: 'data', more: 'testing'})

      expect(result).to.eql({message: 'test message', test: 'data', more: 'testing'})
      done()

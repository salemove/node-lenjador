const Logasm = require('../lib/logasm');
const StdoutAdapter = require('../lib/logasm/adapters/stdout_adapter');
const Whitelist = require('../lib/logasm/preprocessors/whitelist');

describe('Logasm', function() {
  it('creates stdout logger', function() {
    let logasm = Logasm.build("My service", {stdout: {}});

    expect(logasm.adapters).to.have.length(1);
    expect(logasm.adapters[0]).to.be.an.instanceof(StdoutAdapter);
  });

  it('creates stdout logger when no loggers are specified', function() {
    let logasm = Logasm.build("My service", undefined);

    expect(logasm.adapters).to.have.length(1);
    expect(logasm.adapters[0]).to.be.an.instanceof(StdoutAdapter);
  });

  it('creates preprocessor when defined', function() {
    let logasm = Logasm.build("My service", undefined, {whitelist: {pointers: []}});

    expect(logasm.preprocessors).to.have.length(1);
    expect(logasm.preprocessors[0]).to.be.an.instanceof(Whitelist);
  });

  context('when preprocessor defined', function() {
    let preprocessor = {
      process: sinon.stub().returns({data:'processed', message: 'Received message'})
    };
    let adapter = {
      log: sinon.spy()
    };

    it('preprocesses data before logging', function() {
      let logasm = new Logasm([adapter], [preprocessor]);
      logasm.info('Received message', {data: 'data'});

      expect(preprocessor.process).to.be.calledWith({data: 'data', message: 'Received message'});
      expect(adapter.log).to.be.calledWith("info", {data:'processed', message: 'Received message'});
    });
  });

  context('when parsing log data', function() {
    let logasm;

    beforeEach(function() {
      logasm = Logasm.build('');
    });

    it('parses empty string with no metadata', function() {
      let result = logasm.parseLogData('');

      expect(result).to.eql({message: ''});
    });

    it('parses undefined as metadata', function() {
      let result = logasm.parseLogData(undefined);

      expect(result).to.eql({message: undefined});
    });

    it('parses only message', function() {
      let result = logasm.parseLogData('test message');

      expect(result).to.eql({message: 'test message'});
    });

    it('message and metadata', function() {
      let result = logasm.parseLogData('test message', {test: 'data', more: 'testing'});

      expect(result).to.eql({message: 'test message', test: 'data', more: 'testing'});
    });

    it('parses Error', function() {
      let result = logasm.parseLogData(new Error('test message'));

      expect(result.message).to.match(/Error: test message/);
      expect(result.error.message).to.eq('Error: test message');
      expect(result.error.stack).to.match(/Error: test message/);
    });
  });
});

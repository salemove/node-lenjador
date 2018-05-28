const Lenjador = require('../lib/lenjador');
const StdoutAdapter = require('../lib/lenjador/adapters/stdout_adapter');
const Whitelist = require('../lib/lenjador/preprocessors/whitelist');

describe('Lenjador', function() {
  it('creates stdout logger', function() {
    let lenjador = Lenjador.build("My service", {stdout: {}});

    expect(lenjador.adapters).to.have.length(1);
    expect(lenjador.adapters[0]).to.be.an.instanceof(StdoutAdapter);
  });

  it('creates stdout logger when no loggers are specified', function() {
    let lenjador = Lenjador.build("My service", undefined);

    expect(lenjador.adapters).to.have.length(1);
    expect(lenjador.adapters[0]).to.be.an.instanceof(StdoutAdapter);
  });

  it('creates preprocessor when defined', function() {
    let lenjador = Lenjador.build("My service", undefined, {whitelist: {pointers: []}});

    expect(lenjador.preprocessors).to.have.length(1);
    expect(lenjador.preprocessors[0]).to.be.an.instanceof(Whitelist);
  });

  context('when preprocessor defined', function() {
    let preprocessor = {
      process: sinon.stub().returns({data:'processed', message: 'Received message'})
    };
    let adapter = {
      log: sinon.spy()
    };

    it('preprocesses data before logging', function() {
      let lenjador = new Lenjador([adapter], [preprocessor]);
      lenjador.info('Received message', {data: 'data'});

      expect(preprocessor.process).to.be.calledWith({data: 'data', message: 'Received message'});
      expect(adapter.log).to.be.calledWith("info", {data:'processed', message: 'Received message'});
    });
  });

  context('when parsing log data', function() {
    let lenjador;

    beforeEach(function() {
      lenjador = Lenjador.build('');
    });

    it('parses empty string with no metadata', function() {
      let result = lenjador.parseLogData('');

      expect(result).to.eql({message: ''});
    });

    it('parses undefined as metadata', function() {
      let result = lenjador.parseLogData(undefined);

      expect(result).to.eql({message: undefined});
    });

    it('parses only message', function() {
      let result = lenjador.parseLogData('test message');

      expect(result).to.eql({message: 'test message'});
    });

    it('message and metadata', function() {
      let result = lenjador.parseLogData('test message', {test: 'data', more: 'testing'});

      expect(result).to.eql({message: 'test message', test: 'data', more: 'testing'});
    });

    it('parses Error', function() {
      let result = lenjador.parseLogData(new Error('test message'));

      expect(result.message).to.match(/Error: test message/);
      expect(result.error.message).to.eq('Error: test message');
      expect(result.error.stack).to.match(/Error: test message/);
    });
  });
});

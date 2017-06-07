const adaptersFactory = require('./logasm/adapters');
const preprocessorsFactory = require('./logasm/preprocessors');

class Logasm {
  static build(serviceName, loggersConfig = {stdout: {}}, preprocessorsConfig = {}) {
    let adapters = [];
    for (const type in loggersConfig) {
      adapters.push(adaptersFactory.getAdapter(type, serviceName, loggersConfig[type]));
    }

    const preprocessors = [];
    for (const type in preprocessorsConfig) {
      preprocessors.push(preprocessorsFactory.getPreprocessor(type, preprocessorsConfig[type]));
    }

    return new Logasm(adapters, preprocessors);
  }

  constructor(adapters, preprocessors) {
    this.silly = this.silly.bind(this);
    this.debug = this.debug.bind(this);
    this.verbose = this.verbose.bind(this);
    this.info = this.info.bind(this);
    this.warn = this.warn.bind(this);
    this.error = this.error.bind(this);
    this.log = this.log.bind(this);
    this.preprocess = this.preprocess.bind(this);
    this.isHash = this.isHash.bind(this);
    this.adapters = adapters;
    this.preprocessors = preprocessors;
  }

  silly() {
    return this.log('silly', arguments);
  }

  debug() {
    return this.log('debug', arguments);
  }

  verbose() {
    return this.log('verbose', arguments);
  }

  info() {
    return this.log('info', arguments);
  }

  warn() {
    return this.log('warn', arguments);
  }

  error() {
    return this.log('error', arguments);
  }

  log(level, args) {
    const data = this.parseLogData.apply(this, args);
    const processedData = this.preprocess(data);
    return Array.from(this.adapters).map((adapter) =>
      adapter.log(level, processedData));
  }

  preprocess(data) {
    return this.preprocessors.reduce((processedData, preprocessor) => {
      return preprocessor.process(processedData);
    }
    , data);
  }

  parseLogData(message, metadata) {
    if (this.isHash(message)) {
      return message;
    } else {
      let data = {};

      if (metadata instanceof Error) {
        data['error'] = metadata.toString();
        if (metadata.stack) { data['error.stack_trace'] = metadata.stack; }
      } else {
        Object.assign(data, metadata);
      }

      if (message instanceof Error) {
        data['error'] = message.toString();
        if (message.stack) { data['error.stack_trace'] = message.stack; }
      }

      data['message'] = message;
      return data;
    }
  }

  isHash(obj) {
    if (!(obj instanceof Object)) { return false; }
    return Boolean(Object.keys(obj).length);
  }
}

module.exports = Logasm;

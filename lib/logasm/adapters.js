function getAdapter(type, serviceName, args) {
  let Adapter = require(`./adapters/${type}_adapter`);
  let level = args['level'] || 'debug';
  return new Adapter(level, serviceName, args);
}

module.exports = {getAdapter};

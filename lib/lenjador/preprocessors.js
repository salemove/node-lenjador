function getPreprocessor(type, args) {
  const Preprocessor = require(`./preprocessors/${type}`);
  return new Preprocessor(args);
}

module.exports = {getPreprocessor};

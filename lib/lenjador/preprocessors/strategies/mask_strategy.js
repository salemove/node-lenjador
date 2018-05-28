const { isObject } = require('../../object_helpers');

const WILDCARD_SYMBOL = '~';
const MASKED_VALUE = '*****';

class MaskStrategy {
  constructor(whitelistedFields) {
    this.whitelistedFields = whitelistedFields;
  }

  process(data, path) {
    if (path == null) { path = []; }
    
    if (this._isWhitelistedField(path)) {
      return this._processData(data, path)
    } else {
      return MASKED_VALUE;
    }
  }

  _isWhitelistedField(path) {
    let location = this.whitelistedFields;
    for (const pointer of Array.from(path)) {
      location = location[pointer] || location[WILDCARD_SYMBOL];
      if (!location) {
        return false;
      }
    }
    return true;
  }

  _processData(data, path) {
    if (Array.isArray(data)) {
      return this._processArray(data, path);
    } else if (isObject(data)) {
      return this._processObject(data, path);
    } else {
      return data;
    }
  }

  _processArray(array, path) {
    return array.reduce((mem, value, index) => {
      const processedValue = this.process(value, path.concat([index]));
      mem.push(processedValue);
      return mem;
    }, []);
  }

  _processObject(obj, path) {
    return Object.entries(obj).reduce((mem, [key, value]) => {
      const processedValue = this.process(value, path.concat([key]));
      mem[key] = processedValue;
      return mem;
    }, {});
  }
}

module.exports = MaskStrategy;

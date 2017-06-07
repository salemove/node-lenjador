const { isObject } = require('../object_helpers');

function addToWhitelist(whitelist, pointerPaths) {
  const path = pointerPaths[0]
    .replace(/~0/g, '~') // ~ is encoded as ~0
    .replace(/~1/g, '/'); // / is encoded as ~1

  if (whitelist[path] == null) { whitelist[path] = {}; }
  if (pointerPaths.length > 1) {
    return addToWhitelist(whitelist[path], pointerPaths.splice(1));
  }
};

const MASKED_VALUE = '*****';
const WILDCARD_SYMBOL = '~';

class Whitelist {
  constructor(config) {
    // Winston logs the first argument as `message` field. Making sure this is
    // always whitelisted.
    const pointers = (config.pointers || []).concat(['/message']);

    this.whitelistedFields = {};

    for (const pointer of Array.from(pointers)) {
      this._validatePointer(pointer);
      const pointerPaths = pointer.split('/').splice(1);
      addToWhitelist(this.whitelistedFields, pointerPaths);
    }
  }

  process(data, path) {
    if (path == null) { path = []; }
    if (Array.isArray(data)) {
      return this._processArray(data, path);
    } else if (isObject(data)) {
      return this._processObject(data, path);
    } else {
      return this._processValue(data, path);
    }
  }

  _validatePointer(pointer) {
    if (pointer.charAt(pointer.length - 1) === '/') {
      throw Error('Pointer should not contain trailing slash');
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

  _processValue(value, path) {
    let location = this.whitelistedFields;
    for (const pointer of Array.from(path)) {
      location = location[pointer] || location[WILDCARD_SYMBOL];
      if (!location) {
        return MASKED_VALUE;
      }
    }

    return value;
  }
}

module.exports = Whitelist;

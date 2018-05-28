const MaskStrategy = require('./strategies/mask_strategy')
const PruneStrategy = require('./strategies/prune_strategy')

function addToWhitelist(whitelist, pointerPaths) {
  const path = pointerPaths[0]
    .replace(/~0/g, '~') // ~ is encoded as ~0
    .replace(/~1/g, '/'); // / is encoded as ~1

  if (whitelist[path] == null) { whitelist[path] = {}; }
  if (pointerPaths.length > 1) {
    return addToWhitelist(whitelist[path], pointerPaths.splice(1));
  }
};

const PRUNE_ACTION = 'prune';
const MASK_ACTION = 'mask';
const DEFAULT_ACTION = MASK_ACTION;

class Whitelist {
  constructor(config) {
    // Winston logs the first argument as `message` field. Making sure this is
    // always whitelisted.
    const pointers = (config.pointers || []).concat(['/message']);
    const action = config.action || DEFAULT_ACTION;

    this.whitelistedFields = {};

    for (const pointer of Array.from(pointers)) {
      this._validatePointer(pointer);
      const pointerPaths = pointer.split('/').splice(1);
      addToWhitelist(this.whitelistedFields, pointerPaths);
    }

    if (action === MASK_ACTION) {
     this.strategy = new MaskStrategy(this.whitelistedFields);
    } else {
      this.strategy = new PruneStrategy(this.whitelistedFields);
    }
  }

  process(data, path) {
    return this.strategy.process(data, path);
  }

  _validatePointer(pointer) {
    if (pointer.charAt(pointer.length - 1) === '/') {
      throw Error('Pointer should not contain trailing slash');
    }
  }
}

module.exports = Whitelist;

# Logasm

## Installation
```
  npm install --save logasm
```

## Preprocessors

Preprocessors allow modification of log messages, prior to sending of the message to the configured logger(s).

### Whitelist

Masks all the fields except those whitelisted in the configuration using [JSON Pointer](https://tools.ietf.org/html/rfc6901).
Only simple values(`string`, `number`, `boolean`) can be whitelisted. Whitelisting array and hash elements can be done using
wildcard symbol `~`.

#### Configuration

```yaml
preprocessors:
  whitelist:
    pointers: ['/info/phone', '/addresses/~/host']
```

#### Usage

```javascript
logger = Logasm.build(application_name, logger_config, preprocessors)

input = {password: 'password', info: {phone: '+12055555555'}, addresses: [{host: 'example.com', path: 'info'}]}

logger.debug("Received request", input)
```

Logger output:

```
Received request {"password": "********", "info":{"phone":"+12055555555"}, "addresses": [{"host": "example.com","path": "****"}]}
```

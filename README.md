# Logasm

## Installation
```
  npm install --save logasm
```

## Preprocessors

Preprocessors allow modification of log messages, prior to sending of the message to the configured logger(s).

### Blacklist

Excludes or masks defined fields of the passed hash object.
You can specify the name of the field and which action to take on it.
Nested hashes of any level are preprocessed as well.

Available actions:
    
* exclude(`default`) - fully excludes the field and its value from the hash.
* mask - replaces every character from the original value with `*`. In case of `array`, `hash` or `boolean` value is replaced with one `*`.

#### Configuration

```yaml
preprocessors:
  blacklist:
    fields:
      - key: password
      - key: phone
        action: mask
```

#### Usage

```javascript

logger = Logasm.build(application_name, logger_config, preprocessors)

input = {password: 'password', info: {phone: '+12055555555'}}

logger.debug("Received request", input)
```

Logger output:

```
Received request {"info":{"phone":"************"}}
```

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

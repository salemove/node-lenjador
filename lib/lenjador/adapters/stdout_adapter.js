const winston = require('winston');
const buildEvent = require('../event');

class StdoutAdapter {
  constructor(level, serviceName, options) {
    this.serviceName = serviceName;
    this.logger = new winston.Logger();
    this.logger.add(winston.transports.Console, {
      json: Boolean(options.json),
      timestamp: !Boolean(options.json), // Json adds @timestamp manually
      level,
      colorize: true,
      stringify: function(obj) { return JSON.stringify(obj); }
    }
    );
  }

  log(level, args) {
    const event = buildEvent(args, this.serviceName);
    const message = event['message'];

    if (message) {
      delete event['message'];
      this.logger.log(level, message, event);
    } else {
      this.logger.log(level, event);
    }
  }
}

module.exports = StdoutAdapter;

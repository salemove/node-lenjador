function buildEvent(args) {
  event = Object.assign({}, args);

  if (!event['@timestamp']) {
    event['@timestamp'] = new Date().toISOString();
  }

  return event;
};

module.exports = buildEvent;

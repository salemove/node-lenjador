function buildEvent(args, serviceName) {
  event = Object.assign({}, args);

  event['application'] = serviceName;

  if (!event['@timestamp']) {
    event['@timestamp'] = new Date().toISOString();
  }

  return event;
};

module.exports = buildEvent;

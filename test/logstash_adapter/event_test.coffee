buildEvent = require '../../lib/logasm/adapters/logstash_adapter/event'

describe 'buildEvent', ->
  iso8601Matcher = /^\d{4}(-\d\d(-\d\d(T\d\d:\d\d(:\d\d)?(\.\d+)?(([+-]\d\d:\d\d)|Z)?)?)?)?$/i
  payload = {x: 'y'}

  it 'adds @timestamp', ->
    event = buildEvent(payload)
    expect(event['@timestamp']).to.match(iso8601Matcher)

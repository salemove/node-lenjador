Blacklist = require '../lib/logasm/preprocessors/blacklist'
_ = require 'underscore'

nest_data = (data, depth, value) ->
  result = _.extend({}, data, {data: value})
  if depth > 0
    nest_data(data, depth - 1, result)
  else
    result

nested_field = (data, depth) ->
  if depth >= 0
    nested_field(data['data'], depth - 1)
  else
    data

describe 'Blacklist', ->
  processedData = null

  action = memo().is -> null
  config = memo().is -> {fields: [{key: 'field', action: action()}]}
  value = memo().is -> 'secret'
  data = memo().is -> {
    field: value(),
    nested: {
      field: value()
    }
    array: [{field: value()}]
  }

  context 'when action is not supported', ->
    action.is -> 'reverse'

    it 'throws error', ->
      expect(-> new Blacklist(config())).to.throw('Action: reverse is not supported')

  context '#process', ->
    beforeEach ->
      blacklist = new Blacklist(config())
      processedData = blacklist.process(data())

    context 'when field is not blacklisted', ->
      config.is -> {fields:[]}

      it 'keeps the field as it was', ->
        expect(processedData).to.eql(data())

    context 'when action is "exclude"', ->
      action.is -> 'exclude'

      it 'removes the field', ->
        expect(processedData).to.not.include.keys('field')

      it 'removes nested field', ->
        expect(processedData.nested).to.not.include.keys('field')

      it 'removes nested in array field', ->
        expect(processedData.array).to.not.include.keys('field')
        expect(processedData.array).to.be.instanceof(Array)

      context 'when field is deeply nested', ->
        depth = 10
        data.is -> nest_data({}, depth, {field: value()})

        it 'removes field', ->
          expect(nested_field(processedData, depth)).to.not.include.keys('field')

    context 'when action is "mask"', ->
      action.is -> 'mask'

      it 'masks the field', ->
        expect(processedData.field).to.eql('******')

      it 'masks nested field', ->
        expect(processedData.field).to.eql('******')

      it 'masks nested in array field', ->
        expect(processedData.field).to.eql('******')
        expect(processedData.array).to.be.instanceof(Array)

      context 'when field is deeply nested', ->
        depth = 10
        data.is -> nest_data({}, depth, {field: value()})

        it 'removes field', ->
          expect(nested_field(processedData, depth).field).to.eql('******')

      context 'when field is number', ->
        value.is -> 42

        it 'masks value with asterisks', ->
          expect(processedData.field).to.eql('**')

      context 'when field is boolean', ->
        value.is -> true

        it 'masks value with one asterisk', ->
          expect(processedData.field).to.eql('*')

      context 'when field is array', ->
        value.is -> [1,2,3,4]

        it 'masks value with one asterisk', ->
          expect(processedData.field).to.eql('*')

      context 'when field is object', ->
        value.is -> {}

        it 'masks value with one asterisk', ->
          expect(processedData.field).to.eql('*')

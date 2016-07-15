Whitelist = require '../lib/logasm/preprocessors/whitelist'
_ = require 'underscore'

describe 'Whitelist', ->
  processedData = null

  config = memo().is -> {pointers: pointers()}
  data = memo().is -> {
    field: 'secret',
    nested: {
      field: 'secret'
    }
    array: [{field: 'secret'}]
  }
  pointers = memo().is -> []

  context 'when pointer has trailing slash', ->
    pointers.is -> ['/field/']

    it 'throws error', ->
      expect(-> new Whitelist(config())).to.throw('Pointer should not contain trailing slash')

  context '#process', ->
    beforeEach ->
      whitelist = new Whitelist(config())
      processedData = whitelist.process(data())

    context 'when includes fields from default whitelist', ->
      pointers.is -> []
      data.is ->
        id: 'id'
        message: 'message',
        queue: 'queue',
        correlation_id: 'correlation_id'

      it 'includes fields', ->
        expect(processedData).to.eql(data())

    context 'with whitelisted field', ->
      pointers.is -> ['/field']

      it 'includes the field', ->
        expect(processedData).to.eql({
          field: 'secret',
          nested: {
            field: '******'
          }
          array: [{field: '******'}]
        })

    context 'with whitelisted nested field', ->
      pointers.is -> ['/nested/field']

      it 'includes nested field', ->
        expect(processedData).to.eql({
          field: '******',
          nested: {
            field: 'secret'
          }
          array: [{field: '******'}]
        })

    context 'with whitelisted array element field', ->
      pointers.is -> ['/array/0/field']

      it 'includes array element field', ->
        expect(processedData).to.eql({
          field: '******',
          nested: {
            field: '******'
          }
          array: [{field: 'secret'}]
        })

    context 'with whitelisted array element', ->
      pointers.is -> ['/array/0']

      it 'masks array element', ->
        expect(processedData).to.eql({
          field: '******',
          nested: {
            field: '******'
          }
          array: [{field: '******'}]
        })


    context 'with whitelisted array', ->
      pointers.is -> ['/array']

      it 'masks array', ->
        expect(processedData).to.eql({
          field: '******',
          nested: {
            field: '******'
          }
          array: [{field: '******'}]
        })

    context 'with whitelisted object', ->
      pointers.is -> ['/data']

      it 'masks array', ->
        expect(processedData).to.eql({
          field: '******',
          nested: {
            field: '******'
          }
          array: [{field: '******'}]
        })

    context 'when boolean present', ->
      data.is -> {bool: true}

      it 'masks it with single asteriks', ->
        expect(processedData).to.eql({bool: '*'})

    context 'when field has slash in the name', ->
      data.is -> {'field_with_/': 'secret'}
      pointers.is -> ['/field_with_~1']

      it 'does not include array', ->
        expect(processedData).to.eql({'field_with_/': 'secret'})

    context 'when field has tilde in the name', ->
      data.is -> {'field_with_~': 'secret'}
      pointers.is -> ['/field_with_~0']

      it 'does not include array', ->
        expect(processedData).to.eql({'field_with_~': 'secret'})

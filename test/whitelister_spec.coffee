Whitelist = require '../lib/logasm/preprocessors/whitelist'

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

    context 'with whitelisted field', ->
      pointers.is -> ['/field']

      it 'includes the field', ->
        expect(processedData).to.eql({
          field: 'secret',
          nested: {
            field: '*****'
          }
          array: [{field: '*****'}]
        })

    context 'with whitelisted nested field', ->
      pointers.is -> ['/nested/field']

      it 'includes nested field', ->
        expect(processedData).to.eql({
          field: '*****',
          nested: {
            field: 'secret'
          }
          array: [{field: '*****'}]
        })

    context 'with whitelisted array element field', ->
      pointers.is -> ['/array/0/field']

      it 'includes array element field', ->
        expect(processedData).to.eql({
          field: '*****',
          nested: {
            field: '*****'
          }
          array: [{field: 'secret'}]
        })

    context 'with whitelisted array element', ->
      pointers.is -> ['/array/0']

      it 'masks array element', ->
        expect(processedData).to.eql({
          field: '*****',
          nested: {
            field: '*****'
          }
          array: [{field: '*****'}]
        })

    context 'with whitelisted array', ->
      pointers.is -> ['/array']

      it 'masks array', ->
        expect(processedData).to.eql({
          field: '*****',
          nested: {
            field: '*****'
          }
          array: [{field: '*****'}]
        })

    context 'with whitelisted object', ->
      pointers.is -> ['/data']

      it 'masks array', ->
        expect(processedData).to.eql({
          field: '*****',
          nested: {
            field: '*****'
          }
          array: [{field: '*****'}]
        })

    context 'when boolean present', ->
      data.is -> {bool: true}

      it 'masks boolean', ->
        expect(processedData).to.eql({bool: '*****'})

    describe 'wildcard', ->
      context 'with array elements whitelisted with wildcard', ->
        pointers.is -> ['/array/~']

        context 'with string array', ->
          data.is -> {
            array: ['one', 'two']
          }

          it 'does not mask array elements', ->
            expect(processedData).to.eql({
              array: ['one', 'two']
            })

        context 'with objects', ->
          data.is -> {
            array: [{field: 'secret'}]
          }

          it 'masks nested array elements', ->
            expect(processedData).to.eql({
              array: [{field: '*****'}]
            })

      context 'with fields of array elements whitelisted with wildcard', ->
        pointers.is -> ['/array/~/field']
        data.is -> {
          array: [{field: 'secret', field2: 'secret'}]
        }

        it 'does not mask the field array elements', ->
          expect(processedData).to.eql({
            array: [{field: 'secret', field2: '*****'}]
          })

      context 'with hash fields whitelisted with wildcard', ->
        pointers.is -> ['/object/~']

        context 'with string array', ->
          data.is -> {
            object: {
              field: 'secret'
            }
          }

          it 'does not mask fields', ->
            expect(processedData).to.eql({
              object: {
                field: 'secret'
              }
            })

        context 'with nested objects', ->
          data.is -> {
            object: {
              nested: {
                field: 'secret'
              }
            }
          }

          it 'masks nested objects', ->
            expect(processedData).to.eql({
              object: {
                nested: {
                  field: '*****'
                }
              }
            })

      context 'with fields of nested elements whitelisted with wildcard', ->
        pointers.is -> ['/object/~/field']
        data.is -> {
          object: {
            nested: {
              field: 'secret'
              field2: 'secret'
            }
          }
        }

        it 'does not mask the field array elements', ->
          expect(processedData).to.eql({
            object: {
              nested: {
                field: 'secret'
                field2: '*****'
              }
            }
          })

    describe 'README example', ->
      pointers.is -> ['/info/phone', '/addresses/~/host']
      data.is -> {
        password: 'password'
        info: {
          phone: '+12055555555'
        }
        addresses: [{
          host: 'example.com'
          path: 'info'
        }]
      }

      it 'does not mask the field array elements', ->
        expect(processedData).to.eql({
          password: "*****"
          info: {
            phone: "+12055555555"
          }
          addresses: [{
            host: "example.com"
            path: "*****"
          }]
        })

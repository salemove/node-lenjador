const Whitelist = require('../lib/logasm/preprocessors/whitelist');

describe('Whitelist', function() {
  let processedData = null;

  let config = memo().is(() => ({
    pointers: pointers(),
    action: action()
  }));
  let data = memo().is(() => ({
    field: 'secret',
    nested: {
      field: 'secret'
    },
    array: [{field: 'secret'}]
  }) );
  var pointers = memo().is(() => []);
  var action = memo().is(() => '');

  context('when pointer has trailing slash', function() {
    pointers.is(() => ['/field/']);

    it('throws error', () => {
      expect(() => new Whitelist(config())).to.throw('Pointer should not contain trailing slash');
    })
  });

  context('#process', function() {
    beforeEach(function() {
      let whitelist = new Whitelist(config());
      processedData = whitelist.process(data());
    });

    context('with mask strategy', function() {
      action.is(() => 'mask');

      context('with whitelisted field', function() {
        pointers.is(() => ['/field']);

        it('includes the field', () =>
          expect(processedData).to.eql({
            field: 'secret',
            nested: '*****',
            array: '*****'
          })
        );
      });

      context('with whitelisted nested field', function() {
        pointers.is(() => ['/nested/field']);

        it('includes nested field', () =>
          expect(processedData).to.eql({
            field: '*****',
            nested: {
              field: 'secret'
            },
            array: '*****'
          })
        );
      });

      context('with whitelisted array element field', function() {
        pointers.is(() => ['/array/0/field']);

        it('includes array element field', () =>
          expect(processedData).to.eql({
            field: '*****',
            nested: '*****',
            array: [{field: 'secret'}]
          })
        );
      });

      context('with whitelisted array element', function() {
        pointers.is(() => ['/array/0']);

        it('masks array element', () =>
          expect(processedData).to.eql({
            field: '*****',
            nested: '*****',
            array: [{field: '*****'}]
          })
        );
      });

      context('with whitelisted array', function() {
        pointers.is(() => ['/array']);

        it('masks array', () =>
          expect(processedData).to.eql({
            field: '*****',
            nested: '*****',
            array: ['*****']
          })
        );
      });

      context('with whitelisted object', function() {
        pointers.is(() => ['/data']);

        it('masks array', () =>
          expect(processedData).to.eql({
            field: '*****',
            nested: '*****',
            array: '*****'
          })
        );
      });

      context('when boolean present', function() {
        data.is(() => ({bool: true}));

        it('masks boolean', () => expect(processedData).to.eql({bool: '*****'}));
      });

      context('when field has slash in the name', function() {
        data.is(() => ({'field_with_/': 'secret'}));
        pointers.is(() => ['/field_with_~1']);

        it('does not mask it', () => expect(processedData).to.eql({'field_with_/': 'secret'}));
      });

      context('when field has tilde in the name', function() {
        data.is(() => ({'field_with_~': 'secret'}));
        pointers.is(() => ['/field_with_~0']);

        it('does not mask it', () => expect(processedData).to.eql({'field_with_~': 'secret'}));
      });

      describe('wildcard', function() {
        context('with array elements whitelisted with wildcard', function() {
          pointers.is(() => ['/array/~']);

          context('with string array', function() {
            data.is(() => ({
              array: ['one', 'two']
            }) );

            it('does not mask array elements', () =>
              expect(processedData).to.eql({
                array: ['one', 'two']
              })
            );
          });

          context('with objects', function() {
            data.is(() => ({
              array: [{field: 'secret'}]
            }) );

            it('masks nested array elements', () =>
              expect(processedData).to.eql({
                array: [{field: '*****'}]
              })
            );
          });
        });

        context('with fields of array elements whitelisted with wildcard', function() {
          pointers.is(() => ['/array/~/field']);
          data.is(() => ({
            array: [{field: 'secret', field2: 'secret'}]
          }) );

          it('does not mask the field array elements', () =>
            expect(processedData).to.eql({
              array: [{field: 'secret', field2: '*****'}]
            })
          );
        });

        context('with hash fields whitelisted with wildcard', function() {
          pointers.is(() => ['/object/~']);

          context('with string array', function() {
            data.is(() => ({
              object: {
                field: 'secret'
              }
            }) );

            it('does not mask fields', () =>
              expect(processedData).to.eql({
                object: {
                  field: 'secret'
                }
              })
            );
          });

          context('with nested objects', function() {
            data.is(() => ({
              object: {
                nested: {
                  field: 'secret'
                }
              }
            }) );

            it('masks nested objects', () =>
              expect(processedData).to.eql({
                object: {
                  nested: {
                    field: '*****'
                  }
                }
              })
            );
          });
        });

        context('with fields of nested elements whitelisted with wildcard', function() {
          pointers.is(() => ['/object/~/field']);
          data.is(() => ({
            object: {
              nested: {
                field: 'secret',
                field2: 'secret'
              }
            }
          }) );

          it('does not mask the field array elements', () =>
            expect(processedData).to.eql({
              object: {
                nested: {
                  field: 'secret',
                  field2: '*****'
                }
              }
            })
          );
        });
      });

      describe('README example', function() {
        pointers.is(() => ['/info/phone', '/addresses/~/host']);
        data.is(() => ({
          password: 'password',
          info: {
            phone: '+12055555555'
          },
          addresses: [{
            host: 'example.com',
            path: 'info'
          }]
        }) );

        it('does not mask the field array elements', () =>
          expect(processedData).to.eql({
            password: "*****",
            info: {
              phone: "+12055555555"
            },
            addresses: [{
              host: "example.com",
              path: "*****"
            }]
          })
        );
      });
    });

    context('with prune strategy', function() {
      action.is(() => 'prune');

      context('with whitelisted field', function() {
        pointers.is(() => ['/field']);

        it('includes only the field', () =>
          expect(processedData).to.eql({
            field: 'secret'
          })
        );
      });

      context('with whitelisted nested field', function() {
        pointers.is(() => ['/nested/field']);

        it('includes nested field', () =>
          expect(processedData).to.eql({
            nested: {
              field: 'secret'
            }
          })
        );
      });

      context('with whitelisted array element field', function() {
        pointers.is(() => ['/array/0/field']);

        it('includes array element field', () =>
          expect(processedData).to.eql({
            array: [{field: 'secret'}]
          })
        );
      });

      context('with whitelisted array element', function() {
        pointers.is(() => ['/array/0']);

        it('prunes unlisted array element', () =>
          expect(processedData).to.eql({
            array: [{}]
          })
        );
      });

      context('with whitelisted array', function() {
        pointers.is(() => ['/array']);

        it('prunes array contents', () =>
          expect(processedData).to.eql({
            array: []
          })
        );
      });

      context('with whitelisted object', function() {
        pointers.is(() => ['/data']);

        it('prunes unlisted object fields', () =>
          expect(processedData).to.eql({})
        );
      });

      context('when field has slash in the name', function() {
        data.is(() => ({'field_with_/': 'secret'}));
        pointers.is(() => ['/field_with_~1']);

        it('does not prune it', () => expect(processedData).to.eql({'field_with_/': 'secret'}));
      });

      context('when field has tilde in the name', function() {
        data.is(() => ({'field_with_~': 'secret'}));
        pointers.is(() => ['/field_with_~0']);

        it('does not prune it', () => expect(processedData).to.eql({'field_with_~': 'secret'}));
      });

      describe('wildcard', function() {
        context('with array elements whitelisted with wildcard', function() {
          pointers.is(() => ['/array/~']);

          context('with string array', function() {
            data.is(() => ({
              array: ['one', 'two']
            }) );

            it('does not prune array elements', () =>
              expect(processedData).to.eql({
                array: ['one', 'two']
              })
            );
          });

          context('with objects', function() {
            data.is(() => ({
              array: [{field: 'secret'}]
            }) );

            it('prunes nested array elements', () =>
              expect(processedData).to.eql({
                array: [{}]
              })
            );
          });
        });

        context('with fields of array elements whitelisted with wildcard', function() {
          pointers.is(() => ['/array/~/field']);
          data.is(() => ({
            array: [{field: 'secret', field2: 'secret'}]
          }) );

          it('prunes the unlisted array elements', () =>
            expect(processedData).to.eql({
              array: [{field: 'secret'}]
            })
          );
        });

        context('with hash fields whitelisted with wildcard', function() {
          pointers.is(() => ['/object/~']);

          context('with object', function() {
            data.is(() => ({
              object: {
                field: 'secret'
              }
            }) );

            it('does not prune fields', () =>
              expect(processedData).to.eql({
                object: {
                  field: 'secret'
                }
              })
            );
          });

          context('with nested objects', function() {
            data.is(() => ({
              object: {
                nested: {
                  field: 'secret'
                }
              }
            }) );

            it('prunes nested objects', () =>
              expect(processedData).to.eql({
                object: {
                  nested: {}
                }
              })
            );
          });
        });

        context('with fields of nested elements whitelisted with wildcard', function() {
          pointers.is(() => ['/object/~/field']);
          data.is(() => ({
            object: {
              nested: {
                field: 'secret',
                field2: 'secret'
              }
            }
          }) );

          it('prunes unlisted field array elements', () =>
            expect(processedData).to.eql({
              object: {
                nested: {
                  field: 'secret'
                }
              }
            })
          );
        });
      });

      describe('README example', function() {
        pointers.is(() => ['/info/phone', '/addresses/~/host']);
        data.is(() => ({
          password: 'password',
          info: {
            phone: '+12055555555'
          },
          addresses: [{
            host: 'example.com',
            path: 'info'
          }]
        }) );

        it('does not mask the field array elements', () =>
          expect(processedData).to.eql({
            info: {
              phone: "+12055555555"
            },
            addresses: [{
              host: "example.com"
            }]
          })
        );
      });
    });
  });
});

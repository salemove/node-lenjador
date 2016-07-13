process.env.NODE_ENV = 'test'

global.sinon = require 'sinon'
global.chai = require 'chai'
global.expect = chai.expect
global.expect = chai.expect
global.memo = require 'memo-is'

sinonChai = require 'sinon-chai'
chai.use(sinonChai)
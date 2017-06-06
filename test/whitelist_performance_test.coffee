Whitelist = require '../lib/logasm/preprocessors/whitelist'

buildPointers = (exactPointersCount, wildcardPointersCount) ->
  pointers = []

  for index in [1..exactPointersCount]
    pointers.push("/exact#{index}")

  for index in [1..wildcardPointersCount]
    pointers.push("/wildcard#{index}/~")

  pointers

describe 'Whitelist Performance', ->

  it 'processes 10K statements for 100 exact and wildcard pointers with less than 100 milliseconds', ->
    exactPointersCount = 100
    wildcardPointersCount = 100
    messagesToProcess = 10000

    whitelist = new Whitelist(pointers: buildPointers(exactPointersCount, wildcardPointersCount))

    startTimestamp = new Date()

    for num in [1..messagesToProcess]
      whitelist.process {
        exact5: 'is',
        exact40: 'this',
        exact60: 'the',
        wildcard5: {real: 'life'}
        wildcard20: {is: 'this'}
        secret: 'life'
      }

    endTimestamp = new Date()
    duration = endTimestamp.getTime() - startTimestamp.getTime()

    expect(duration).to.be.at.most(100)

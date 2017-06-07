const Whitelist = require('../lib/logasm/preprocessors/whitelist');

let buildPointers = function(exactPointersCount, wildcardPointersCount) {
  let pointers = [];

  for (let index = 0; index < exactPointersCount; index++) {
    pointers.push(`/exact${index}`);
  }

  for (let index = 0; index < wildcardPointersCount; index++) {
    pointers.push(`/wildcard${index}/~`);
  }

  return pointers;
};

describe('Whitelist Performance', () =>

  it('processes 10K statements for 100 exact and wildcard pointers with less than 100 milliseconds', function() {
    let exactPointersCount = 100;
    let wildcardPointersCount = 100;
    let messagesToProcess = 10000;

    let whitelist = new Whitelist({pointers: buildPointers(exactPointersCount, wildcardPointersCount)});

    let startTimestamp = new Date();

    for (let i = 0; i < messagesToProcess; i++) {
      whitelist.process({
        exact5: 'is',
        exact40: 'this',
        exact60: 'the',
        wildcard5: {real: 'life'},
        wildcard20: {is: 'this'},
        secret: 'life'
      });
    }

    let endTimestamp = new Date();
    let duration = endTimestamp.getTime() - startTimestamp.getTime();

    expect(duration).to.be.at.most(100);
  })
);

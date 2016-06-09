var chai = require('chai');
var expect = chai.expect
  , should = chai.should();
var NumberBlackBox = require(__dirname+'/../src/NumberBlackBox.js');

describe('NumberBlackBox Unit tests', function() {

  var numberBlackBox = new NumberBlackBox();

  // GETNUMBER
  it('getNumber() should return a number', function() {
    expect(numberBlackBox.getNumber()).to.not.be.NaN;
  });

  // ADD
  it('add() should return resulting number', function() {
    expect(numberBlackBox.add(1)).to.equal(numberBlackBox.getNumber());
  });

  it('add() should return NaN if a NaN value is passed in as argument', function() {
    expect(numberBlackBox.add('hello')).to.be.NaN;
  });

  // subtract
  it('subtract() should return resulting number', function() {
    expect(numberBlackBox.subtract(1)).to.equal(numberBlackBox.getNumber());
  });

  it('subtract() should return NaN if a NaN value is passed in as argument', function() {
    expect(numberBlackBox.subtract('hello')).to.be.NaN;
  });

});

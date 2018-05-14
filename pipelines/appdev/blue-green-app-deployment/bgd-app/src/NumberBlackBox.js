function NumberBlackBox() {
};

NumberBlackBox.prototype.myNumber = Math.floor(Math.random() * 1000); // generates a number between 0 and 1000

NumberBlackBox.prototype.getNumber = function() {
  return this.myNumber;
};

NumberBlackBox.prototype.add = function(delta) {
  if ( isNaN(delta) ) { return NaN };
  this.myNumber += delta;
  return this.myNumber;
};

NumberBlackBox.prototype.subtract = function(delta) {
  if ( isNaN(delta) ) { return NaN };
  this.myNumber -= delta;
  return this.myNumber;
};

module.exports = NumberBlackBox;

var BookLocal = artifacts.require('./BookLocal.sol');
var Hotel = artifacts.require('./Hotel.sol');
var RoomType = artifacts.require('./RoomType.sol');
var Reservation = artifacts.require('./Reservation.sol');

module.exports = function(deployer,networks,accounts) {
  deployer.deploy(BookLocal,[accounts[0]],accounts[0]);
};

// need to deploy MultiDigWallet and Escrow...

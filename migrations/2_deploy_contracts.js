var BookLocal = artifacts.require('./BookLocal.sol');

module.exports = function(deployer,networks,accounts) {
  deployer.deploy(BookLocal,[accounts[0]],accounts[0]);
};

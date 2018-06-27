var BookLocal = artifacts.require('./BookLocal.sol');

let steve = "0xBAE2175539624c861920C9566486DA79b582D362";
let bookLocalWallet = "0xd4acca3da200a57b3d4e091b2b0dc6812781bd52";

module.exports = function(deployer,networks) {
  deployer.deploy(BookLocal,[steve],bookLocalWallet);
};

// need to deploy MultiDigWallet and Escrow...

var HDWalletProvider = require("truffle-hdwallet-provider");

// random generated. First account is 0xa00CDd6d976e4b22D94098dD5e185E12045d03D6
var mnemonic = "box ketchup large early mutual obscure anxiety guide scheme film fever juice";

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: { // used if truffle console is ran
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // Match any network id
    },
    truffleDevelop: { // used
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    rinkeby: { 
      provider: function() {return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/ZaVfmcipJtP2PwcV9t8t")},
      network_id: 4,
      gas: 7012388 // Gas limit used for deploys
    }
  }
};

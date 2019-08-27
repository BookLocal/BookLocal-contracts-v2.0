var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');

const utils = require('./utils.js');

contract('BookLocal', function([blWallet,hotelWallet,guestWallet,serverAddr]) {

    let bookLocal;

    beforeEach('setup BookLocal', async function() {
        bookLocal = await BookLocal.new([blWallet],blWallet);
        let receipt = await web3.eth.getTransactionReceipt(bookLocal.transactionHash);
        console.log("Total gas used on deploy: " + receipt.gasUsed)
        assert.ok(bookLocal);
    })

    // make sure money is sent to the right place!
    it('should have the correct wallet', async() => {
        const wallet = await bookLocal.bookLocalWallet.call();
        assert.equal(wallet, blWallet, "wrong wallet");
    })

    // make sure BookLocal can add new hotels. Check:
    //    - counts hotel
    //    - stores proper hotel address
    it('should track new hotel counts and addresses', async() => {
        const tx = await bookLocal.newHotel([hotelWallet],hotelWallet, {gas: 5000000});
        const hotelAddressFromTx = utils.getAddressFromTxEvent(tx);
        const hotel = await bookLocal.hotelRegistry(0);    // access public array this way 
        assert.equal(hotel, hotelAddressFromTx, "different addresses");
    })

    it('should let me add a new BookLocal server', async() => {
        await bookLocal.addServer(serverAddr, {from:blWallet});
        _server = await bookLocal.bookLocalServer.call();
        assert.equal(_server, serverAddr, 'Server address not set.')
    })
})

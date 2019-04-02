var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');

const utils = require('./utils.js');

contract('BookLocal', function([blWallet,hotelWallet,guestWallet]) {

    let bookLocal;

    beforeEach('setup BookLocal', async function() {
        bookLocal = await BookLocal.new([blWallet],blWallet);
        assert.ok(bookLocal);
    })

    // make sure money is sent to the right place!
    it('should have the correct wallet', async() => {
        const wallet = await bookLocal.getWallet();
        assert.equal(wallet, blWallet, "wrong wallet");
    })

    // make sure BookLocal can add new hotels. Check:
    //    - counts hotel
    //    - stores proper hotel address
    it('should track new hotel counts and addresses', async() => {
        // set upper bound on gas use
        const tx = await bookLocal.newHotel([hotelWallet],hotelWallet, {gas: 5000000});
        const hotelAddressFromTx = utils.getAddressFromTxEvent(tx);
        const hotelCount = await bookLocal.getHotelCount();
        const hotelAddressFromBL = await bookLocal.getHotelAddress(1);

        assert.equal(hotelCount, 1, "no new hotel");
        assert.equal(hotelAddressFromTx, hotelAddressFromBL, "different addresses");
    })
})

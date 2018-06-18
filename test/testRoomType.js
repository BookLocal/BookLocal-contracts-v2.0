var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');
var RoomType = artifacts.require('RoomType');

const utils = require('./utils.js');

contract('RoomType', function([blWallet,hotelWallet,guestWallet]) {

    let bookLocal;
    let hotelAddress;
    let hotel;
    let roomTypeAddr;
    let roomType;

    // make a fresh roomType for each call and make sure:
    //    - roomType count and address are stored in hotel
    beforeEach('setup roomType', async function() {
        const price = 100;
        const sleeps = 2;
        const inventory = 10;

        bookLocal = await BookLocal.new([blWallet],blWallet);
        await bookLocal.newHotel([hotelWallet], hotelWallet);

        hotelAddress = await bookLocal.getHotelAddress(1);
        hotel = await Hotel.at(hotelAddress);
        await hotel.addRoomType(price, sleeps, inventory, {from:hotelWallet});

        roomTypeAddr = await hotel.getRoomTypeAddress(0);
        roomType = await RoomType.at(roomTypeAddr);
        assert.ok(roomType);
    })

    // make sure the price is correct
    it('should have the correct price', async() => {
        const price = await roomType.getPrice();
        assert.equal(price, 100, "wrong price");
    })

    // make sure inventory is correct and available
    it('should have the correct inventory and availability', async() => {
        const inventory = await roomType.getRoomTypeInventory();
        const available = await roomType.getAvailability(1);
        assert.equal(inventory, 10, "wrong inventory");
        assert.equal(inventory.toNumber(), available.toNumber(), "wrong availability");
    })

    it('should let hotel change price', async() => {
        await hotel.changeRoomTypePrice(roomTypeAddr, 75,{from:hotelWallet});
        const price = await roomType.getPrice();
        assert.equal(price, 75);
    })

    it('should not let guest change price through hotel call', async() => {
        try {
            await hotel.changeRoomTypePrice(roomTypeAddr, 75, {from:guestWallet});
            assert.fail('Expected revert');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    it('should not let guest change price through roomType call', async() => {
        try {
            await roomType.changePrice(75, {from:hotelWallet});
            assert.fail('Expected revert');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    it('should let you get room type information', async() => {
        const price = await roomType.getPrice();
        const sleeps = await roomType.getNumSleeps();
        assert.equal(price.toNumber(), 100);
        assert.equal(sleeps.toNumber(), 2);
    })
})

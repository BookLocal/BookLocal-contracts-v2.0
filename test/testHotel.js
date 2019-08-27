var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');
var RoomType = artifacts.require('RoomType');

const utils = require('./utils.js');

contract('Hotel', function([blWallet,hotelWallet,guestWallet,blServerAddr]) {

    let bookLocal;
    let hotelAddress;
    let hotel;
    let roomCode = 10;

    beforeEach('setup Hotel', async function() {
        bookLocal = await BookLocal.new([blWallet],blWallet);
        await bookLocal.addServer(blServerAddr);
        await bookLocal.newHotel([hotelWallet], hotelWallet);
        hotelAddress = await bookLocal.hotelRegistry(0);
        hotel = await Hotel.at(hotelAddress);
        assert.ok(hotel);
    })

    it('should have the correct wallet', async() => {
        const walletFromContract = await hotel.hotelWallet.call();
        assert.equal(walletFromContract, hotelWallet);
    })

    it('should only let hotel owner create inventory', async () => {
        await hotel.addRoomType(100,2,1,10,{from:hotelWallet});
        const roomCount = await hotel.getTotalRooms();
        assert.equal(roomCount, 10);
    })

    it('should not let bookLocal (or anyone else) create inventory', async() => {
        try {
            await hotel.addRoomType(100,2,1,10,{from:blWallet});
            assert.fail('Expected revert');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })
})

var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');
var RoomType = artifacts.require('RoomType');
var Reservation = artifacts.require('Reservation');

contract('Reservation with checkIn date today', function([blWallet,hotelWallet,guestWallet,attacker]) {

    let bookLocal;
    let hotelAddress;
    let hotel;
    let reservationAddr;
    let reservation;
    let checkIn;
    let checkOut;
    let roomTypeId = 0;
    let hotelDB_id = 10;
    let roomDB_id = 10;

    // make a new reservation
    beforeEach('setup reservation', async function() {
        /* set up new reservation with a check in date for 'today' */

        const price = 100;
        const sleeps = 2;
        const beds = 1;
        const inventory = 10;

        // new booklocal and hotel
        bookLocal = await BookLocal.new([blWallet],blWallet);
        const newHotelTx = await bookLocal.newHotel([hotelWallet], hotelWallet, hotelDB_id);
        hotelAddress = await bookLocal.getHotelAddress(1);
        hotel = await Hotel.at(hotelAddress);

        // add new room
        await hotel.addRoomType(price, sleeps, beds, inventory, roomDB_id, {from:hotelWallet});

        // set checkIn and checkOut info
        checkIn = await hotel.getCurrentAdjustedTime(roomTypeId);
        checkOut = checkIn.toNumber() + 2;

        // make reservation and get it's info
        await hotel.reserve(roomTypeId, checkIn.toNumber(), checkOut, {from:guestWallet, value:200});
        const reservations = await hotel.getReservationByCheckInDay(checkIn.toNumber());
        reservationAddr = reservations[0];
        reservation = await Reservation.at(reservationAddr);
        assert.ok(reservation);
    })

    it("should fail if you don't send enough money", async() => {
        try {
            await hotel.reserve(0, checkIn.toNumber(), checkOut, {from:guestWallet, value:100});
            assert.fail('expected revert');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    // check balance of reservation escrow
    it('should have money in it after a correct call', async() => {
        const balance = await reservation.getBalance();
        assert.equal(balance, 200, "different balance");
    });

    // check bookLocal and hotel wallets
    it('should find the correct wallets for checkout transfers', async() => {
        const _blWallet = await reservation.getBookLocalWallet();
        const _hotelWallet = await reservation.getHotelWallet();
        assert.equal(blWallet, _blWallet);
        assert.equal(hotelWallet, _hotelWallet);
    })

    // check that only owner can change price
    it('should let hotel owner change price', async() => {
        await hotel.changeReservationPrice(reservationAddr, 75, {from:hotelWallet});
        assert.equal(await reservation.getPrice(), 75);
    })

    it('should not let guest change price by calling through the hotel', async() => {
        try {
            await hotel.changeReservationPrice(reservationAddr, 75, {from:guestWallet});
            assert.fail('Expected revert not received');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    it('should not let guest change price by calling through the reservation', async() => {
        try {
            await reservation.changePrice(75, {from:guestWallet});
            assert.fail('Expected revert not received');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    it('should update availability after a reservation is made', async() => {
        const availability = await hotel.getAvailability(roomTypeId, checkIn.toNumber());
        assert.equal(availability, 9);
    })

    it('should let the guest checkIn ', async() => {
        const canCheckIn = await hotel.access(reservationAddr, guestWallet);
        assert.equal(canCheckIn, true);
    })

    it('should not let an attacker call checkout', async() => {
        try {
            await reservation.checkOut({from:attacker});
            assert.fail('Expected revert not received');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    it('should let guest checkout', async() => {
        assert(await reservation.checkOut({from:guestWallet}));
    })

    it('should let hotel checkout', async() => {
        assert(await hotel.settle(reservationAddr,{from:hotelWallet}));
    })

    it('should let bookLocal checkout', async() => {
        assert(await bookLocal.settle(reservationAddr,{from:blWallet}));
    })

    it('should not let the guest cancel the day of checkIn', async() => {
        try {
            await await reservation.cancel({from: guestWallet});
            assert.fail('Expected revert not received');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })
})

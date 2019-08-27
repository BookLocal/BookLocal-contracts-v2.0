var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');
var RoomType = artifacts.require('RoomType');
var Reservation = artifacts.require('Reservation');

contract('Reservation with checkIn date today', function([blWallet,hotelWallet,guestWallet,attacker,blServer]) {

    let bookLocal;
    let hotelAddress;
    let hotel;
    let roomTypeAddr;
    let reservationAddr;
    let reservation;
    let checkIn;
    let checkOut;

    // make a new reservation
    beforeEach('setup reservation', async function() {
        /* set up new reservation with a check in date for 'today' */

        const price = 100;
        const sleeps = 2;
        const beds = 1;
        const inventory = 10;

        // new booklocal and hotel
        bookLocal = await BookLocal.new([blWallet],blWallet);
        await bookLocal.addServer(blServer);
        bookLocalServer = await bookLocal.bookLocalServer.call();
        const newHotelTx = await bookLocal.newHotel([hotelWallet], hotelWallet);
        hotelAddress = await bookLocal.hotelRegistry(0);
        hotel = await Hotel.at(hotelAddress);

        // add new room
        await hotel.addRoomType(price, sleeps, beds, inventory, {from:hotelWallet});

        // set checkIn and checkOut info
        roomTypeAddr = await hotel.roomTypes(0);
        checkIn = await hotel.getCurrentAdjustedTime(roomTypeAddr);
        checkIn = checkIn.toNumber();
        checkOut = checkIn + 2;

        // make reservation and get it's info
        await hotel.reserve(roomTypeAddr, checkIn, checkOut, {from:guestWallet, value:200});
        const reservations = await hotel.getReservationByCheckInDay(checkIn);
        reservationAddr = reservations[0];
        reservation = await Reservation.at(reservationAddr);
        assert.ok(reservation);
    })

    it("should fail if you don't send enough money", async() => {
        try {
            await hotel.reserve(roomTypeAddr, checkIn, checkOut, {from:guestWallet, value:100});
            assert.fail('expected revert');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })

    it('should allow the bookLocal server to make a reservation without any money', async() => {
        await hotel.reserve(roomTypeAddr, checkIn, checkOut, {from:bookLocalServer})
        assert.ok('expected success')
    })

    // check balance of reservation escrow
    it('should have money in it after a correct call', async() => {
        const balance = await web3.eth.getBalance(reservationAddr);
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
        assert.equal(await reservation.reservationPrice.call(), 75);
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

    it('should let hotel owner set the cancellation price', async() => {
        await hotel.changeCancelPrice(reservationAddr, 75, {from:hotelWallet});
        assert.equal(await reservation.cancelPrice.call(), 75);
    })

    it('should update availability after a reservation is made', async() => {
        const availability = await hotel.getAvailability(roomTypeAddr, checkIn);
        assert.equal(availability, 9);
    })

    it('should let the guest checkIn ', async() => {
        const canCheckIn = await hotel.canAccess(reservationAddr, guestWallet);
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
        assert(await hotel.closeReservation(reservationAddr,{from:hotelWallet}));
    })

    it('should let bookLocal checkout', async() => {
        assert(await bookLocal.closeReservation(reservationAddr,{from:blWallet}));
    })

    it('should not let the guest cancelReservation the day of checkIn', async() => {
        try {
            await await reservation.cancelReservation({from: guestWallet});
            assert.fail('Expected revert not received');
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    })
})

var BookLocal = artifacts.require('BookLocal');
var Hotel = artifacts.require('Hotel');
var RoomType = artifacts.require('RoomType');
var Reservation = artifacts.require('Reservation');

contract('Reservation with future checkIn date', function([blWallet,hotelWallet,guestWallet,attacker]) {

    let bookLocal;
    let hotelAddress;
    let hotel;
    let roomTypeAddr;
    let reservationAddr;
    let reservation;
    let checkIn;
    let checkOut;
    let roomTypeId = 0;

    // make a new reservation
    beforeEach('setup reservation', async function() {
        /* set up new reservation with a check in date for 'today' */

        const price = 100;
        const sleeps = 2;
        const beds = 2;
        const inventory = 10;

        // new booklocal and hotel
        bookLocal = await BookLocal.new([blWallet],blWallet);
        const newHotelTx = await bookLocal.newHotel([hotelWallet], hotelWallet);
        hotelAddress = await bookLocal.hotelRegistry(0);
        hotel = await Hotel.at(hotelAddress);

        // add new room
        await hotel.addRoomType(price, sleeps, beds, inventory, {from:hotelWallet});

        // set checkIn for tomorrow
        roomTypeAddr = await hotel.roomTypes(0);
        checkIn = await hotel.getCurrentAdjustedTime(roomTypeAddr);
        checkIn = checkIn.toNumber() + 1;
        checkOut = checkIn + 2;

        // make reservation and get it's info
        await hotel.reserve(roomTypeAddr, checkIn, checkOut, {from:guestWallet, value:200});
        const reservations = await hotel.getReservationByCheckInDay(checkIn);
        reservationAddr = reservations[0];
        reservation = await Reservation.at(reservationAddr);
        assert.ok(reservation);
    })

    it('should not let the guest checkIn early', async() => {
        const canCheckIn = await hotel.canAccess(reservationAddr, guestWallet);
        assert.equal(canCheckIn, false);
    })

    it('should let the guest cancel before checkIn', async() => {
        assert(await reservation.cancelReservation({from:guestWallet}));
    })

    it('should update availability after a guest cancels', async() => {
        await reservation.cancelReservation({from:guestWallet});
        const roomType = await RoomType.at(roomTypeAddr);

        const available = await roomType.getAvailability(checkIn);
        assert.equal(available, 10);
    })
})

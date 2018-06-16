// define contracts for JS
var BookLocal = artifacts.require('./BookLocal.sol');
var Hotel = artifacts.require('./Hotel.sol');
var RoomType = artifacts.require('./RoomType.sol');
var Reservation = artifacts.require('./Reservation.sol');

// attach to BookLocal
let bl, hotelAddr, hotel, hotelOwner, hotelWallet;
let roomTypeAddr, roomType, reservationAddrs, reservation;
let currentDay, checkOut, guest;

blOwner = web3.eth.accounts[0];
hotelOwner = web3.eth.accounts[1];
hotelWallet = web3.eth.accounts[2];
guest1 = web3.eth.accounts[3];
guest2 = web3.eth.accounts[4];
guest3 = web3.eth.accounts[5];
guest4 = web3.eth.accounts[6];

///////////////
/* BOOKLOCAL */
///////////////

// access bookLocal
BookLocal.deployed().then(function(res) {bl = res});

// deploy new hotel
bl.newHotel([hotelOwner],hotelWallet);

// get hotel address
// note hotel is stored in an mapping from hotelID to address.
// So the first hotel address is looked up at id=1.
bl.getHotelAddress.call(1).then(function(addr) {hotelAddr = addr;});

///////////
/* HOTEL */
///////////

// access hotel
Hotel.at(hotelAddr).then(function(res) {hotel = res});

// add room inventory through room type
hotel.addRoomType(1000, 2, 5, {from:hotelOwner})

// check total inventory (should equal 5)
hotel.getTotalRooms.call().then(function(rooms) {console.log(rooms.toNumber())});

// get current time in proper units
hotel.getCurrentAdjustedTime.call(0).then(function(time) {currentDay = time.toNumber()});

// get roomType address and contract
// note roomType is stored in an array. So the first
// roomType address is stored at index 0.
hotel.getRoomTypeAddress.call(0).then(function(addr) {roomTypeAddr = addr});

// make reservation
checkOut = currentDay + 1;
hotel.reserve(0, currentDay, checkOut, {from:guest, value:10000});

// get reservation address
hotel.getReservationByCheckInDay.call(currentDay).then(function(array) {reservationAddrs = array});

/////////////////
/* RESERVATION */
/////////////////

// access reservation
Reservation.at(reservationAddrs[0]).then(function(res) {reservation = res});

// make sure we can check in today
hotel.access.call(reservationAddrs[0],guest).then(function(res) {console.log(res)});

// hotel checks out the guest
hotel.settle(reservationAddrs[0], {from:hotelOwner});

/*
// Alternatively, the guest could check out like so:
reservation.checkOut({from:guest});
*/

////////////////////////////////////////
/* ROOMTYPE */// unused, but for example
////////////////////////////////////////

// access roomtype
RoomType.at(roomTypeAddr).then(function(res) {roomType = res});

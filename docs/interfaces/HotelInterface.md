[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

# Hotel Interface

## Events
These events are intended for front end and server use.
```js
  event Reserve(address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
```

```js
  event ChangeRoomPrice(address indexed roomType, uint256 newPrice);
```

```js
  event ChangeReservationPrice(address indexed reservation, uint256 newPrice);
```

## Functions

#### External
External functions are designed to be called from other contracts or user accounts. These are not (in general) supposed to be called inside the contract that created them.

```js
  function addRoomType(uint256 _price, uint256 _sleeps, uint256 _beds, uint256 _inventory) external;
  -> restricted to hotel owners.
  -> called in RoomTypesMolecule
```

```js
  function addAdmins(address[] _admins) external;
  -> restricted to hotel owners.
  -> adds hotel admins that can use select functions.
```

```js
  function addOwners(address[] _owners) external;
  -> restricted to hotel owners.
```

```js
  function removeAdmins(address[] _admins) external;
  -> restricted to hotel owners.
```

```js
  function removeOwners(address[] _owners) external;
  -> restricted to hotel owners.
```

```js
  function changeReservationPrice(address _reservationAddr, uint256 _newPrice) external;
  -> called in settle
```

```js
  function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice) external;
  -> restricted to hotel admins.
  -> called in RoomTypesMolecule
```

```js
  function getAdmins() external view returns (address[]);
  -> restricted to hotel admins.
  -> returns all current administrator addresses
  -> view function so costs zero gas.
  // note that this may return an array with some zero address values (0x000...000) if owners have been removed.
  // the zero addresses should be removed from the front end, but it is too costly to do so from the EVM.
```

```js
  function getOwners() external view returns (address[]);
  -> restricted to hotel admins.
  -> returns all current owner addresses
  -> view function so costs zero gas.
  // note that this may return an array with some zero address values (0x000...000) if owners have been removed.
  // the zero addresses should be removed from the front end, but it is too costly to do so from the EVM.
```

##### ERC809 renting
These functions are based on ERC809 - a proposed renting standard for all non-fungible assets.

```js
  function reserve(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) external payable;
  -> reserve access from _checkIn (inclusive) to _checkout (exclusive) of a specific roomType.
  -> payable. Must receive enough Ether as calculated by `_calculateReservationPrice(...)`
  -> each new reservation is essentially an escrow account between hotel, guest, and booklocal.
  -> the address of each new reservation is stored by both guest, and by checkin date.
  -> called by 'traveler interface' Reserve
```

```js
  function access(address _reservationAddr, address _potentialGuest) external view returns (bool);
  -> simple lookup with true or false return to show if guest has access.
  -> implementation looks at the reservation address and returns true if current day is greater than or equal to checkin day.  
```

```js
  function settle(address _reservationAddr) external;
  -> restricted to hotel admins.
  -> this ends the reservation contract and transfers money from reservation to hotel and booklocal. Any extra money is sent back to guest.
  -> called in Settle
```

```js
  function cancel(address _reservationAddr) external;
  -> restricted to admin
  -> cancel reservation and sends money back to guest.
  -> could be modified to send partial money to hotel.
```

```js
 function getReservationByCheckInDay(uint256 _day) external view returns (address[]);
 -> no restrictions on visibility.
 -> returns all reservations that begin on _day.
 -> called in ViewBookings
```

```js
  function getReservationByGuestAddr(address _guest) external view returns (address[])
  -> no restrictions on visibility.
  -> returns all reservations made by _guest.
  -> called in SingleBookingWindow and DetailsCard
```

```js
  function getRoomInfo(address _roomTypeAddr) external view returns (uint256 _sleeps, uint256 _beds, uint256 _price, uint256 _minRentTime);
  -> get relevant information about a particular roomtype
  -> called in ManageInventoryContainer
```

#### Public
These functions can be (and often are) called from within the contract and from outside.

```js
  function getWallet() public view returns (address);
  -> returns the hotel wallet.
  -> called in Payment
```

```js
  function getNumOfRoomTypes() public view returns (uint256);
  -> returns the number of roomType options.
  -> called in ManageInventoryContainer, TapeChart
```

```js
  function getRoomTypeAddress(uint256 _type) public view returns (address);
  -> returns the address of a particular roomtype.
  -> called in ManageInventoryContainer
```

```js
  function getAvailability(uint256 _roomType, uint256 _day) public view returns (uint256);
  -> returns the number of rooms (of a specific type) that are available to rent on a given day.
  -> called in 'traveler interface' Search
```

```js
  function getTotalRooms() public view returns (uint256);
  -> returns the total number of rooms (of any type) that the hotel has.
  -> called in ManageInventoryContainer
```

```js
  function hasAvailability(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (bool);
  -> calls 'getAvailability' on a given roomType for each date in the intended stay. Returns false if any day in the range [checkIn, checkOut) doesn't have any availability.
  -> called in 'traveler interface' Search
```

```js
  function getCurrentAdjustedTime(uint256 _roomType) public view returns (uint256);
  -> converts UNIX epochs into proper units for renting purpose.  
  -> for example, minRentTime defaults to 1 day (3600*24 seconds). This function takes the time now (in seconds) and divides by minRentTime.
```

```js
  function getReservationPrice(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (uint256 _price);
  -> wrapper function to calculate price for a given stay.
```

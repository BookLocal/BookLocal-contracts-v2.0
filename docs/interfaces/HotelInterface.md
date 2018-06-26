[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

## Contract Hotel Interface
```js
  event Reserve(address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
  -> listened for by BE
```
#### access is restricted to hotel owner
```js
  function addRoomType(uint256 _price, uint256 _sleeps, uint256 _inventory) external;
  -> called in RoomTypesMolecule
```
#### access is restricted to hotel admin
```js
  function changeReservationPrice(address _reservationAddr, uint256 _newPrice) external;
  -> called in settle
```
```js
  function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice) external;
  -> called in RoomTypesMolecule
```
```js
  function settle(address _reservationAddr) external;
  -> called in Settle
```
### Renting

#### access is open to all
```js
  function reserve(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) external payable;
  -> called by 'traveler interface' Reserve
```
#### Info
```js
  function getReservationByCheckInDay(uint256 _day) external view returns (address[] reservationAddress);
  -> called in ViewBookings
```
```js
  // where do the guest addresses come from?
  function getReservationByGuestAddr(address _guest) external view returns (address[]);
  -> called in SingleBookingWindow and DetailsCard
```
```js
  // returns hotel wallet address
  function getWallet() public view returns (address);
  -> called in Payment
```
```js
  function getNumOfRoomTypes() public view returns (uint256 _totalNumberOfRoomTypes);
  -> called in ManageInventoryContainer, TapeChart
```
```js
  function getRoomTypeAddress(uint256 _type) public view returns (uint256 _beds, uint256 _price);
  -> called in ManageInventoryContainer
```
```js
  // get total rooms in hotel (that booklocal has to sell)
  function getTotalRooms() public view returns (uint256);
  -> called in ManageInventoryContainer
```
```js
  function getRoomInfo(roomTypeAddress) public view returns (uint256 _sleeps, uint256 _price, uint256 _minRentTime);
  -> called in ManageInventoryContainer
```
```js
  function getAvailability(uint256 _roomType, uint256 _day) public view;
  -> called in 'traveler interface' Search
```
```js
  function hasAvailability(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (bool);
  -> called in 'traveler interface' Search
```
```js
  function getCurrentAdjustedTime(uint256 _roomType) public view returns (uint256);
  -> called in ? could also use Moment?
```
#### need
```js
  function addHotelAdmin(adminAddress) external;
  // hotel admin only
```
```js
  function deleteHotelAdmin(adminAddress) external;
  // hotel admin only
```
```js
  function getHotelAdminsArray() public view returns ([adminAddress]);
  // hotel admin only
```

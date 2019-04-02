# Hotel Interface

## Events
These events are intended for front end and server use.
```js
event Reserve(address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
event ChangeRoomPrice(address indexed roomType, uint256 newPrice);
event ChangeReservationPrice(address indexed reservation, uint256 newPrice);
```

## Functions

#### External

```js
function addRoomType(uint256 _price, uint256 _sleeps, uint256 _beds, uint256 _inventory) external;
function changeWallet(address _newWallet) senderIsOwner external;
function addAdmins(address _admin) external;
function addOwners(address _owner) external;
function removeAdmins(address _admin) external;
function removeOwners(address _owner) external;
function changeReservationPrice(address _reservationAddr, uint256 _newPrice) external;
function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice) external;
function getAdmins() external view returns (address[]);
function getOwners() external view returns (address[]);
```

#### ERC809 renting
```js
function reserve(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) external payable;
function access(address _reservationAddr, address _potentialGuest) external view returns (bool);
function settle(address _reservationAddr) external;
function cancel(address _reservationAddr) external;
function getReservationByCheckInDay(uint256 _day) external view returns (address[]);
function getReservationByGuestAddr(address _guest) external view returns (address[]);
function getRoomInfo(address _roomTypeAddr) external view returns (uint256 _sleeps, uint256 _beds, uint256 _price, uint256 _inventory);
```

#### Public
These functions can be (and often are) called from within the contract and from outside.

```js
function getWallet() public view returns (address);
function getNumOfRoomTypes() public view returns (uint256);
function getRoomTypeAddress(uint256 _type) public view returns (address);
function getAvailability(uint256 _roomType, uint256 _day) public view returns (uint256);
function hasAvailability(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (bool);
function getCurrentAdjustedTime(uint256 _roomType) public view returns (uint256);
function getReservationPrice(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (uint256 _price);
```

# Hotel Interface
Deploy Gas Used (1st Hotel): 3,869,515
Deploy Gas Used (2nd Hotel): 3,854,515
Deploy Gas Used (3rd Hotel): 3,854,515

## Events
```js
event Reserve(address indexed sender, address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
event ChangeRoomPrice(address indexed roomType, uint256 newPrice);
event ChangeReservationPrice(address indexed reservation, uint256 newPrice);
event NewHotelWallet(address wallet, address sender);
event NewRoomType(address indexed hotel, address indexed roomType);
```

## Functions

#### ERC809, renting
```js
function reserve(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) external payable;
function closeReservation(address _reservationAddr) senderIsAdmin external;
function cancelReservation(address _reservationAddr) senderIsAdmin external;
function canAccess(address _reservationAddr, address _potentialGuest) external view returns (bool);
function getReservationByCheckInDay(uint256 _day) external view returns (address[]);
function getReservationByGuestAddr(address _guest) external view returns (address[]);
```

#### External
```js
function addRoomType(uint256 _price, uint256 _sleeps, uint256 _beds, uint256 _inventory) senderIsOwner external;
function changeWallet(address _newWallet) senderIsOwner external;
function addAdmin(address _admin) external;
function addOwner(address _owner) external;
function removeAdmin(address _admin) external;
function removeOwner(address _owner) external;
function changeReservationPrice(address _reservationAddr, uint256 _newPrice) senderIsAdmin external;
function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice) senderIsAdmin external;
function getRoomInfo(address _roomTypeAddr) external view returns (uint256 _sleeps, uint256 _beds, uint256 _price, uint256 _inventory);
function getAdmins() external view returns (address[]);
function getOwners() external view returns (address[]);
```

#### Public
```js
function getWallet() public view returns (address);
function getNumOfRoomTypes() public view returns (uint256);
function getRoomTypeAddress(uint256 _type) public view returns (address);
function getAvailability(uint256 _roomType, uint256 _day) public view returns (uint256);
function hasAvailability(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (bool);
function getTotalRooms() public view returns (uint256);
function getCurrentAdjustedTime(uint256 _roomType) public view returns (uint256);
function getReservationPrice(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (uint256 _price);
```

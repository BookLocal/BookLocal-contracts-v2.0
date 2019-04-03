# BookLocal Interface
Deploy Gas Used: 6,063,634

## Events
```js
event NewHotelCreated(address hotelAddress);
event NewBookLocalWallet(address wallet);
```

## Functions

#### External
```js
function newHotel(address[] _owners, address _wallet) external returns (address hotel);
```
```js
function changeWallet(address _newWallet) senderIsOwner external;
function closeReservation(address _reservationAddr) senderIsOwner external;
function addOwner(address _owner) senderIsOwner external;
function removeOwner(address _owner) senderIsOwner external;
```

#### Public
```js
function getHotelCount() external view returns (uint256);
function getHotelAddress(uint256 _hotelId) public view  returns (address);
function getWallet() public view returns (address);
```

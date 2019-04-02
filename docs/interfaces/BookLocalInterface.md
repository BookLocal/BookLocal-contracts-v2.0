# BookLocal Interface

## Events
```js
event NewHotelCreated(address hotelAddress);
```

## Functions
Overview of function names separated by visibility.

#### External
External functions are intended to be called outside of the contract they were created in. Ideally, these are reserved for human calls.
```js
function newHotel(address[] _owners, address _wallet) external returns (address hotel);
function changeWallet(address _newWallet) senderIsOwner external;
function settle(address _reservationAddr) external;
function addOwner(address _owner) external;
function removeOwner(address _owner) external;
function getOwners() external returns (address[]);
```

#### Public
```js
function getHotelCount() external view returns (uint256);
function getHotelAddress(uint256 _hotelId) public view  returns (address);
function getWallet() public view returns (address);
```

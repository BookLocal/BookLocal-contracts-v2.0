# Reservation Interface

## Events
```js
event Deposit(address indexed sender, uint256 value);
event Cancel(address indexed guest, address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
event CheckOut(address indexed guest);
```

## Functions

#### External
```js
function checkOut() isInContract afterCheckIn external;
function cancelReservation() isInContract beforeCheckIn external;
function canCheckin(address _guest) external view returns (bool);
function changePrice(uint256 _newPrice) onlyHotel external;
function changeCancelPrice(uint256 _newPrice) onlyHotel external;
```

#### Public
```js
function getBookLocalWallet() public view returns (address);
function getHotelWallet() public view returns (address);
function getRoomType() public view returns (address);
function getCheckIn() public view returns (address);
function getCheckOut() public view returns (address);
function getBalance() public view returns (wallet balance);
function getPrice() public view returns (reservation price);
function getCancelPrice() public view returns (uint256);
```

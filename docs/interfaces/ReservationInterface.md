# Reservation Interface
Deploy Gas Used (1st Reservation): 1,290,032
Deploy Gas Used (2nd Reservation): 1,200,032
endReservation i.e. checkout (1st): 37,940
endReservation i.e. checkout (2nd): 37,940

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
```

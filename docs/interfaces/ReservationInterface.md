[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

# Reservation Interface
Costs 1,269,968 gas to deploy. 

## Events
```js
event Deposit(address indexed sender, uint256 value);
event CheckOut(address indexed guest);
event Cancel(address indexed guest, address indexed hotel);
```

## Functions

#### External

```js
function checkOut() external;
function cancel() isInContract beforeCheckIn external;
function canCheckin(address _guest) external view returns (bool);
function changePrice(uint256 _newPrice) external;
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

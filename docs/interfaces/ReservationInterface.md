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
  -> restricted to hotel, guest, and booklocal.
  -> calculates and transfers hotel share, booklocal share, and returns any extra to guest.
  -> selfdestructs when done.
  -> in 'Hotel Interface' BookLocalAdmin Settle, 'traveler interface' checkOut
```

```js
  function cancel() isInContract beforeCheckIn external;
  -> restricted to hotel, guest, and booklocal.
  -> calculates a cancelPrice and returns leftover to guest.
```

```js
  function canCheckin(address _guest) external view returns (bool);
  -> checks if _guest can check in right now.  
```

```js
 function changePrice(uint256 _newPrice) external;
 -> restricted to hotel.
```

```js
  function changeCancelPrice(uint256 _newPrice) onlyHotel external;
  -> defaults sets the cancel price at half of the reservation price.
  -> can change if different.
```

#### Public
```js
  function getBookLocalWallet() public view returns (address);
```
```js
  function getHotelWallet() public view returns (address);
```

```js
  function getRoomType() public view returns (address);
```

```js
  function getCheckIn() public view returns (address);
```

```js
  function getCheckOut() public view returns (address);
```

```js
  function getBalance() public view returns (wallet balance);
  -> called in ViewCurrentGuests on DetailsCard
```
```js
  function getPrice() public view returns (reservation price);
  -> called in ViewCurrentGuests
```

```js
  function getCancelPrice() public view returns (uint256);
```

[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

## ReservationInterface
```js
  event Deposit(address indexed sender, uint256 value);
  event CheckOut(address indexed guest);
  -> to BE
```
#### access restricted to only hotel call
```js
  function changePrice(uint256 _newPrice) external;
```
#### access restricted to only hotel, bookLocal, or guest
```js
  function checkOut() external;
  -> in 'Hotel Interface' BookLocalAdmin Settle, 'traveler interface' checkOut
```
#### access open to all
```js
  function getBookLocalWallet() public view returns (address);
```
```js
  function getHotelWallet() public view returns (address);
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
  function getRoomType() public view returns (roomTypeAddr)
  -> called in ViewBookings, DetailsCard?
```
```js
  function getCheckIn() public view returns (checkInDate)
  -> called in ViewBookings, SingleBookingWindow
```
```js
  function getCheckOut() public view returns (checkOutDate)
  -> called in ViewBookings, SingleBookingWindow
```

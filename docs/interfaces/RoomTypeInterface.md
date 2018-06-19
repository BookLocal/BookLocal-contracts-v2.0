[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

## RoomTypeInterface

#### access restricted to hotel contract calls
```js
  function changePrice(uint256 _newPrice) external;
```
```js
  function addReservation(uint256 _checkIn, uint256 _checkOut) external;
```
#### access open to all
```js
  function getDailyInfo(uint256 _day) public view returns (uint256 _checkIns, uint256 _checkOuts, uint256 _occupied);
```
```js
  function getAvailability(uint256 _day) public view returns (uint256);
  -> used in TapeChart
```
```js
  function getRoomTypeInventory() public view returns (uint256);
```
```js
  function getMinRentTime() public view returns (uint256);
```
```js
  function getPrice() public view returns (uint256);
  -> 'traveler interface' Search?
```

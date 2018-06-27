[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

# RoomType Interface
Costs 541,229 gas to deploy a new room type.

## Functions

#### External

```js
  function changePrice(uint256 _newPrice) onlyHotel external;
```
```js
  function addReservation(address _reservation, uint256 _checkIn, uint256 _checkOut) onlyHotel external;
```

```js
  function cancelReservation(uint256 _checkIn, uint256 _checkOut) onlyReservation external;
  -> adds room back into inventory.
```

#### Public
```js
  function getDailyInfo(uint256 _day) public view returns (uint256 _checkIns, uint256 _checkOuts, uint256 _occupied);
  -> returns an easy view for hotel management.
```

```js
  function getAvailability(uint256 _day) public view returns (uint256);
  -> returns the number of rooms not occupied.
  -> used in TapeChart
```

```js
  function getNumSleeps() public view returns (uint256);
```

```js
  function getNumBeds() public view returns (uint256);
```

```js
  function getRoomTypeInventory() public view returns (uint256);
  -> returns total inventory.
```
```js
  function getMinRentTime() public view returns (uint256);
```
```js
  function getPrice() public view returns (uint256);
  -> 'traveler interface' Search?
```

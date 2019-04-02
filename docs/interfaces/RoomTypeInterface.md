# RoomType Interface
Deploy Gas Used (1st Room): 629,911
Deploy Gas Used (2nd Room): 614,911

## Functions

#### External
```js
function changePrice(uint256 _newPrice) onlyHotel external;
function addReservation(address _reservation, uint256 _checkIn, uint256 _checkOut) onlyHotel external;
function cancelReservation(uint256 _checkIn, uint256 _checkOut) onlyReservation external;
```

#### Public
```js
function getDailyInfo(uint256 _day) public view returns (uint256 _checkIns, uint256 _checkOuts, uint256 _occupied);
function getAvailability(uint256 _day) public view returns (uint256);
function getNumSleeps() public view returns (uint256);
function getNumBeds() public view returns (uint256);
function getRoomTypeInventory() public view returns (uint256);
function getMinRentTime() public view returns (uint256);
function getPrice() public view returns (uint256);
```

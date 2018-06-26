[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

## BookLocalInterface
```js
  event NewHotelCreated(address location);
  -> picked up by BE server
```
#### access is restricted to hotel admins
```js
  function settle(address _reservationAddr) external;
  -> called at ViewCurrentGuests or a CheckOut view
```
```js
  function addAdmins(address[] _admins) external;
  -> called at HotelProfile - ManageEmployees
```
#### access is open to all
```js
  function newHotel(address[] _owners, uint256 _required) external;
  -> called as part of the registration process or from BookLocalAdmin component
  // needs to return something to the front end that will link the address with
  // the rest of the data. Could also accept another parameter and include in
  // the event.
```
```js
  function getHotelCount() external view returns (uint256);
  -> called at NavWrapper, BookLocalAdmin, and 'traveler interface' Search
  // not needed if the hotelEthAddress is returned from the server on login
```
```js
  function getHotelAddress(uint256 _hotelId) public returns (address);
  -> called at NavWrapper
```
```js
  function getWallet() public view returns (address);
  -> called in BookLocalAdmin
```
#### need
```js
  function getBookLocalAdminArray() public view returns ([adminAddress]);
  // booklocal admin only
```

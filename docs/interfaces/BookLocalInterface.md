[//]: <> ( in Atom hit ctrl + shift + m for markdown preview )

# BookLocal Interface
Deploy costs 5946815 gas to deploy! Need to reduce.

## Events
```js
  event NewHotelCreated(address hotelAddress);
  -> for use front end and server use.
```

## Functions
Overview of function names separated by visibility.

#### External
External functions are intended to be called outside of the contract they were created in. Ideally, these are reserved for human calls.
```js
  function newHotel(address[] _owners, address _wallet) external returns (address hotel);
  -> open for anyone to set up a new hotel.
  -> called as part of the registration process or from BookLocalAdmin component
  // needs to return something to the front end that will link the address with
  // the rest of the data. Could also accept another parameter and include in
  // the event.
```

```js
  function changeWallet(address _newWallet) senderIsOwner external;
  -> restricted to booklocal owner use
```

```js
  function settle(address _reservationAddr) external;
  -> ERC809 name for "checkOut"
  -> restricted to booklocal owner use
  -> shouldn't need to be used, but left as an option for if we allow for reservation disputes.
  -> called at ViewCurrentGuests or a CheckOut view
```

```js
  function addOwners(address[] _owners) external;
  -> restricted to owner use.
  -> adds owners to the BookLocal contract.
  -> called at HotelProfile - ManageEmployees.
```

```js
  function removeOwners(address[] _owners) external;
  -> restricted to owner use.
  -> removes owners from BookLocal contract.
```

```js
  function getOwners() external returns (address[]);
  -> returns all current owners.
```

#### Public
Public functions can be called within the contract they were created.
```js
  function getHotelCount() external view returns (uint256);
  -> called at NavWrapper, BookLocalAdmin, and 'traveler interface' Search
  // not needed if the hotelEthAddress is returned from the server on login
```
```js
  function getHotelAddress(uint256 _hotelId) public view  returns (address);
  -> called at NavWrapper
```
```js
  function getWallet() public view returns (address);
  -> called in BookLocalAdmin
```

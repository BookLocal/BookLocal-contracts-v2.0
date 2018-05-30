pragma solidity ^0.4.20;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './Reservation.sol';
import './RoomType.sol';

contract Hotel {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
    event Reserve(uint256 roomType, uint256 checkIn, uint256 checkOut);
    event Cancel(uint256 roomType, uint256 checkIn, uint256 checkOut);

    /**************************************************
     *  Storage
     */

    // BookLocal contract, NOT the wallet.
    address bookLocal;

    // Ownership
    address hotelWallet;

    address[] hotelOwners;
    mapping (address => bool) isOwner;

    address[] hotelAdmins;
    mapping (address => bool) isAdmin;

    // Inventory
    address[] roomTypes;
    uint256 totalInventory;

    // Reservations
    mapping (address => address[]) reservationsByGuest;
    mapping (uint256 => address[]) reservationsByCheckIn;

    /**************************************************
     *  Constructor
     */
    constructor(
        address[] _owners,
        address _wallet,
        address _bookLocal
    )
        public
    {
        uint256 numOwners = _owners.length;

        for(uint i=0; i<numOwners; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }

        hotelWallet = _wallet;
        hotelOwners = _owners;
        bookLocal = _bookLocal;
    }

    /**************************************************
     *  Fallback
     */
    function() public payable {
        revert();
    }

    /**************************************************
     *  Modifiers
     */
    modifier senderIsOwner() {
        require(isOwner[msg.sender]);
        _;
    }

    modifier senderIsAdmin() {
        require(isOwner[msg.sender] || isAdmin[msg.sender]);
        _;
    }

    /**************************************************
     *  External Functions
     */

    // Owner only
    function addRoomType(
        uint256 _price,
        uint256 _sleeps,
        uint256 _inventory
    )
        senderIsOwner
        external
    {
        address _hotel = address(this);
        address _roomType = new RoomType(_hotel, _price, _sleeps, _inventory);
        _recordRoomType(_roomType);
    }

    function changeReservationPrice(address _reservationAddr, uint256 _newPrice)
        senderIsOwner
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.changePrice(_newPrice);
    }

    function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice)
        senderIsOwner
        external
    {
        RoomType _roomType = RoomType(_roomTypeAddr);
        _roomType.changePrice(_newPrice);
    }

    function addAdmins(address[] _admins)
        senderIsOwner
        external
    {
        address _admin;
        uint numOwners = _admins.length;
        for(uint i=0; i<numOwners; i++) {
            _admin = _admins[i];
            require(!isAdmin[_admin] && _admin != address(0));
            isAdmin[_admin] = true;
        }
        hotelAdmins.push(_admin);
    }

    // Renting (i.e. ERC809)
    function reserve(
        uint256 _roomType,
        uint256 _checkIn,
        uint256 _checkOut
    )
        payable
        external
        returns (address _reservation)
    {
        address _roomTypeAddr = roomTypes[_roomType];
        RoomType room = RoomType(_roomTypeAddr);
        uint256 _pricePerNight = room.getPrice();

        uint256 _duration = _lengthOfReservation(_checkIn, _checkOut);
        uint256 _price = _calculateReservationPrice(_pricePerNight, _duration);

        require(msg.value >= _price);
        require(hasAvailability(_roomType, _checkIn, _checkOut));
        //require(_isFuture(_checkIn, room));

        address _bookLocal = bookLocal;
        address _hotel = address(this);
        address _guest = msg.sender;

        _reservation = new Reservation(
            _bookLocal,
            _hotel,
            _guest,
            _checkIn,
            _checkOut,
            _price
        );

        _reservation.transfer(msg.value);
        _recordReservation(_reservation, _guest, _checkIn);
        room.addReservation(_checkIn, _checkOut);
    }

    function settle(address _reservationAddr)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    /**************************************************
     *  Public
     */
    function getWallet() public view returns (address) {
        return hotelWallet;
    }

    function getNumOfRoomTypes() public view returns (uint256) {
        return roomTypes.length;
    }

    function getRoomTypeAddress(uint256 _type) public view returns (address) {
        return roomTypes[_type];
    }

    function getReservationByCheckInDay(uint256 _day) public view returns (address[]) {
        return reservationsByCheckIn[_day];
    }

    function getReservationByGuestAddr(address _guest) public view returns (address[]) {
        return reservationsByGuest[_guest];
    }

    function getAvailability(uint256 _roomTypeNum, uint256 _day) public view returns (uint256) {
        address _roomTypeAddr = roomTypes[_roomTypeNum];
        RoomType _roomType = RoomType(_roomTypeAddr);
        return _roomType.getAvailability(_day);
    }

    function getTotalRooms() public view returns (uint256) {
        uint256 _totalRoomTypes = getNumOfRoomTypes();
        uint256 _totalRooms;
        address _roomTypeAddr;
        RoomType _room;

        for (uint256 i=0; i<_totalRoomTypes; i++) {
            _roomTypeAddr = roomTypes[i];
            _room = RoomType(_roomTypeAddr);

            _totalRooms += _room.getRoomTypeInventory();
        }
        return _totalRooms;
    }

    function hasAvailability(
        uint256 _roomType,
        uint256 _checkIn,
        uint256 _checkOut
    )
        public
        view
        returns (bool)
    {
        address _roomTypeAddr = roomTypes[_roomType];
        RoomType _room = RoomType(_roomTypeAddr);

        for (uint i=_checkIn; i<_checkOut; i++) {
            uint256 _available = _room.getAvailability(i);

            if (_available <= 0) {
                return false;
            }
        }
        return true;
    }

    /**************************************************
     *  Internal
     */
    function _recordReservation(address _reservation, address _guest, uint256 _checkIn) internal {
        reservationsByGuest[_guest].push(_reservation);
        reservationsByCheckIn[_checkIn].push(_reservation);
    }

    function _recordRoomType(address _roomType) internal {
        roomTypes.push(_roomType);
    }

    function _isFuture(uint256 _reservationTime, RoomType _room)
        internal
        view
        returns (bool)
    {
        uint256 _minRentTime = _room.getMinRentTime();
        uint256 _adjustedTime = now.div(_minRentTime);
        return _adjustedTime > _reservationTime;
    }

    function _lengthOfReservation(uint256 _checkIn, uint256 _checkOut)
        internal
        pure
        returns (uint256)
    {
        require(_checkIn < _checkOut);
        return _checkOut.sub(_checkIn);
    }

    function _calculateReservationPrice(uint256 _price, uint256 _duration)
        internal
        pure
        returns (uint256)
    {
        return _price.mul(_duration);
    }
}

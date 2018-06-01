pragma solidity ^0.4.20;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './Reservation.sol';
import './RoomType.sol';

contract Hotel {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
    event Reserve(address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
    event ChangeRoomPrice(address indexed roomType, uint256 newPrice);
    event ChangeReservationPrice(address indexed reservation, uint256 newPrice);

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

    // Admin only
    function addAdmins(address[] _admins)
        senderIsAdmin
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

    function changeReservationPrice(address _reservationAddr, uint256 _newPrice)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.changePrice(_newPrice);
        emit ChangeReservationPrice(_reservationAddr, _newPrice);
    }

    function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice)
        senderIsAdmin
        external
    {
        RoomType _roomType = RoomType(_roomTypeAddr);
        _roomType.changePrice(_newPrice);
        emit ChangeRoomPrice(_roomTypeAddr, _newPrice);
    }

    // Renting (i.e. ERC809)
    function reserve(
        uint256 _roomType,
        uint256 _checkIn,
        uint256 _checkOut
    )
        external
        payable
    {
        address _roomTypeAddr = roomTypes[_roomType];
        RoomType _room = RoomType(_roomTypeAddr);

        uint256 _price = _calculateReservationPrice(_room, _checkIn, _checkOut);
        require(msg.value >= _price);

        require(hasAvailability(_roomType, _checkIn, _checkOut));
        require(_isNotPast(_checkIn, _room));

        address _bookLocal = bookLocal;
        address _hotel = address(this);
        address _guest = msg.sender;
        uint256 _minRentTime = _room.getMinRentTime();

        address _reservation = new Reservation(
            _bookLocal,
            _hotel,
            _guest,
            _checkIn,
            _checkOut,
            _price,
            _minRentTime
        );

        _reservation.transfer(msg.value);
        _recordReservation(_reservation, _guest, _checkIn);
        _room.addReservation(_checkIn, _checkOut);
        emit Reserve(_reservation, _roomTypeAddr, _checkIn, _checkOut);
    }

    function access(address _reservationAddr, address _potentialGuest)
        external
        view
        returns (bool)
    {
        Reservation _reservation = Reservation(_reservationAddr);
        return _reservation.canCheckIn(_potentialGuest);
    }

    function settle(address _reservationAddr)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function cancel(address _reservationAddr)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.cancel();
    }

    function getReservationByCheckInDay(uint256 _day)
        external
        view
        returns (address[])
    {
        return reservationsByCheckIn[_day];
    }

    function getReservationByGuestAddr(address _guest)
        external
        view
        returns (address[])
    {
        return reservationsByGuest[_guest];
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

    function getAvailability(uint256 _roomType, uint256 _day)
        public
        view
        returns (uint256)
    {
        address _roomTypeAddr = roomTypes[_roomType];
        RoomType _room = RoomType(_roomTypeAddr);
        return _room.getAvailability(_day);
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

    function getCurrentAdjustedTime(uint256 _roomType)
        public
        view
        returns (uint256)
    {
        address _roomTypeAddr = roomTypes[_roomType];
        RoomType _room = RoomType(_roomTypeAddr);
        uint256 _minRentTime = _room.getMinRentTime();
        return now.div(_minRentTime);
    }

    /**************************************************
     *  Internal
     */
    function _recordReservation(
        address _reservation,
        address _guest,
        uint256 _checkIn
    )
        internal
    {
        reservationsByGuest[_guest].push(_reservation);
        reservationsByCheckIn[_checkIn].push(_reservation);
    }

    function _recordRoomType(address _roomType) internal {
        roomTypes.push(_roomType);
    }

    function _isNotPast(uint256 _reservationTime, RoomType _room)
        internal
        view
        returns (bool)
    {
        uint256 _minRentTime = _room.getMinRentTime();
        uint256 _adjustedCurrentTime = now.div(_minRentTime);
        return _reservationTime >= _adjustedCurrentTime;
    }

    function _lengthOfReservation(uint256 _checkIn, uint256 _checkOut)
        internal
        pure
        returns (uint256)
    {
        require(_checkIn < _checkOut);
        return _checkOut.sub(_checkIn);
    }

    function _calculateReservationPrice(RoomType _room, uint256 _checkIn, uint256 _checkOut)
        internal
        view
        returns (uint256)
    {
        uint256 _lengthOfStay = _lengthOfReservation(_checkIn, _checkOut);
        uint256 _pricePerNight = _room.getPrice();
        return _pricePerNight.mul(_lengthOfStay);
    }
}

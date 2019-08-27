pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './BookLocal.sol';
import './Reservation.sol';
import './RoomType.sol';

contract Hotel {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
     
    event Reserve(address indexed sender, address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
    event ChangeRoomPrice(address indexed roomType, uint256 newPrice);
    event ChangeReservationPrice(address indexed reservation, uint256 newPrice);
    event NewHotelWallet(address wallet);
    event NewRoomType(address indexed hotel, address indexed roomType);

    /**************************************************
     *  Storage
     */

    // BookLocal contract, NOT the wallet.
    address public bookLocal;

    // Ownership
    address public hotelWallet;

    mapping (address => bool) isOwner;
    mapping (address => bool) isAdmin;

    // Inventory
    address[] public roomTypes;

    // Reservations
    mapping (address => address[]) public reservationsByGuest;
    mapping (uint256 => address[]) public reservationsByCheckIn;

    /**************************************************
     *  Constructor
     */

    constructor(
        address[] memory _owners,
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
    
    /* ERC809 renting */

    function reserve(
        address _roomTypeAddr,
        uint256 _checkIn,
        uint256 _checkOut
    )
        external
        payable
    {
        RoomType _room = RoomType(_roomTypeAddr);

        // make sure renter sends enough money OR is from BookLocal
        // this function also checks that checkout is after checkin
        address _bookLocalServer = getBookLocalServer();
        if (msg.sender != _bookLocalServer) {
            uint256 _price = _calculateReservationPrice(_room, _checkIn, _checkOut);
            require(msg.value >= _price);
        }

        // make sure there is availability
        // and that check in is in the future
        require(hasAvailability(_roomTypeAddr, _checkIn, _checkOut));
        require(_isNotPast(_checkIn, _room));

        address _bookLocal = bookLocal;
        address _hotel = address(this);
        address _guest = msg.sender;
        uint256 _minRentTime = _room.minRentTime();

        // make new Reservation
        // transfer the money to the new address
        // record the reservation for both hotel and roomType
        address _reservation = new Reservation(
            _roomTypeAddr,
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
        _room.addReservation(_reservation, _checkIn, _checkOut);
        emit Reserve(_guest, _reservation, _roomTypeAddr, _checkIn, _checkOut);
    }

    function closeReservation(address _reservationAddr)
        external
        senderIsAdmin
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function cancelReservation(address _reservationAddr)
        external
        senderIsAdmin
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.cancelReservation();
    }

    function canAccess(address _reservationAddr, address _potentialGuest)
        external
        view
        returns (bool)
    {
        Reservation _reservation = Reservation(_reservationAddr);
        return _reservation.canCheckIn(_potentialGuest);
    }

    function getReservationByCheckInDay(uint256 _day)
        external
        view
        returns (address[] memory)
    {
        return reservationsByCheckIn[_day];
    }

    function getReservationByGuestAddr(address _guest)
        external
        view
        returns (address[] memory)
    {
        return reservationsByGuest[_guest];
    }

    function getRoomInfo(address _roomTypeAddr)
        external
        view
        returns
    (
        uint256 _sleeps,
        uint256 _beds,
        uint256 _price,
        uint256 _inventory)
    {
        RoomType _room = RoomType(_roomTypeAddr);
        _sleeps = _room.sleeps();
        _beds = _room.beds();
        _price = _room.price();
        _inventory = _room.inventory();
    }

    /* owner only */

    function addRoomType(
        uint256 _price,
        uint256 _sleeps,
        uint256 _beds,
        uint256 _inventory
    )
        external
        senderIsOwner
    {
        address _hotel = address(this);
        address _roomTypeAddr = new RoomType(_hotel, _price, _sleeps, _beds, _inventory);
        _recordRoomType(_roomTypeAddr);
    }

    function changeWallet(address _newWallet) external senderIsOwner {
        hotelWallet = _newWallet;
        emit NewHotelWallet(_newWallet);
    }

    function addAdmin(address _admin)
        external
        senderIsOwner
    {
        require(!isAdmin[_admin] && _admin != address(0));
        isAdmin[_admin] = true;
    }

    function addOwner(address _owner)
        external
        senderIsOwner
    {
        require(!isOwner[_owner] && _owner != address(0));
        isOwner[_owner] = true;
    }

    function removeAdmin(address _admin)
        external
        senderIsOwner
    {
        isAdmin[_admin] = false;
    }

    function removeOwner(address _owner)
        external
        senderIsOwner
    {
        isOwner[_owner] = false;
    }

    /* admin only */

    function changeReservationPrice(address _reservationAddr, uint256 _newPrice)
        external
        senderIsAdmin
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.changePrice(_newPrice);
        emit ChangeReservationPrice(_reservationAddr, _newPrice);
    }

    function changeCancelPrice(address _reservationAddr, uint256 _newPrice)
        external
        senderIsAdmin
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.changeCancelPrice(_newPrice);
    }

    function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice)
        external
        senderIsAdmin
    {
        RoomType _roomType = RoomType(_roomTypeAddr);
        _roomType.changePrice(_newPrice);
        emit ChangeRoomPrice(_roomTypeAddr, _newPrice);
    }

    /**************************************************
     *  Public
     */

    function getBookLocalServer() public view returns (address) {
        BookLocal _bl = BookLocal(bookLocal);
        return _bl.bookLocalServer();
    }

    function getRoomTypeAddress(uint256 _type) public view returns (address) {
        return roomTypes[_type];
    }

    function getAvailability(address _roomTypeAddr, uint256 _day)
        public
        view
        returns (uint256)
    {
        RoomType _room = RoomType(_roomTypeAddr);
        return _room.getAvailability(_day);
    }
 
    function hasAvailability(
        address _roomTypeAddr,
        uint256 _checkIn,
        uint256 _checkOut
    )
        public
        view
        returns (bool)
    {
        RoomType _room = RoomType(_roomTypeAddr);

        for (uint i=_checkIn; i<_checkOut; i++) {
            uint256 _available = _room.getAvailability(i);

            if (_available <= 0) {
                return false;
            }
        }
        return true;
    }

    function getTotalRooms() public view returns (uint256) {
        uint256 _totalRoomTypes = roomTypes.length;
        uint256 _totalRooms;
        address _roomTypeAddr;
        RoomType _room;

        for (uint256 i=0; i<_totalRoomTypes; i++) {
            _roomTypeAddr = roomTypes[i];
            _room = RoomType(_roomTypeAddr);

            _totalRooms += _room.inventory();
        }
        return _totalRooms;
    }

    function getCurrentAdjustedTime(address _roomTypeAddr)
        public
        view
        returns (uint256)
    {
        RoomType _room = RoomType(_roomTypeAddr);
        return _room.getCurrentAdjustedTime();
    }

    function getReservationPrice(
        address _roomTypeAddr,
        uint256 _checkIn,
        uint256 _checkOut
    )
        public
        view
        returns (uint256 _price)
    {
        RoomType _room = RoomType(_roomTypeAddr);
        _price = _calculateReservationPrice(_room, _checkIn, _checkOut);
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

    function _recordRoomType(address _roomTypeAddr) internal {
        address _hotel = address(this);
        roomTypes.push(_roomTypeAddr);
        emit NewRoomType(_hotel, _roomTypeAddr);
    }

    function _isNotPast(uint256 _reservationTime, RoomType _room)
        internal
        view
        returns (bool)
    {
        uint256 _adjustedCurrentTime = _room.getCurrentAdjustedTime();
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
        uint256 _pricePerNight = _room.price();
        return _pricePerNight.mul(_lengthOfStay);
    }
}

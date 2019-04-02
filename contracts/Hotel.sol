pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './Reservation.sol';
import './RoomType.sol';

contract Hotel {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
     
    event Reserve(address indexed sender, address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
    event Cancel(address indexed sender, address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);
    event ChangeRoomPrice(address indexed roomType, uint256 newPrice);
    event ChangeReservationPrice(address indexed reservation, uint256 newPrice);
    event NewHotelWallet(address wallet, address sender);
    event NewRoomType(address indexed hotel, address indexed roomType);

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

    /* owner only */

    function addRoomType(
        uint256 _price,
        uint256 _sleeps,
        uint256 _beds,
        uint256 _inventory
    )
        senderIsOwner
        external
    {
        address _hotel = address(this);
        address _roomTypeAddr = new RoomType(_hotel, _price, _sleeps, _beds, _inventory);
        _recordRoomType(_roomTypeAddr);
    }

    function changeWallet(address _newWallet) senderIsOwner external {
        hotelWallet = _newWallet;
        emit NewHotelWallet(_newWallet, msg.sender);
    }

    function addAdmin(address _admin)
        senderIsOwner
        external
    {
        require(!isAdmin[_admin] && _admin != address(0));
        isAdmin[_admin] = true;
        hotelAdmins.push(_admin);
    }

    function addOwner(address _owner)
        senderIsOwner
        external
    {
        require(!isOwner[_owner] && _owner != address(0));
        isOwner[_owner] = true;
        hotelOwners.push(_owner);
    }

    function removeAdmin(address _admin)
        senderIsOwner
        external
    {
        isAdmin[_admin] = false;
        _removeAdmin(_admin);
    }

    function removeOwner(address _owner)
        senderIsOwner
        external
    {
        isOwner[_owner] = false;
        _removeOwner(_owner);
    }

    /* admin only */

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

    function getAdmins()
        external
        view
        returns (address[] memory)
    {
        return hotelAdmins;
    }

    function getOwners()
        external
        view
        returns (address[] memory)
    {
        return hotelOwners;
    }

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

        // make sure renter sends enough money
        // this function also checks that checkout is after checkin
        uint256 _price = _calculateReservationPrice(_room, _checkIn, _checkOut);
        require(msg.value >= _price);

        // make sure there is availability
        // and that check in is in the future
        require(hasAvailability(_roomTypeAddr, _checkIn, _checkOut));
        require(_isNotPast(_checkIn, _room));

        address _bookLocal = bookLocal;
        address _hotel = address(this);
        address _guest = msg.sender;
        uint256 _minRentTime = _room.getMinRentTime();

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

    function canAccess(address _reservationAddr, address _potentialGuest)
        external
        view
        returns (bool)
    {
        Reservation _reservation = Reservation(_reservationAddr);
        return _reservation.canCheckIn(_potentialGuest);
    }

    function closeReservation(address _reservationAddr)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function cancelReservation(address _reservationAddr)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.cancelReservation();
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
        _sleeps = _room.getNumSleeps();
        _beds = _room.getNumBeds();
        _price = _room.getPrice();
        _inventory = _room.getRoomTypeInventory();
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

    function getCurrentAdjustedTime(address _roomTypeAddr)
        public
        view
        returns (uint256)
    {
        RoomType _room = RoomType(_roomTypeAddr);
        uint256 _minRentTime = _room.getMinRentTime();
        return now.div(_minRentTime);
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

    function _removeOwner(address _address) internal {

        uint256 _index;
        uint256 _numOwners = hotelOwners.length;

        for (uint i=0; i<_numOwners; i++) {
            if (_address == hotelOwners[i]) {
                _index = i;
            }
        }
        _removeIndex(_index, hotelOwners);
    }

    function _removeAdmin(address _address) internal {

        uint256 _index;
        uint256 _numAdmins = hotelAdmins.length;

        for (uint i=0; i<_numAdmins; i++) {
            if (_address == hotelAdmins[i]) {
                _index = i;
            }
        }
        _removeIndex(_index, hotelAdmins);
    }

    function _removeIndex(uint256 _index, address[] storage _addrList) internal {
        require(_index <= _addrList.length-1);

        for (uint i = _index; i<_addrList.length-1; i++){
            _addrList[i] = _addrList[i+1];
        }
        delete _addrList[_addrList.length-1];
        _addrList.length--;
    }
}

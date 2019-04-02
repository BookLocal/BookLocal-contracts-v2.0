pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './BookLocal.sol';
import './Hotel.sol';
import './RoomType.sol';

contract Reservation {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
    event Deposit(address indexed sender, uint256 value);
    event CheckOut(uint256 hotelShare);
    event Cancel(uint256 hotelShare);

    /**************************************************
     *  Storage
     */
    address bookLocal;
    address hotel;
    address guest;

    uint256 checkInDate;
    uint256 checkOutDate;

    address roomTypeAddr;
    uint256 minRentTime;
    uint256 reservationPrice;
    uint256 cancelPrice;
    uint256 bookLocalPctShare;

    bool hotelHappy;
    bool guestHappy;

    /**************************************************
     *  Fallback
     */
    function() public payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**************************************************
     *  Constructor
     */
    constructor(
        address _roomTypeAddr,
        address _bookLocal,
        address _hotel,
        address _guest,
        uint256 _checkIn,
        uint256 _checkOut,
        uint256 _reservationPrice,
        uint256 _minRentTime
    )
        public
    {
        roomTypeAddr = _roomTypeAddr;
        bookLocal = _bookLocal;
        hotel = _hotel;
        guest = _guest;
        checkInDate = _checkIn;
        checkOutDate = _checkOut;
        reservationPrice = _reservationPrice;
        minRentTime = _minRentTime;
        bookLocalPctShare = 25;
        _setDefaultCancelPrice();
    }

    /**************************************************
     *  Modifiers
     */
    modifier onlyHotel() {
        require(msg.sender == hotel);
        _;
    }

    modifier isInContract() {
        require(msg.sender==hotel || msg.sender==guest || msg.sender==bookLocal);
        _;
    }

    modifier afterCheckIn() {
        uint256 _currentDay = now/minRentTime;
        require(_currentDay >= checkInDate);
        _;
    }

    modifier beforeCheckIn() {
        uint256 _currentDay = now/minRentTime;
        require(_currentDay < checkInDate);
        _;
    }

    /**************************************************
     *  External
     */
    function checkOut() isInContract afterCheckIn external {

        uint256 _bookLocalShare = reservationPrice.div(bookLocalPctShare);
        uint256 _hotelShare = reservationPrice.sub(_bookLocalShare);
        uint256 _extra = address(this).balance.sub(reservationPrice);

        require(_bookLocalShare.add(_hotelShare).add(_extra) == address(this).balance);

        address bookLocalWallet = getBookLocalWallet();
        address hotelWallet = getHotelWallet();

        // make transfers
        hotelWallet.transfer(_hotelShare);
        bookLocalWallet.transfer(_bookLocalShare);
        if (_extra > 0) {
            guest.transfer(_extra);
        }

        emit CheckOut(_hotelShare);

        // delete contract
        selfdestruct(hotel);
    }

    function cancel() isInContract beforeCheckIn external {

        // for a cancelled room, charge less
        uint256 _cancelPrice = getCancelPrice();

        uint256 _bookLocalShare = _cancelPrice.div(bookLocalPctShare);
        uint256 _hotelShare = _cancelPrice.sub(_bookLocalShare);
        uint256 _extra = address(this).balance.sub(_cancelPrice);
        require(_bookLocalShare.add(_hotelShare).add(_extra) == address(this).balance);

        // add room back to inventory
        RoomType _room = RoomType(roomTypeAddr);
        _room.cancelReservation(checkInDate, checkOutDate);

        address bookLocalWallet = getBookLocalWallet();
        address hotelWallet = getHotelWallet();

        // make transfers
        hotelWallet.transfer(_hotelShare);
        bookLocalWallet.transfer(_bookLocalShare);
        if (_extra > 0) {
            guest.transfer(_extra);
        }

        emit Cancel(_hotelShare);

        // delete contract
        selfdestruct(hotel);
    }

    function canCheckIn(address _guest)
        external
        view
        returns (bool)
    {
        uint256 _adjustedCurrentTime = now.div(minRentTime);
        return (_guest == guest && _adjustedCurrentTime >= checkInDate);
    }

    function changePrice(uint256 _newPrice) onlyHotel external {
        reservationPrice = _newPrice;
    }

    function changeCancelPrice(uint256 _newPrice) onlyHotel external {
        cancelPrice = _newPrice;
    }

    /**************************************************
     *  Public
     */
    function getBookLocalWallet() public view returns (address) {
        BookLocal _bookLocal = BookLocal(bookLocal);
        return _bookLocal.getWallet();
    }

    function getHotelWallet() public view returns (address) {
        Hotel _hotel = Hotel(hotel);
        return _hotel.getWallet();
    }

    function getRoomType() public view returns (address) {
        return roomTypeAddr;
    }

    function getCheckIn() public view returns (uint256) {
        return checkInDate;
    }

    function getCheckOut() public view returns (uint256) {
        return checkOutDate;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPrice() public view returns (uint256) {
        return reservationPrice;
    }

    function getCancelPrice() public view returns (uint256) {
        return cancelPrice;
    }

    /**************************************************
     *  Internal
     */
    function _setDefaultCancelPrice() internal {
        cancelPrice = reservationPrice.div(2);
    }
}

pragma solidity ^0.4.20;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './BookLocal.sol';
import './Hotel.sol';

contract Reservation {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
    event Deposit(address indexed sender, uint256 value, address indexed reservation);
    event CheckOut(address indexed guest, address indexed hotel);
    event Cancel(address indexed guest, address indexed hotel);

    /**************************************************
     *  Storage
     */
    address bookLocal;
    address hotel;
    address guest;

    uint256 checkInDate;
    uint256 checkOutDate;

    uint256 minRentTime;
    uint256 reservationPrice;
    uint256 bookLocalPctShare;

    bool hotelHappy;
    bool guestHappy;

    /**************************************************
     *  Fallback
     */
    function() public payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value, address(this));
        }
    }

    /**************************************************
     *  Constructor
     */
    constructor(
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
        bookLocal = _bookLocal;
        hotel = _hotel;
        guest = _guest;
        checkInDate = _checkIn;
        checkOutDate = _checkOut;
        reservationPrice = _reservationPrice;
        minRentTime = _minRentTime;
        bookLocalPctShare = 25;
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

        uint256 bookLocalShare = reservationPrice.div(bookLocalPctShare);
        uint256 hotelShare = reservationPrice.sub(bookLocalShare);
        uint256 extra = address(this).balance.sub(reservationPrice);

        require(bookLocalShare.add(hotelShare).add(extra) == address(this).balance);

        address bookLocalWallet = getBookLocalWallet();
        address hotelWallet = getHotelWallet();

        // make transfers
        hotelWallet.transfer(hotelShare);
        bookLocalWallet.transfer(bookLocalShare);
        if (extra > 0) {
            guest.transfer(extra);
        }

        emit CheckOut(guest, hotel);

        // delete contract
        selfdestruct(hotel);
    }

    function cancel() isInContract beforeCheckIn external {

        // for a cancelled room, charge less
        uint256 cancelPrice = _calculateCancelPrice();

        uint256 bookLocalShare = cancelPrice.div(bookLocalPctShare);
        uint256 hotelShare = cancelPrice.sub(bookLocalShare);
        uint256 extra = address(this).balance.sub(cancelPrice);

        require(bookLocalShare.add(hotelShare).add(extra) == address(this).balance);

        address bookLocalWallet = getBookLocalWallet();
        address hotelWallet = getHotelWallet();

        // make transfers
        hotelWallet.transfer(hotelShare);
        bookLocalWallet.transfer(bookLocalShare);
        if (extra > 0) {
            guest.transfer(extra);
        }

        emit Cancel(guest, hotel);

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

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPrice() public view returns (uint256) {
        return reservationPrice;
    }

    /**************************************************
     *  Internal
     */
    function _calculateCancelPrice() internal view returns (uint256) {
        return reservationPrice.div(2);
    }
}

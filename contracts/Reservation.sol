pragma solidity ^0.4.20;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './BookLocal.sol';
import './Hotel.sol';

contract Reservation {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
    event Deposit(address indexed sender, uint256 value);
    event CheckOut(address indexed guest);

    /**************************************************
     *  Storage
     */
    address bookLocal;
    address hotel;
    address guest;

    uint256 checkInDate;
    uint256 checkOutDate;

    uint256 roomPrice;
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
        address _bookLocal,
        address _hotel,
        address _guest,
        uint256 _checkIn,
        uint256 _checkOut,
        uint256 _roomPrice
    )
        public
    {
        bookLocal = _bookLocal;
        hotel = _hotel;
        guest = _guest;
        checkInDate = _checkIn;
        checkOutDate = _checkOut;
        roomPrice = _roomPrice;
        bookLocalPctShare = 25;
    }

    /**************************************************
     *  Modifiers
     */
    modifier onlyHotel() {
        require(msg.sender == hotel);
        _;
    }

    modifier inContract() {
        require(msg.sender==hotel || msg.sender==guest || msg.sender==bookLocal);
        _;
    }

    /**************************************************
     *  External
     */
    function checkOut() inContract external {

        uint256 bookLocalShare = roomPrice.div(bookLocalPctShare);
        uint256 hotelShare = roomPrice.sub(bookLocalShare);
        uint256 extra = address(this).balance.sub(roomPrice);

        require(bookLocalShare.add(hotelShare).add(extra) == address(this).balance);

        address bookLocalWallet = getBookLocalWallet();
        address hotelWallet = getHotelWallet();

        // make transfers
        hotelWallet.transfer(hotelShare);
        bookLocalWallet.transfer(bookLocalShare);
        if (extra > 0) {
            guest.transfer(extra);
        }

        emit CheckOut(guest);

        // delete contract
        selfdestruct(bookLocalWallet);
    }

    function changePrice(uint256 _newPrice) onlyHotel external {
        roomPrice = _newPrice;
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
        return roomPrice;
    }
}

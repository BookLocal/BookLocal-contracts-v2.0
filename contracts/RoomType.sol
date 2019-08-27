pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract RoomType {

    using SafeMath for uint256;

    /**************************************************
     *  Storage
     */

    // hotel ownership information
    address public hotel;

    // room information
    uint256 public price;
    uint256 public sleeps;
    uint256 public beds;

    // initial time values
    bool public timeIsPlusUtc = false;
    uint256 public timeShift = 0;            // accounts for time zones
    uint256 public minRentTime = 3600*24;    // minimum time in seconds

    // availability information
    uint256 public inventory;
    mapping (uint256 => uint256) checkIns;   // date => numCheckIns
    mapping (uint256 => uint256) checkOuts;  // date => numCheckOuts
    mapping (uint256 => uint256) occupied;   // date => numOccupied

    // track active reservations
    mapping (address => bool) isReservation;

    /**************************************************
     *  Constructor
     */

    constructor(
        address _hotel,
        uint256 _price,
        uint256 _sleeps,
        uint256 _beds,
        uint256 _inventory
    )
        public
    {
        hotel = _hotel;
        price = _price;
        sleeps = _sleeps;
        beds = _beds;
        inventory = _inventory;
    }

    /**************************************************
     *  Modifiers
     */

    modifier onlyHotel() {
        require(msg.sender == hotel);
        _;
    }

    modifier onlyReservation() {
        require(isReservation[msg.sender]);
        _;
    }

    /**************************************************
     *  External
     *
     *  (protected for hotel use only)
     */

    function changePrice(uint256 _newPrice)
        external
        onlyHotel
    {
        price = _newPrice;
    }

    function addReservation(
        address _reservation,
        uint256 _checkIn,
        uint256 _checkOut
    )
        external
        onlyHotel
    {
        isReservation[_reservation] = true;
        checkIns[_checkIn] ++;
        checkOuts[_checkOut] ++;

        for (uint i=_checkIn; i<_checkOut; i++) {
            occupied[i] ++;
        }
    }

    function setTimeZone(uint256 _shift, bool _timeIsPlusUtc)
        external
        onlyHotel
    {
        timeShift = _shift;
        timeIsPlusUtc = _timeIsPlusUtc;
    }

    function cancelReservation(
        uint256 _checkIn,
        uint256 _checkOut
    )
        external
        onlyReservation
    {
        checkIns[_checkIn] --;
        checkOuts[_checkOut] --;

        for (uint i = _checkIn; i<_checkOut; i++) {
            occupied[i] --;
        }
    }

    /**************************************************
     *  Public
     */

    function getDailyInfo(uint256 _day)
        public
        view
        returns (uint256 _checkIns, uint256 _checkOuts, uint256 _occupied)
    {
        _checkIns = checkIns[_day];
        _checkOuts = checkOuts[_day];
        _occupied = occupied[_day];
    }

    function getAvailability(uint256 _day)
        public
        view
        returns (uint256)
    {
        uint256 _occupied = occupied[_day];
        uint256 _available = inventory.sub(_occupied);

        return _available;
    }

    function getCurrentAdjustedTime() public view returns (uint256) {
        uint256 _roomTime;
        if (timeIsPlusUtc) {
            _roomTime = now.add(timeShift).div(minRentTime);
        } else {
            _roomTime = now.sub(timeShift).div(minRentTime);
        }
        return _roomTime;
    }
}

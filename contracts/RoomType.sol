pragma solidity ^0.4.20;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract RoomType {

    using SafeMath for uint256;

    /**************************************************
     *  Storage
     */

    // hotel ownership information
    address hotel;

    // room information
    string description;

    uint256 price;
    uint256 sleeps;
    uint256 beds;
    uint256 minRentTime = 3600*24;           // minimum time in seconds

    // availability information
    uint256 inventory;
    mapping (uint256 => uint256) checkIns;   // date => numCheckIns
    mapping (uint256 => uint256) checkOuts;  // date => numCheckOuts
    mapping (uint256 => uint256) occupied;   // date => numOccupied

    /**************************************************
     *  Constructor
     */
    constructor(
        address _hotel,
        uint256 _price,
        uint256 _sleeps,
        uint256 _inventory
    )
        public
    {
        hotel = _hotel;
        price = _price;
        sleeps = _sleeps;
        inventory = _inventory;
    }

    /**************************************************
     *  Modifiers
     */
    modifier onlyHotel() {
        require(msg.sender == hotel);
        _;
    }

    /**************************************************
     *  External
     *
     *  (all protected for hotel use only)
     */
    function changePrice(uint256 _newPrice)
        onlyHotel
        external
    {
        price = _newPrice;
    }

    function addReservation(
        uint256 _checkIn,
        uint256 _checkOut
    )
        onlyHotel
        external
    {
        checkIns[_checkIn] ++;
        checkOuts[_checkOut] ++;

        for (uint i=_checkIn; i<_checkOut; i++) {
            occupied[i] ++;
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

    function getRoomTypeInventory() public view returns (uint256) {
        return inventory;
    }

    function getMinRentTime() public view returns (uint256) {
        return minRentTime;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }
}

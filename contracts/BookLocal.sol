pragma solidity ^0.4.23;

/*
 *  Author... Steven Lee
 *  Email.... steven@booklocal.in
 *  Date..... 5.30.18
 */

import './Hotel.sol';

contract BookLocal {

    /**************************************************
     *  Events
     */
    event NewHotelCreated(address hotelAddress);

    /**************************************************
     *  Storage
     */

    // Ownership
    address bookLocalWallet;

    address[] bookLocalOwners;
    mapping (address => bool) isOwner;

    // Hotel inventory
    uint256 totalHotels;
    mapping (uint256 => address) hotelRegistry;

    /**************************************************
     *  Constructor
     */
    constructor(address[] _owners, address _wallet) public {

        uint256 numOwners = _owners.length;

        for(uint i=0; i<numOwners; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }

        bookLocalWallet = _wallet;
        bookLocalOwners = _owners;
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

    /**************************************************
     *  External
     */
    function newHotel(address[] _owners, address _wallet)
        external
        returns (address hotel)
    {
        hotel = new Hotel(_owners, _wallet, address(this));
        _registerHotel(hotel);
    }

    function settle(address _reservationAddr)
        senderIsOwner
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function addOwners(address[] _owners)
        senderIsOwner
        external
    {
        address _owner;
        uint numOwners = _owners.length;
        for(uint i=0; i<numOwners; i++) {
            _owner = _owners[i];
            require(!isOwner[_owner] && _owner != address(0));
            isOwner[_owner] = true;
            bookLocalOwners.push(_owner);
        }
    }

    function removeOwners(address[] _owners)
        senderIsOwner
        external
    {
        uint256 numToRemove = _owners.length;
        for(uint256 i=0; i<numToRemove; i++) {
            isOwner[_owners[i]] = false;
        }
    }

    function getOwners()
        external
        senderIsOwner
        view
        returns (address[])
    {
        uint256 numOfOwners = bookLocalOwners.length;
        address[] memory validOwners = new address[](numOfOwners);
        for(uint256 i=0; i<numOfOwners; i++) {
            if (isOwner[bookLocalOwners[i]]) {
                validOwners[i] = bookLocalOwners[i];
            }
        }
        return validOwners;
    }

    /**************************************************
     *  Public
     */
    function getHotelCount() public view returns (uint256) {
        return totalHotels;
    }

    function getHotelAddress(uint256 _hotelId) public view returns (address) {
        return hotelRegistry[_hotelId];
    }

    function getWallet() public view returns (address) {
        return bookLocalWallet;
    }

    /**************************************************
     *  Internal
     */
    function _incrementHotelCount() internal returns (uint256) {
        totalHotels++;
        return totalHotels;
    }

    function _registerHotel(address _hotel) internal {
        uint256 hotelId = _incrementHotelCount();
        hotelRegistry[hotelId] = _hotel;
        emit NewHotelCreated(_hotel);
    }
}

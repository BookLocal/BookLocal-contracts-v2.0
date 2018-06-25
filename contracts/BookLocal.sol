pragma solidity ^0.4.20;

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

    address[] bookLocalAdmins;
    mapping (address => bool) isAdmin;

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

     modifier senderIsAdmin() {
         require(isOwner[msg.sender] || isAdmin[msg.sender]);
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
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function addAdmins(address[] _admins)
        senderIsOwner
        external
    {
        address _admin;
        uint numAdmins = _admins.length;
        for(uint i=0; i<numAdmins; i++) {
            _admin = _admins[i];
            require(!isAdmin[_admin] && _admin != address(0));
            isAdmin[_admin] = true;
            bookLocalAdmins.push(_admin);
        }
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

    function removeAdmins(address[] _admins)
        senderIsOwner
        external
    {
        uint256 numToRemove = _admins.length;
        for(uint256 i=0; i<numToRemove; i++) {
            isAdmin[_admins[i]] = false;
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

    function getAdmins()
        external
        senderIsAdmin
        view
        returns (address[])
    {
        uint256 numOfAdmins = bookLocalAdmins.length;
        address[] memory validAdmins = new address[](numOfAdmins);
        for(uint256 i=0; i<numOfAdmins; i++) {
            if (isAdmin[bookLocalAdmins[i]]) {
                validAdmins[i] = bookLocalAdmins[i];
            }
        }
        return validAdmins;
    }

    function getOwners()
        external
        senderIsAdmin
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

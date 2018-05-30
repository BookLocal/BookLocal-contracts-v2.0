pragma solidity ^0.4.20;

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
    function settle(address _reservationAddr)
        senderIsAdmin
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function newHotel(address[] _owners, address _wallet)
        external
        returns (address hotel)
    {
        hotel = new Hotel(_owners, _wallet, address(this));
        _registerHotel(hotel);
    }

    function addAdmins(address[] _admins)
        senderIsOwner
        external
    {
        address _admin;
        uint numOwners = _admins.length;
        for(uint i=0; i<numOwners; i++) {
            _admin = _admins[i];
            require(!isAdmin[_admin] && _admin != address(0));
            isAdmin[_admin] = true;
        }
        bookLocalAdmins.push(_admin);
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

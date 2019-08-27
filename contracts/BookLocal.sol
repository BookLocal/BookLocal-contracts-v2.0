pragma solidity ^0.4.23;

import './Hotel.sol';

contract BookLocal {

    /**************************************************
     *  Events
     */
    event NewHotelCreated(address hotelAddress);
    event NewBookLocalWallet(address wallet);

    /**************************************************
     *  Storage
     */

    // Ownership
    address public bookLocalWallet;
    address public bookLocalServer;

    mapping (address => bool) public isOwner;

    // Hotel inventory
    address[] public hotelRegistry;

    /**************************************************
     *  Constructor
     */

    constructor(address[] memory _owners, address _wallet) public {

        uint256 numOwners = _owners.length;

        for(uint i=0; i<numOwners; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }

        bookLocalWallet = _wallet;
    }

    /**************************************************
     *  Fallback
     */
    function() external payable {
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

    function changeWallet(address _newWallet) external senderIsOwner {
        bookLocalWallet = _newWallet;
        emit NewBookLocalWallet(_newWallet);
    }

    function closeReservation(address _reservationAddr)
        external
        senderIsOwner
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function addOwner(address _owner)
        external
        senderIsOwner
    {
        require(!isOwner[_owner] && _owner != address(0));
        isOwner[_owner] = true;
    }

    function removeOwner(address _owner)
        external
        senderIsOwner
    {
        isOwner[_owner] = false;
    }

    function addServer(address _server)
        external
        senderIsOwner
    {
        bookLocalServer = _server;
    }

    /**************************************************
     *  Internal
     */
    
    function _registerHotel(address _hotel) internal {
        hotelRegistry.push(_hotel);
        emit NewHotelCreated(_hotel);
    }
}

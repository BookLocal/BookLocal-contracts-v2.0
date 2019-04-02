pragma solidity ^0.4.23;

import './Hotel.sol';

contract BookLocal {

    /**************************************************
     *  Events
     */
    event NewHotelCreated(address hotelAddress);
    event NewBookLocalWallet(address wallet, address sender);

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
    constructor(address[] memory _owners, address _wallet) public {

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

    function changeWallet(address _newWallet) senderIsOwner external {
        bookLocalWallet = _newWallet;
        emit NewBookLocalWallet(_newWallet, msg.sender);
    }

    function settle(address _reservationAddr)
        senderIsOwner
        external
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.checkOut();
    }

    function addOwner(address _owner)
        senderIsOwner
        external
{
        require(!isOwner[_owner] && _owner != address(0));
        isOwner[_owner] = true;
        bookLocalOwners.push(_owner);
    }

    function removeOwner(address _owner)
        senderIsOwner
        external
{
        isOwner[_owner] = false;
        _removeOwner(_owner);
    }

    function getOwners()
        external
        view
        returns (address[] memory)
    {
        return bookLocalOwners;
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

    function _removeOwner(address _address) internal {

        uint256 _index;
        uint256 _numOwners = bookLocalOwners.length;

        for (uint i=0; i<_numOwners; i++) {
            if (_address == bookLocalOwners[i]) {
                _index = i;
            }
        }
        _removeIndex(_index, bookLocalOwners);

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

pragma solidity ^0.4.20;

contract BookLocalInterface {

    event NewHotelCreated(address location);

    // access is restricted to hotel admins
    function settle(address _reservationAddr) external;
    function addAdmins(address[] _admins) external;

    // access is open to all

    // add new Hotel to the BookLocal contract
    function newHotel(address[] _owners, address _wallet) external;
    // _owners is an array of addresses of the hotel owners. _wallet is the address of a multisig
    // wallet. This needs to already be created. For development it can be a testing address.


    function getHotelCount() external view returns (uint256);
    function getHotelAddress(uint256 _hotelId) public returns (address);
    function getWallet() public view returns (address);
}

pragma solidity ^0.4.20;

contract BookLocalInterface {

    event NewHotelCreated(address location);

    // access is restricted to hotel admins
    function settle(address _reservationAddr) external;
    function addAdmins(address[] _admins) external;

    // access is open to all
    function newHotel(address[] _owners, uint256 _required) external;
    function getHotelCount() external view returns (uint256);
    function getHotelAddress(uint256 _hotelId) public returns (address);
    function getWallet() public view returns (address);
}

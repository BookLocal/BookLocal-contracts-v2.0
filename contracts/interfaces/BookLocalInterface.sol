pragma solidity ^0.4.20;

contract BookLocalInterface {

    event NewHotelCreated(address location);

    function newHotel(address[] _owners, uint256 _required) external;
    function getHotelCount() external view returns (uint256);
    function getHotelAddress(uint256 _hotelId) public returns (address);
    function getWallet() public view returns (address);
}

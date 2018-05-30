pragma solidity ^0.4.20;

contract HotelInterface {

    event Reserve(uint256 roomType, uint256 checkIn, uint256 checkOut);
    event Cancel(uint256 roomType, uint256 checkIn, uint256 checkOut);

    // inventory
    function addRoomType(uint256 _price, uint256 _sleeps, uint256 _inventory) external;

    // renting
    function reserve(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) payable external returns (address _reservation);
    function settle(uint256 _roomId) external;
    function cancelReservation(uint256 _roomId, uint256 _checkIn, uint256 _checkOut) external;

    // info
    function getWallet() public view returns (address);
    function getNumOfRoomTypes() public view returns (uint256);
    function getRoomTypeAddress(uint256 _roomType) public view returns (uint256 _beds, uint256 _price);
    function getRoomCount() public view returns (uint256);
}

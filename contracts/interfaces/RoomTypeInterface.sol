pragma solidity ^0.4.20;

contract RoomTypeInterface {

    // access restricted to hotel contract calls
    function changePrice(uint256 _newPrice) external;
    function addReservation(uint256 _checkIn, uint256 _checkOut) external;

    // access open to all
    function getDailyInfo(uint256 _day) public view returns (uint256 _checkIns, uint256 _checkOuts, uint256 _occupied);
    function getAvailability(uint256 _day) public view returns (uint256);
    function getRoomTypeInventory() public view returns (uint256);
    function getMinRentTime() public view returns (uint256);
    function getPrice() public view returns (uint256);
}

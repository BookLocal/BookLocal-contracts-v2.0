pragma solidity ^0.4.20;

contract HotelInterface {

    event Reserve(address indexed reservation, address roomTypeAddr, uint256 checkIn, uint256 checkOut);

    // access is restricted to hotel owner
    function addRoomType(uint256 _price, uint256 _sleeps, uint256 _inventory) external;

    // access is restricted to hotel admin
    function changeReservationPrice(address _reservationAddr, uint256 _newPrice) external;
    function changeRoomTypePrice(address _roomTypeAddr, uint256 _newPrice) external;
    function settle(address _reservationAddr) external;

    // Renting
    // access is open to all
    function reserve(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) external payable;

    // Info
    function getReservationByCheckInDay(uint256 _day) external view returns (address[]);
    function getReservationByGuestAddr(address _guest) external view returns (address[]);
    function getWallet() public view returns (address);
    function getNumOfRoomTypes() public view returns (uint256);
    function getRoomTypeAddress(uint256 _type) public view returns (address);
    function getAvailability(uint256 _roomType, uint256 _day) public view;
    function getTotalRooms() public view returns (uint256);
    function hasAvailability(uint256 _roomType, uint256 _checkIn, uint256 _checkOut) public view returns (bool);
    function getCurrentTimeInProperUnits(uint256 _roomType) public view returns (uint256);
}

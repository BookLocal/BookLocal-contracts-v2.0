pragma solidity ^0.4.20;

contract ReservationInterface {

    function checkOut() external;
    function dispute() external;
    function getBookLocalWallet() public view returns (address);
    function getHotelWallet() public view returns (address);
}

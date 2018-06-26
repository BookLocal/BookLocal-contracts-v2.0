pragma solidity ^0.4.20;

contract ReservationInterface {

    event Deposit(address indexed sender, uint256 value);
    event CheckOut(address indexed guest);

    // access restricted to only hotel call
    function changePrice(uint256 _newPrice) external;

    // access restricted to only hotel, bookLocal, or guest
    function checkOut() external;

    // access open to all
    function getBookLocalWallet() public view returns (address);
    function getHotelWallet() public view returns (address);
    function getBalance() public view returns (uint256);
    function getPrice() public view returns (uint256);
}

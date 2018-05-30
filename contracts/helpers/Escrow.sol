pragma solidity ^0.4.20;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Escrow {

    using SafeMath for uint256;

    /**************************************************
     *  Events
     */
    event Deposit(address indexed sender, uint256 value);

    /**************************************************
     *  Storage
     */
    address owner;
    address buyer;
    address seller;

    uint256 start;
    uint256 end;
    uint256 price;

    uint256 ownerPctShare;

    bool buyerHappy;
    bool sellerHappy;

    /**************************************************
     *  Fallback
     */
    function() public payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**************************************************
     *  Constructor
     */
    constructor(
        address _owner,
        address _seller,
        address _buyer,
        uint256 _end,
        uint256 _price
    )
        public
    {
        owner = _owner;
        seller = _seller;
        buyer = _buyer;
        start = now;
        end = _end;
        price = _price;
        ownerPctShare = 25;  // i.e. "one-twenty-fifth"
    }

    /**************************************************
     *  Modifiers
     */
    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }

    /**************************************************
     *  External
     */
    function close() external {
        uint256 escrowBalance = getBalance();

        uint256 ownerShare = price.div(ownerPctShare);
        uint256 sellerShare = price.sub(ownerShare);
        uint256 extra = escrowBalance.sub(price);

        require(price.add(extra) == escrowBalance);

        owner.transfer(ownerShare);
        seller.transfer(sellerShare);
        buyer.transfer(extra);

        selfdestruct(owner);
    }

    function changePrice(uint256 _newPrice) onlySeller external {
        price = _newPrice;
    }

    /**************************************************
     *  Public
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

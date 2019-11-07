pragma solidity ^0.5.11;

import "https://github.com/Smart0tter/TradeFinance/blob/master/SafeMath.sol"

contract Whitelist {
    
    using SafeMath for uint256;
    
    address payable public buyer = msg.sender;
    uint256 public minimumAmount;
    uint256 public minimumscore;
    uint256 x = 1000000000000000000;
    address payable public financier;
    
    constructor() public {
        msg.sender == buyer;
    }
    
    mapping(address => bool) public whitelisted;

    modifier onlyBuyer {
        require(msg.sender == buyer);
        _;
    }

    function setMinimumRequirement(uint256 _minimumAmount, uint256 _minimumscore) public onlyBuyer {
        minimumAmount = _minimumAmount.mul(x);
        minimumscore = _minimumscore;
    }

    function addWhitelist(address _financier, uint256 _score) public onlyBuyer { // check onlyBuyer
        require(_financier.balance >= minimumAmount);
        require(_score >= minimumscore);
        whitelisted[_financier] = true;
    }
    
    function removeWhitelist(address _financier) public onlyBuyer {
        whitelisted[_financier] = false;
    }
    
    function validateFinancier(address _financier) public view onlyBuyer returns(bool){
        return(whitelisted[_financier]);
    }
}

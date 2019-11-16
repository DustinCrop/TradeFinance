pragma solidity ^0.5.11;

import "https://github.com/Smart0tter/TradeFinance/blob/master/SafeMath.sol";

contract WhitelistFinal {
    
    using SafeMath for uint256;
    
    address payable public buyer = msg.sender;
    address payable public financier;
    uint256 public minimumAmount;
    uint256 public minimumscore;
    uint256 x = 1000000000000000000;
    //bool isFinancier;
    
    /*struct Financier {
        address payable financier;
        uint256 minimumAmount;
        uint256 minimumscore;
        bool isFinancier;
    }*/
    
    constructor() public {
        msg.sender == buyer;
    }
    
    mapping(address => bool) public whitelisted;
    
    //mapping(address => Financier) public whites;

    modifier onlyBuyer {
        require(msg.sender == buyer);
        _;
    }

    function setMinimumRequirement(uint256 _minimumAmount, uint256 _minimumscore) public onlyBuyer {
        minimumAmount = _minimumAmount.mul(x);
        minimumscore = _minimumscore;
    }

    function addWhitelist(address payable _financier, uint256 _score) public onlyBuyer returns(bool) {
        require(_financier.balance >= minimumAmount);
        require(_score >= minimumscore);
        whitelisted[_financier] = true;
        return true;
        //if(isFinancier(_financier)) revert();
        //whites[_financier].financier = _financier;
        //whites[_financier].isFinancier = true;
    }
    
    function removeWhitelist(address _financier) public onlyBuyer {
        whitelisted[_financier] = false;
    }
    
    function validateFinancier(address _financier) public view onlyBuyer returns(bool){
        return(whitelisted[_financier]);
    }
    
    /*function isFinancier(address _financier) public view returns (bool) {
        return whites[_financier].isFinancier;
    }
    
    function validateFinancierTest(address _financier) public returns (address) {
        require(whitelisted[_financier] = true);
        //return financier;
    }*/
}

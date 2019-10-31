pragma solidity ^0.5.11;

contract Whitelist {
    address buyer = msg.sender;
    uint256 amount;
    uint256 x = 1000000000000000000;
    
    constructor() public {
        msg.sender == buyer;
    }
    
    mapping (address => bool) public whitelisted;

    modifier onlyBuyer {
        require(msg.sender == buyer);
        _;
    }

    function setAmount(uint256 _amount) public onlyBuyer {
        amount = _amount * x;
    }

    function addWhitelist(address _financier) public {
        require(_financier.balance >= amount);
        whitelisted[_financier] = true;
    }

    function removeWhitelist(address _financier) public onlyBuyer {
        whitelisted[_financier] = false;
    }
}

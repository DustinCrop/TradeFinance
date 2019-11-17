pragma solidity ^0.5.11;

import "https://github.com/Smart0tter/TradeFinance/blob/master/SafeMath.sol";
import "https://github.com/Smart0tter/TradeFinance/blob/master/Whitelist.sol";

contract TradeFinance {
    
    Whitelist w;
    
    using SafeMath for uint256;
    
    bytes32 internal priceSeller;
    bytes32 internal quantitySeller;
    bytes32 internal priceBuyer;
    bytes32 internal quantityBuyer;
    uint256 internal orderAmountSeller;
    uint256 internal orderAmountBuyer;
    uint256 y = 1000000000000000000;
    string internal productname;
    uint256 internal weight;
    uint256 internal quantity;
    string internal shippingmode;
    string internal origin;
    string internal destination;
    uint256 internal freightrate;
    uint256 internal customsDuty;
    uint256 internal balanceSeller1;
    uint256 internal balanceSeller2;
    uint256 internal balanceSeller3;
    uint256 internal balanceCustoms1;
    uint256 internal balanceCustoms2;
    bytes32 public orderAddress;
    bytes32 public guaranteeAddress;
    bytes32 internal billAddress;
    uint256 internal ordersCount;
    uint256 internal guaranteesCount;
    address payable public seller = msg.sender;
    address payable public buyer;
    address payable public freight;
    address payable public customs;
    address payable public financier;
    uint256 internal salt;
    
    event OrderCancelled(string description);
    
    event OrderConfirmed(string description);
    
    event OrderLocked(string description);
    
    event OrderReceivedFreight(string description);
    
    event OrderReceivedCustoms(string description);
    
    event OrderReceived(string description);
    
    event GuaranteeActive(string description);
    
    event GuaranteeInactive(string description);

    enum OrderState { Negotiation, Created, Locked, Freight, Customs, Received, Cancelled }

    enum GuaranteeState { Inactive, Active }
    GuaranteeState public guaranteestate;
    
    mapping(bytes32 => Guarantee) public guarantees;
    
    mapping(bytes32 => Order) public orders;
    
    constructor() public {
        msg.sender == seller;
    } 
    
    struct Guarantee {
        bytes32 guaranteeAddress;
        bytes32 orderAddress;
        address to;
        bool isGuarantee;
    }
    
    struct Order {
        bytes32 orderAddress;
        address payable seller;
        address payable buyer;
        bytes32 priceSeller;
        bytes32 quantitySeller;
        uint256 weight;
        string productname;
        uint256 freightrate;
        uint256 orderAmountSeller;
        OrderState orderstate;
        uint256 customsDuty;
        bytes32 guarantee;
        bool isOrder;
    }
    
    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }
    
    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    modifier onlyFreight() {
        require(msg.sender == freight);
        _;
    }
    
    modifier onlyCustoms() {
        require(msg.sender == customs);
        _;
    }
    
    modifier inOrderState(OrderState _orderstate) {
        require(orders[orderAddress].orderstate == _orderstate);
        _;
    }
    
    modifier inGuaranteeState(GuaranteeState _guaranteestate) {
        require(guaranteestate == _guaranteestate);
        _;
    }
    
    function access(address payable _buyer, address payable _freight, address payable _customs, bytes32 _orderAddress, uint256 _salt) public onlySeller {
        require(orders[_orderAddress].orderstate == OrderState.Negotiation);
        buyer = _buyer;
        freight = _freight;
        customs = _customs;
        orderAddress = _orderAddress;
        salt = _salt;
    }
    
    function addOrder(bytes32 _orderAddress, address payable _seller, address payable _buyer, bytes32 _priceSeller, bytes32 _quantitySeller, uint256 _weight,
        string memory _productname, uint256 _freightrate, uint256 _orderAmountSeller, uint256 _customsDuty) public onlySeller {
        require(orders[_orderAddress].orderstate == OrderState.Negotiation, "Error: Order cannot modified anymore!");
        if(isOrder(_orderAddress)) revert();
        orders[_orderAddress].orderAddress = _orderAddress;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].orderstate = OrderState.Negotiation;
        orders[_orderAddress].seller = _seller;
        orders[_orderAddress].buyer = _buyer;
        orders[_orderAddress].priceSeller = _priceSeller;
        orders[_orderAddress].quantitySeller = _quantitySeller;
        orders[_orderAddress].weight = _weight;
        orders[_orderAddress].productname = _productname;
        orders[_orderAddress].freightrate = _freightrate;
        orders[_orderAddress].orderAmountSeller = _orderAmountSeller;
        orders[_orderAddress].customsDuty = _customsDuty;
        orders[_orderAddress].guarantee = "";
        ordersCount++;
        orderAddress = _orderAddress;
        priceSeller = keccak256(abi.encode(_priceSeller, salt));
        quantitySeller = keccak256(abi.encode(_quantitySeller, salt));
        weight = _weight;
        productname = _productname;
        freightrate = _freightrate.mul(y);
        orderAmountSeller = _orderAmountSeller.mul(y);
        customsDuty = _customsDuty.div(100);
    }
    
    function isOrder(bytes32 _orderAddress) public view returns(bool) {
        return orders[_orderAddress].isOrder;
    }
    
    function cancelOrder(bytes32 _orderAddress) public inOrderState(OrderState.Negotiation) onlySeller returns(bool) {
        require(orders[_orderAddress].orderstate == OrderState.Negotiation);
        emit OrderCancelled("Order has been cancelled by the seller");
        orders[_orderAddress].orderstate = OrderState.Cancelled;
        return true;
    }
    
    function confirmOrder(bytes32 _priceBuyer, bytes32 _quantityBuyer, uint256 _orderAmountBuyer, bytes32 _orderAddress) public inOrderState(OrderState.Negotiation) onlyBuyer returns(bool) {
        if (keccak256(abi.encode(_priceBuyer, salt)) == priceSeller && keccak256(abi.encode(_quantityBuyer, salt)) == quantitySeller && _orderAmountBuyer.mul(y) == orderAmountSeller) {
            require(orders[_orderAddress].orderstate != OrderState.Cancelled);
            emit OrderConfirmed("Order has been confirmed by the buyer");
            orders[_orderAddress].orderstate = OrderState.Created;
            return true;
        } else {
            emit OrderCancelled("Order has not been confirmed by the buyer");
            orders[_orderAddress].orderstate = OrderState.Cancelled;
            return false;
        }
    }
    
    function addGuarantee(bytes32 _guaranteeAddress, bytes32 _orderAddress, address _to) public payable {
        require(orderAddress == _orderAddress);
        require(orders[_orderAddress].orderstate == OrderState.Created);
        require(orders[_orderAddress].isOrder = true);
        //require(w.whitelisted[msg.sender] = true);
        require(msg.value >= orderAmountSeller);
            if(isGuarantee(_guaranteeAddress)) revert();
            guarantees[_guaranteeAddress].guaranteeAddress = _guaranteeAddress;
            guarantees[_guaranteeAddress].isGuarantee = true;
            guarantees[_guaranteeAddress].orderAddress = _orderAddress;
            guarantees[_guaranteeAddress].to = _to;
            guaranteesCount++;
            orders[_orderAddress].guarantee = _guaranteeAddress;
            guaranteeAddress = _guaranteeAddress;
            emit GuaranteeActive("Guarantee is Active");
            guaranteestate = GuaranteeState.Active;
            financier = msg.sender;
            emit OrderLocked("Order payment is guaranteed by bank");
            orders[_orderAddress].orderstate = OrderState.Locked;
    }
    
    function isGuarantee(bytes32 _guaranteeAddress) public view returns(bool) {
        return guarantees[_guaranteeAddress].isGuarantee;
    }
    
    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function receiveOrderFreight(bytes32 _billAddress, string memory _shippingmode, bytes32 _orderAddress, uint256 _weight, string memory _origin, string memory _destination) public inOrderState(OrderState.Locked) onlyFreight returns(bool) {
        require(orders[_orderAddress].orderstate == OrderState.Locked);
        emit OrderReceivedFreight("Order arrived at Freight Company");
        orders[_orderAddress].orderstate = OrderState.Freight;
        billAddress = _billAddress;
        shippingmode = _shippingmode;
        weight = _weight;
        origin = _origin;
        destination = _destination;
        return true;
    }
    
    function receiveOrderCustoms(bytes32 _orderAddress) public inOrderState(OrderState.Freight) onlyCustoms returns(bool) {
        require(orders[_orderAddress].orderstate == OrderState.Freight);
        emit OrderReceivedCustoms("Order arrived at Customs broker");
        orders[_orderAddress].orderstate = OrderState.Customs;
        require(orders[_orderAddress].orderstate == OrderState.Customs);
        require(address(this).balance >= orderAmountSeller); 
        address(freight).transfer(freightrate);
        require(address(this).balance >= orderAmountSeller.sub(freightrate), "Error: Contract balance too low!");
        balanceSeller1 = orderAmountSeller.sub(freightrate);
        balanceSeller2 = orderAmountSeller.mul(customsDuty);
        balanceSeller3 = balanceSeller1.sub(balanceSeller2);
        address(seller).transfer(balanceSeller3);
        emit GuaranteeInactive("Guarantee is Inactive");
        guaranteestate = GuaranteeState.Inactive;
        return true;
    }
    
    function receiveOrder(bytes32 _orderAddress) public inOrderState(OrderState.Customs) onlyBuyer returns(bool) { 
        require(orders[_orderAddress].orderstate == OrderState.Customs);
        emit OrderReceived("Order arrived at the buyer"); 
        orders[_orderAddress].orderstate = OrderState.Received;
        balanceCustoms1 = orderAmountSeller.sub(freightrate);
        balanceCustoms2 = balanceCustoms1.sub(balanceSeller3);
        require(address(this).balance >= balanceCustoms2);
        address(customs).transfer(balanceCustoms2);
        return true;
    }
    
    function reset(bytes32 _orderAddress, bytes32 _guaranteeAddress) public onlySeller {
        require(address(this).balance == 0, "Error: Contract balance is not zero!");
        require(orders[_orderAddress].orderstate == OrderState.Received || orders[_orderAddress].orderstate == OrderState.Cancelled);
        buyer = address(0);
        freight = address(0);
        customs = address(0);
        financier = address(0);
        guarantees[_guaranteeAddress].guaranteeAddress = bytes32(0);
        guarantees[_guaranteeAddress].orderAddress = bytes32(0);
        guarantees[_guaranteeAddress].to = address(0);
        guarantees[_guaranteeAddress].isGuarantee = false;
        billAddress = bytes32(0);
        salt = 0;
    }
}

pragma solidity ^0.5.11;

contract TradeFinance {
    
    using SafeMath for uint256;
    
//import "github.com/Smart0tter/TradeFinance/blob/master/Whitelist.sol" as Whitelist;
    
    bytes32 internal priceSeller;
    bytes32 internal quantitySeller;
    bytes32 internal priceBuyer;
    bytes32 internal quantityBuyer;
    bytes32 internal orderAmountSeller;
    bytes32 internal orderAmountBuyer;
    //uint256 internal orderDate;
    uint256 y = 1000000000000000000;
    string internal productname;
    //string internal date1;
    string internal shippingmode;
    uint256 internal freightrate;
    //uint256 internal taxrate;
    bytes32 public orderAddress;
    bytes32 public guaranteeAddress;
    bytes32 internal billAddress;
    uint256 internal ordersCount;
    uint256 internal guaranteesCount;
    address payable public seller = msg.sender;
    address payable public buyer;
    address payable public freight;
    address payable public customs;
    //address payable public financier;
    
    event OrderCancelled(string description);
    
    event OrderConfirmed(string description);
    
    event OrderLocked(string description);
    
    event OrderReceivedFreight(string description);
    
    event OrderReceivedCustoms(string description);
    
    event OrderReceived(string description);
    
    event GuaranteeActive(string description);
    
    event GuaranteeInactive(string description);

    enum OrderState { Negotiation, Created, Locked, Freight, Customs, Received, Cancelled }
    //OrderState public orderstate;

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
        uint256 issueDate;
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
        //string shippingmode;
        uint256 freightrate;
        //uint256 orderDate;
        bytes32 orderAmountSeller;
        OrderState orderstate;
        uint256 taxrate;
        bytes32 guarantee;
        bool isOrder;
    }
    
    struct EBillOfLading {
        bytes32 billAddress;
        address payable seller;
        address payable buyer;
        string shippingmode;
        string productname;
        uint256 quantity;
        uint256 weight;
        string destination;
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
        //require(orderstate == _orderstate);
        _;
    }
    
    modifier inGuaranteeState(GuaranteeState _guaranteestate) {
        require(guaranteestate == _guaranteestate);
        _;
    }
    
    function access(address payable _buyer, address payable _freight, address payable _customs, bytes32 _orderAddress) public onlySeller {
        require(orders[_orderAddress].orderstate == OrderState.Negotiation);
        buyer = _buyer;
        freight = _freight;
        customs = _customs;
    }
    
    function addOrder(bytes32 _orderAddress, address payable _seller, address payable _buyer, bytes32 _priceSeller, bytes32 _quantitySeller,
        string memory _productname, uint256 _freightrate, bytes32 _orderAmountSeller, uint256 _taxrate) public onlySeller {
        require(orders[_orderAddress].orderstate == OrderState.Negotiation, "Error: Order cannot modified anymore!"); //remove for multiple use!
        if(isOrder(_orderAddress)) revert();
        orders[_orderAddress].orderAddress = _orderAddress;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].orderstate = OrderState.Negotiation;
        orders[_orderAddress].seller = _seller;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].buyer = _buyer;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].priceSeller = _priceSeller;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].quantitySeller = _quantitySeller;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].productname = _productname;
        //orders[_orderAddress].isOrder = true;
        //orders[_orderAddress].shippingmode = _shippingmode;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].freightrate = _freightrate;
        //orders[_orderAddress].isOrder = true;
        //orders[_orderAddress].orderDate = _orderDate;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].orderAmountSeller = _orderAmountSeller;
        //orders[_orderAddress].isOrder = true;
        orders[_orderAddress].taxrate = _taxrate;
        //orders[_orderAddress].isOrder = true;
        //orders[_orderAddress].guarantee = "";
        ordersCount++;
        orderAddress = _orderAddress;
        priceSeller = _priceSeller;
        quantitySeller = _quantitySeller;
        freightrate = _freightrate;
        //orderDate = _orderDate;
        orderAmountSeller = _orderAmountSeller;
        //taxrate = _taxrate;
    }
    
    function isOrder(bytes32 _orderAddress) public view returns(bool) {
        return orders[_orderAddress].isOrder;
    }
    
    function cancelOrder(bytes32 _orderAddress) public inOrderState(OrderState.Negotiation) onlySeller returns(bool) {
        require(orders[_orderAddress].orderstate == OrderState.Negotiation); // check for multiple use!
        emit OrderCancelled("Order has been cancelled by the seller");
        orders[_orderAddress].orderstate = OrderState.Cancelled;
        return true;
    }
    
    function confirmOrder(bytes32 _priceBuyer, bytes32 _quantityBuyer, bytes32 _orderAmountBuyer, bytes32 _orderAddress) public inOrderState(OrderState.Negotiation) onlyBuyer returns(bool) {
        if (_priceBuyer == priceSeller && _quantityBuyer == quantitySeller && _orderAmountBuyer == orderAmountSeller) {
            require(orders[_orderAddress].orderstate != OrderState.Cancelled); // check for multiple use!
            emit OrderConfirmed("Order has been confirmed by the buyer");
            orders[_orderAddress].orderstate = OrderState.Created;
            return true;
        } else {
            emit OrderCancelled("Order has not been confirmed by the buyer"); // check for multiple use!
            orders[_orderAddress].orderstate = OrderState.Cancelled;
            return false;
        }
    }
    
    function addGuarantee(bytes32 _guaranteeAddress, bytes32 _orderAddress, uint256 _issueDate, address _to) public payable {
        require(orderAddress == _orderAddress);
        require(orders[_orderAddress].orderstate == OrderState.Created); // check for multiple use!
        require(orders[_orderAddress].isOrder);
        require(msg.value > 0);
        //if(Whitelist.whitelisted[financier]) {
            if(isGuarantee(_guaranteeAddress)) revert();
            guarantees[_guaranteeAddress].guaranteeAddress = _guaranteeAddress;
            guarantees[_guaranteeAddress].isGuarantee = true;
            guarantees[_guaranteeAddress].orderAddress = _orderAddress;
            guarantees[_guaranteeAddress].isGuarantee = true;
            guarantees[_guaranteeAddress].issueDate = _issueDate;
            guarantees[_guaranteeAddress].isGuarantee = true;
            guarantees[_guaranteeAddress].to = _to;
            guarantees[_guaranteeAddress].isGuarantee = true;
            guaranteesCount++;
            orders[_orderAddress].guarantee = _guaranteeAddress; //orderAddress must equal guarantee and vice versa
            guaranteeAddress = _guaranteeAddress;
            emit GuaranteeActive("Guarantee is Active");
            guaranteestate = GuaranteeState.Active;
            emit OrderLocked("Order payment is guaranteed by bank");
            orders[_orderAddress].orderstate = OrderState.Locked;
        //}
    }
    
    function isGuarantee(bytes32 _guaranteeAddress) public view returns(bool) {
        return guarantees[_guaranteeAddress].isGuarantee;
    }
    
    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function receiveOrderFreight(bytes32 _billAddress, string memory _shippingmode, bytes32 _orderAddress) public inOrderState(OrderState.Locked) onlyFreight returns(bool) {
        require(orders[_orderAddress].orderstate == OrderState.Locked); // check for multiple use!
        emit OrderReceivedFreight("Order arrived at Freight Company");
        orders[_orderAddress].orderstate = OrderState.Freight;
        billAddress = _billAddress;
        shippingmode = _shippingmode;
        return true;
    }
    
    function addEBillOfLading(bytes32 _billAddress, address payable _seller, address payable _buyer, string memory _shippingmode) public onlyFreight {
        billAddress = _billAddress;
        shippingmode = _shippingmode;
        seller = _seller;
        buyer = _buyer;
    }
    
    function receiveOrderCustoms(bytes32 _orderAddress) public inOrderState(OrderState.Locked) onlyCustoms returns(bool) {
        require(orders[_orderAddress].orderstate == OrderState.Locked); // check for multiple use!
        emit OrderReceivedCustoms("Order arrived at Customs broker");
        orders[_orderAddress].orderstate = OrderState.Customs;
        require(orders[_orderAddress].orderstate == OrderState.Customs); // check for multiple use!
        require(address(this).balance > 0); 
        address(freight).transfer(freightrate.mul(y));
        return true;
    }
    
    function receiveOrder(bytes32 _orderAddress) public inOrderState(OrderState.Customs) onlyBuyer returns(bool) { 
        require(orders[_orderAddress].orderstate == OrderState.Customs); // check for multiple use!
        emit OrderReceived("Order arrived at the buyer"); 
        orders[_orderAddress].orderstate = OrderState.Received; // until here receive
        uint256 balanceCustoms = address(this).balance;
        require(address(this).balance > 0);
        address(customs).transfer(orders[_orderAddress].taxrate.mul(balanceCustoms.div(100))); // payout customs
        uint256 balanceSeller = address(this).balance; // check correct amount, transaction amount instead of rest of SC 
        require(address(this).balance > 0, "Error: Contract balance too low!");
        address(seller).transfer(balanceSeller); // payout seller
        emit GuaranteeInactive("Guarantee is Inactive");
        guaranteestate = GuaranteeState.Inactive;
        return true;
    }
    
    function reset(bytes32 _orderAddress, bytes32 _guaranteeAddress) public onlySeller { // check to implement reset function instead of selfdestruct, because then can use more often!
        // require(address(this).balance == 0, "Error: Contract balance is not zero!");
        require(orders[_orderAddress].orderstate == OrderState.Received);
        buyer = address(0);
        freight = address(0);
        customs = address(0);
        guarantees[_guaranteeAddress].guaranteeAddress = bytes32(0);
        guarantees[_guaranteeAddress].orderAddress = bytes32(0);
        guarantees[_guaranteeAddress].issueDate = uint256(0);
        guarantees[_guaranteeAddress].to = address(0);
        guarantees[_guaranteeAddress].isGuarantee = false;
        billAddress = bytes32(0);
        //selfdestruct(Whitelist.financier); // returns rest of funds
    }
}

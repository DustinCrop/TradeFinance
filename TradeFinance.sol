pragma solidity ^0.5.11;

contract TradeFinance {
    uint256 public time;
    uint256 internal price;
    uint256 internal quantity;
    uint256 internal orderamount;
    string internal productname;
    string internal date1;
    string internal shippingmode;
    uint256 internal freightrate;
    uint256 internal taxrate;
    address public orderAddress;
    address public guaranteeAddress;
    address public billAddress;
    uint256 public ordersCount;
    uint256 public guaranteesCount;
    address payable public seller = msg.sender;
    address payable public buyer;
    address payable public freight;
    address payable public customs;
    address payable public financier = Whitelist.financier;
    
    event OrderCancelled(string description);
    
    event OrderConfirmed(string description);
    
    event OrderLocked(string description);
    
    event OrderReceivedFreight(string description);
    
    event OrderReceivedCustoms(string description);
    
    event OrderReceived(string description);
    
    event GuaranteeActive(string description);
    
    event GuaranteeInactive(string description);

    enum OrderState { Negotiation, Created, Locked, Freight, Customs, Received, Cancelled }
    OrderState public orderstate;

    enum GuaranteeState { Inactive, Active }
    GuaranteeState public guaranteestate;
    
    mapping(address => Guarantee) public guarantees;
    
    mapping(address => Order) public orders;
    
    constructor() public {
        msg.sender == seller;
        time = now;
    } 
    
    struct Guarantee {
        address guaranteeAddress;
        address orderAddress;
        string date2;
        string expiry;
        address to;
        bool isGuarantee;
    }
    
    struct Order {
        address orderAddress;
        address seller;
        address buyer;
        uint256 price;
        uint256 quantity;
        string productname;
        string shippingmode;
        uint256 freightrate;
        string date1;
        uint256 orderamount;
        uint256 taxrate;
        bool isOrder;
    }
    
    struct BillOfLading {
        bytes32 billAddress;
        string shippingmode;
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
        require(orderstate == _orderstate);
        _;
    }
    
    modifier inGuaranteeState(GuaranteeState _guaranteestate) {
        require(guaranteestate == _guaranteestate);
        _;
    }
    
    function access(address payable _buyer, address payable _freight, address payable _customs) public onlySeller {
        buyer = _buyer;
        freight = _freight;
        customs = _customs;
    }
    
    function addOrder(address _orderAddress, address _seller, address _buyer, uint256 _price, uint256 _quantity,
        string memory _productname, string memory _shippingmode, uint256 _freightrate, string memory _date1, uint256 _orderamount, uint256 _taxrate) public onlySeller {
        // require(orderstate == Orderstate.Negotiation, "Error: Order cannot modified anymore!"); remove for multiple use!
        if(isOrder(_orderAddress)) revert();
        orders[_orderAddress].orderAddress = _orderAddress;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].seller = _seller;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].buyer = _buyer;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].price = _price;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].quantity = _quantity;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].productname = _productname;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].shippingmode = _shippingmode;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].freightrate = _freightrate;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].date1 = _date1;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].orderamount = _orderamount;
        orders[_orderAddress].isOrder = true;
        orders[_orderAddress].taxrate = _taxrate;
        orders[_orderAddress].isOrder = true;
        ordersCount++;
        orderAddress = _orderAddress;
        price = _price;
        quantity = _quantity;
        freightrate = _freightrate;
        orderamount = _orderamount;
        taxrate = _taxrate;
    }
    
    function isOrder(address _orderAddress) public view returns(bool) {
        return orders[_orderAddress].isOrder;
    }
    
    function cancelOrder() public inOrderState(OrderState.Negotiation) onlySeller returns(bool) {
        require(orderstate != OrderState.Created); // check for multiple use!
        emit OrderCancelled("Order has been cancelled by the seller");
        orderstate = OrderState.Cancelled;
        return true;
    }
    
    function confirmOrder() public inOrderState(OrderState.Negotiation) onlyBuyer returns(bool) {
        if (time <= now + 6 hours) { // check for multiple use!
            require(orderstate != OrderState.Cancelled); // check for multiple use!
            emit OrderConfirmed("Order has been confirmed by the buyer");
            orderstate = OrderState.Created;
            return true;
        } else {
            emit OrderCancelled("Order has not been confirmed by the buyer"); // check for multiple use!
            orderstate = OrderState.Cancelled;
            return false;
        }
    }
    
    function addGuarantee(address _guaranteeAddress, address _orderAddress, string memory _date2,
        string memory _expiry, address _to) public payable {
        require(time <= now + 10 hours, "Error: time frame expired!"); // check for multiple use!
        require(orderstate == OrderState.Created); // check for multiple use!
        require(orders[_orderAddress].isOrder);
        require(msg.value > 0);
        require(Whitelist.whitelisted[financier] = true);
        if(isGuarantee(_guaranteeAddress)) revert();
        guarantees[_guaranteeAddress].guaranteeAddress = _guaranteeAddress;
        guarantees[_guaranteeAddress].isGuarantee = true;
        guarantees[_guaranteeAddress].orderAddress = _orderAddress;
        guarantees[_guaranteeAddress].isGuarantee = true;
        guarantees[_guaranteeAddress].date2 = _date2;
        guarantees[_guaranteeAddress].isGuarantee = true;
        guarantees[_guaranteeAddress].expiry = _expiry;
        guarantees[_guaranteeAddress].isGuarantee = true;
        guarantees[_guaranteeAddress].to = _to;
        guarantees[_guaranteeAddress].isGuarantee = true;
        guaranteesCount++;
        guaranteeAddress = _guaranteeAddress;
        emit GuaranteeActive("Guarantee is Active");
        guaranteestate = GuaranteeState.Active;
        emit OrderLocked("Order payment is guaranteed by bank");
        orderstate = OrderState.Locked;
    }
    
    function isGuarantee(address _guaranteeAddress) public view returns(bool) {
        return guarantees[_guaranteeAddress].isGuarantee;
    }
    
    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function receiveOrderFreight(address _billAddress, string memory _shippingmode) public inOrderState(OrderState.Locked) onlyFreight returns(bool) {
        require(orderstate == OrderState.Locked); // check for multiple use!
        emit OrderReceivedFreight("Order arrived at Freight Company");
        orderstate = OrderState.Freight;
        billAddress = _billAddress;
        shippingmode = _shippingmode;
        return true;
    }
    
    function receiveOrderCustoms() public inOrderState(OrderState.Locked) onlyCustoms returns(bool) {
        require(orderstate == OrderState.Locked); // check for multiple use!
        emit OrderReceivedCustoms("Order arrived at Customs broker");
        orderstate = OrderState.Customs;
        require(orderstate == OrderState.Customs); // check for multiple use!
        require(address(this).balance > 0); 
        address(freight).transfer(freightrate * Whitelist.x);
        return true;
    }
    
    function receiveOrder() public inOrderState(OrderState.Customs) onlyBuyer returns(bool) { 
        require(orderstate == OrderState.Customs); // check for multiple use!
        emit OrderReceived("Order arrived at the buyer"); 
        orderstate = OrderState.Received; // until here receive
        uint256 balanceCustoms = address(this).balance;
        require(address(this).balance > 0);
        address(customs).transfer(taxrate * balanceCustoms / 100); // payout customs
        uint256 balanceSeller = address(this).balance;
        require(address(this).balance > 0, "Error: Contract balance too low!");
        address(seller).transfer(balanceSeller); // payout seller
        emit GuaranteeInactive("Guarantee is Inactive");
        guaranteestate = GuaranteeState.Inactive;
        return true;
    }
    
    function sendInvoice() public onlySeller {
        
    }
    
    function end() public onlySeller { // check to implement reset function instead of selfdestruct, because then can use more often!
        // require(address(this).balance == 0, "Error: Contract balance is not zero!");
        require(orderstate == OrderState.Received);
        selfdestruct(Whitelist.financier); // returns rest of funds
    }
}

pragma solidity ^0.4.21;

/** @title Alpha version of smart contract for processing, storing, verification of Driver behavior on the road.
 *  @notice Current version oriented on one main and 4 additional characteristics of driver behavior analizing.
 *  @author Peter Zverkov 
 */

//Preconditions: Smart Contract sould have 2 x bid_limit x transactions Tokens balance

contract DriverBehaviorDemoSuperNovaLight {
    
    event PaymentReceived(address indexed fromAddress, uint256 amount);
    event PaymentProcessed(address indexed toAddress, uint256 amount);
    
    address private owner; // The one setting up the contract.
    address private beneficiary; // The address which will get the funds.
    bool private paid;
    bool private tripStarted;
    uint private bid_limit; // Minimum limit for transaction based on contract
    mapping (address => uint256) private balances;
    
    constructor() public{
        paid = false;
        owner = msg.sender;
        bid_limit = 1;
        tripStarted = false;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function deposit() public payable returns(bool success) {
        balances[msg.sender] +=msg.value;
        emit PaymentReceived(msg.sender, msg.value);
        return true;
    }
    
    function deposit(address paidAddress) public payable returns(bool success) {
        balances[paidAddress] +=msg.value;
        emit PaymentReceived(paidAddress, msg.value);
        return true;
    }
    
    function () public payable {
		require(msg.value >= bid_limit);
		balances[msg.sender] +=msg.value;
		emit PaymentReceived(msg.sender, msg.value);
		tripStarted = true;
	}
    
    function getBeneficiary() public constant returns (address) {
        return beneficiary;
    }
    
    function getMinLimit() public constant returns (uint) {
        return bid_limit;
    }
    
    function updateLimit(uint newLimit) public onlyOwner {
        bid_limit = newLimit;
    }
    
    function initDriverTrip(address driverAddress) public payable{
        setbeneficiary(driverAddress);
    }
    
    function setbeneficiary(address benef) public {
        beneficiary = benef;
    }
    
    function withdraw(uint256 _amount) public payable {
        transfer(beneficiary, _amount);
    } 
    
    function transfer(address to, uint value) internal {
        require(balances[to] >= bid_limit);
        uint256 share = balances[to];
        balances[to] = share - bid_limit;
        to.transfer(value);
        emit PaymentProcessed(to, value);
    }
    /* *** General END *** */
}

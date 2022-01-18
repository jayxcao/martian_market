pragma solidity >=0.4.22 <0.6.0;

contract MartianAuction {
    address deployer;
    address payable public beneficiary;
    address public highestBidder;
    uint public highestBid;
    bool public ended;

    mapping(address => uint) pendingReturns;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(address payable _beneficiary) public {
        deployer = msg.sender;
        beneficiary = _beneficiary;
    }

    function bid(address payable sender) public payable {
        require(msg.value > highestBid, "there is already a higher bid.");
        require(!ended, "The auction has already ended.");

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;

        }
        highestBidder = sender;
        highestBid = msg.value;
        emit HighestBidIncreased(sender, msg.value);

    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0) {
            pendingReturns[msg.sender]=0;
            if(!msg.sender.send(amount)) {
                pendingReturns[msg.sender]=amount;
                return false;
            }
        }
        return true;
    }

    function pendingReturn(address sender) public view returns (uint) {
        return pendingReturns[sender];
    }

    function auctionEnd() public {
        //stage 1. check the conditions
        require(!ended, "The auction has been ended previously");
        require(msg.sender == beneficiary, "You are not the action beneficiary");
        //stage 2. Perform internal actions
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        //stage 3. interact with other contracts
        beneficiary.transfer(highestBid);
    }
}
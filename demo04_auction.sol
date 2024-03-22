// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

/**
    秘密竞拍合约
    先简单，再升级

    每个人出价，锁定，价格失效后可以拿回钱
    受益人手动接收money
 */
contract SimpoeAuction{
    // 拍卖参数
    address payable public beneficiary;
    //结束时间
    unit public auctionEnd;
    address public highestBidder;
    unit public heghestBid;
    mapping(address => unit) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, unit amount);
    event AuctionEnded(address winner, unit amount);

    /// The auction has already ended.
    error AuctionAlreadyEnded();
    error BidNotHighEnough(unit highestBid);
    error AuctionNotYetEnded();
    error AuctionEndAlreadyCalled();

    constructor(
        unit biddingTime,
        address payable beneficiaryAddress
    ){
        beneficiary = beneficiaryAddress;
        auctionEnd = block.timestamp + biddingTime;
    }

    function bid() external payable{
        if(block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();

        if(msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBidder;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() external returns (bool) {
        unit amoutn = pendingReturns[msg.sender];
        if (amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                //判断错误，还是要回复amount
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() external {
        if(block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();

        if(ended)
            revert AuctionEndAlreadyCalled();

        ended = true;
        // how to have the result?
        emit AuctionEnded(highestBidder,highestBid);

        beneficiary.transfer(highestBid);
    }

}
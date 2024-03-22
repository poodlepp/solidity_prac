// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.1;

contract TinyStorage{
    uint storedXlbData;

    function Mybid() public payable{

    }

    address public seller;
    modifier onlySeller(){
        require(
            msg.sender == seller,
            "Only seller can call this."
        );
        _;
    }

    function abort() public onlySeller{

    }

    // 事件能够调用EVM日志功能   DApp中使用？
    event HighestBidIncreased(address bidder, uint amount);

    function bid() public payable {
        emit HighestBidIncreased(msg.sender,msg.value);
    }

    error NotEnoughFunds(uint requested, uint available);

    mapping(address => uint) balances;
    function transfer(address to, uint amount) public {
        uint balance = balances[msg.sender];
        if(balance < amount)
            revert NotEnoughFunds(amount,balance);
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    struct Voter{
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    enum State {Created,Locked,Invalid}
}

function helper(uint x) pure returns (uint){
    return x*2;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Coin {
    //声明一个公开访问的address 160bit
    //编译器会转换为一个函数 返回 addres  minter
    address public minter;

    //哈希表，虚拟初始化
    mapping (address => unit) public balances;

    //事件 
    event Sent(address from, address to, unit amount);

    constructor(){
        minter = msg.sender;
    }

    function mint(address receiver, unit amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    error InsufficientBalance(unit requested, unit available);

    function send(address recerver, unit amount) public {
        if(amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[recerver] += amount;
        emit Sent(msg.sender,receiver,amount);
    }
}



//事件监听  web3.js??
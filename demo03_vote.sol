// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

/**

 */

/// @title 委托投票
contract Ballot {
    // 选民
    struct Voter {
        unit weight; //权重，默认都为1，被委托人会>1
        bool voted;  //是否已经投票标识
        address delegate; //被委托人
        unit vote; //提案的索引
    }

    // 提案
    struct Proposal {
        bytes32 name; // 投票简称，最长32byte
        unit voteCount; // 得票数
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    //初始化
    constructor(bytes32[] memory proposalNames){
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for(unit i = 0; i < proposalNames.length; i++){
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    //授权voter进行投票,weight字段用于标记
    function giveRightToVote(address voter) external {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    // 把投票委托到投票者
    function delegate (address to) external{
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no right to vote");
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

        //不允许闭环委托   这里to要递归寻找最终委托人
        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];

        require(delegate_.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if(delegate_.voted){
            proposals[delegate_.vote].voteCounnt += sender.weight;
        }else{
            delegate_.weight += sender.weight;
        }
    }

    // 投票给提案 （包含委托给自己的票）
    function vote(unit proposal) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    //计算胜出答案
    function winningProposal() external view returns (unit winningProposal_){
        unit winningVoteCount = 0;
        for(unit p = 0; p < proposals.length; p++){
            if (proposals[p].voteCount > winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // 返回获胜者名称
    function winnerName() public view returns (bytes32 winnerName_){
        winnerName_ = proposals[winningProposal()].name;
    }
}

/**
    还有优化空间：
    平局情况的处理
 */
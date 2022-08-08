// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract test
{   
    uint public startTime;
    uint public endTime;
    uint public Block = 3;
    uint public blockTimePeriod = 10;

    function startTimesStamp() public{
        startTime = block.timestamp;
        endTime = block.timestamp + Block * blockTimePeriod;
    }

    function setNoOfBlocks(uint value) public{
        Block = value;
    }
    function setBlockTimePeriod(uint time) public {
        blockTimePeriod = time;
    }

    function auction() public {
        require(block.timestamp <= endTime , "Time up" );

    }
    function showTimeLeft() public view returns(uint){
        return (endTime-block.timestamp);
    }
    // function showCurrentBlock() public view returns(uint){
    //     return ((endTime-block.timestamp)/blockTimePeriod)+1;
    // }
    function CurrentBlockPosition() public view returns(uint){
        uint timePassed = ((endTime-startTime)-(endTime-block.timestamp));
        uint currentBlock;
        if(timePassed % blockTimePeriod == 0)
            {currentBlock = timePassed / blockTimePeriod;}
        else
        {currentBlock = (timePassed / blockTimePeriod)+1;}
        return currentBlock;
    }

    
}
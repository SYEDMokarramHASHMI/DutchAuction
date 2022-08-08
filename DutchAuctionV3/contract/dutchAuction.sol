// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


import "./IERC20.sol";
import "./NFTToken/IERC721.sol";
import "./console.sol";

contract dutchAuction {
    
    uint public reservePrice;
    uint public numBlocksAuctionOpen;
    uint public blockTimePeriod;
    uint public offerPriceDecrement;
    uint public startTime;
    uint public endTime;
    uint public winningBid;
    address public winningBidder;
    bool public ended;
    uint nftTokenId;
    
    mapping(address => uint) bidderData;
    
    constructor(uint256 _reservePrice, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement, uint _nftTokenId) {
        console.log("Step:1");
        require(_reservePrice > 0);
        require(_numBlocksAuctionOpen > 0);
        require(_offerPriceDecrement > 0);

        console.log("Step:3");
        reservePrice = _reservePrice;
        numBlocksAuctionOpen = _numBlocksAuctionOpen;
        offerPriceDecrement = _offerPriceDecrement;
        startTime = block.timestamp;
        blockTimePeriod = 10;
        endTime = startTime + numBlocksAuctionOpen * blockTimePeriod;
        nftTokenId = _nftTokenId;
        }
    function bid(uint _bidAmount, address _ERC20Address, address _ERC721Address,
        address seller, address addressThis, address msgSender) public {
        require(block.timestamp <= endTime , "The auction has expired." );
        require(msgSender != seller, "The owner/seller cannot bid.");
        require(!ended, "Auction has ended");
        uint currentBlock = ((endTime-block.timestamp)/blockTimePeriod)+1;
        require(_bidAmount >= reservePrice + offerPriceDecrement * (currentBlock), "The bid value is lower than current price.");
        winningBidder = (msgSender);
        winningBid = _bidAmount;

        uint userTokenBalance = IERC20(_ERC20Address).balanceOf(msgSender);
        require(userTokenBalance >= _bidAmount, "Your token amount must be greater than winning bid.");
        
        IERC20(_ERC20Address).transferFrom(msgSender, addressThis, _bidAmount);
        require(IERC20(_ERC20Address).balanceOf(addressThis) >= _bidAmount, "The contract does not have enough token.");
        
        // (bool NFTSent) = IERC721(_ERC721Address).safeTransferFrom(seller, msgSender, nftTokenId);
        IERC721(_ERC721Address).safeTransferFrom(seller, msgSender, nftTokenId);
        (bool tokenSent) = IERC20(_ERC20Address).transfer(seller, _bidAmount);

        //require(NFTSent, "Unsuccessful NFT transfer.");
        require(tokenSent, "Unsuccessful bid transfer.");
        ended = true;}

    
    function setBlockTimePeriod(uint timeperiod) public{
        blockTimePeriod = timeperiod;
    }
    function setNoOFBlocks(uint noOfBlocks) public{
        console.log("step:1");
        numBlocksAuctionOpen = noOfBlocks;
        console.log("step:1");
        endTime = startTime + numBlocksAuctionOpen * blockTimePeriod;
        console.log("step:1");
    }
    function getTimePeriod() public view returns(uint){
        return blockTimePeriod;
    }

    function getBasicInfo() public view returns(uint _reservePrice, uint _OfferPriceDecrement, uint _endTime){
        return (reservePrice, offerPriceDecrement, numBlocksAuctionOpen );}
    function NFTPriceOfCurrentBlock() public view returns(uint){
        return reservePrice + offerPriceDecrement * (getCurrentBlockPosition());
    }
    
    function getTimeLeft() public view returns(uint){
        return endTime-block.timestamp;}
    function getStartTime() public view returns(uint){
        return startTime;}
    function getEndTime() public view returns(uint){
        return endTime;}
    function isEnded() public view returns(bool){return ended;}
    
    function getCurrentBlockPosition() public view returns(uint){
        uint timePassed = ((endTime-startTime)-(endTime-block.timestamp));
        uint currentBlock;
        if(timePassed % blockTimePeriod == 0)
            {currentBlock = timePassed / blockTimePeriod;}
        else
        {currentBlock = (timePassed / blockTimePeriod)+1;}
        return currentBlock;
    }
    function getTimePassed() public view returns(uint){
        return ((endTime-startTime)-(endTime-block.timestamp));
    }
    
}
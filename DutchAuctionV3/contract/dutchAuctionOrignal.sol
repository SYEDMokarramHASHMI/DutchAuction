// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract DutchAuctionOrignal {
    address payable public seller;

    uint public reservePrice;
    address public judgeAddress;
    uint public numBlocksAuctionOpen;
    uint public offerPriceDecrement;

    uint public startBlockNumber;
    uint public winningBid;
    address payable public winningBidder;

    bool public ended;
    bool public finalized;

    constructor(uint256 _reservePrice, address _judgeAddress, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement) {
        require(_reservePrice > 0);
        require(_numBlocksAuctionOpen > 0);
        require(_offerPriceDecrement > 0);

        seller = payable(msg.sender);
        reservePrice = _reservePrice;
        judgeAddress = _judgeAddress;
        numBlocksAuctionOpen = _numBlocksAuctionOpen;
        offerPriceDecrement = _offerPriceDecrement;
        startBlockNumber = block.number;
    }

    function bid() public payable returns(address) {
        require(!ended, "The auction has ended.");
        require(block.number < startBlockNumber + numBlocksAuctionOpen, "The auction has expired.");
        require(msg.value >= reservePrice + offerPriceDecrement * (startBlockNumber + numBlocksAuctionOpen - block.number), "The bid value is lower than current price.");
        require(msg.sender != seller, "The owner/seller cannot bid.");

        ended = true;
        winningBidder = payable(msg.sender);
        winningBid = msg.value;

        if (judgeAddress == address(0)) {
            // there is no judge -> transfer winning bid immediately to the seller
            require(address(this).balance >= winningBid, "The contract does not have enough wei.");

            (bool sent, ) = seller.call{value: winningBid}("");
            require(sent, "Unsuccessful bid transfer.");
        }

        return winningBidder;
    }

    function finalize() public {
        require(ended, "The auction has not ended.");
        require(!finalized, "The auction has been finalized.");
        require(msg.sender == winningBidder || msg.sender == judgeAddress, "Only winner or judge can call this method.");
        require(address(this).balance >= winningBid, "The contract does not have enough wei to transfer to seller.");

        finalized = true;
        (bool sent, ) = seller.call{value: winningBid}("");
        require(sent, "Unsuccessful bid transfer.");
    }

    function refund(uint256 refundAmount) public {
        require(ended, "The auction has not ended.");
        require(!finalized, "The auction has been finalized.");
        require(msg.sender == judgeAddress, "Only judge can call this method.");
        require(address(this).balance >= refundAmount, "The contract does not have enough wei to refund.");
        require(refundAmount <= winningBid, "Refund amount exceeded winning bid.");

        finalized = true;
        (bool sent, ) = winningBidder.call{value: refundAmount}("");
        require(sent, "Unsuccessful refund.");
    }

    //for testing framework
    function nop() public returns(bool) {
        return true;
    }
}
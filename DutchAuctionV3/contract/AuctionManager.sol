// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NFTToken/IERC721.sol";
import "./IERC20.sol";
import "./NFTToken/Counters.sol";

import "./dutchAuction.sol";
import "./console.sol";


contract AuctionManager {
    address ERC20Address;
    address ERC721Address;
    uint nftTokenId;
    address seller;

    using Counters for Counters.Counter;
    Counters.Counter private AutoContractID;

    struct AuctionContract{
        uint auctionID;
        address seller;
        dutchAuction dutchAuc;
    }
    mapping(uint => AuctionContract) public contracts;
    constructor(address _ERC721Address){
        require(_ERC721Address != address(0), "There must be an ERC721-Token address ");
        seller = msg.sender;
        ERC721Address = _ERC721Address;
    }
    function mint(uint tokenid) public{
        IERC721(ERC721Address)._safeMint(msg.sender, tokenid);
    }
    function sell(uint256 _reservePrice, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement, uint nftId) public {
        uint contractID = AutoContractID.current();
        dutchAuction dutchAuc;        
        dutchAuc = new dutchAuction(_reservePrice, _numBlocksAuctionOpen, _offerPriceDecrement, nftId);
        AuctionContract memory aucContract = AuctionContract(contractID, msg.sender, dutchAuc);
        contracts[contractID] = aucContract;
        AutoContractID.increment();}
    function getContractsInfo() public view returns(AuctionContract[] memory){
        uint256 ContractIDs = AutoContractID.current();
        AuctionContract[] memory contractIdsArray = new AuctionContract[](ContractIDs);
        for (uint256 x = 0; x < ContractIDs; x++) {
            contractIdsArray[x] = contracts[x];
        }
        return contractIdsArray;}
    function getContracts(uint contractID) public view returns(AuctionContract memory){
        return contracts[contractID];}
    function getContractInfo(uint contractID) view public returns(uint reservePrice, uint OfferPriceDecrement, uint endTime) {
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        return _ducAuction.getBasicInfo();}
    function getRemainingAcutionTime(uint contractID) public view returns(uint){
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        console.log("putin");
        return _ducAuction.getTimeLeft();}
    function getCurrentBlock(uint contractID) public view returns(uint){
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        return _ducAuction.getCurrentBlockPosition();}

    function getTimePeriod(uint contractID) public view returns(uint){
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        return _ducAuction.getTimePeriod();}
    function getTimePassed(uint contractID) public view returns(uint){
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        return _ducAuction.getTimePassed();}

    function IsContractEnded(uint contractID) public view returns(bool){
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        return _ducAuction.isEnded();}
    function setBlockTimePeriod(uint contractID, uint timePeriod) public{
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        _ducAuction.setBlockTimePeriod(timePeriod);}
    function setNoOFBlocks(uint contractID, uint noOfBlocks) public{
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        _ducAuction.setNoOFBlocks(noOfBlocks);
    }

    function NFTPriceOfCurrentBlock(uint contractID) public view returns(uint){
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        return _ducAuction.NFTPriceOfCurrentBlock();}

    function Bid(uint contractID, uint bidAmount, address _ERC20Address) public {
        dutchAuction _ducAuction;
        _ducAuction = contracts[contractID].dutchAuc;
        console.log("Step1");
        _ducAuction.bid(bidAmount, _ERC20Address, ERC721Address, seller, address(_ducAuction), msg.sender);}
    function getContractAmount(address token) public view returns(uint) {
        return IERC20(token).balanceOf(address(this));}
    function getUsereAmount(address token) public view returns(uint) {
        return IERC20(token).balanceOf(msg.sender);}

    

    
    
    

}
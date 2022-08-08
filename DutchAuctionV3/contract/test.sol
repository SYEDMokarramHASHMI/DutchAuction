// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;

contract Child {
    uint public num1;
    uint public num2;


    constructor(uint _num1, uint _num2) {
        num1 = _num1;
        num2 = _num2;
    }
    function show() public view returns(uint, uint ){
        return (num1, num2);
    }
}


contract Parent {

    uint myNum1;
    uint myNum2;
    Child public childContract; 
    mapping(address => Child) userToContract;
    function createChild(uint num1, uint num2) public returns(Child) {
        childContract = new Child(num1, num2); // creating new contract inside another parent contract
        userToContract[msg.sender] = childContract;
       return childContract;
    }
    
    function showMappinfRecord() public view returns(Child){
        return userToContract[msg.sender];
    }

    function showResult() public {
        childContract = userToContract[msg.sender];
        (myNum1, myNum2) = childContract.show();
    }
    function showRealResult() public view returns(uint, uint) {
        
        return (myNum1, myNum2);
    }

}
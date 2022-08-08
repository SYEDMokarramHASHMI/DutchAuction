// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


import "./ERC20.sol";

contract Token is ERC20{
    constructor() ERC20("DutchAuc","DA"){
        _mint(msg.sender, 1000000000*10**18);
    }
}


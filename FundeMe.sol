//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {priceConverter} from './priceConverter.sol';

contract FundMe{
  using priceConverter for uint256;

    constructor() payable {}

    uint256 public minUsd = 5e18;
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addresstoAmountFunded;

    function fund() public payable{
        require(msg.value.getConversionRate() > minUsd,"Not Enough Funds");
        //Returns value with 18 decimmal points
        funders.push(msg.sender);
        addresstoAmountFunded[msg.sender] = addresstoAmountFunded[msg.sender] + msg.value;
    } 

   
}

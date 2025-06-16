//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {priceConverter} from './priceConverter.sol';

contract FundMe{
  using priceConverter for uint256;

   

    uint256 public minUsd = 5e18;
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addresstoAmountFunded;
    
    address public owner;
    constructor() {
      owner = msg.sender;
     }

    function fund() public payable{
        require(msg.value.getConversionRate() > minUsd,"Not Enough Funds");
        //Returns value with 18 decimmal points
        funders.push(msg.sender);
        addresstoAmountFunded[msg.sender] +=msg.value;
    } 

    function withdraw() public {
      require(msg.sender == owner, "This person isnt the owner");
      for (uint256 funderIndex= 0 ;funderIndex < funders.length; funderIndex++){

        address funder = funders[funderIndex];
        addresstoAmountFunded[funder] = 0;
      }

      funders = new address[](0);

      //three types of methods to withdraw money i.e sendin ETH from a contract

      //transfer
       //payable(msg.sender).transfer(address(this).balance);
      //send
       //bool sendSuccess = payable(msg.sender).send(address(this).balance);
       //require(sendSuccess,"Send Failed");

      // call ,most optimum methdod for sending Etherum from a contraact
      (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess,"call Failed");
    }
   
}

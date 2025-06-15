//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe{

    constructor() payable {}

    uint256 public minUsd = 5e18;
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addresstoAmountFunded;

    function fund() public payable{
        require(getConversionRate(msg.value) > minUsd , "Not Enough Funds");
        //Returns value with 18 decimmal points
        funders.push(msg.sender);
        addresstoAmountFunded[msg.sender] = addresstoAmountFunded[msg.sender] + msg.value;
    } 

    function getPrice() public view returns (uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      (,int256 price,,,) = priceFeed.latestRoundData();
      //Returns values with 8 decimal points,so to convert them to 18 decimal points inorder to make it equal with the fund function
      //we multiply with 10 more decimal ponts
      return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
      uint256 ethPrice = getPrice();
      uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;//18 decimal times 18 decimals is 36 so divide by 18 decimals
      return ethAmountInUsd; 
    }
}

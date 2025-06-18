//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;



import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


library priceConverter{

     function getPrice() internal view returns (uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
      (,int256 price,,,) = priceFeed.latestRoundData();
      //Returns values with 8 decimal points,so to convert them to 18 decimal points inorder to make it equal with the fund function
      //we multiply with 10 more decimal ponts
      return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
      uint256 ethPrice = getPrice();
      uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;//18 decimal times 18 decimals is 36 so divide by 18 decimals
      return ethAmountInUsd; 
    }

    

}

error notOwner();

contract FundMe{
  using priceConverter for uint256;

   

    uint256 public constant minUsd = 5e18;
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addresstoAmountFunded;
    
    address public immutable owner;
    constructor() payable {
      owner = msg.sender;
     }

    function fund() public payable{
        require(msg.value.getConversionRate() > minUsd,"Not Enough Funds");
        //Returns value with 18 decimmal points
        funders.push(msg.sender);
        addresstoAmountFunded[msg.sender] +=msg.value;
    } 

    function withdraw() public  onlyOwner{
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
   
   modifier onlyOwner(){
    //require(owner == msg.sender,"Sender not owner");
    if (owner != msg.sender){
      revert notOwner();//this reduces gas cost better than requiremsg
    }
    _;
   }

   receive() external payable { 
    fund();
   }

   fallback() external payable { 
    fund();
   }
   
}

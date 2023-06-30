// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    

    address public tokenAddress;

    constructor(address token) ERC20("Ethreum LPTOKEN","lpETHTOKEN"){
        require(token != address(0),'Invalid Token Address');
        tokenAddress = token;
    }


    function balance() public view returns(uint256){
        return ERC20(tokenAddress).balanceOf(address(this));
    }


    // function of adding liquidity

    function addLiquidity(uint256 amountOfToken) public payable returns(uint256){
        uint256 lpTokensToMint;
        uint256 ethReserve = address(this).balance;
        uint256 tokenReserve  = balance();

        ERC20 token = ERC20(tokenAddress);


        if(tokenReserve == 0 ){
            token.transferFrom(msg.sender, address(this), amountOfToken);

            lpTokensToMint = ethReserve;
            _mint(msg.sender , lpTokensToMint);
            return lpTokensToMint;
        }

        uint256 ethRservepriorToFunctioncall = ethReserve = msg.value;

         uint256 minTokenAmountRequired = (msg.value * tokenReserve) /
        ethRservepriorToFunctioncall;

        require(
        amountOfToken >= minTokenAmountRequired,
        "Insufficient amount of tokens provided"
    );

    token.transferFrom(msg.sender, address(this), minTokenAmountRequired);

    lpTokensToMint =   (totalSupply() * msg.value) /
        ethRservepriorToFunctioncall;

    _mint(msg.sender, lpTokensToMint);

    return lpTokensToMint;
    }


    // remove liquidity 

    function removeLiquidity(uint256  amountoflpTokens) public returns(uint256 , uint256){
        require(amountoflpTokens > 0 , "Invalid LP No of TOkens");

        uint256 ethReserveBalance = address(this).balance;
        uint256 tokenBalance = balance();


        uint256 ethToBeReturned  =  (ethReserveBalance * amountoflpTokens) / tokenBalance;
        uint256 tokenToReturned =  (balance() * amountoflpTokens) / tokenBalance;

        _burn(msg.sender , amountoflpTokens);
        payable(msg.sender).transfer(ethToBeReturned);
        ERC20(tokenAddress).transfer(msg.sender, tokenToReturned);

        return (ethToBeReturned , tokenToReturned);

    }   


    function getOutputAmountFromSwap(  uint256 inputAmount,
    uint256 inputReserve,
    uint256 outputReserve) public pure returns(uint256){

        require(inputReserve > 0 , ' not valid');
           uint256 inputAmountWithFee = inputAmount * 99;

    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

    return numerator / denominator;
    }


    function ethToTokenSwap(uint256 minTokensToReceive) public payable {
    uint256 tokenReserveBalance = balance();
    uint256 tokensToReceive = getOutputAmountFromSwap(
        msg.value,
        address(this).balance - msg.value,
        tokenReserveBalance
    );

    require(
        tokensToReceive >= minTokensToReceive,
        "Tokens received are less than minimum tokens expected"
    );

    ERC20(tokenAddress).transfer(msg.sender, tokensToReceive);
}

// tokenToEthSwap allows users to swap tokens for ETH
function tokenToEthSwap(
    uint256 tokensToSwap,
    uint256 minEthToReceive
) public {
    uint256 tokenReserveBalance = balance();
    uint256 ethToReceive = getOutputAmountFromSwap(
        tokensToSwap,
        tokenReserveBalance,
        address(this).balance
    );

    require(
        ethToReceive >= minEthToReceive,
        "ETH received is less than minimum ETH expected"
    );

    ERC20(tokenAddress).transferFrom(
        msg.sender,
        address(this),
        tokensToSwap
    );

    payable(msg.sender).transfer(ethToReceive);
}
}
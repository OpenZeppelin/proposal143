// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import {Users} from "./utils/Users.sol";
import {SimulationConstants} from "../src/SimulationConstants.sol";
import {IcERC20} from "../src/Interfaces/IcERC20.sol";
import {IcETH} from "../src/Interfaces/IcETH.sol";
import {IComptroller} from "../src/Interfaces/IComptroller.sol";
import {IGovernorBravo} from "../src/Interfaces/IGovernorBravo.sol";
import {IERC20} from "../src/Interfaces/IERC20.sol";

contract CompoundProposalTest is Test, Users {
    function setUp() public {
        vm.label(GOVERNOR, "GOVERNOR BRAVO");
        vm.label(POLYCHAIN, "POLYCHAIN ADDRESS");
        vm.label(A16Z, "A16Z ADDRESS");
        skip(1 days);
        createUsers(2);
        passProposal143();
    }

    function passProposal143() internal {
        uint256 blockForVoting = block.number + IGovernorBravo(GOVERNOR).votingDelay() + 1;

        vm.roll(blockForVoting);

        vm.prank(POLYCHAIN);
        IGovernorBravo(GOVERNOR).castVote(143, 1);

        vm.prank(A16Z);
        IGovernorBravo(GOVERNOR).castVote(143, 1);

        vm.roll(blockForVoting + IGovernorBravo(GOVERNOR).votingPeriod() + 1);

        vm.prank(A16Z);
        IGovernorBravo(GOVERNOR).queue(143);

        (,, uint256 eta,,,,,,,) = IGovernorBravo(GOVERNOR).proposals(143);

        vm.warp(eta + 1);

        vm.prank(A16Z);
        IGovernorBravo(GOVERNOR).execute(143);
    }

    function depositsInCethMarket() public {
        vm.prank(users[1]);
        IcETH(cETH).mint{value: 1 ether}();
        console.log("User 1 cETH balance", IcETH(cETH).balanceOf(users[1]));
        address[] memory markets = new address[](1);
        markets[0] = cETH;

        vm.prank(users[1]);
        IComptroller(COMPTROLLER).enterMarkets(markets);
        console.log("Is user in market?", IComptroller(COMPTROLLER).checkMembership(users[1], cETH));
    }

    function depositsInOtherMarkets() public {
        vm.startPrank(users[1]);
        IcERC20(USDC).approve(cUSDC, 10_000e6);
        IcERC20(cUSDC).mint(10_000e6);
        console.log("User 1 cUSDC balance", IcERC20(cUSDC).balanceOf(users[1]));
        address[] memory markets = new address[](1);
        markets[0] = cUSDC;
        IComptroller(COMPTROLLER).enterMarkets(markets);
        console.log("Is user in market?", IComptroller(COMPTROLLER).checkMembership(users[1], cUSDC));
        vm.stopPrank();
    }

    function testBorrowsInCethMarket() public {
        depositsInOtherMarkets();
        vm.startPrank(users[1]);
        IcETH(cETH).borrow(1 ether);
        console.log(users[1].balance, "ETH balance");
        vm.stopPrank();
    }

    function testBorrowsInOtherMarkets() public {
        depositsInCethMarket();
        vm.startPrank(users[1]);
        IcERC20(cUSDC).borrow(200e6);
        console.log(IERC20(USDC).balanceOf(users[1]), "User 1 USDC balance");
        vm.stopPrank();
    }

    function testWithdrawsInCethMarket() public {
        depositsInCethMarket();
        vm.startPrank(users[1]);
        IcERC20(cUSDC).borrow(200e6);
        console.log(IERC20(USDC).balanceOf(users[1]), "User 1 USDC balance");
        vm.stopPrank();
    }

    function testWithdrawsInOtherMarkets() public {
        depositsInCethMarket();
        vm.startPrank(users[1]);
        IcERC20(cUSDC).borrow(200e6);
        console.log(IERC20(USDC).balanceOf(users[1]), "User 1 USDC balance");
        skip(10 days);
        uint256 amountToRepay = IcERC20(cUSDC).borrowBalanceCurrent(users[1]);
        console.log(amountToRepay);
        IcERC20(USDC).approve(cUSDC, amountToRepay);
        IcERC20(cUSDC).repayBorrow(amountToRepay);
        console.log(IERC20(USDC).balanceOf(users[1]), "User 1 USDC balance after repay");
        IComptroller(COMPTROLLER).exitMarket(cETH);
        console.log("Is user in market?", IComptroller(COMPTROLLER).checkMembership(users[1], cETH));
        vm.stopPrank();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import {SimulationConstants} from "../../src/SimulationConstants.sol";

contract Users is Test, SimulationConstants {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));
    address payable[] users;

    function getNextUserAddress() internal returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function createUsers(uint256 userNum) internal {
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = getNextUserAddress();
            vm.deal(user, 100 ether);
            deal(USDC, user, 100_000e6);
            users.push(user);
        }
    }
}
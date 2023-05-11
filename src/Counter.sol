// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";


contract Counter {
    uint256 public number;


    function chechSigHash(uint256 input) public returns (bytes4){
        bytes4 sighash;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, calldataload(4))
            sighash := mload(ptr)
        }
        console.logBytes4(sighash);
        return sighash;
    }


    function convertBytesToBytes4(bytes memory inBytes) public returns (bytes4 outBytes4) {
        if (inBytes.length == 0) {
            return 0x0;
        }
        assembly {
            outBytes4 := mload(add(inBytes, 32))
        }
    }

    function setNumber(uint256 newNumber) public {
        console.logUint(newNumber);
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue()
        }
        console.log("showing foo");
        console.logBytes32(foo);
        console.logBytes32(bar);
        console.logUint(wad);

        number = newNumber;


    }

    function executeMetaTransaction(address userAddress,
        bytes memory functionSignature, bytes32 sigR, bytes32 sigS, uint8 sigV) public payable returns (bytes memory) {
        console.log(userAddress);
        console.logBytes(functionSignature);
        console.logBytes32(sigR);
        console.logBytes32(sigS);
        console.logUint(sigV);


    }

    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    function selectorFromCallData(bytes calldata data) external payable {
        bytes4 selector;
        int offset;
        bytes4 selector2;
        assembly {
            offset := data.offset
            selector := calldataload(data.offset)
            selector2 := calldataload(68)

        }
        console.logInt(offset);
        console.logBytes4(selector);
        console.logBytes4(selector2);

    }

    function increment() public {
        number++;
    }
}

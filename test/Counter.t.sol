// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";


contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(100);
    }

    /*  function testIncrement() public {
          counter.increment();
          assertEq(counter.number(), 101);
      }

      function testSetNumber(uint256 x) public {

          counter.setNumber(x);
          assertEq(counter.number(), x);
      }
*/


    function _testChechSigHash(uint256 x) public {

        bytes memory testBytes = abi.encode(x);
        console.logBytes(testBytes);
        bytes4 sighash = counter.convertBytesToBytes4(testBytes);
        bytes4 qwe = counter.getSelector(string(testBytes));
        console.logString("log sighash -------------------------");
        console.logBytes4(sighash);
        console.logString("log qwe --------------------------------");
        console.logBytes4(qwe);

        assertEq(string(abi.encode(qwe)), string(abi.encode(sighash)), "sighash not match");
    }

    function _testExecuteMetaTransaction(address a, bytes memory b, bytes32 r, bytes32 s, uint8 v) public {
        counter.executeMetaTransaction(a, b, r, s, v);
    }

    function _testSelectorFromCallData() public {
        counter.selectorFromCallData("MetaTransaction(uint256 nonce,address from,bytes functionSignature)");
        counter.selectorFromCallData("executeMetaTransaction(address,bytes,bytes32,bytes32,uint8)");
    }


    function _parseValidationData(uint validationData) public pure returns (ValidationData memory data) {
        address aggregator = address(uint160(validationData));
        uint48 validUntil = uint48(validationData >> 160);
        if (validUntil == 0) {
            validUntil = type(uint48).max;
        }
        uint48 validAfter = uint48(validationData >> (48 + 160));
        return ValidationData(aggregator, validAfter, validUntil);
    }

    function _getAddressFromValidationData(uint validationData) public pure returns (address aggregator) {
        return address(uint160(validationData));
        //        uint48 validUntil = uint48(validationData >> 160);
        //        if (validUntil == 0) {
        //            validUntil = type(uint48).max;
        //        }
        //        uint48 validAfter = uint48(validationData >> (48 + 160));
        //        return ValidationData(aggregator, validAfter, validUntil);
    }


    struct ValidationData {
        address aggregator;
        uint48 validAfter;
        uint48 validUntil;
    }

    function testGetSelector() public {
        string memory msg = "executeMetaTransaction(address,bytes,bytes32,bytes32,uint8)";
        bytes4 selector;
        selector = counter.getSelector(msg);
        console.logString(msg);
        console.logBytes4(selector);

        msg = "execute(address,uint256,bytes)";
        selector = counter.getSelector(msg);
        console.logString(msg);
        console.logBytes4(selector);

        msg = "transact(uint256,address)";
        selector = counter.getSelector(msg);
        console.logString(msg);
        console.logBytes4(selector);

        msg = "executeBatch(address[],bytes[])";
        selector = counter.getSelector(msg);
        console.logString(msg);
        console.logBytes4(selector);

        address agregator = _getAddressFromValidationData(0);
        console.logAddress(agregator);


        //        counter.selectorFromCallData("executeMetaTransaction(address,bytes,bytes32,bytes32,uint8)");
        //        bytes4 transactSelector = counter.getSelector("transact(uint256, address)");
        //        console.logBytes4(transactSelector);
        //transact(uint256, address)
    }
    //bytes4(keccak256("executeMetaTransaction(address,bytes,bytes32,bytes32,uint8)"))

}

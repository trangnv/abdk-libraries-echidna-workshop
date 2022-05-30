// SPDX-License-Identifier: BSD-4-Clause
pragma solidity ^0.8.1;

import "ABDKMath64x64.sol";

contract Test {
  
  int128 internal zero = ABDKMath64x64.fromInt(0);
  int128 internal one = ABDKMath64x64.fromInt(1);
  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  /*
   * Maximum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


  //  event Value(string, int64);
  //  function debug(string calldata x, int128 y) public {
  //    emit Value(x, ABDKMath64x64.toInt(y));
  //  }
  event AssertionFailed(string message);
 
  function add(int128 x, int128 y) public returns(int128) {
    return ABDKMath64x64.add(x, y);
  }

  function sub(int128 x, int128 y) public returns(int128) {
    return ABDKMath64x64.sub(x, y);
  }

  function mul(int128 x, int128 y) public returns(int128) {
    return ABDKMath64x64.mul(x, y);
  }

  function mulu(int128 x, uint256 y) public returns(uint256) {
    return ABDKMath64x64.mulu(x, y);
  }

  function muli(int128 x, int256 y) public returns(int256) {
    return ABDKMath64x64.muli(x, y);
  }

  function div(int128 x, int128 y) public returns(int128) {
    return ABDKMath64x64.div(x, y);
  }

  function fromInt(int256 x) public returns(int128) {
    return ABDKMath64x64.fromInt(x);
  }

  function toInt(int128 x) public returns(int64) {
    return ABDKMath64x64.toInt(x);
  }

  function fromUInt(uint256 x) public returns(int128) {
    return ABDKMath64x64.fromUInt(x);
  }

  function toUInt(int128 x) public returns(uint64) {
    return ABDKMath64x64.toUInt(x);
  }

  function from128x128(int256 x) public returns(int128) {
    return ABDKMath64x64.from128x128(x);
  }

  function to128x128(int128 x) public returns(int256) {
    return ABDKMath64x64.to128x128(x);
  }


   function pow(int128 x, uint256 y) public returns(int128) {
     return ABDKMath64x64.pow(x, y);
   }


   function neg(int128 x) public returns(int128) {
     return ABDKMath64x64.neg(x);
   }

   function abs(int128 x) public returns(int128) {
     return ABDKMath64x64.abs(x);
   }

   function avg(int128 x, int128 y) internal returns(int128) {
     return ABDKMath64x64.avg(x,y);
   }

   function inv(int128 x) internal returns(int128) {
     return ABDKMath64x64.inv(x);
   }

   function sqrt(int128 x) internal returns(int128) {
     return ABDKMath64x64.sqrt(x);
   }

   function log_2(int128 x) internal returns(int128) {
     return ABDKMath64x64.log_2(x);
   }

   function ln(int128 x) internal returns(int128) {
     return ABDKMath64x64.ln(x);
   }

  /* 
  TEST ADDITION PROPERTIES, including associative, commutative, identity, distributive
  - Associative property:(x + y) + z = x +(y + z)
  - Commutative property: x + y = y + x
  - Identity property: x + 0 = x
  - Distributive property, with multiplication involved: x * (y + z) =  x * y + x * z
  NOTE: 
  - To prevent overflow, some functions use modulo operation to make sure arguments are in range
  e.g. x = x % mod to make sure x is in range [-mod + 1, mod - 1]
  */
  
  function testAddAssociative(int128 x, int128 y, int128 z) public {    
    int128 mod = 56713727820156407428984779325531226112; // mod = MAX_64x64 / 3
    x = x % mod;
    y = y % mod;
    z = z % mod;

    // try this.add(this.add(x, y), z) returns(int128 r) {
    //   assert(r == this.add(x, this.add(y, z)));
    // }
    // catch {
    //   emit AssertionFailed('Addition associative error');
    // }
    assert(add(add(x, y), z) == add(x, add(y, z)));
  }

  function testAddCommutative(int128 x, int128 y) public {
    int128 mod = 85070591730234615865843651857942052864; // mod = MAX_64x64 / 2
    x = x % mod;
    y = y % mod;

    assert(add(x, y) == add(y,x));

    // try this.add(x, y) returns(int128 r) {
    //   assert(r == this.add(y, x));
    // }
    // catch {
    //   emit AssertionFailed('Addition commutative error');
    // }
  }

  function testAddIdentity(int128 x) public {
    assert(add(x,zero) == x);

    // try this.add(x, zero) returns(int128 r) {
    //   assert(r == x);
    // }
    // catch {
    //   emit AssertionFailed('Addition identity error');
    // }
  }
  
  function testAddDistributive(int128 x, int128 y, int128 z) public {
    // to make sure y + z doesn't overflow
    int128 mod = 85070591730234615865843651857942052864; // mod = MAX_64x64 / 2
    y = y % mod;
    z = z % mod;

    try this.mul(x, add(y, z)) returns(int128 r1) {
      int128 r2 = add(mul(x, y), mul(x, z));
      // r1 = this.abs(r1);
      // r2 = this.abs(r2);
      assert(
        // r1 >= r2 * (1- (1/2))
        // (r1 >= mul(r2, sub(one, div(one, this.fromInt(2)))) 
        // && r1 <= this.mul(r2, this.add(one, this.div(one, this.fromInt(2)))))
        r1 >= sub(r2, one) &&
        r1 <= add(r2,one)
      );
    }
    catch {}
  }

  /* 
  TEST SUBTRACTION PROPERTIES, including non-associative, non-commutative, distributive
  - Non-associative:(x - y) - z = x - (y - z) with z != 0
  - Non-commutative: x - y != y - x with x != 0 || y!0
  - Distributive, with multiplication involved: x * (y - z) =  x * y - x * z
  */

  function testSubNonAssociative(int128 x, int128 y, int128 z) public {
    require(z!= zero );
    try this.sub(sub(x, y), z) returns(int128 r) {
      assert(r != sub(x, sub(y, z)));
    }
    catch {}
  }

  function testSubNonCommutative(int128 x, int128 y) public {
    require(x != y);
    try this.sub(x, y) returns(int128 r) {
      assert(r != sub(y, x));
    }
    catch {}
  }

  function testSubDistributive(int128 x, int128 y, int128 z) public {
    try this.sub(y,z) returns(int128) {
      try this.mul(x, sub(y, z)) returns(int128 r1) {
        int128 r2 = sub( mul(x, y), mul(x, z));
        assert(
          ( r1 <= r2 && r1 >= sub(r2, one)) ||
          ( r1 >= r2 && r1 <= add(r2, one))
        );
      }
      catch{}
    }
    catch {}
  }

  /* TEST MULTIPLICATION PROPERTIES
  - Associative: (x * y) * z = x * (y * z)
  - Commutative: x + y = y + x
  - Identity: x * 1 = x
  */

  function testMulAssociative(int128 x, int128 y, int128 z) public {
    try this.mul(x,y) returns(int128) {
      try this.mul(mul(x, y), z) returns(int128 r1) {
        int128 r2 = mul(x, mul(y,z));
        assert(
          ( r1 <= r2 && r1 >= sub(r2, one)) ||
          ( r1 >= r2 && r1 <= add(r2, one))
        );
      }
      catch {}
    }
    catch{}
  }
  
  function testMulCommutative(int128 x, int128 y) public {
    try this.mul(x, y) returns(int128 r) {
      assert(r == mul(y, x));
    }
    catch {}

  }

  function testMulIdentity(int128 x) public {
    try this.mul(x, one) returns(int128 r) {
      assert(r == x);
    }
    catch {
      emit AssertionFailed('Multiplication identity failed');
    }
  }

  /* TEST DIVISION PROPERTIES
  - Division by 1: x / 1 = x
  - Division by itself: x / x = 1
  - Division of 0: 0 / x = 0
  */

  function testDivByOne(int128 x) public {
    try this.div(x, one) returns(int128 r) {
      assert(r == x);
    }
    catch {}
  }

  function testDivByItself(int128 x) public {
    try this.div(x, x) returns(int128 r) {
      assert(r == one);
    }
    catch {}
  }

  function testDivOfZero(int128 x) public {
    try this.div(zero, x) returns(int128 r) {
      assert(r == zero);
    }
    catch {}
  }

  /* TEST NEGATIVE AND ABSOLUTE CALCULATIONS
  */
  function testNeg(int128 x) public {
    try this.neg(x) returns(int128 r) {
      assert(r + x == zero);
    }
    catch {
      assert(x == MIN_64x64);
    }
  }

  function testAbs(int128 x) public {
    try this.abs(x) returns(int128 r) {
      assert(r == x || r == neg(x));
    }
    catch {
      assert(x == MIN_64x64);
    }
  }

  /* TEST AVERAGE PROPERTIES
  Idempotency avg(x, x) = x
  - Commutative: avg(x, y) = avg(y, x)
  - Exchangable: avg(avg(x1,y1), avg(x2,y2)) = avg(avg(x1,x2), avg(y1,y2))
  */
  function testAvgIdempotency(int128 x) public {
    assert(avg(x, x) == x);
  }

  function testAvgCommutative(int128 x, int128 y) public {
    assert(avg(x, y) == avg(y, x));
  }

  function testAvgExchangeable(int128 x1, int128 x2, int128 y1, int128 y2) public {
    int128 r1 = avg(avg(x1,y1), avg(x2,y2));
    int128 r2 = avg(avg(x1,x2), avg(y1,y2));
    assert(
      (r1 >= r2 && r1 <= add(r2, one)) ||
      (r1 <= r2 && r1 >= sub(r2, one))
    );
  }

  function testPowProduct(int128 x, uint256 y, uint256 z) public {
    /* This test need improvements
    - y1+y2 || pow(x, y1+y2) can be reverted and assert never be reached
    */
    try this.pow(x, y+z) returns (int128 r1) {
      int128 r2 = mul(pow(x,y), pow(x,z));
      assert(
        (r1 >= r2 && r1 <= add(r2, one)) ||
        (r1 <= r2 && r1 >= sub(r2, one))
      );
    }
    catch {}
  }

  /*
  TEST INVERT
  */
  function testInv(int128 x) public {
    require(x != 0);
    try this.mul(x,inv(x)) returns (int128 r) {
      assert(
        r <= one && 
        r >= sub(one, div(one, fromInt(3)))
      );
    }
    catch {}
  }

  /*
  TEST SQRT
  */
  function testSQRT(int128 x) public {
    x = abs(x);
    int128 sqrt_x = sqrt(x);
    assert(
      pow(sqrt_x, 2) <= x &&
      // pow(sqrt_x, 2) >= mul(x, sub(one, div(one, fromInt(1000))))
      pow(sqrt_x, 2) >= sub(x, one)
    );
  }

  function testLog2Commutative(int128 x, int128 y) public {
    x = abs(x);
    y = abs(y);
    try this.mul(x,y) returns(int128) {
      int128 r1 = log_2(mul(x,y));
      int128 r2 = add(log_2(x), log_2(y));
      assert(
        (r1 >= r2 && r1 <= add(r2, one)) ||
        (r1 <= r2 && r1 >= sub(r2, one))
      );
    }
    catch{}
  }

  function testLnCommutative(int128 x, int128 y) public {
    x = abs(x);
    y = abs(y);
    try this.mul(x,y) returns(int128) {
      int128 r1 = ln(mul(x,y));
      int128 r2 = add(ln(x), ln(y));
      assert(
        (r1 >= r2 && r1 <= add(r2, one)) ||
        (r1 <= r2 && r1 >= sub(r2, one))
      );
    }
    catch{}
  }


}

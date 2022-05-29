# Fuzz tests for the ABDK Math 64.64 library using Echidna

## Before starting

Install Echidna 2.0.1:

* Install/upgrade [slither](https://github.com/crytic/slither): `pip3 install slither-analyzer --upgrade`
* Recommended option: [precompiled binaries](https://github.com/crytic/echidna/releases/tag/v2.0.1) (Linux and MacOS supported). 
* Alternative option: [use docker](https://hub.docker.com/layers/echidna/trailofbits/echidna/v2.0.1/images/sha256-526df14f9a90ba5615816499844263e851d7f34ed241acbdd619eb7aa0bb8556?context=explore).

## The contest

This repository contains everything necessary to test expected properties of the *Math 64.64 library*. Users should complete the `Test` creating functions to test different invariants from different mathematical operations (e.g. add, sub, etc) and adding assertions. The developer marked two functions as `private` instead of `internal` (`sqrtu` and `divuu`) which we are NOT going to directly test. 

A few pointers to start:

0. Read the documentation
1. Think of basic arithmetic properties for every operation
2. Consider when operation should or it should *not* revert
3. Some properties could require to use certain tolerance

To start a Echidna fuzzing campaign use:

```
$ echidna-test EchidnaTest.sol --contract Test --test-mode assertion --corpus-dir corpus --seq-len 1 --test-limit 1000000 
```

The last argument, `--test-limit` should be tweaked according to the time you want to spend in the fuzzing campaign. 
Additionally, from time to time, you should remove the corpus using `rm -Rf corpus`.

The recommended Solidity version for the fuzzing campaign is 0.8.1, however, more recent releases can be used as well.

## Expected Results and Evaluation

User should be able to fully test the *Math 64.64 library*. It is worth mentioning that the code is unmodified and there are no known issues. 
If you find some security or correctness issue in the code do NOT post it in this repository nor upstream, since these are public messages.
Instead, [contact us by email](mailto:gustavo.grieco@trailofbits.com) to confirm the issue and discuss how to proceed.

For Secureum, the resulting properties will be evaluated introducing an artificial bug in the code and running a short fuzzing campaign. 

## Documentation

Before starting, please review the [Echidna README](https://github.com/crytic/echidna#echidna-a-fast-smart-contract-fuzzer-), as well as [the official tutorials](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna). Additionally, there is specific documentation on the libraries:

### Math 64.64

Library of mathematical functions operating with signed 64.64-bit fixed point
numbers.

\[ [documentation](ABDKMath64x64.md) | [source](ABDKMath64x64.sol) \]

## Test file
### Structure
The tests are structurized as follow: (also commented in the Test.sol file)
- Addition properties
  - Associative: (x + y) + z = x +(y + z) ✅
  First I used try/catch but realize that inputs can be filtered to avoid expected revert, same applied for commutative and identity properties
  - Commutative: x + y = y + x ✅
  - Identity: x + 0 = x ✅
  - Distributive, with multiplication involved: x * (y + z) =  x * y + x * z ✅
  Using try/catch:
    - First attemp: simply `assert (mul(x, add(y, z) == add (mul(x, y), mul(x, z)))` ❌

    This one failed, e.g. with (-1,1,1)
    Why? 
      - mul(-1, add(1, 1) = mul(-1,2) yields -1
      - add (mul(-1, 1), mul(-1, 1))) = add(-1,-1) yields -2
    
    - Second attemp: add precision losses ✅

    In the above example, precision loss is 100%!!! Let try with 100% tolerance (suggestion from Gustavo)
      ```solidity
      r1 = mul(x, add(y, z);
      r2 = add (mul(x, y), mul(x, z)));
      r1 = abs(r1); // absolute value
      r2 = abs(r2);
      assert(
        // r2 * (1+ (1/2)) >= r1 >= r2 * (1- (1/2))
        r1 >= mul(r2, sub(one, div(one, fromInt(2)))) 
        && r1 <= mul(r2, add(one, div(one, fromInt(2))))
      );
      ```
    I tried with `r1 * (1+ (1/2)) >= r2 >= r1 * (1- (1/2))` but actually not necessary as the above assertion passed already




- Subtraction properties
  - Non-associative:(x - y) - z = x - (y - z) with z != 0 ✅
  - Non-commutative: x - y != y - x with x != 0 || y!0 ✅
  - Distributive, with multiplication involved: x * (y - z) =  x * y - x * z ❌

- Multiplication properties
  - Associative: (x * y) * z = x * (y * z) ❌
  - Commutative: x * y = y * x ✅
  - Identity: x * 1 = x ✅

- Division properties
  - Division by 1: x / 1 = x ✅
  - Division by itself: x / x = 1 ✅
  - Division of 0: 0 / x = 0 ✅

- Negative and Absolute calculations ✅

- Average
  - Idempotency avg(x, x) = x ✅
  - Commutative: avg(x, y) = avg(y, x) ✅
  - Exchangable: avg(avg(x1,y1), avg(x2,y2)) = avg(avg(x1,x2), avg(y1,y2)) ❌

- Power
  - Product of powers: x ** y1 * x ** y2 = x ** (y1 + y2) ❗️
  - 


### Notes
- Failed tests (marked ❌): I've yet to found the appropriate solutions to make them passed. Nevertheless it shows some insights of the code.
  - Distributivity for both Addition and Subtraction; Associativity of Multiplication: all these relate to precision loss. 
  - Exchangable of Average function: this one fails because of rounding down

- Tests that need improvements (marked ❗️)
  - Product of powers: `y1+y2` or `pow(x, y1+y2)` can be reverted and assert never be reached

- Tests for other functions need to be written

## Copyright

Copyright (c) 2019, [ABDK Consulting](https://abdk.consulting/)

All rights reserved.

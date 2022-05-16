# Fuzz tests for the ABDK Libraries using Echidna

This repository contains everything necessary to test expected properties of the *Math 64.64 library*. Users should complete the `Test` contract adding code with assertions.

A few pointers to start:

1. Think of basic arithmetic properties for every operation
2. Consider when operation should or it should *not* revert
3. Some properties could require to use certain tolerance

To start a Echidna fuzzing campaign use:

```
$ echidna-test EchidnaTest.sol --contract Test --test-mode assertion --corpus-dir corpus --seq-len 1 --test-limit 1000000 
```

The last argument, `--test-limit` should be tweaked according to the time you want to spend in testing. 
Additionally, from time to time, you should remove the corpus using `rm -Rf corpus`.

The recommended Solidity version for the fuzzing campaign is 0.8.1, however, more recent releases can be used as well.

# Documentation

Before starting, please review the [Echidna README](https://github.com/crytic/echidna#echidna-a-fast-smart-contract-fuzzer-), as well as [the official tutorials](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna). Additionally, there is specific documentation on the libraries:

## Math 64.64

Library of mathematical functions operating with signed 64.64-bit fixed point
numbers.

\[ [documentation](ABDKMath64x64.md) | [source](ABDKMath64x64.sol) \]

## Math Quad

Library of mathematical functions operating with IEEE 754 quadruple precision
(128 bit) floating point numbers.

\[ [documentation](ABDKMathQuad.md) | [source](ABDKMathQuad.sol) \]

# Copyright

Copyright (c) 2019, [ABDK Consulting](https://abdk.consulting/)

All rights reserved.

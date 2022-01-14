pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";
include "../circomlib/circuits/comparators.circom";
include "../circomlib/circuits/mimcsponge.circom";
include "../gcd/gcd.circom";
include "../prime/prime.circom";

template Spawn() {
    signal input x;
    signal input y;
    signal output pub;

    /* check abs(x), abs(y) <= 2^31 */
    component n2bx = Num2Bits(32);
    n2bx.in <== x + (1 << 31);
    component n2by = Num2Bits(32);
    n2by.in <== y + (1 << 31);

    // It has to be within a Euclidean distance of 64 to the origin (0, 0)
    component compUpper = LessThan(64);
    signal xSq;
    signal ySq;
    xSq <== x * x;
    ySq <== y * y;
    compUpper.in[0] <== xSq + ySq;
    compUpper.in[1] <== 64*64;
    compUpper.out === 1;

    // Its Euclidean distance to the origin (0,0) has to be more than 32.
    component compLower = GreaterThan(64);
    compLower.in[0] <== xSq + ySq;
    compLower.in[1] <== 32*32;
    compLower.out === 1;

    // GCD(x,y) must be greater than 1 
    component gcd = GCD();
    gcd.in[0] <== x;
    gcd.in[1] <== y;

    component gcdGreater = GreaterThan(64);
    gcd.out ==> gcdGreater.in[0];
    gcdGreater.in[1] <== 1;

    gcdGreater.out === 1;

    //and must not be a prime number.
    component prime = Prime();
    gcd.out ==> prime.in;

    prime.out === 0;

    //generate hash output
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== 0;

    pub <== mimc.outs[0];
}

component main = Spawn();

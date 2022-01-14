pragma circom 2.0.0;

function isPrime(n)
{
    // Corner case
    if (n <= 1) {return 0;}
  
    // Check from 2 to n \ 2
    for (var i = 2; i < (n >> 1); i++) {
        if ((n % i == 0)&(n != i)) {return 0;}
    }
    return 1;
}

template Prime() {
    signal input in;
    signal output out;

    out <-- isPrime(in);
}

//component main = Prime();
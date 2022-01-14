pragma circom 2.0.0;

function GetGCD(x, y){
    var temp;

    // Pass by reference
    var X;
    var Y;
    X = x;
    Y = y;

    while (Y != 0){
        temp = X % Y;
        X = Y;
        Y = temp;
    }
    return X;
}

template GCD() {
    signal input in[2];
    signal output out;

    out <-- GetGCD(in[0], in[1]);
}

//component main = GCD();
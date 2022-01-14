const { readFileSync } = require("fs");
const { generateWitness } = require("./spawn_js/generate_witness.js");
const snarkjs = require("snarkjs");
//const ff = require("ffjavascript");
//const { unstringifyBigInts } = ff.utils;

function unstringifyBigInts(o) {
    if ((typeof(o) == "string") && (/^[0-9]+$/.test(o) ))  {
        return BigInt(o);
    } else if ((typeof(o) == "string") && (/^0x[0-9a-fA-F]+$/.test(o) ))  {
        return BigInt(o);
    } else if (Array.isArray(o)) {
        return o.map(unstringifyBigInts);
    } else if (typeof o == "object") {
        if (o===null) return null;
        const res = {};
        const keys = Object.keys(o);
        keys.forEach( (k) => {
            res[k] = unstringifyBigInts(o[k]);
        });
        return res;
    } else {
        return o;
    }
}

module.exports.spawnCalldata = async function main(x, y) {
    const input = {
        "x": x,
        "y": y
    }
    
    let generateWitnessSuccess = true;

    let buff = await generateWitness(input)
        .catch((error) => {
            console.error('Fail to generate witness');
            generateWitnessSuccess = false;
        });
    
    if (!generateWitnessSuccess) { return; }


    const { proof, publicSignals } = await snarkjs.groth16.prove('./scripts/spawn_js/spawn_0001.zkey', buff);

    //console.log(proof);
    //console.log(publicSignals);

    const editedPublicSignals = unstringifyBigInts(publicSignals);
    const editedProof = unstringifyBigInts(proof);
    const calldata = await snarkjs.groth16.exportSolidityCallData(editedProof, editedPublicSignals);

    const argv = calldata.replace(/[\"\[\]\s]/g,"").split(',').map(x => BigInt(x).toString());

    const a = [argv[0], argv[1]];
    const b = [[argv[2], argv[3]], [argv[4], argv[5]]];
    const c = [argv[6], argv[7]];
    const Input = [argv[8]];

    return [a, b, c, Input];
}
#!/bin/bash
# verify coordinates and spawn
read -p 'contract address: ' addr
read -p 'x-coordinate: ' xcoord
read -p 'y-coordinate: ' ycoord
echo "{\"x\": $xcoord, \"y\": $ycoord}" > circuits/spawn/input.json

# remove historical files
rm -f circuits/spawn/witness.wtns
rm -f circuits/spawn/proof.json
rm -f circuits/spawn/public.json

# generate witness
node "circuits/spawn/spawn_js/generate_witness.js" circuits/spawn/spawn_js/spawn.wasm circuits/spawn/input.json circuits/spawn/witness.wtns

# general proof
snarkjs groth16 prove circuits/spawn/spawn_0001.zkey circuits/spawn/witness.wtns circuits/spawn/proof.json circuits/spawn/public.json

# generate call
call=$(snarkjs generatecall circuits/spawn/public.json circuits/spawn/proof.json)

truffle exec scripts/spawn.js $call $addr

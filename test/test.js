const { expect } = require("chai");
const { ethers } = require("hardhat");
const { spawnCalldata } = require("../scripts/spawn.js")

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

describe("Dark Forest Contract", function () {

    let Verifier;
    let verifier;
    let DarkForest;
    let darkForest;

    beforeEach(async function () {

        Verifier = await ethers.getContractFactory("Verifier");
        verifier = await Verifier.deploy();

        //console.log("Verifier address:", verifier.address);

        DarkForest = await ethers.getContractFactory("DarkForest");
        darkForest = await DarkForest.deploy(verifier.address);

        //console.log("DarkForest address:", darkForest.address);
    });

    describe("Deployment", function () {

        it("Deploy correctly", async function () {
            expect(await darkForest.verifierAddr()).to.equal(verifier.address);
        });
    });


    describe("Spawn", function () {
        it("Spawn valid inputs", async function () {
            let calldata = await spawnCalldata(40, 40);
            //console.log(calldata);
            expect(calldata).to.have.lengthOf(4);
            expect(calldata[0]).to.have.lengthOf(2);
            expect(calldata[1]).to.have.lengthOf(2);
            expect(calldata[2]).to.have.lengthOf(2);
            expect(calldata[3]).to.have.lengthOf(1);

            let result = await darkForest.spawn(calldata[0], calldata[1], calldata[2], calldata[3]);
            //console.log(result);
            expect(result.confirmations).to.equal(1);
        });

        it("Reject invalid inputs", async function () {
            const invalidCalldata = await spawnCalldata(20, 20);
            expect(invalidCalldata).to.be.undefined;
        });

        it("Reject a position where other players have spawned within the last 5 minutes", async function () {

            let calldata = await spawnCalldata(40, 40);
            let errorString;

            await darkForest.spawn(calldata[0], calldata[1], calldata[2], calldata[3]);
            await darkForest.spawn(calldata[0], calldata[1], calldata[2], calldata[3])
                .catch((error) => {
                    errorString = error.toString();
                });
            //console.log(errorString);
            expect(errorString).to.have.string('Other players have spawned at this position within the last 5 minutes.');
        });
        
          it("Reject a position currently occupied by another player.", async function () {
            this.timeout(1000000);
            let calldata = await spawnCalldata(40, 40);
            let errorString;

            await darkForest.spawn(calldata[0], calldata[1], calldata[2], calldata[3]);
              
            await sleep(300000).then(() => console.log('ran after 5 minutes passed'));

            await darkForest.spawn(calldata[0], calldata[1], calldata[2], calldata[3])
                .catch((error) => {
                    errorString = error.toString();
                });
            //console.log(errorString);
            expect(errorString).to.have.string('This position is currently occupied by another player.');
          });
        
    });
});

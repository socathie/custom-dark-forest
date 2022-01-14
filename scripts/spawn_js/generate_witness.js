const wc = require("./witness_calculator.js");
const { readFileSync, writeFile } = require("fs");

module.exports.generateWitness = async function (input) {
	const buffer = readFileSync('./scripts/spawn_js/spawn.wasm');
	let buff;

	await wc(buffer).then(async witnessCalculator => {
		buff = await witnessCalculator.calculateWTNSBin(input, 0);
	});
	return buff;
}
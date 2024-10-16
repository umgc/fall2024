
const testCases = 5
let passed = 0;

const studentFilePath = process.argv[2];
const { addition, subtraction, multiplication, division, power } = require(`./${studentFilePath}`);

function runTest() {
    const addResult = addition(2, 3);
    if (addResult === 5) {
        passed += 1;
    } 

    const subtractResult = subtraction(3, 1);
    if (subtractResult === 2) {
        passed += 1;
    } 

    const multiplyResult = multiplication(3, 4);
    if (multiplyResult === 12) {
        passed += 1;
    } 

    const divideResult = division(10, 2);
    if (divideResult === 5) {
        passed += 1;
    } 

    const powerResult = power(2, 2);
    if (powerResult === 4) {
        passed += 1;
    } 

    console.log(`${studentFilePath}: ${passed} out of ${testCases} test cases passed`);
}

runTest();

const testCases = 5
let passed = 0;

const studentFilePath = process.argv[2];
const { addition, subtraction, multiplication, division, power } = require(`./${studentFilePath}`);

function runTest() {
    const addResult = addition(2, 3);
    if (addResult === 5) {
        passed += 1;
        console.log(`Addition test passed: ${addResult} === 5`);
    } else {
        console.log(`Addition test failed: ${addResult} !== 5`);
    }

    const subtractResult = subtraction(3, 1);
    if (subtractResult === 2) {
        passed += 1;
        console.log(`Subtraction test passed: ${subtractResult} === 2`);
    } else {
        console.log(`Subtraction test failed: ${subtractResult} !== 2`);
    }

    const multiplyResult = multiplication(3, 4);
    if (multiplyResult === 12) {
        passed += 1;
        console.log(`Multiplication test passed: ${multiplyResult} === 12`);
    } else {
        console.log(`Multiplication test failed: ${multiplyResult} !== 12`);
    }

    const divideResult = division(10, 2);
    if (divideResult === 5) {
        passed += 1;
        console.log(`Division test passed: ${divideResult} === 5`);
    } else {
        console.log(`Division test failed: ${divideResult} !== 5`);
    }

    const powerResult = power(2, 2);
    if (powerResult === 4) {
        passed += 1;
        console.log(`Power test passed: ${powerResult} === 4`);
    } else {
        console.log(`Power test failed: ${powerResult} !== 4`);
    }

    console.log(`${studentFilePath}: ${passed} out of ${testCases} test cases passed`);
    console.log(`-------------------------------------------------------------------`);
}

runTest();
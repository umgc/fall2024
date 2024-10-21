import sys 
import importlib.util

filename = sys.argv[2]

spec = importlib.util.spec_from_file_location("addition", filename)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

addition = getattr(module, "addition")
subtraction = getattr(module, "subtraction")
multiplication = getattr(module, "multiplication")
division = getattr(module, "division")
power = getattr(module, "power")

testCases = 5
passed = 0

def runTests():
    addResult = addition(2, 3)
    if addResult == 5:
        print("Addition test passed: ${addResult} == 5")
        passed += 1
    else:
        print("Addition test failed:  ${addResult} != 5")

    subtractionResult = subtraction(5, 3)
    if subtractionResult == 2:
        print("Subtraction test passed: ${subtractionResult} == 2")
        passed += 1
    else:
        print("Subtraction test failed: ${subtractionResult} != 2")

    multiplicationResult = multiplication(2, 3)
    if multiplicationResult == 6:
        print("Multiplication test passed: ${multiplicationResult} == 6")
        passed += 1
    else:
        print("Multiplication test failed: ${multiplicationResult} != 6")

    divisionResult = division(6, 3)
    if divisionResult == 2:
        print("Division test passed: ${divisionResult} == 2")
        passed += 1
    else:
        print("Division test failed: ${divisionResult} != 2")

    powerResult = power(2, 3)
    if powerResult == 8:
        print("Power test passed: ${powerResult} == 8")
        passed += 1
    else:
        print("Power test failed: ${powerResult} != 8")

runTests()
import sys 
import importlib.util

studentFilename = sys.argv[1]

filename = "uploads_python/" + studentFilename

spec = importlib.util.spec_from_file_location("addition", filename)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

addition = getattr(module, "addition")
subtraction = getattr(module, "subtraction")
multiplication = getattr(module, "multiplication")
division = getattr(module, "division")
power = getattr(module, "power")

def runTests():
    testCases = 5
    passed = 0

    addResult = addition(2, 3)
    if addResult == 5:
        print(f"Addition test passed: {addResult} == 5")
        passed += 1
    else:
        print(f"Addition test failed: {addResult} != 5")

    subtractionResult = subtraction(5, 3)
    if subtractionResult == 2:
        print(f"Subtraction test passed: {subtractionResult} == 2")
        passed += 1
    else:
        print(f"Subtraction test failed: {subtractionResult} != 2")

    multiplicationResult = multiplication(2, 3)
    if multiplicationResult == 6:
        print(f"Multiplication test passed: {multiplicationResult} == 6")
        passed += 1
    else:
        print(f"Multiplication test failed: {multiplicationResult} != 6")

    divisionResult = division(6, 3)
    if divisionResult == 2:
        print(f"Division test passed: {divisionResult} == 2")
        passed += 1
    else:
        print(f"Division test failed: {divisionResult} != 2")

    powerResult = power(2, 3)
    if powerResult == 8:
        print(f"Power test passed: {powerResult} == 8")
        passed += 1
    else:
        print(f"Power test failed: {powerResult} != 8")

    print(f'{studentFilename}: {passed} out of {testCases} test cases passed')
    print('-------------------------------------------------------------------')

runTests()
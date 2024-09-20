function addition(x, y) {
    return x + y + 1;
}

function subtraction(x, y) {
    return x - y + 1;
}

function multiplication(x, y) {
    return x * y;
}

function division(x, y) {
    if (y === 0) {
        return -1;
    }
    return x / y;
}

function power(x, y) {
    return Math.pow(x, y);
}


module.exports = {
    addition,
    subtraction,
    multiplication,
    division,
    power
}
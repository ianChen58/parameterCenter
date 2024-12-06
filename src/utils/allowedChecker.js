const number_regex = new RegExp("([\\(\\[])(.*)(,)(.*)([\\)\\]])")
const options_regex = new RegExp("(\\{)(.*)(\\})")
const regex_regex = new RegExp("(/)(.*)(/)")

export default function allowedChecker(allowed, value) {
    const numberMatch = number_regex.exec(allowed);
    if (numberMatch && numberMatch[0] === allowed) {
        return NumericalRangeAllowedChecker(allowed, value)
    }
    const optionsMatch = options_regex.exec(allowed);
    if (optionsMatch && optionsMatch[0] === allowed) {
        return OptionsAllowedChecker(allowed, value)
    }
    const regexMatch = regex_regex.exec(allowed);
    if (regexMatch && regexMatch[0] === allowed) {
        return RegexAllowedChecker(allowed, value)
    }
    return false;
}
    
function OptionsAllowedChecker(allowed, value) {
    const check = allowed.match(options_regex)[2]
    const checkList = check.split(",")
    return checkList.includes(value)
}

function NumericalRangeAllowedChecker(allowed, value) {
    if (isNaN(value)) {
        return false
    }
    const leftScope = allowed.match(number_regex)[1]
    const left = parseFloat(allowed.match(number_regex)[2])
    const right = parseFloat(allowed.match(number_regex)[4])
    const rightScope = allowed.match(number_regex)[5]
    // check left
    let leftCheck = false
    if (leftScope === "(") {
        leftCheck = value > left
    } else if (leftScope === "[") {
        leftCheck = value >= left
    }
    // check right
    let rightCheck = false
    if (rightScope === ")") {
        rightCheck = value < right
    } else if (rightScope === "]") {
        rightCheck = value <= right
    }
    return leftCheck && rightCheck
}


function RegexAllowedChecker(allowed, value) {
    const check = allowed.match(regex_regex)[2]
    let regexBody = new RegExp(check);
    return regexBody.test(value);
}
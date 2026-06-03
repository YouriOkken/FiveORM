StringFunctions = {}

function StringFunctions.replaceString(str, pattern, replacement)
    return string.gsub(str, pattern, replacement)
end
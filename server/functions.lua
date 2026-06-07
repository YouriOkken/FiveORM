StringFunctions = {}

function StringFunctions.replaceString(str, pattern, replacement)
    return string.gsub(str, pattern, replacement)
end

function log(msg) 
    print("[FiveORM] " .. msg)
end
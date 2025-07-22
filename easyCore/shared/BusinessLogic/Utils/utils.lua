local random = math.random

---generate guid
---@return string
function Guid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

---count items in table
---@param list table
---@return integer
function ListCount(list)
    local count=0
    if not list then
        return count
    end
    for k,v in pairs(list) do
        count=count+1
    end
    return count
end

---check table is not null or empty
---@param table table
---@return boolean
function CheckTableCountNotZero(table)
    local result=false
    if not table then
        return result
    end
    for k,v in pairs(table) do
        result=true
        break
    end
    return result
end

---check itrem is in table
---@param table table
---@param item any
---@return boolean
function Contains(table, item)
    local result=false
    if not table or not item then
        return result
    end
    for k,v in pairs(table) do
        if v==item then
            result=true
            break
        end
    end
    return result
end

---get value by key
---@param table any
---@param item any
---@return boolean|any
function GetValueByKey(table, key)
    if not table then
        return false
    end
    if not table[key] then
        return false
    end 
    return table[key]
end

---copy table deep to ne table object
---@param orig table
---@return table
function DeepClone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[EasyCore.Utils.DeepClone(orig_key)] = EasyCore.Utils.DeepClone(orig_value)
        end
        setmetatable(copy, EasyCore.Utils.DeepClone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function CheckOnceStringItemOfTableExistsInString(table, text, ignoreCase)
    if not table or not CheckTableCountNotZero(table) then
        return false
    end
    
    if ignoreCase then
        text = text:lower()
    end
    
    for k, v in pairs(table) do
        if type(v) == "string" then
            local pattern = v
            if ignoreCase then
                pattern = pattern:lower()
            end

            local start, ende = string.find(text, pattern)

            if start then
                return true
            end
        end
    end
    return false
end

--- Summary: Converts a version string (e.g., "1.2.3") to a comparable number (e.g., 123).
--- It removes all non-digit characters from the string and then converts it to a number.
--- This is useful for numerical comparisons of version numbers.
---@param versionString string The version string to clean and convert. Can be nil.
---@return number The numerical representation of the version, or 0 if conversion fails or input is nil.
function CleanAndToNumber(versionString)
    if not versionString then
        return 0
    end
    -- Remove all non-digit characters (like dots, dashes, letters)
    local cleanedVersion = versionString:gsub("%D", "")
    return tonumber(cleanedVersion) or 0 -- Return 0 if conversion to number fails
end
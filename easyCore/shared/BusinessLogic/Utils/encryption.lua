-- Helper function to replace bit.bxor for broader compatibility
---
--- Performs bitwise XOR between two numbers.
--- @param a number First operand
--- @param b number Second operand
--- @return number Result of XOR operation
local function Xor(a, b)
    local r = 0
    local p = 1
    while a > 0 or b > 0 do
        local rem_a = a % 2
        local rem_b = b % 2
        if rem_a ~= rem_b then
            r = r + p
        end
        a = (a - rem_a) / 2
        b = (b - rem_b) / 2
        p = p * 2
    end
    return r
end

--------------------------------------------------------------------------------
-- NEUE, ZUVERLÄSSIGE BASE64 FUNKTIONEN --
--------------------------------------------------------------------------------
local b64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

---
--- Encodes a string to Base64.
--- @param data string The input string to encode
--- @return string Base64 encoded string
function Base64Encode(data)
    local bytes = {data:byte(1,-1)}
    local result = ''
    for i=1, #bytes, 3 do
        local c1, c2, c3 = bytes[i], bytes[i+1], bytes[i+2]
        local b1 = math.floor(c1 / 4)
        local b2 = (c1 % 4) * 16 + (c2 and math.floor(c2 / 16) or 0)
        
        result = result .. b64_chars:sub(b1 + 1, b1 + 1) .. b64_chars:sub(b2 + 1, b2 + 1)

        if c2 then
            local b3 = (c2 % 16) * 4 + (c3 and math.floor(c3 / 64) or 0)
            result = result .. b64_chars:sub(b3 + 1, b3 + 1)
            if c3 then
                local b4 = c3 % 64
                result = result .. b64_chars:sub(b4 + 1, b4 + 1)
            else
                result = result .. '='
            end
        else
            result = result .. '=='
        end
    end
    return result
end

---
--- Decodes a Base64 string.
--- @param data string The Base64 encoded string
--- @return string Decoded string
function Base64Decode(data)
    data = data:gsub('[^A-Za-z0-9+/=]', '')
    local decoding_map = {}
    for i=1, #b64_chars do decoding_map[b64_chars:sub(i,i)] = i-1 end
    
    local bytes = {}
    for i=1, #data, 4 do
        local c1, c2, c3, c4 = data:sub(i,i), data:sub(i+1,i+1), data:sub(i+2,i+2), data:sub(i+3,i+3)
        local n1, n2 = decoding_map[c1], decoding_map[c2]
        
        if n1 and n2 then
            table.insert(bytes, n1 * 4 + math.floor(n2 / 16))
            if c3 and c3 ~= '=' then
                local n3 = decoding_map[c3]
                table.insert(bytes, (n2 % 16) * 16 + math.floor(n3 / 4))
                if c4 and c4 ~= '=' then
                    local n4 = decoding_map[c4]
                    table.insert(bytes, (n3 % 4) * 64 + n4)
                end
            end
        end
    end
    return string.char(table.unpack(bytes))
end
--------------------------------------------------------------------------------
-- ENDE DER NEUEN BASE64 FUNKTIONEN --
--------------------------------------------------------------------------------

---
--- Encrypts a string using XOR and encodes it with Base64.
--- @param data string The input string to encrypt
--- @param key string The key to use for XOR encryption
--- @return string|boolean Base64 encoded encrypted string, or false on error
function XorEncrypt(data, key)
    if not data or not key then return false end
    local encrypted = ''
    for i = 1, #data do
        local charCode = string.byte(data, i)
        local keyCode = string.byte(key, (i - 1) % #key + 1)
        encrypted = encrypted .. string.char(Xor(charCode, keyCode))
    end
    return Base64Encode(encrypted)
end

---
--- Decrypts a Base64 encoded XOR encrypted string.
--- @param encryptedBase64 string The Base64 encoded encrypted string
--- @param key string The key to use for XOR decryption
--- @return string|boolean Decrypted string, or false on error
function XorDecrypt(encryptedBase64, key)
    if not encryptedBase64 or not key then return false end
    local encryptedData = Base64Decode(encryptedBase64)
    if not encryptedData then return false end
    local decrypted = ''
    for i = 1, #encryptedData do
        local charCode = string.byte(encryptedData, i)
        local keyCode = string.byte(key, (i - 1) % #key + 1)
        decrypted = decrypted .. string.char(Xor(charCode, keyCode))
    end
    return decrypted
end
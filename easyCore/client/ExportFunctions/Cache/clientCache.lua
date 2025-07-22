if not EasyCore then
    EasyCore={}
end


--ClientCache
if not EasyCore.Cache then
    EasyCore.Cache={}
end

EasyCore.Cache.Client={}

---Set value to client cache by key
---@param ressourceName string
---@param key string
---@param value any
---@return boolean
EasyCore.Cache.Client.SetData=function(ressourceName, key, value) --use for update too
    if key and value then
        local p = promise.new()
        FRAMEWORK.TriggerServerCallback("EasyCore:SetClientCacheKeyValue", function(cb)
            p:resolve(cb)
        end, {ressourceName=ressourceName, key=key, value=value})
        local result = Citizen.Await(p)
        return result
    end
    return false
end

---get value from client cache by key
---@param ressourceName string
---@param key string
---@return boolean|any
EasyCore.Cache.Client.GetData=function(ressourceName, key)
    local result=false
    if key then
        local p = promise.new()
        FRAMEWORK.TriggerServerCallback("EasyCore:GetClientCacheKeyValue", function(cb)
            p:resolve(cb)
        end, {ressourceName=ressourceName, key=key})
        local result = Citizen.Await(p)
        return result
    end
    return result
end


---get total client cache
---@param ressourceName string
---@return boolean|any
EasyCore.Cache.Client.GetTotalDataForClient=function(ressourceName)
    local result=false
    if ressourceName then
        local p = promise.new()
        FRAMEWORK.TriggerServerCallback("EasyCore:GetTotalClientCache", function(cb)
            p:resolve(cb)
        end, {ressourceName=ressourceName})
        local result = Citizen.Await(p)
        return result
    end
    return result
end

---delete total client cache for client
---@param ressourceName any
---@return boolean
EasyCore.Cache.Client.InvalidateTotalClientCachData=function(ressourceName)
    local result=false
    if ressourceName then
        local p = promise.new()
        FRAMEWORK.TriggerServerCallback("EasyCore:InvalidateTotalClientCachData", function(cb)
            p:resolve(cb)
        end, {ressourceName=ressourceName})
        local result = Citizen.Await(p)
        return result
    end
    return result
end


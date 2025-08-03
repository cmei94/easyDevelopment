---@class EconomyClientRepository

EconomyClientRepository={}

EconomyClientRepository.__index=EconomyClientRepository

--- Konstruktor
---@return EconomyStockMarketProcessor
function EconomyClientRepository:new()
    local economyClientRepository={}
    setmetatable(economyClientRepository, self)

    return economyClientRepository
end

--- load item prizes
---@param requestId string
---@param items table
---@return table<EconomyExportItem>
function EconomyClientRepository:LoadItemPrizes(requestId, items)
    local p = promise.new()
    ESX.TriggerServerCallback("EasyEconomy:GetEconomyItem", function(cb)
        p:resolve(cb)
    end, {RequestId=requestId, Items=items})
    local result = Citizen.Await(p)
    return result
end
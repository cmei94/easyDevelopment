---@class ShopClientRepository

ShopClientRepository={}

ShopClientRepository.__index=ShopClientRepository

--- Konstruktor
---@return EconomyStockMarketProcessor
function ShopClientRepository:new()
    local shopClientRepository={}
    setmetatable(shopClientRepository, self)

    return shopClientRepository
end

--- load item prizes
---@param requestId string
---@param items table
---@return table<EconomyExportItem>
function ShopClientRepository:LoadItemPrizes(requestId, items)
    return EasyEconomy.GetEconomyItems(items)
end

--- LoadData PlayerData WithPlayerInformations and CurrentInventory
---@param requestId string
function ShopClientRepository:LoadForTabletNeededPlayerData(requestId)
    return EasyCore.FrameworkHelper.GetPlayerData()
end

--- LoadData PlayerLicenses
---@param requestId string
function ShopClientRepository:LoadPlayerLicenses(requestId)
    return EasyCore.FrameworkHelper.GetPlayerLicenses()
end

function ShopClientRepository:TransmitOrderToPlayer(requestId,data)
    local result=false
    local p = promise.new()
    ESX.TriggerServerCallback("easyShop:OrderToPlayer", function(cb)
        p:resolve(cb)
    end, {RequestId=requestId, Items=data})
    result = Citizen.Await(p)
    return result
end


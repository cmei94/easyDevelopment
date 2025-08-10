---@type ShopProcessor
local shopProcessor=ShopProcessor:new()

shopProcessor:StartShopSystem()

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    shopProcessor:CloseTablet()
end)

RegisterNUICallback('orderItems', function(data, cb)
    local requestId= EasyCore.Utils.Guid()
    local success=false
    local items=nil
    local player=nil
    if not data or not EasyCore.Utils.CheckTableCountNotZero(data) then
        EasyCore.Logger.LogError(RessourceName, requestId, "Data at orderItems is null or empty!")
    else
        success=shopProcessor:ProcessItemOrder(requestId, data)
        player=shopProcessor:LoadForTabletNeededPlayerData(requestId)
        items=shopProcessor:LoadDataForTablet(requestId, player)
    end
    cb({success = success, playerdata=tostring(json.encode(player)), shopitems=tostring(json.encode(items))})
end)



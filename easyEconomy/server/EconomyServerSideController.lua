local economyProcessor=EconomyServerSideProcessor:new()
local calculationProcessor=EconomyCalculationProcessor:new()
local economyHookProcessor=EconomyHookProcessor:new()

---get itemprizes
---@param items table e.g. items={'water','apple'} or items={} ->getAllItems or items=nil->getAllItems
---@return table e.g. returnResult={['water']={EconomyLabel='Water', "Category": "Default", CurrentBuyPrize=100, CurrentSellPrize=20}, ['apple']={EconomyLabel='Apple', "Category": "Default", CurrentBuyPrize=110, CurrentSellPrize=50}}
EasyEconomy.GetEconomyItems=function(items)
    return economyProcessor:GetExportItems(items)
end

ESX.RegisterServerCallback("EasyEconomy:GetEconomyItem", function(source, cb, args)
    local requestId = args.RequestId or EasyCore.Utils.Guid()
    local items = args.Items or {}
    local result = EasyEconomy.GetEconomyItems(items)
    cb(result)
end)

ESX.RegisterServerCallback("EasyEconomy:GetEconomyCategoryItems", function(source, cb, args)
    local requestId = args.RequestId or EasyCore.Utils.Guid()
    while not EconomyCategoriesItems do
        Wait(100)
    end
    cb(EconomyCategoriesItems)
end)


---Calculate item prizes by item and amount
---@param items table e.g. items={["wool"]=1, ["water"]=2}
EasyEconomy.SellItems=function(items)
    local requestId=EasyCore.Utils.Guid()
    if EasyCore.Utils.CheckTableCountNotZero(items) then
        calculationProcessor:SellItemCalculate(items)
        EasyCore.Logger.LogDebug(RessourceName,requestId,"Items were sell calculated for items:"..json.encode(items))
    else
        EasyCore.Logger.LogWarning(RessourceName,requestId,"SellItem: Empty items list was send to CalculateBuyItem!")
    end
end

---Calculate item prizes by item and amount
---@param items table e.g. items={["wool"]=1, ["water"]=2}
EasyEconomy.BuyItems=function(items)
    local requestId=EasyCore.Utils.Guid()
    if EasyCore.Utils.CheckTableCountNotZero(items) then
        calculationProcessor:BuyItemCalculate(items)
        EasyCore.Logger.LogDebug(RessourceName,requestId,"Items were buy calculated for items:"..json.encode(items))
    else
        EasyCore.Logger.LogWarning(RessourceName,requestId,"BuyItems: Empty items list was send to CalculateBuyItem!")
    end
end


--#region Hooks

EasyEconomy.RegisterHook = function(event, cb)
    return economyHookProcessor:RegisterEventHook(event, cb)
end

EasyEconomy.RemoveHook =function(id)
	economyHookProcessor:RemoveResourceHooks(GetInvokingResource() or GetCurrentResourceName(), id)
end

AddEventHandler('onResourceStop', economyHookProcessor:RemoveResourceHooks())
--#endregion





local economyClientRepository=EconomyClientRepository:new()


---get itemprizes
---@param items table e.g. items={'water','apple'} or items={} ->getAllItems or items=nil->getAllItems
---@return table e.g. returnResult={['water']={EconomyLabel='Water', "Category": "Default", CurrentBuyPrize=100, CurrentSellPrize=20}, ['apple']={EconomyLabel='Apple', "Category": "Default", CurrentBuyPrize=110, CurrentSellPrize=50}}
EasyEconomy.GetEconomyItems=function(items)
    local requestId=EasyCore.Utils.Guid()
    local result=economyClientRepository:LoadItemPrizes(requestId, items)
    return result
end

---@class EconomyRepository
---@type EconomyRepository

EconomyRepository={}
EconomyRepository.__index = EconomyRepository
--#region Konstruktor

function EconomyRepository:new()
    local economyRepository = {}
    setmetatable(economyRepository, self)

    return economyRepository
end

--#endregion

--- UpdateItemBuyPrizes and sell prizes
---@param items table<string,EconomyItem>
function EconomyRepository:UpdateItemInfluencesOnPrizes(items)
    local queries = GenerateItemUpdateQueries(items)
    EasyCore.DB.QueriesTransactionExecut(queries)
end

function GenerateItemUpdateQueries(items)
    local result={}
    for k,v in pairs(items) do
        table.insert(result, {DBHelper.UpdateHelper.Update_Itemprizes:format(v.CurrentSellPrize, v.CurrentBuyPrize, k), {}})
    end
    return result
end

function EconomyRepository:RefreshReadEconomyItems()
    ReadEconomyItems=EasyCore.Utils.DeepClone(CalculationEconomyItems)
    for k,v in pairs(ReadEconomyItems) do
        EconomyItem:SetMetaTable(v)
    end
end

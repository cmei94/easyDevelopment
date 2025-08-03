---@class EconomyCalculationProcessor
---@type EconomyCalculationProcessor

EconomyCalculationProcessor={}

---@type EconomyRepository
local economyRepository = EconomyRepository:new()
local economyHookProcessor= EconomyHookProcessor:new()

--#region Konstruktor

function EconomyCalculationProcessor:new()
    local economyCalculationProcessor = {}
    setmetatable(economyCalculationProcessor, self)
    self.__index = self
    return economyCalculationProcessor
end

--#endregion

--- Processor methode for calculate new prizes if some items are buyed
---@param requestItems table of string  to amount e.g. {"water"=2}
function EconomyCalculationProcessor:BuyItemCalculate(requestItems)
    local shouldCalculatedItems=CalculateShouldCalculatedItems(requestItems)
    
    if EasyCore.Utils.CheckTableCountNotZero(shouldCalculatedItems) then
        --Calculate and add change
        for kSI,vSI in pairs(shouldCalculatedItems) do
            local amount = requestItems[kSI] 
            for kI,vI in pairs(vSI) do
                if kI==kSI then --buyed Item influence themself
                    vI:CalculateSELFBuy(amount)
                else --not buyed Item will be influenced
                    vI:CalculateBuy(amount)
                end
            end
        end
        --Create Itemsllist for query generate
        local queryGenerateList={}
        for kSI,vSI in pairs(shouldCalculatedItems) do
            for kI,vI in pairs(vSI) do
                queryGenerateList[kI]=vI
            end
        end
        economyRepository:UpdateItemInfluencesOnPrizes(queryGenerateList)
        if not Config.Features.RefreshPublicEconomyItems.Enable then
            economyRepository:RefreshReadEconomyItems()
            economyHookProcessor:TriggerEventHooks("refreshReadEconomyItems",{WasRefreshed=true, TrigeredBy="BuyItem"})
        end
    end
    

end


---Processor methode for calculate new prizes if some items are selled
---@param requestItems table of string  to amount e.g. {"water"=2}
function EconomyCalculationProcessor:SellItemCalculate(requestItems)
    local shouldCalculatedItems=CalculateShouldCalculatedItems(requestItems)
    if EasyCore.Utils.CheckTableCountNotZero(shouldCalculatedItems) then
        --Calculate and add change
        for kSI,vSI in pairs(shouldCalculatedItems) do
            local amount = requestItems[kSI] 
            for kI,vI in pairs(vSI) do
                if kI==kSI then --buyed Item influence themself
                    vI:CalculateSELFSell(amount)
                else --not buyed Item will be influenced
                    vI:CalculateSell(amount)
                end
            end
        end
        --Create Itemsllist for query generate
        local queryGenerateList={}
        for kSI,vSI in pairs(shouldCalculatedItems) do
            for kI,vI in pairs(vSI) do
                queryGenerateList[kI]=vI
            end
        end
        economyRepository:UpdateItemInfluencesOnPrizes(queryGenerateList)
        if not Config.Features.RefreshPublicEconomyItems.Enable then
            economyRepository:RefreshReadEconomyItems()
            economyHookProcessor:TriggerEventHooks("refreshReadEconomyItems",{WasRefreshed=true, TrigeredBy="SellItem"})
        end
    end
end


function CalculateShouldCalculatedItems(requestItems)
    local shouldCalculatedItems = {}

    for k, v in pairs(requestItems) do
        if CalculationEconomyItems[k] then
            local willCalculateItems = GetInfluenceItems(CalculationEconomyItems[k])
            if EasyCore.Utils.CheckTableCountNotZero(willCalculateItems) then
                willCalculateItems[k] = CalculationEconomyItems[k]
                shouldCalculatedItems[k] = willCalculateItems
            end
        end
    end

    return shouldCalculatedItems
end


--- returns Items which will be influenced by this item
---@param calculationItem EconomyItem
---@return table<EconomyItem> 
function GetInfluenceItems(calculationItem)
    local result={[calculationItem.ItemName]=calculationItem}
    if EasyCore.Utils.CheckTableCountNotZero(calculationItem.Influence) and (EasyCore.Utils.CheckTableCountNotZero(calculationItem.Influence.InfluenceToCategories) or EasyCore.Utils.CheckTableCountNotZero(calculationItem.Influence.InfluenceToItems)) then
        if EasyCore.Utils.CheckTableCountNotZero(calculationItem.Influence.InfluenceToItems) then
            for k,v in pairs(calculationItem.Influence.InfluenceToItems) do
                if CalculationEconomyItems[v] then
                    result[v]=CalculationEconomyItems[v]
                end
            end
        end
        if EasyCore.Utils.CheckTableCountNotZero(calculationItem.Influence.InfluenceToCategories) then
            for kCI,vCI in pairs(calculationItem.Influence.InfluenceToCategories) do
                if EconomyCategoriesItems[vCI] and EasyCore.Utils.CheckTableCountNotZero(EconomyCategoriesItems[vCI]) then
                    for kECI,vECI in pairs(EconomyCategoriesItems[vCI]) do
                        if CalculationEconomyItems[vECI] then
                            result[vECI]=CalculationEconomyItems[vECI]
                        end
                    end
                end
            end
        end
    elseif EasyCore.Utils.CheckTableCountNotZero(calculationItem.Category) and EasyCore.Utils.CheckTableCountNotZero(calculationItem.Category.Influence) and EasyCore.Utils.CheckTableCountNotZero(calculationItem.Category.Influence.InfluenceToCategories) then
        for kCI,vCI in pairs(calculationItem.Category.Influence.InfluenceToCategories) do
            if EconomyCategoriesItems[vCI] and EasyCore.Utils.CheckTableCountNotZero(EconomyCategoriesItems[vCI]) then
                for kECI,vECI in pairs(EconomyCategoriesItems[vCI]) do
                    if CalculationEconomyItems[vECI] then
                        result[vECI]=CalculationEconomyItems[vECI]
                    end
                end
            end
        end
    else
        if EasyCore.Utils.CheckTableCountNotZero(EconomyCategoriesItems[calculationItem.Category.CategoryName]) then
            for k,v in pairs(EconomyCategoriesItems[calculationItem.Category.CategoryName]) do
                if CalculationEconomyItems[v] then
                    result[v]=CalculationEconomyItems[v]
                end
            end
        end
    end
    return result
end
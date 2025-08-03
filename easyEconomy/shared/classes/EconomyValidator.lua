---@class EconomyValidator

EconomyValidator={}
EconomyValidator.__index = EconomyValidator
--#region Konstruktor

function EconomyValidator:new()
    local economyValidationCheck = {}
    setmetatable(economyValidationCheck, self)
    return economyValidationCheck
end

--#endregion

--- func desc
---@param isItemInfluence boolean
---@param influenceDatas table
---@param categories table of type EconomyCategory
---@param items table of type ExonomyItem
---@return boolean , string
function EconomyValidator:CheckInfluenceData(isItemInfluence,influenceDatas,categories,items)
    
    local resultMessage="\n"
    for k,v in pairs(influenceDatas) do
        if isItemInfluence then
            if not items[k] then
                resultMessage=resultMessage..("-->Config.ItemInfluence: Item %s does not exist in database!"):format(k).."\n"
            end
        else
            if not categories[k] then
                resultMessage=resultMessage..("-->Config.CategoryInfluence: Category %s does not exist in database!"):format(k).."\n"
            end
        end
        if EasyCore.Utils.CheckTableCountNotZero(v.InfluenceToCategories) then
            for kCategories,vCategories in pairs(v.InfluenceToCategories) do
                if not categories[vCategories] then
                    if isItemInfluence then
                        resultMessage=resultMessage..("-->Config.ItemInfluence: Item %s: InfluenceToCategories: Category %s does not exist!"):format(k,vCategories).."\n"
                    else
                        resultMessage=resultMessage..("-->Config.CategoryInfluence: Category %s: InfluenceToCategories: Category %s does not exist!"):format(k,vCategories).."\n"
                    end
                end
            end
        end
        if isItemInfluence and EasyCore.Utils.CheckTableCountNotZero(v.InfluenceToItems) then
            for kItems,vItems in pairs(v.InfluenceToItems) do
                if not items[vItems] then
                    resultMessage=resultMessage..("-->Config.ItemInfluence: Item %s: InfluenceToItems: Item %s does not exist!"):format(k,vItems).."\n"
                end
            end
        end
    end
    if resultMessage~="\n" then
        return false, resultMessage
    else
        return true, nil
    end
end
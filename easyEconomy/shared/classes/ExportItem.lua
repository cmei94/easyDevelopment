---@class EconomyExportItem
---@field EconomyLabel string
---@field Category string
---@field CurrentBuyPrize number
---@field CurrentSellPrize number
---@field Weight number

EconomyExportItem = {}

--- Konstruktor
---@param economyItem EconomyItem
function EconomyExportItem:new(economyItem)

    local exportItem = {}

    setmetatable(exportItem, self)
    self.__index = self
    -- Initialisiere die Instanzfelder mit den angegebenen Werten
    exportItem.EconomyLabel=economyItem.ItemLabel
    exportItem.Category=economyItem.Category.CategoryName
    exportItem.CurrentBuyPrize=economyItem.CurrentBuyPrize
    exportItem.CurrentSellPrize=economyItem.CurrentSellPrize
    exportItem:AddInfluenceByJobIfNeeded(economyItem)
    exportItem.CurrentBuyPrize=ESX.Math.Round(exportItem.CurrentBuyPrize)
    exportItem.CurrentSellPrize=ESX.Math.Round(exportItem.CurrentSellPrize)
    exportItem.Weight=economyItem.Weight
    -- Gebe das neue WIrtshcafts category zurück
    return exportItem
end

--- Set object to class
---@param exportItem table
function EconomyExportItem:SetMetaTable(exportItem)
    setmetatable(exportItem, self)
    self.__index = self
end



--- Add job influence
---@param economyItem EconomyItem 
function EconomyExportItem:AddInfluenceByJobIfNeeded(economyItem)
    if EasyCore.Utils.CheckTableCountNotZero(economyItem.Influence) and EasyCore.Utils.CheckTableCountNotZero(economyItem.Influence.InfluenceByJob) then
        local sellValueAddInfluence=0
        local buyValueAddInfluence=0
        for k,v in pairs(economyItem.Influence.InfluenceByJob) do
            ---@type EconomyInfluenceByJob
            local jobOnDutyInfo = NeededJobOnDutyCount[k]
            if jobOnDutyInfo then
                if jobOnDutyInfo>=v.Count then
                    sellValueAddInfluence=sellValueAddInfluence+v.SellPriceInfluence
                    buyValueAddInfluence=buyValueAddInfluence+v.BuyPriceInfluence
                end
            end
        end
        self.CurrentSellPrize = self.CurrentSellPrize+sellValueAddInfluence
        self.CurrentBuyPrize = self.CurrentBuyPrize+buyValueAddInfluence

    elseif EasyCore.Utils.CheckTableCountNotZero(economyItem.Category.Influence) and EasyCore.Utils.CheckTableCountNotZero(economyItem.Category.Influence.InfluenceByJob) then
        local sellValueAddInfluence=0
        local buyValueAddInfluence=0
        ---@type EconomyInfluenceByJob
        for k,v in pairs(economyItem.Category.Influence.InfluenceByJob) do
            local jobOnDutyInfo = NeededJobOnDutyCount[k]
            if jobOnDutyInfo then
                if jobOnDutyInfo>=v.Count then
                    sellValueAddInfluence=sellValueAddInfluence+v.SellPriceInfluence
                    buyValueAddInfluence=buyValueAddInfluence+v.BuyPriceInfluence
                end
            end
        end

        self.CurrentSellPrize = self.CurrentSellPrize+sellValueAddInfluence
        self.CurrentBuyPrize = self.CurrentBuyPrize+buyValueAddInfluence
    end
end
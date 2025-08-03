---@class EconomyItem
---@field ItemName string
---@field ItemLabel string
---@field Category EconomyCategory
---@field MinSellPrize number
---@field DefaultSellPrize number
---@field MaxSellPrize number
---@field MinBuyPrize number
---@field DefaultBuyPrize number
---@field MaxBuyPrize number
---@field ChangePrizeValue number
---@field CurrentSellPrize number
---@field CurrentBuyPrize number
---@field UpdateTimestamp number
---@field ResetTimestamp number
---@field Influence EconomyItemInfluence
---@field Weight number
---@type EconomyItem


-- Eine Klasse für ein WirtschaftsItem
EconomyItem = {}
EconomyItem.__index = EconomyItem


--- Class Constructor
---@param databaseObject table
---@param categoryObject EconomyCategory
function EconomyItem:new(databaseObject, categoryObject, inventoryItemInfos)

  local economyItem = {}

  setmetatable(economyItem, self)
  -- Initialisiere die Instanzfelder mit den angegebenen Werten
  economyItem.ItemName = databaseObject.item
  economyItem.ItemLabel = databaseObject.label
  economyItem.Category = categoryObject
  economyItem.MinSellPrize = databaseObject.min_sell_prize
  economyItem.DefaultSellPrize = databaseObject.default_sell_prize
  economyItem.MaxSellPrize = databaseObject.max_sell_prize
  economyItem.MinBuyPrize = databaseObject.min_buy_prize
  economyItem.DefaultBuyPrize = databaseObject.default_buy_prize
  economyItem.MaxBuyPrize = databaseObject.max_buy_prize
  economyItem.ChangePrizeValue = databaseObject.change_prize_value
  economyItem.CurrentSellPrize = databaseObject.current_sell_prize
  economyItem.CurrentBuyPrize = databaseObject.current_buy_prize
  economyItem.UpdateTimestamp = databaseObject.update_timestamp
  economyItem.ResetTimestamp = databaseObject.reset_timestamp
  economyItem.Weight = 0.0
  if inventoryItemInfos and inventoryItemInfos.weight then
    economyItem.Weight = inventoryItemInfos.weight
  end
  -- Gebe das neue Kontoobjekt zurück
  return economyItem
end

--- Set object to class
---@param economyItem table
function EconomyItem:SetMetaTable(economyItem)
    setmetatable(economyItem, self)
end

function EconomyItem:ToExportItem()
    return EconomyExportItem:new(self)
end

function EconomyItem:CalculateSELFBuy(amount)
  local newBuyPrize=self.CurrentBuyPrize+(self.ChangePrizeValue*amount)
  local newSellPrize=self.CurrentSellPrize+(self.ChangePrizeValue*amount)
  local checkedBuyPrize=self:CheckMinMaxBuyPrize(newBuyPrize)
  local checkedSellPrize=self:CheckMinMaxSellPrize(newSellPrize)
  self.CurrentBuyPrize=checkedBuyPrize
  self.CurrentSellPrize=checkedSellPrize
end

function EconomyItem:CalculateBuy(amount)
  local newBuyPrize=self.CurrentBuyPrize-(self.ChangePrizeValue*amount)
  local newSellPrize=self.CurrentSellPrize-(self.ChangePrizeValue*amount)
  local checkedBuyPrize=self:CheckMinMaxBuyPrize(newBuyPrize)
  local checkedSellPrize=self:CheckMinMaxSellPrize(newSellPrize)
  self.CurrentBuyPrize=checkedBuyPrize
  self.CurrentSellPrize=checkedSellPrize
end

function EconomyItem:CalculateSELFSell(amount)
  local newBuyPrize=self.CurrentBuyPrize-(self.ChangePrizeValue*amount)
  local newSellPrize=self.CurrentSellPrize-(self.ChangePrizeValue*amount)
  local checkedBuyPrize=self:CheckMinMaxBuyPrize(newBuyPrize)
  local checkedSellPrize=self:CheckMinMaxSellPrize(newSellPrize)
  self.CurrentBuyPrize=checkedBuyPrize
  self.CurrentSellPrize=checkedSellPrize
end

function EconomyItem:CalculateSell(amount)
  local newBuyPrize=self.CurrentBuyPrize+(self.ChangePrizeValue*amount)
  local newSellPrize=self.CurrentSellPrize+(self.ChangePrizeValue*amount)
  local checkedBuyPrize=self:CheckMinMaxBuyPrize(newBuyPrize)
  local checkedSellPrize=self:CheckMinMaxSellPrize(newSellPrize)
  self.CurrentBuyPrize=checkedBuyPrize
  self.CurrentSellPrize=checkedSellPrize
end

function EconomyItem:CheckMinMaxBuyPrize(buyPrize)
  if buyPrize<self.MinBuyPrize then
    return self.MinBuyPrize
  end
  if buyPrize>self.MaxBuyPrize then
    return self.MaxBuyPrize
  end
  return buyPrize
end

function EconomyItem:CheckMinMaxSellPrize(sellPrize)
  if sellPrize<self.MinSellPrize then
    return self.MinSellPrize
  end
  if sellPrize>self.MaxSellPrize then
    return self.MaxSellPrize
  end
  return sellPrize
end
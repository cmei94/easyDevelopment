---@class EconomyCategory
---@field CategoryName string
---@field MinSellPrize number
---@field DefaultSellPrize number
---@field MaxSellPrize number
---@field MinBuyPrize number
---@field DefaultBuyPrize number
---@field MaxBuyPrize number
---@field ChangePrizeValue number
---@field Influence EconomyCategoryInfluence
---@type EconomyCategory

EconomyCategory = {}


--- Konstruktor
---@param databaseObject table
function EconomyCategory:new(databaseObject)

  local economyCategory = {}

  setmetatable(economyCategory, self)
  self.__index = self
  -- Initialisiere die Instanzfelder mit den angegebenen Werten
  economyCategory.CategoryName = databaseObject.category_name
  economyCategory.MinSellPrize = databaseObject.min_sell_prize
  economyCategory.DefaultSellPrize = databaseObject.default_sell_prize
  economyCategory.MaxSellPrize = databaseObject.max_sell_prize
  economyCategory.MinBuyPrize = databaseObject.min_buy_prize
  economyCategory.DefaultBuyPrize = databaseObject.default_buy_prize
  economyCategory.MaxBuyPrize = databaseObject.min_buy_prize
  economyCategory.ChangePrizeValue = databaseObject.change_prize_value

  -- Gebe das neue WIrtshcafts category zurück
  return economyCategory
end


function EconomyCategory:SetMetaTable(economyItem)
    setmetatable(economyItem, self)
end

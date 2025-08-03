---@class EconomyItemInfluence
---@field InfluenceToCategories table oof type string
---@field InfluenceToItems table of type string
---@field InfluenceByJob table of type EconomyInfluenceByJob

EconomyItemInfluence = {}


--- Konstruktor
---@param configItemInfluence table
function EconomyItemInfluence:new(configItemInfluence)

    local economyItemInfluence = {}

    setmetatable(economyItemInfluence, self)
    self.__index = self
    -- Initialisiere die Instanzfelder mit den angegebenen Werten
    economyItemInfluence.InfluenceToCategories=configItemInfluence.InfluenceToCategories
    economyItemInfluence.InfluenceToItems=configItemInfluence.InfluenceToItems or {}
    local influenceByJob={}
    if EasyCore.Utils.CheckTableCountNotZero(configItemInfluence.InfluenceByJob) then
        for k,v in pairs(configItemInfluence.InfluenceByJob) do
            influenceByJob[k]=EconomyInfluenceByJob:new(k,v)
        end
    end
    economyItemInfluence.InfluenceByJob=influenceByJob

    
    return economyItemInfluence
end

--- Set object to class meta
---@param economyItemInfluence table
function EconomyItemInfluence:SetMetaTable(economyItemInfluence)
    setmetatable(economyItemInfluence, self)
    self.__index = self
end
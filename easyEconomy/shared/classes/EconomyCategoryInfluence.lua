---@class EconomyCategoryInfluence
---@field InfluenceToCategories table of type string
---@field InfluenceByJob table of type EconomyInfluenceByJob

EconomyCategoryInfluence = {}


--- Konstruktor
---@param configCategoryInfluence table
function EconomyCategoryInfluence:new(configCategoryInfluence)

    local economyCategoryInfluence = {}

    setmetatable(economyCategoryInfluence, self)
    self.__index = self
    -- Initialisiere die Instanzfelder mit den angegebenen Werten
    economyCategoryInfluence.InfluenceToCategories=configCategoryInfluence.InfluenceToCategories
    
    local influenceByJob={}
    if EasyCore.Utils.CheckTableCountNotZero(configCategoryInfluence.InfluenceByJob) then
        for k,v in pairs(configCategoryInfluence.InfluenceByJob) do
            influenceByJob[k]=EconomyInfluenceByJob:new(k,v)
        end
    end
    economyCategoryInfluence.InfluenceByJob=influenceByJob


    return economyCategoryInfluence
end

--- Set object to class
---@param economyCategoryInfluence table
function EconomyCategoryInfluence:SetMetaTable(economyCategoryInfluence)
    setmetatable(economyCategoryInfluence, self)
    self.__index = self
end
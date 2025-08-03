---@class EconomyInfluenceByJob
---@field JobDbName string
---@field Count number
---@field SellPriceInfluence number
---@field BuyPriceInfluence number

EconomyInfluenceByJob = {}

--- Konstruktor
---@param configInfluenceByJob table
function EconomyInfluenceByJob:new(configJob,configInfluenceByJob)

    local economyInfluenceByJob = {}

    setmetatable(economyInfluenceByJob, self)
    self.__index = self
    -- Initialisiere die Instanzfelder mit den angegebenen Werten

    economyInfluenceByJob.JobDbName=configJob
    economyInfluenceByJob.Count=configInfluenceByJob.Count
    economyInfluenceByJob.SellPriceInfluence=configInfluenceByJob.SellPriceInfluence
    economyInfluenceByJob.BuyPriceInfluence=configInfluenceByJob.BuyPriceInfluence

    -- Gebe das neue WIrtshcafts category zurück
    return economyInfluenceByJob
end

--- Set object to class meta
---@param economyInfluenceByJob table
function EconomyInfluenceByJob:SetMetaTable(economyInfluenceByJob)
    setmetatable(economyInfluenceByJob, self)
    self.__index = self
end
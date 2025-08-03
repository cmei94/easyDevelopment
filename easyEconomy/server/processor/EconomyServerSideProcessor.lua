---@class EconomyServerSideProcessor
---@type EconomyServerSideProcessor

EconomyServerSideProcessor={}

--#region Konstruktor

function EconomyServerSideProcessor:new()
    local economyServerSideProcessor = {}
    setmetatable(economyServerSideProcessor, self)
    self.__index = self
    return economyServerSideProcessor
end

--#endregion


function EconomyServerSideProcessor:GetExportItems(items)
    local result={}
    if EasyCore.Utils.CheckTableCountNotZero(items) then
        result = GetReturnSelectedItemsList(items)
    else
        result = GetReturnAllItemsList()
    end
    return result
end

function GetReturnAllItemsList()
    local result={}
    local totalJobs={}
    for ecoK,ecoV in pairs(ReadEconomyItems) do
        result[ecoK]=ecoV:ToExportItem()
    end
    return result
end

function GetReturnSelectedItemsList(items)
    local result={}
    for _,v in pairs(items) do
        ---@type EconomyItem
        local economyItem=ReadEconomyItems[v]
        if economyItem then
            result[v]=economyItem:ToExportItem()
        end
    end
    return result
end
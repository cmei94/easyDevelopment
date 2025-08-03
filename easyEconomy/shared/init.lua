EasyEconomy={}

exports('GetEconomySystem', function()
    return EasyEconomy
end)

EasyCore = exports["easyCore"]:getCore()
ESX=EasyCore.FrameworkHelper.Framework
RessourceName=GetCurrentResourceName()

if IsDuplicityVersion() then--if true it is server side
    ServerInit=false
    GitRepositoryPath="easyEconomy"
    --Influence tables
    function GetCategoryInfluences()
        local result={}
        if EasyCore.Utils.CheckTableCountNotZero(Config.CategoryInfluence) then
            for k,v in pairs(Config.CategoryInfluence) do
                result[k]=EconomyCategoryInfluence:new(v)
            end
        end
        return result
    end
    CategoryInfluences=GetCategoryInfluences()
    function GetItemInfluences()
        local result={}
        if EasyCore.Utils.CheckTableCountNotZero(Config.ItemInfluence) then
            for k,v in pairs(Config.ItemInfluence) do
                result[k]=EconomyItemInfluence:new(v)
            end
        end
        return result
    end
    ItemInfluences=GetItemInfluences()
    NeededJobOnDutyCount={}
else--clientSide
    ClientInit=false
end

--both
---@type table<EconomyCategory>
ActualEconomyCategories={}
---@type table<EconomyItem>
ReadEconomyItems={}
---@type table<EconomyItem>
CalculationEconomyItems={}
---@type table<string>
EconomyCategoriesItems={}



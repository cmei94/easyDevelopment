Citizen.CreateThread(function ()
    local requestId=EasyCore.Utils.Guid()
    local p = promise.new()
    ESX.TriggerServerCallback("EasyEconomy:GetEconomyCategoryItems", function(cb)
        p:resolve(cb)
    end, {RequestId=requestId})
    local result = Citizen.Await(p)
    EconomyCategoriesItems=result
    ClientInit=true
end)
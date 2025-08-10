local orderProcessor= OrderProcessor:new()

Citizen.CreateThread(function()
    Wait(500)

    RegisterServerEvent("easyShop:server:GetInitData")
    AddEventHandler("easyShop:server:GetInitData", function()
        local src=source
        while not NeededJobOnDutyCount do
            Wait(200)
        end
        TriggerClientEvent("easyShop:client:UpdateJobsOnDuty", src, NeededJobOnDutyCount)
    end)
end)

local function errorHandler(err)
    EasyCore.Logger.ErrorHandler(RessourceName, requestId, err)
end

ESX.RegisterServerCallback("easyShop:OrderToPlayer", function(source, cb, args)
    local result=false
    local requestId=args.RequestId
    local sellItems=args.Items.Sell
    local buyItems=args.Items.Buy
    local playerData=EasyCore.FrameworkHelper.GetPlayerData(source)
    local takeOrGiveMoney={}

    local function errorHandler(err)
        EasyCore.Logger.ErrorHandler(RessourceName, requestId, err)
    end

    if sellItems and EasyCore.Utils.CheckTableCountNotZero(sellItems) then
        for k,v in pairs(sellItems) do
            if EasyCore.Utils.CheckTableCountNotZero(v) then
                if not takeOrGiveMoney[k] then
                    takeOrGiveMoney[k]=0
                end
                for ks,vs in pairs(v) do
                    takeOrGiveMoney[k]=takeOrGiveMoney[k]-vs.Amount*vs.Prize
                end
            end
        end
    end

    if buyItems and EasyCore.Utils.CheckTableCountNotZero(buyItems) then
        for k,v in pairs(buyItems) do
            if EasyCore.Utils.CheckTableCountNotZero(v) then
                if not takeOrGiveMoney[k] then
                    takeOrGiveMoney[k]=0
                end
                for kb,vb in pairs(v) do
                    takeOrGiveMoney[k]=takeOrGiveMoney[k]+vb.Amount*vb.Prize
                end
            end
        end
    end

    local result, _ = xpcall(function()
        orderProcessor:GiveOrTakePlayerMoney(requestId, playerData, takeOrGiveMoney)
        orderProcessor:GiveOrTakeInventoryItemsMoney(requestId, playerData, sellItems, buyItems)
        orderProcessor:ProcessEconomyChange(requestId, sellItems, buyItems)
    end, errorHandler)
    
    return cb(result)
end)


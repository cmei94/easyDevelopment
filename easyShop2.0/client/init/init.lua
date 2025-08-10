Wait(500)

RegisterNetEvent("easyShop:client:UpdateJobsOnDuty", function(NeedJobsDutyCount)
    NeededJobOnDutyCount=NeedJobsDutyCount
end)

TriggerServerEvent("easyShop:server:GetInitData")
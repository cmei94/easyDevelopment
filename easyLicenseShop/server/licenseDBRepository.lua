ActualLicenseDB = {}

AddEventHandler('easyLicenseShop:databaseReady', function()
    EasyCore.Logger.LogInfo("easyLicenseShop", "DB-Sync", "Database is ready, loading licenses now.")
    LoadLicensesFromDB()
    CheckPlayermustPayLicense()
end)

function LoadLicensesFromDB()
    local result = EasyCore.DB.QueryExecut(DBHelper.SelectHelper.Select_AllLicenses, {}).QueryResult
    if result and #result > 0 then
        for _, license in ipairs(result) do
            if not ActualLicenseDB[license.identifier] then
                ActualLicenseDB[license.identifier] = {}
            end
            ActualLicenseDB[license.identifier][license.license_type] = {
                Timestamp = license.timestamp,
                LicenseName = license.license_name,
                Price = license.price,
                HourInterval = license.hour_interval
            }
        end
    end
end

function CheckPlayermustPayLicense()
    while true do
        Citizen.Wait(3600000) -- Check every hour
        local currentTime = os.time()
        local xPlayers = ESX.GetExtendedPlayers()

        for _, xPlayer in pairs(xPlayers) do
            CheckPlayerMustPay(xPlayer, currentTime)
        end
    end
end

function CheckPlayerMustPay(xPlayer, currentTime)
    local identifier = xPlayer.getIdentifier()
    local playerLicenses = ActualLicenseDB[identifier]

    if not playerLicenses then return end
    
    for licenseType, licenseData in pairs(playerLicenses) do
        if licenseData.HourInterval and licenseData.Timestamp then
            local timeElapsed = currentTime - licenseData.Timestamp
            local intervalInSeconds = licenseData.HourInterval * 3600

            if timeElapsed >= intervalInSeconds then
                if xPlayer.getAccount("bank").money >= licenseData.Price then
                    xPlayer.removeAccountMoney("bank", licenseData.Price)
                    xPlayer.showNotification(("Deine %s Gebühr ist fällig. Dir wurden ~g~%s$~s~ von deinem Bankkonto abgezogen."):format(licenseData.LicenseName, licenseData.Price))
                    licenseData.Timestamp = currentTime
                    EasyCore.DB.QueryExecut(DBHelper.UpdateHelper.Update_LicenseTimestamp, {
                        ['@timestamp'] = currentTime,
                        ['@identifier'] = identifier,
                        ['@license_type'] = licenseType
                    })
                else
                    RemoveLicense(xPlayer, licenseType)
                    xPlayer.showNotification(("~r~Deine %s Gebühr ist fällig. Dir wurde aufgrund fehlenden Geldes die Lizenz entzogen."):format(licenseData.LicenseName, licenseData.Price))
                end
            end
        end
    end
end

ESX.RegisterServerCallback("easyLicenseShop:GetActualLicenseInfosForPlayer", function(source, cb, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentShopLicenseInfo = ActualLicenseDB[xPlayer.getIdentifier()]
    cb(currentShopLicenseInfo or {})
end)

RegisterNetEvent("easyLicenseShop:BuyAndAddLicenseToPlayer", function(licenseInfo, cancelLicenses)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local price = licenseInfo.Price

    if xPlayer.getAccount("money").money >= price then
        xPlayer.removeAccountMoney("money", price)
        AddLicense(xPlayer, licenseInfo, cancelLicenses)
    elseif xPlayer.getAccount("bank").money >= price then
        xPlayer.removeAccountMoney("bank", price)
        AddLicense(xPlayer, licenseInfo, cancelLicenses)
    else
        xPlayer.showNotification("~r~Du hast nicht genug Geld.")
    end
end)

function AddLicense(xPlayer, licenseInfo, cancelLicenses)
    local identifier = xPlayer.getIdentifier()

    if ActualLicenseDB[identifier] and ActualLicenseDB[identifier][licenseInfo.LicenseType] then
        EasyCore.Logger.LogWarning(RessourceName, "AddLicense",
            ("Player %s (Identifier: %s) is trying to purchase license '%s' which they already own according to 'ActualLicenseDB'. This might indicate a UI issue or a client-side logic error."):format(xPlayer.getName(), identifier, licenseInfo.LicenseType))
    end

    TriggerEvent("esx_license:addLicense", xPlayer.source, licenseInfo.LicenseType)

    if not ActualLicenseDB[identifier] then
        ActualLicenseDB[identifier] = {}
    end

    local newLicenseData = {
        Timestamp = os.time(),
        LicenseName = licenseInfo.LicenseName,
        Price = licenseInfo.Price,
        HourInterval = licenseInfo.IntervalInHours
    }

    ActualLicenseDB[identifier][licenseInfo.LicenseType] = newLicenseData
    
    EasyCore.DB.QueryExecut(DBHelper.InsertHelper.Insert_License, {
        ['@identifier'] = identifier,
        ['@license_type'] = licenseInfo.LicenseType,
        ['@timestamp'] = newLicenseData.Timestamp,
        ['@license_name'] = newLicenseData.LicenseName,
        ['@price'] = newLicenseData.Price,
        ['@hour_interval'] = newLicenseData.HourInterval
    })

    if cancelLicenses and #cancelLicenses > 0 then
        for _, licenseToCancel in ipairs(cancelLicenses) do
            RemoveLicense(xPlayer, licenseToCancel)
        end
    end

    xPlayer.showNotification(("Deine %s Lizenz wurde für dich ausgestellt."):format(licenseInfo.LicenseName))
end

function RemoveLicense(xPlayer, licenseType)
    local identifier = xPlayer.getIdentifier()
    if ActualLicenseDB[identifier] and ActualLicenseDB[identifier][licenseType] then
        ActualLicenseDB[identifier][licenseType] = nil
    end

    EasyCore.DB.QueryExecut(DBHelper.DeleteHelper.Delete_License, {
        ['@identifier'] = identifier,
        ['@license_type'] = licenseType
    })
    
    RemoveLicenseByDB(identifier, licenseType)
end

RegisterNetEvent("easyLicenseShop:RemoveLicenseFromPlayer", function(licenseType, name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    RemoveLicense(xPlayer, licenseType)
    xPlayer.showNotification(("Deine %s Lizenz wurde storniert."):format(name))
end)

function RemoveLicenseByDB(identifier, licenseType)
    EasyCore.DB.QueryExecut('DELETE FROM user_licenses WHERE type = @license_type AND owner = @identifier', {
        ['@license_type'] = licenseType,
        ['@identifier'] = identifier
    })
end
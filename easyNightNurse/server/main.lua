---
--- Serverseitige Logik für easyNightNurse.
--- Verwaltet den Status der Behandlungsbetten und die Zahlungsabwicklung.
---
---
--=================================================================================
--== CALLBACKS
--=================================================================================

---
--- Überprüft, ob die Nachtschwester verfügbar ist.
--- Dies hängt von der Anzahl der Mediziner im Dienst ab, wie in der Config definiert.
---@param source number Die Server-ID des anfragenden Spielers.
---@param cb function Die Callback-Funktion, die das Ergebnis empfängt.
---@param neededJobs table Eine Liste der zu zählenden Job-Namen (z.B. {"ambulance"}).
---@param onDutyCount number Die Anzahl an Spielern, ab der die Station deaktiviert wird.
---@return boolean true, wenn die Station benutzbar ist, sonst false.
---
ESX.RegisterServerCallback('easyNightNurse:isUsable', function(source, cb, neededJobs, onDutyCount)
    local jobCounts = EasyCore.FrameworkHelper.GetJobsOnDutyCount(neededJobs)
    local totalOnDuty = 0
    for _, count in pairs(jobCounts) do
        totalOnDuty = totalOnDuty + count
    end
    cb(totalOnDuty < onDutyCount)
end)

---
--- Findet ein freies Bett an einer Station, markiert es als belegt und gibt den Schlüssel zurück.
---@param source number Die Server-ID des anfragenden Spielers.
---@param cb function Die Callback-Funktion, die den Schlüssel des Bettes empfängt.
---@param nurseKey string Der Schlüssel der Krankenschwester-Station.
---@return string|boolean Den Schlüssel des freien Bettes oder false, wenn kein Bett frei ist.
---
ESX.RegisterServerCallback('easyNightNurse:getFreeBed', function(source, cb, nurseKey)
    if not AllUsedBeds[nurseKey] then
        cb(false)
        return
    end

    for bedKey, isUsed in pairs(AllUsedBeds[nurseKey]) do
        if not isUsed then
            AllUsedBeds[nurseKey][bedKey] = true
            cb(bedKey)
            return
        end
    end
    cb(false)
end)

---
--- Überprüft, ob der Spieler genug Geld (Bargeld + Bank) für eine Transaktion hat.
---@param source number Die Server-ID des anfragenden Spielers.
---@param cb function Die Callback-Funktion, die das Ergebnis empfängt.
---@param amount number Der benötigte Geldbetrag.
---@return boolean true, wenn der Spieler genug Geld hat, sonst false.
---
ESX.RegisterServerCallback('easyNightNurse:checkMoney', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalMoney = xPlayer.getAccount('bank').money + xPlayer.getAccount('money').money
    cb(totalMoney >= amount)
end)


--=================================================================================
--== EVENTS
--=================================================================================

---
--- Gibt ein zuvor belegtes Bett wieder frei.
---@param requestId string Die einzigartige ID des Behandlungsvorgangs.
---@param nurseKey string Der Schlüssel der Krankenschwester-Station.
---@param bedKey string Der Schlüssel des Bettes, das freigegeben wird.
---
RegisterNetEvent('easyNightNurse:freeBed', function(requestId, nurseKey, bedKey)
    if AllUsedBeds[nurseKey] and AllUsedBeds[nurseKey][bedKey] then
        AllUsedBeds[nurseKey][bedKey] = false
        EasyCore.Logger.LogDebug(RessourceName, requestId, ("Bed %s at %s has been freed."):format(bedKey, nurseKey))
    end
end)

---
--- Zieht dem Spieler das Geld für die Behandlung ab. Priorisiert Bankguthaben.
---@param requestId string Die einzigartige ID des Behandlungsvorgangs.
---@param amount number Der zu zahlende Betrag.
---@param nurseLabel string Der Name der Station für die Benachrichtigung.
---
RegisterNetEvent('easyNightNurse:payMoney', function(requestId, amount, nurseLabel)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getAccount('bank').money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
    else
        xPlayer.removeAccountMoney('money', amount)
    end
    xPlayer.showNotification(string.format("Dir wurden ~g~$%s~s~ für die Behandlung bei '%s' abgebucht.", amount, nurseLabel))
    EasyCore.Logger.LogDebug(RessourceName, requestId, ("Player %s paid $%s for treatment."):format(xPlayer.identifier, amount))
end)

---
--- Zahlt den Behandlungsbetrag an die in der Config definierten Staatskassen.
---@param requestId string Die einzigartige ID des Behandlungsvorgangs.
---@param amount number Der Gesamtbetrag, der aufgeteilt werden soll.
---@param societies table Eine Liste der Staatskassen-Namen.
---
RegisterNetEvent('easyNightNurse:payToSociety', function(requestId, amount, societies)
    if not Config.Features.EnableSetMoneyToSociety or not societies then return end

    local payPerSociety = ESX.Math.Round(amount / #societies)
    for _, societyName in ipairs(societies) do
        TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
            if account then
                account.addMoney(payPerSociety)
                EasyCore.Logger.LogDebug(RessourceName, requestId, ("Paid $%s to society account: %s"):format(payPerSociety, societyName))
            end
        end)
    end
end)
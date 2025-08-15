---
--- Client-side main logic for easyNightNurse.
--- Manages player interaction, creation of peds/markers, and initiates the treatment process.
---

--=================================================================================
--== LOCAL VARIABLES
--=================================================================================
local IsInTreatment = false
local CurrentNurseKey = nil
local IsNearNurse = false
local TextUiShown = false

--=================================================================================
--== CORE FUNCTIONS
--=================================================================================

---
--- Starts the treatment process when the player interacts.
--- Generates a new requestId for this operation.
---@param nurseKey string The key of the nurse station being interacted with.
---
function BeginTreatment(nurseKey)
    --- Each interaction creates a new, unique ID for tracking purposes.
    local requestId = EasyCore.Utils.Guid()
    local nurse = Config.Nurses[nurseKey]

    if not nurse then return end

    -- Check if enough medics are on duty
    ESX.TriggerServerCallback('easyNightNurse:isUsable', function(isUsable)
        if not isUsable then
            EasyCore.Notifications.Error("Night Nurse", "There are enough medics on duty. Please send a dispatch!", 5000)
            EasyCore.Logger.LogWarning(RessourceName, requestId, "Player tried to use nurse while enough medics were on duty.")
            return
        end

        -- Get the player's health status
        local healthState = Config.ClientFunctions.HealthCheck()
        if not healthState then
            EasyCore.Notifications.Error("Error", "Could not determine your health status.", 5000)
            EasyCore.Logger.LogError(RessourceName, requestId, "Health check returned nil.")
            return
        end

        IsInTreatment = true
        -- The generated requestId is passed to the next function.
        SwitchCaseHealthState(requestId, healthState, nurseKey, nurse)

    end, nurse.DisableCondition.NeededJobs, nurse.DisableCondition.OnDutyCount)
end

---
--- Decides which treatment is necessary based on the health status.
---@param requestId string The unique ID for this treatment process.
---@param healthState table The object containing the player's health status.
---@param nurseKey string The key of the nurse station.
---@param nurse table The configuration table for the nurse.
---
function SwitchCaseHealthState(requestId, healthState, nurseKey, nurse)
    EasyCore.Logger.LogDebug(RessourceName, requestId, ("Player health state: %s (%s/200)"):format(healthState.state, healthState.health))

    if healthState.state == 1 then -- Injured
        EasyCore.Notifications.Info("Night Nurse", "You are injured! Let's get that checked out.", 4000)
        StartHealing(requestId, nurseKey, nurse)
    elseif healthState.state == 2 then -- Dead/Downed
        EasyCore.Notifications.Info("Night Nurse", "Oh dear, that doesn't look good! We'll get you into treatment right away.", 4000)
        StartRevive(requestId, nurseKey, nurse)
    else -- Healthy
        EasyCore.Notifications.Success("Night Nurse", "You are perfectly healthy! What are you doing here?", 4000)
        Wait(3000)
        ResetTreatmentState()
    end
end

---
--- Resets the treatment state, allowing the player to interact again.
---
function ResetTreatmentState()
    IsInTreatment = false
end

--=================================================================================
--== SERVER CALLBACKS
--=================================================================================

---
--- Fetches a free bed from the server for the respective station.
---@param nurseKey string The key of the nurse station.
---@return string|boolean The bed key or false if no bed is available.
---
function GetFreeBed(nurseKey)
    local p = promise.new()
    ESX.TriggerServerCallback('easyNightNurse:getFreeBed', function(bedKey)
        p:resolve(bedKey)
    end, nurseKey)
    return Citizen.Await(p)
end

--=================================================================================
--== THREADS (Markers, Peds, Interaction)
--=================================================================================

---
--- This thread creates all peds, markers, and blips on startup according to the configuration.
---
Citizen.CreateThread(function()
    Wait(1000) -- Wait a bit for everything to load

    for key, nurse in pairs(Config.Nurses) do
        -- Create blip
        if nurse.Blip and nurse.Blip.Enable then
            local blip = AddBlipForCoord(nurse.Position.x, nurse.Position.y, nurse.Position.z)
            SetBlipSprite(blip, nurse.Blip.BlipId)
            SetBlipScale(blip, nurse.Blip.BlipScale)
            SetBlipColour(blip, nurse.Blip.BlipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(nurse.Label)
            EndTextCommandSetBlipName(blip)
        end

        -- Create ped if configured
        if nurse.Display.UsePed then
            local model = GetHashKey(nurse.Display.PedModel)
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(50) end
            
            local ped = CreatePed(4, model, nurse.Position.x, nurse.Position.y, nurse.Position.z - 1.0, nurse.Position.w, false, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            Config.Nurses[key].ped = ped -- Store ped handle for later use
        end
    end
end)

---
--- This thread continuously monitors the player's distance to the stations.
---
Citizen.CreateThread(function()
    while true do
        Wait(500)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestDistance = -1
        local closestNurseKey = nil

        for key, nurse in pairs(Config.Nurses) do
            local distance = #(playerCoords - vector3(nurse.Position.x, nurse.Position.y, nurse.Position.z))
            if closestDistance == -1 or distance < closestDistance then
                closestDistance = distance
                closestNurseKey = key
            end
        end

        if closestDistance ~= -1 and closestDistance < Config.Nurses[closestNurseKey].InteractDistance then
            IsNearNurse = true
            CurrentNurseKey = closestNurseKey
        else
            IsNearNurse = false
            CurrentNurseKey = nil
        end
    end
end)

---
--- This thread handles player interaction (key press) and displays the text UI.
---
Citizen.CreateThread(function()
    while true do
        Wait(5)
        if IsNearNurse and not IsInTreatment then
            if not TextUiShown then
                local nurse = Config.Nurses[CurrentNurseKey]
                local text = string.format("Press [~g~%s~s~] for treatment. Heal: ~g~$%s~s~ | Revive: ~g~$%s~s~",
                    Config.General.InteractKey, nurse.HealingPrice, nurse.RevivePrice)
                
                if Config.Features.UseOkOkTextUi then
                    exports['okokTextUI']:Open(text, 'darkblue', 'left')
                else
                    EasyCore.TextUi.ShowUi(text, 'info')
                end
                TextUiShown = true
            end

            if IsControlJustReleased(0, EasyCore.Utils.Keys[Config.General.InteractKey]) then
                BeginTreatment(CurrentNurseKey)
            end
        elseif TextUiShown then
            if Config.Features.UseOkOkTextUi then
                exports['okokTextUI']:Close()
            else
                EasyCore.TextUi.HideUi()
            end
            TextUiShown = false
        end
    end
end)
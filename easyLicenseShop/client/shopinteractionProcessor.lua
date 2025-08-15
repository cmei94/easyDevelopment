ShowUi=false
TabletIsOpen=false
PlayerProps={}

Citizen.CreateThread(function()
    while true do
        local sleep=300

        if CurrentMarker and not ShowUi and not TabletIsOpen then
            ShowTextUI(("Drücke [%s] zum öffnen des %s-Shops!"):format(Config.Tablet.ShopInteractionKey, CurrentMarker.ShopName))
            ShowUi=true
        elseif CurrentMarker and ShowUi and not TabletIsOpen then
            if IsControlPressed(0, Config.Keys[Config.Tablet.ShopInteractionKey]) then
                HideTextUI()
                TabletIsOpen=true
                ShowUi=false
                OpenTablet()
            end
            sleep=1
        elseif not CurrentMarker and ShowUi then
            CloseShopInteract()
        end
        
        Wait(sleep)
    end
end)




local function StopAnimationAndDeleteTablet()
    ClearPedTasks(PlayerPedId())
    --#region Delete Tablet
    for _,v in pairs(PlayerProps) do
        DeleteEntity(v)
    end
    PlayerProps={}
    --#endregion
end

local function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(Player))
    local modelHash=GetHashKey(prop1)

    if not HasModelLoaded(prop1) then
        while not HasModelLoaded(modelHash) do
            RequestModel(modelHash)
            Wait(10)
        end
    end

    local prop = CreateObject(modelHash, x, y, z+0.1,  true,  true, true)
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(PlayerProps, prop)
    SetModelAsNoLongerNeeded(prop1)
end

local function PlayOpenTabletAnimation()
    if (IsPedInAnyVehicle(PlayerPedId(), true)) then
		return
	end
	local dict = Config.Tablet.Animation.AnimationDictionary  
	local anim = "base"
	RequestAnimDict(dict)
    local prop = Config.Tablet.Animation.PropModel				  
    local propBone = Config.Tablet.Animation.Bone
    AddPropToPlayer(prop, propBone, 0.0, -0.05, 0.0, 20.0, 280.0, 20.0)
    TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 2.0, -1, 1, 0, false, false, false)
end

function LoadNeededInfos()
    local playerData = ESX.GetPlayerData()
    local playerInfos = {}

    playerInfos.Identifier = playerData.identifier
    playerInfos.Accounts = playerData.accounts
    playerInfos.FirstName = playerData.firstName
    playerInfos.LastName = playerData.lastName
    
    local p1 = promise.new()
    ESX.TriggerServerCallback("easyLicenseShop:GetActualLicenseInfosForPlayer", function(cb)
        p1:resolve(cb)
    end)
    local shopPlayerLicenseInfos = Citizen.Await(p1)

    local p2 = promise.new()
    ESX.TriggerServerCallback("esx_license:getLicenses", function(cb)
        p2:resolve(cb)
    end, GetPlayerServerId(PlayerId()))
    local esxLicenses = Citizen.Await(p2)

    playerInfos.Licenses = {}
    
    local esxLicenseMap = {}
    for _, lic in ipairs(esxLicenses) do
        esxLicenseMap[lic.type] = true
    end

    for licenseType, licenseData in pairs(shopPlayerLicenseInfos) do
        if esxLicenseMap[licenseType] then
            playerInfos.Licenses[licenseType] = {
                ExtendedInfos = {
                    LastPayedTimeStamp = licenseData
                }
            }
        else
            EasyCore.Logger.LogWarning(RessourceName, "LoadNeededInfos", 
                ("Inconsistency found: License '%s' exists in the 'easy_licenses' DB but is not reported by 'esx_license'. Please check if the license exists in the 'licenses' table and is spelled correctly."):format(licenseType))
        end
    end

    for licenseType, _ in pairs(esxLicenseMap) do
        if not playerInfos.Licenses[licenseType] then
            playerInfos.Licenses[licenseType] = {}
        end
    end
    
    return playerInfos
end

function OpenTablet()
    local playerInfos = LoadNeededInfos()
    PlayOpenTabletAnimation()
    TabletIsOpen=true
    SetNuiFocus(true,true)
    SendNUIMessage({
        action='openShop',
        playerInfos=playerInfos,
        shopInfos=CurrentMarker
    })
end

--#region closeTablet
function CloseShopInteract()
    StopAnimationAndDeleteTablet()
    HideTextUI()
    CurrentMarker=nil
    ShowUi=false
    TabletIsOpen=false
end

function CloseTablet()
    StopAnimationAndDeleteTablet()
    CloseShopInteract()
end

RegisterNUICallback('buyLicense', function(data, cb) 
    SetNuiFocus(false, false)
    local cancelLicenses = {}
    
    -- Logik für EnableOwnMultipleLicenses: Kündigt andere Lizenzen aus DIESEM Shop
    if not CurrentMarker.ShopInfos.EnableOwnMultipleLicenses then
        local playerData = LoadNeededInfos()
        -- Iteriere durch alle Lizenzen, die der Spieler besitzt
        for licenseOwned, _ in pairs(playerData.Licenses) do
            -- Prüfe, ob die besessene Lizenz in diesem Shop verkauft wird
            if CurrentMarker.ShopInfos.Licenses[licenseOwned] then
                -- Füge sie zur Kündigungsliste hinzu
                table.insert(cancelLicenses, licenseOwned)
            end
        end
    end

    local licenseInfo = {
        LicenseType = data,
        Price = CurrentMarker.ShopInfos.Licenses[data].Price,
        IntervalInHours = CurrentMarker.ShopInfos.Licenses[data].PayIntervalInHours,
        LicenseName = CurrentMarker.ShopInfos.Licenses[data].Name,
    }

    -- WICHTIG: Entferne die Lizenz, die gerade gekauft wird, aus der Kündigungsliste.
    -- Dies verhindert, dass man eine Lizenz kauft, die man bereits hat, und sie dabei aus Versehen kündigt.
    for i = #cancelLicenses, 1, -1 do
        if cancelLicenses[i] == licenseInfo.LicenseType then
            table.remove(cancelLicenses, i)
        end
    end

    TriggerServerEvent("easyLicenseShop:BuyAndAddLicenseToPlayer", licenseInfo, cancelLicenses)
    CloseTablet()
end)

RegisterNUICallback('cancelLicense', function(data, cb)
    TriggerServerEvent("easyLicenseShop:RemoveLicenseFromPlayer", data, CurrentMarker.ShopInfos.Licenses[data].Name)
    SetNuiFocus(false, false)
    CloseTablet()
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    CloseTablet()
end)
--#endregion


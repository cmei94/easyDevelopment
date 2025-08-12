CurrentMarker=nil


--- set ped
---@param location vector4
---@param model string
---@return integer
local function SetPed(location, model)
    local hashKey=GetHashKey(model)
    RequestModel(hashKey)
    while not HasModelLoaded(hashKey) do
        RequestModel(hashKey)
        Citizen.Wait(100)
    end
    local ped = CreatePed(26, hashKey, location.x, location.y, location.z, location.w, false, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    return ped
end

--- removes ped
---@param ped integer
local function RemovePed(ped)
    DeletePed(ped)
end

--- Ceate a default marker by params
---@param position vector3 coord
---@param markerId integer markerId by 
---@param color table of {r,g,b}
local function CreateMarker(position, markerId, color)
    DrawMarker(markerId, position.x,position.y, position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.5, color.r, color.g, color.b, 100, false, false, 2, true, false, false, false)
end


 --- Create a marker for the shop and set the ped if needed
Citizen.CreateThread(function()
    Citizen.CreateThread(function()
        
        for k,v in pairs(Config.LicenseShops) do
            if v.Blip and v.Blip.Enable then
                local blip = AddBlipForCoord(v.Position.x, v.Position.y, v.Position.z)
                SetBlipScale(blip, v.Blip.Size)
                SetBlipSprite(blip, v.Blip.BlipId)
                SetBlipDisplay(blip, 4)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(k)
                EndTextCommandSetBlipName(blip)  
                v.SettedBlip=blip
            end
        end
        
    end)
    while true do
        local PlayerIsInInteractionPoint=false
        local sleep=true
        local coords=GetEntityCoords(PlayerPedId())
        for shopName, shopInfos in pairs(Config.LicenseShops) do
            local interactionDistance=0
            if shopInfos.Ped and shopInfos.Ped.Enable then
                if shopInfos.Ped.InteractionDistance and shopInfos.Ped.InteractionDistance>0 then
                    interactionDistance=shopInfos.Ped.InteractionDistance
                else
                    interactionDistance= 2
                end
            else
                interactionDistance= 1.5
            end
            
            local interactPosition=vector3(shopInfos.Position.x, shopInfos.Position.y, shopInfos.Position.z)
            if shopInfos.Ped and shopInfos.Ped.Enable then
                interactPosition=vector3(shopInfos.Ped.Position.x, shopInfos.Ped.Position.y, shopInfos.Ped.Position.z)
            end
            local distance = #(coords - interactPosition);
            if distance <= shopInfos.CreateDistance and shopInfos.SettedPed==nil then
                if shopInfos.Ped and shopInfos.Ped.Enable and not shopInfos.SettedPed then
                    local pedPosition = shopInfos.Position
                    if shopInfos.Ped.Position then
                        pedPosition = shopInfos.Ped.Position
                    end
                    shopInfos.SettedPed = SetPed(pedPosition, shopInfos.Ped.Model)
                elseif shopInfos.Marker then
                    CreateMarker(shopInfos.Position, shopInfos.Marker.MarkerId, shopInfos.Marker.MarkerColor)
                    sleep=false
                end
            elseif shopInfos.SettedPed~=nil and distance >= shopInfos.CreateDistance then
                RemovePed(shopInfos.SettedPed)
                shopInfos.SettedPed=nil
            end
            if distance <= interactionDistance then
                CurrentMarker={ShopName=shopName,ShopInfos=shopInfos}
                PlayerIsInInteractionPoint=true
            end 
        end
        if not PlayerIsInInteractionPoint and CurrentMarker then
            CloseShopInteract()
        end
        if sleep then
            Citizen.Wait(1000)
        else
            Citizen.Wait(1)
        end
    end 
end)


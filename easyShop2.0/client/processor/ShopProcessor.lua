---@class ShopProcessor
---@field CurrentMarker table
---@field TableIsOpen boolean
---@field ShowUi boolean
---@field PlayerProps table
---@field TabletIsOpen boolean
---@field StartShopSystem function Starts ShopSystem

ShopProcessor={}

ShopProcessor.__index=ShopProcessor

---@type ShopClientRepository
local shopClientRepository=ShopClientRepository:new()
 
--- Konstruktor
---@return ShopProcessor
function ShopProcessor:new()
    local shopProcessor={}
    setmetatable(shopProcessor, self)

    shopProcessor.CurrentMarker={}
    shopProcessor.TabletIsOpen=false
    shopProcessor.ShowUi=false
    shopProcessor.PlayerProps={}

    return shopProcessor
end

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


local function CreateMarketPedOrMarker(processor)
    Citizen.CreateThread(function()
        if EasyCore.Utils.CheckTableCountNotZero(Config.Shops) then
            for k,v in pairs(Config.Shops) do
                if v.Blip and v.Blip.Enable then
                    local blip = AddBlipForCoord(v.Position.x, v.Position.y, v.Position.z)
                    SetBlipSprite(blip, v.Blip.BlipId)
                    SetBlipDisplay(blip, 4)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(k)
                    EndTextCommandSetBlipName(blip)  
                    v.SettedBlip=blip
                end
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            local sleep=true
            local coords=GetEntityCoords(PlayerPedId())
            local PlayerIsInInteractionPoint=false
    
            for shopName, shopInfos in pairs(Config.Shops) do
                local interactionDistance=0
                if shopInfos.Ped and shopInfos.Ped.Enable then
                    interactionDistance= 2
                else
                    interactionDistance= 1.5
                end
                
                local distance = #(coords - vector3{shopInfos.Position.x, shopInfos.Position.y, shopInfos.Position.z});
                if distance <= shopInfos.CreateDistance and shopInfos.SettedPed==nil then
                    if shopInfos.Ped and shopInfos.Ped.Enable and not shopInfos.SettedPed then
                        shopInfos.SettedPed = SetPed(shopInfos.Position, shopInfos.Ped.PedModel)
                    elseif shopInfos.Marker then
                        CreateMarker(shopInfos.Position, shopInfos.Marker.MarkerId, shopInfos.Marker.MarkerColor)
                        sleep=false
                    end
                elseif shopInfos.SettedPed~=nil and distance >= shopInfos.CreateDistance then
                    RemovePed(shopInfos.SettedPed)
                    shopInfos.SettedPed=nil
                end
                if distance <= interactionDistance then
                    processor.CurrentMarker={ShopName=shopName,ShopInfos=shopInfos}
                    PlayerIsInInteractionPoint=true
                end 
                
            end
    
            if not PlayerIsInInteractionPoint and processor.CurrentMarker then
                processor:CloseShopInteract()
            end
    
            if sleep then
                Citizen.Wait(1000)
            else
                Citizen.Wait(1)
            end
        end
        
    end)
end

function CheckJobsAreOnDuty(openByJobDutyCount)
    if not EasyCore.Utils.CheckTableCountNotZero(NeededJobOnDutyCount) then
        return false
    end
    for k,v in pairs(openByJobDutyCount) do
        if NeededJobOnDutyCount[k] and NeededJobOnDutyCount[k]>=v then
            return true
        end
    end
    return false
end

---Check intercation of player with current location marker or ped
---@param processor ShopProcessor
local function CheckCurrentMarkerAndInteraction(processor)
    local openTabletKey=EasyCore.Utils.Keys[Config.Tablet.OpenTabletKey]
    Citizen.CreateThread(function()
        local jobAccess=false
        local accessByDutyCount=false
        while true do
            local sleep=300

            if processor.CurrentMarker and not processor.ShowUi and not processor.TabletIsOpen then
                if EasyCore.Utils.CheckTableCountNotZero(processor.CurrentMarker.ShopInfos.JobAccess) and not EasyCore.FrameworkHelper.CheckJob(processor.CurrentMarker.ShopInfos.JobAccess) then
                    EasyCore.Notifications.Error(processor.CurrentMarker.ShopName,"Kein Zugriff auf diesen Shop!",5000, false)
                    jobAccess=false
                elseif  EasyCore.Utils.CheckTableCountNotZero(processor.CurrentMarker.ShopInfos.OpenByJobDutyCount) and not CheckJobsAreOnDuty(processor.CurrentMarker.ShopInfos.OpenByJobDutyCount) then
                    EasyCore.Notifications.Error(processor.CurrentMarker.ShopName,"Komm wieder wenn ich beim Handeln nervös werde!",5000, false)
                    accessByDutyCount=false
                else
                    EasyCore.TextUi.ShowUi(("Drücke [%s] zum öffnen des %s-Shops!"):format(Config.Tablet.OpenTabletKey, processor.CurrentMarker.ShopName))
                    jobAccess=true
                    accessByDutyCount=true
                end
                processor.ShowUi=true

            elseif processor.CurrentMarker and processor.ShowUi and not processor.TabletIsOpen and jobAccess and accessByDutyCount then
                if IsControlPressed(0, openTabletKey) then
                    processor:OpenTablet()
                end
                sleep=1
            elseif not processor.CurrentMarker and processor.ShowUi then
                processor:CloseShopInteract()
            end
            
            Wait(sleep)
        end
    end)
end

--- check and return checked and gap filled FeatureSettings
---@param currentFeatureSettings table
---@return table
local function CheckMarketFeatureSettings(currentFeatureSettings)
    local resultDefault={
        EconomyItemsList={
            ShowSellPrice=false,
            ShowBuyPrice=false,
        }
    }
    if currentFeatureSettings then
        if currentFeatureSettings.EconomyItemsList then
            resultDefault.EconomyItemsList.ShowSellPrice=currentFeatureSettings.EconomyItemsList.ShowSellPrice or resultDefault.EconomyItemsList.ShowSellPrice
            resultDefault.EconomyItemsList.ShowBuyPrice=currentFeatureSettings.EconomyItemsList.ShowBuyPrice or resultDefault.EconomyItemsList.ShowBuyPrice
        end
    end

    return resultDefault
end

local function FilterNeededItems(whiteList)
    local tempResult={}
    if EasyCore.Utils.CheckTableCountNotZero(whiteList.Categories) then
        for k,v in pairs(whiteList.Categories) do
            if EconomyCategoriesItems[v] then
                for kc,vc in pairs(EconomyCategoriesItems[v]) do
                    tempResult[vc]=vc
                end
            end
        end
    end
    if EasyCore.Utils.CheckTableCountNotZero(whiteList.Items) then
        for k,v in pairs(whiteList.Items) do
            tempResult[v]=v
        end
    end
    if EasyCore.Utils.CheckTableCountNotZero(tempResult) then
        local result={}
        for k,v in pairs(tempResult)do
            table.insert(result, v)
        end
        return result
    else
        return {}
    end
end

local function StopAnimationAndDeleteTablet(processor)
    ClearPedTasks(PlayerPedId())
    --#region Delete Tablet
    for _,v in pairs(processor.PlayerProps) do
        DeleteEntity(v)
    end
    processor.PlayerProps={}
    --#endregion
end

local function AddPropToPlayer(processor, prop1, bone, off1, off2, off3, rot1, rot2, rot3)
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
    table.insert(processor.PlayerProps, prop)
    SetModelAsNoLongerNeeded(prop1)
end

--- Reset all interaction helpers
function ShopProcessor:CloseShopInteract()
    EasyCore.TextUi.HideUi()
    self.CurrentMarker=nil
    self.ShowUi=false
    self.TabletIsOpen=false
end

--- Starts stock market system
function ShopProcessor:StartShopSystem()
    CreateMarketPedOrMarker(self)
    CheckCurrentMarkerAndInteraction(self)
end

--- open tablet main
function ShopProcessor:OpenTablet()
    local requestId=EasyCore.Utils.Guid()
    EasyCore.TextUi.HideUi()
    self.ShowUi=false
    local playerData= self:LoadForTabletNeededPlayerData(requestId)
    local items=self:LoadDataForTablet(requestId, playerData)
    self:PlayOpenTabletAnimation()
    self.TabletIsOpen=true
    SetNuiFocus(true,true)
    SendNUIMessage({
        action='openShop', 
        items=tostring(json.encode(items)), 
        playerData=tostring(json.encode(playerData)),
        shopName=self.CurrentMarker.ShopName
    })
end

function ShopProcessor:LoadForTabletNeededPlayerData(requestId)
    local playerData=shopClientRepository:LoadForTabletNeededPlayerData(requestId)
    local licenses=shopClientRepository:LoadPlayerLicenses(requestId)
    playerData.licenses={}
    for k,v in pairs(licenses) do
        playerData.licenses[v.type]=v
    end
    return playerData
end

--- LoadData Current prizes
---@param requestId string
function ShopProcessor:LoadDataForTablet(requestId, playerData)
    local items={}
    if EasyCore.Utils.CheckTableCountNotZero(self.CurrentMarker.ShopInfos.Inventory) then
        if EasyCore.Utils.CheckTableCountNotZero(self.CurrentMarker.ShopInfos.Inventory.Buy) then
            for kb, vb in pairs(self.CurrentMarker.ShopInfos.Inventory.Buy) do
                items[kb]=kb 
            end
        end
        if EasyCore.Utils.CheckTableCountNotZero(self.CurrentMarker.ShopInfos.Inventory.Sell) then
            for ks, vs in pairs(self.CurrentMarker.ShopInfos.Inventory.Sell) do
                items[ks]=ks 
            end
        end
    end
    local requestItems={}
    local resolvedExportItems={}
    local messages=""
    local finalResult={}
    if EasyCore.Utils.CheckTableCountNotZero(items) then
        for k,v in pairs(items) do
            table.insert(requestItems, k)
        end
        local resolvedExportItems=shopClientRepository:LoadItemPrizes(requestId, items)
        
        if EasyCore.Utils.CheckTableCountNotZero(self.CurrentMarker.ShopInfos.Inventory.Buy) then
            for kb, vb in pairs(self.CurrentMarker.ShopInfos.Inventory.Buy) do
                if resolvedExportItems[kb] then
                    if (not vb.License) or (playerData.licenses and playerData.licenses[vb.License]) then
                        local resolvedData=resolvedExportItems[kb]
                        if not finalResult[kb] then
                            finalResult[kb]={
                                Category=resolvedData.Category,
                                EconomyLabel=resolvedData.EconomyLabel,
                                Weight=resolvedData.Weight
                            }
                        end
                        if vb.Prize and vb.Prize>=0 then
                            finalResult[kb].CurrentBuyPrize=vb.Prize--if not prize should use from economicSystem
                        else
                            finalResult[kb].CurrentBuyPrize=resolvedData.CurrentBuyPrize--if prize should use from economicSystem
                        end
                        finalResult[kb].BuyCurrency=vb.Currency
                    end
                else
                    messages=messages..("\nThere were issues processing the buy economic item %s. The item will be removed from the shop %s!"):format(kb, self.CurrentMarker.ShopName)
                end
            end
        end
        if EasyCore.Utils.CheckTableCountNotZero(self.CurrentMarker.ShopInfos.Inventory.Sell) then
            for ks, vs in pairs(self.CurrentMarker.ShopInfos.Inventory.Sell) do
                if resolvedExportItems[ks] then
                    if (not vs.License)  or (playerData.licenses and playerData.licenses[vs.License]) then
                        local resolvedData=resolvedExportItems[ks]
                        if not finalResult[ks] then
                            finalResult[ks]={
                                Category=resolvedData.Category,
                                EconomyLabel=resolvedData.EconomyLabel,
                                Weight=resolvedData.Weight,
                            }
                        end
                        if vs.Prize and vs.Prize>=0 then
                            finalResult[ks].CurrentSellPrize=vs.Prize--if not prize should use from economicSystem
                        else
                            finalResult[ks].CurrentSellPrize=resolvedData.CurrentSellPrize--if prize should use from economicSystem
                        end
                        finalResult[ks].SellCurrency=vs.Currency
                    end
                else
                    messages=messages..("\nThere were issues processing the sell economic item %s. The item will be removed from the shop %s!"):format(ks, self.CurrentMarker.ShopName)
                end
            end
        end
        if messages~="" then
            EasyCore.Logger.LogError(RessourceName, requestId, messages)
        end
    end

    if messages~="" then
        EasyCore.Notifications.Error(self.CurrentMarker.ShopName,"Failure found by processing shop items. Please make screenshot and report requestId:"..requestId, 5000, false)
    end

    return  finalResult
end


---Process submitted order from Frontend
---@param requestId string
---@param data table
function ShopProcessor:ProcessItemOrder(requestId, data)
    local orderItems=self:PreEditData(requestId, data)
    return shopClientRepository:TransmitOrderToPlayer(requestId,orderItems)
end

---filter and order itemData for order process
---@param requestId string
---@param javascriptData table
---@return table
function ShopProcessor:PreEditData(requestId, javascriptData)
    local result={
        Buy={
            ["black_money"]={},
            ["money"]={},
        },
        Sell={
            ["black_money"]={},
            ["money"]={},
        }
    }
    for k,v in pairs(javascriptData) do
        if v.CanBuy and v.BuyAmount>0 and result.Buy[v.BuyCurrency]then
            result.Buy[v.BuyCurrency][v.Name]={Name=v.Name, Label=v.Label, Amount=v.BuyAmount, Prize=v.CurrentBuyPrize}
        elseif v.CanSell and v.SellAmount>0 and result.Sell[v.SellCurrency] then
            result.Sell[v.SellCurrency][v.Name]={Name=v.Name, Label=v.Label, Amount=v.SellAmount, Prize=v.CurrentSellPrize}
        end
    end
    return result
end

function ShopProcessor:CloseTablet()
    StopAnimationAndDeleteTablet(self)
    self:CloseShopInteract()
end

function ShopProcessor:PlayOpenTabletAnimation()
    if (IsPedInAnyVehicle(PlayerPedId(), true)) then
		return
	end
	local dict = Config.Tablet.Animation.AnimationDictionary  
	local anim = "base"
	RequestAnimDict(dict)
    local prop = Config.Tablet.Animation.PropModel				  
    local propBone = Config.Tablet.Animation.Bone
    AddPropToPlayer(self, prop, propBone, 0.0, -0.05, 0.0, 20.0, 280.0, 20.0)
    TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 2.0, -1, 1, 0, false, false, false)
end


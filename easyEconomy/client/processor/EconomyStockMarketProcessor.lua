---@class EconomyStockMarketProcessor
---@field CurrentMarker table
---@field TableIsOpen boolean
---@field ShowUi boolean
---@field PlayerProps table
---@field TabletIsOpen boolean

EconomyStockMarketProcessor={}

EconomyStockMarketProcessor.__index=EconomyStockMarketProcessor

local economyClientRepository=EconomyClientRepository:new()

--- Konstruktor
---@return EconomyStockMarketProcessor
function EconomyStockMarketProcessor:new()
    local economyStockMarketProcessor={}
    setmetatable(economyStockMarketProcessor, self)

    economyStockMarketProcessor.CurrentMarker={}
    economyStockMarketProcessor.TabletIsOpen=false
    economyStockMarketProcessor.ShowUi=false
    economyStockMarketProcessor.PlayerProps={}

    return economyStockMarketProcessor
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
    DrawMarker(markerId, position.x,position.y, position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.5, color.r, color.g, color.b, 100, false, false, 2, false, false, false, false)
end


local function CreateMarketPedOrMarker(processor)
    Citizen.CreateThread(function()
        if EasyCore.Utils.CheckTableCountNotZero(Config.StockMarket) then
            for k,v in pairs(Config.StockMarket) do
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
    
            for marketName, marketInfos in pairs(Config.StockMarket) do
                local interactionDistance=0
                if marketInfos.Ped and marketInfos.Ped.Enable then
                    interactionDistance= 2
                else
                    interactionDistance= 1.5
                end
                
                local distance = #(coords - vector3{marketInfos.Position.x, marketInfos.Position.y, marketInfos.Position.z});
                if distance <= marketInfos.CreateDistance and marketInfos.SettedPed==nil then
                    if marketInfos.Ped and marketInfos.Ped.Enable and not marketInfos.SettedPed then
                        marketInfos.SettedPed = SetPed(marketInfos.Position, marketInfos.Ped.PedModel)
                    elseif marketInfos.Marker then
                        CreateMarker(marketInfos.Position, marketInfos.Marker.MarkerId, marketInfos.Marker.MarkerColor)
                        sleep=false
                    end
                elseif marketInfos.SettedPed~=nil and distance >= marketInfos.CreateDistance then
                    RemovePed(marketInfos.SettedPed)
                    marketInfos.SettedPed=nil
                end
                if distance <= interactionDistance then
                    processor.CurrentMarker={MarketName=marketName,MarketInfos=marketInfos}
                    PlayerIsInInteractionPoint=true
                end 
                
            end
    
            if not PlayerIsInInteractionPoint and processor.CurrentMarker then
                processor:CloseMarketInteract()
            end
    
            if sleep then
                Citizen.Wait(1000)
            else
                Citizen.Wait(1)
            end
        end
        
    end)
end

---Check intercation of player with current location marker or ped
---@param processor EconomyStockMarketProcessor
local function CheckCurrentMarkerAndInteraction(processor)
    local openTabletKey=EasyCore.Utils.Keys[Config.Tablet.OpenTabletKey]
    Citizen.CreateThread(function()
        while true do
            local sleep=300
            if processor.CurrentMarker and not processor.ShowUi and not processor.TabletIsOpen then
                EasyCore.TextUi.ShowUi(("Drücke [%s] zum öffnen des %s-Tablets!"):format(Config.Tablet.OpenTabletKey, processor.CurrentMarker.MarketName))
                processor.ShowUi=true

            elseif processor.CurrentMarker and processor.ShowUi and not processor.TabletIsOpen  then
                if IsControlPressed(0, openTabletKey) then
                    processor:OpenTablet()
                end
                sleep=1
            elseif not processor.CurrentMarker and processor.ShowUi then
                processor:CloseMarketInteract()
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
function EconomyStockMarketProcessor:CloseMarketInteract()
    EasyCore.TextUi.HideUi()
    self.CurrentMarker=nil
    self.ShowUi=false
    self.TabletIsOpen=false
end

--- Starts stock market system
function EconomyStockMarketProcessor:StartStockMarketSystem()
    CreateMarketPedOrMarker(self)
    CheckCurrentMarkerAndInteraction(self)
end

--- open tablet main
function EconomyStockMarketProcessor:OpenTablet()
    local requestId=EasyCore.Utils.Guid()
    EasyCore.TextUi.HideUi()
    self.ShowUi=false
    local items=self:LoadDataForTablet(requestId)
    self:PlayOpenTabletAnimation()
    self.TabletIsOpen=true
    SetNuiFocus(true,true)
    SendNUIMessage({
        action='openEconomy', 
        items=tostring(json.encode(items)), 
        stockMarket=self.CurrentMarker.MarketName, 
        featureSettings=tostring(json.encode(
            (CheckMarketFeatureSettings(self.CurrentMarker.MarketInfos.FeatureSettings))
        ))
    })
end

--- LoadData Current prizes
---@param requestId string
function EconomyStockMarketProcessor:LoadDataForTablet(requestId)
    local items={}
    if EasyCore.Utils.CheckTableCountNotZero(self.CurrentMarker.MarketInfos.WhiteList) then
        items=FilterNeededItems(self.CurrentMarker.MarketInfos.WhiteList)
    end
    local resolvedExportItems=economyClientRepository:LoadItemPrizes(requestId, items)
    return  resolvedExportItems
end

function EconomyStockMarketProcessor:CloseTablet()
    StopAnimationAndDeleteTablet(self)
    self:CloseMarketInteract()
end

function EconomyStockMarketProcessor:PlayOpenTabletAnimation()
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


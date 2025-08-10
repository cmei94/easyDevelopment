---@class OrderProcessor
---@field GiveOrTakePlayerMoney function
---@field GiveOrTakeInventoryItemsMoney function
---@field ProcessEconomyChange function

OrderProcessor={}
OrderProcessor.__index=OrderProcessor

local orderRepository=OrderRepository:new()

--- Konstruktor
---@return OrderProcessor
function OrderProcessor:new()
    local orderProcessor={}
    setmetatable(orderProcessor, self)

    return orderProcessor
end

---gives or take money from account by currency
---@param requestId any
---@param playerData any
---@param giveOrTakeMoneyPerCurrency any
function OrderProcessor:GiveOrTakePlayerMoney(requestId, playerData,giveOrTakeMoneyPerCurrency)
    for k,v in pairs(giveOrTakeMoneyPerCurrency) do
        orderRepository:GiveOrTakeAccountMoney(requestId, playerData, k, v)
    end
end

---gives or take money from account by currency
---@param requestId any
---@param playerData any
---@param sellItems any
---@param buyItems any
function OrderProcessor:GiveOrTakeInventoryItemsMoney(requestId, playerData, sellItems, buyItems)
    for k,v in pairs(sellItems) do
        for ki,vi in pairs(v) do
            orderRepository:RemoveItem(requestId, playerData, ki, vi.Amount)
        end
    end
    for k,v in pairs(buyItems) do
        for ki,vi in pairs(v) do
            orderRepository:AddItem(requestId, playerData, ki, vi.Amount)
        end
    end
end

---trigger economySystemCalculate
---@param requestId any
---@param sellItems any
---@param buyItems any
function OrderProcessor:ProcessEconomyChange(requestId, sellItems, buyItems)
    local sellEcoItems={}
    local buyEcoItems={}
    for k,v in pairs(sellItems) do
        for ki,vi in pairs(v) do
            sellEcoItems[ki]=vi.Amount
        end
    end
    if EasyCore.Utils.CheckTableCountNotZero(sellEcoItems) then
        orderRepository:TriggerSellEconomyItems(sellEcoItems)
    end

    for k,v in pairs(buyItems) do
        for ki,vi in pairs(v) do
            buyEcoItems[ki]=vi.Amount
        end
    end
    if EasyCore.Utils.CheckTableCountNotZero(buyEcoItems) then
        orderRepository:TriggerBuyEconomyItems(buyEcoItems)
    end
end

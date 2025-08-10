---@class OrderRepository
OrderRepository={}
OrderRepository.__index=OrderRepository


--- Konstruktor
---@return OrderRepository
function OrderRepository:new()
    local orderRepository={}
    setmetatable(orderRepository, self)

    return orderRepository
end

---Gives account money
---@param requestId string
---@param currency 
---@param MoneyAmount any
function OrderRepository:GiveOrTakeAccountMoney(requestId, player, currency, moneyAmount)
    if currency then
        if currency=="money"then
            local rest=self:TakeOrGiveMoneyCash(requestId, player,moneyAmount)
            if rest>0 then
                self:TakeMoneyBank(requestId, player, rest)
            end
        elseif currency=="black_money" then
            self:TakeOrGiveBlackMoneyCash(requestId, player, moneyAmount)
        else
            EasyCore.Logger.LogError(RessourceName, requestId, "GiveOrTakeAccountMoney: Not valid currency used! Currency name: "..currency)
        end
    else
        EasyCore.Logger.LogError(RessourceName, requestId, "GiveOrTakeAccountMoney: No currency set")
    end
end

function OrderRepository:TakeOrGiveMoneyCash(requestId, player, moneyAmount)
    local rest=0
    if moneyAmount>0 then
         --buy
        local currentCash=player.getAccount("money").money

        if moneyAmount <= currentCash then
            player.removeAccountMoney("money", moneyAmount)
        else
            rest=moneyAmount-currentCash
            if currentCash>0 then
                player.addAccountMoney("money", currentCash)
            end
        end
    elseif moneyAmount<0 then
        --sell
        moneyAmount = moneyAmount*-1
        player.addAccountMoney("money", moneyAmount)
    end
    return rest
end

function OrderRepository:TakeMoneyBank(requestId, player, moneyAmount)
    player.removeAccountMoney("bank", moneyAmount)
end

function OrderRepository:TakeOrGiveBlackMoneyCash(requestId, player, moneyAmount)
    if moneyAmount>0 then
        --buy
       local currentCash=player.getAccount("black_money").money
       if moneyAmount <= currentCash then
           player.removeAccountMoney("black_money", moneyAmount)
       else
           if currentCash>0 then
               player.addAccountMoney("black_money", currentCash)
           end
       end
   elseif moneyAmount<0 then
       --sell
       moneyAmount = moneyAmount*-1
       player.addAccountMoney("black_money", moneyAmount)
   end
end

function OrderRepository:AddItem(requestId, playerData, item, amount)
    playerData.addInventoryItem(item, amount)
end

function OrderRepository:RemoveItem(requestId, playerData, item, amount)
    playerData.removeInventoryItem(item, amount)
end

function OrderRepository:TriggerSellEconomyItems(sellEcoItems)
    EasyEconomy.SellItems(sellEcoItems)
end

function OrderRepository:TriggerBuyEconomyItems(buyEcoItems)
    EasyEconomy.BuyItems(buyEcoItems)
end
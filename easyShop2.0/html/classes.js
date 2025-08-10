class Player {
	constructor(openEventPlayerData) {
	  this.FirstName = openEventPlayerData.firstName;
	  this.LastName = openEventPlayerData.lastName;
      this.Group = openEventPlayerData.group;
      this.BirthDay=openEventPlayerData.dateofbirth;
      this.Gender=openEventPlayerData.sex;
      this.Cash=openEventPlayerData.accounts.find(x => x.name=="money").money;
      this.Bank=openEventPlayerData.accounts.find(x => x.name=="bank").money;
      this.CashAndBank=this.Cash+this.Bank
      this.BlackMoney=openEventPlayerData.accounts.find(x => x.name=="black_money").money;
      this.CurrentCarryWeight=0;
      this.SetJob(openEventPlayerData.job);
      this.SetInventory(openEventPlayerData.inventory);
	}

	SetInventory(openEventPlayerDataInventar) {
        this.Inventory = new Map();
        openEventPlayerDataInventar.forEach(inventoryItem => {
            if(inventoryItem!=undefined || inventoryItem!=null)
            {
                var item=new InventoryItem(inventoryItem);
                this.Inventory.set(inventoryItem.name,item);
                this.CurrentCarryWeight=this.CurrentCarryWeight+item.TotalWeight;
            }
        });
	}

    SetJob(openEventPlayerDataJob){
        this.Job =new PlayerJob(openEventPlayerDataJob)
    }

    GetMoneyByCurrency(currency){
        switch(currency){
            case "money": return this.CashAndBank;
            case "black_money": return this.BlackMoney;
            default: return this.CashAndBank;
        }
    }
}

class PlayerJob {
	constructor(gamePlayerJob) {
        this.Label = gamePlayerJob.label;
	    this.Name = gamePlayerJob.name;
        this.Grade = gamePlayerJob.grade;
        this.GradeName = gamePlayerJob.grade_name;
        this.GradeLabel = gamePlayerJob.grade_label;
        this.GradeSalary = gamePlayerJob.grade_salary;
    }
}

class InventoryItem {
	constructor(gameInventoryItem) {
        this.Label = gameInventoryItem.label;
	    this.Name = gameInventoryItem.name;
        this.Count = gameInventoryItem.count;
        this.Weight = gameInventoryItem.weight/this.Count;
        this.TotalWeight = gameInventoryItem.weight;
        this.Description = gameInventoryItem.description;
	}
}

class ShopItem {
	constructor(shopEcoItem) {
        this.IsShowen = true;
	    this.Name = shopEcoItem.name;
        this.Label = shopEcoItem.EconomyLabel;
        this.Category = shopEcoItem.Category;
        this.ItemWeight = shopEcoItem.Weight;
        this.CanSell=false;
        this.HtmlItem=null;
        if(shopEcoItem.CurrentSellPrize!=null && shopEcoItem.CurrentSellPrize != undefined){
            this.CurrentSellPrize=shopEcoItem.CurrentSellPrize;
            this.SellAmount=0;
            this.SellCurrency=shopEcoItem.SellCurrency;
            this.CanSell=true;
        }
        this.CanBuy=false;
        if(shopEcoItem.CurrentBuyPrize!=null && shopEcoItem.CurrentBuyPrize != undefined){
            this.CurrentBuyPrize=shopEcoItem.CurrentBuyPrize
            this.BuyAmount=0;
            this.BuyCurrency=shopEcoItem.BuyCurrency;
            this.CanBuy=true;
        }
	}

    PreCalculateWeightAddWithoutSellItems(){
        var weightCalculated=0;
        if (this.CanBuy){
            weightCalculated=weightCalculated+(this.BuyAmount*this.ItemWeight);
        }
        // if (this.CanSell){ //Da beim Gewicht die Verkaufsitems nicht evrrechnet werden
        //     weightCalculated=weightCalculated-(this.SellAmount*this.ItemWeight);
        // }
        return weightCalculated;
    }

    PreCalculateWeightAdd(){
        var weightCalculated=0;
        if (this.CanBuy){
            weightCalculated=weightCalculated+(this.BuyAmount*this.ItemWeight);
        }
        if (this.CanSell){ //Da beim Gewicht die Verkaufsitems nicht evrrechnet werden
            weightCalculated=weightCalculated+(this.SellAmount*this.ItemWeight)*-1;
        }
        return weightCalculated;
    }
    
}

class ShopCart {

    constructor(maxWeight, currentInitInventoryWeight){
        this.CartItems= new Map();
        this.MaxCarryWeight= maxWeight;
        this.CurrentCarryWeight= currentInitInventoryWeight;
    }

    GetWouldCarryWeightForBuyItems(){
        var weight=this.CurrentCarryWeight;
        
        this.CartItems.forEach(item=>{
            if(item.CanBuy && item.BuyAmount>0){
                weight=weight+item.PreCalculateWeightAddWithoutSellItems();
            }
        })

        return weight;
    }

    GetShouldPayForBuyItems(currency){
        var payprize=0
        this.CartItems.forEach(item=>{
            if (item.CanBuy){
                if(item.BuyCurrency==currency){
                payprize=payprize+item.CurrentBuyPrize*item.BuyAmount;
                }
            }
        })
        return payprize;
    }

    //nur genutzt für die Rechnung da bei Kaufen auf die Anfangswerte gerechnet wird damit es nicht zu Problemen kommt
    GetShouldPay(currency){
        var payprize=0
        this.CartItems.forEach(item=>{
            
                if (item.CanBuy){
                    if(item.BuyCurrency==currency){
                        payprize=payprize+item.CurrentBuyPrize*item.BuyAmount;
                    }
                }
                if (item.CanSell){
                    if(item.SellCurrency==currency){
                        payprize=payprize-item.CurrentSellPrize*item.SellAmount;
                    }
                }
        })
        return payprize;
    }

    AddOrUpdateItem(shopItem){
        this.CartItems.set(shopItem.Name,shopItem);
    }

    RemoveItem(itemName){
        this.CartItems.delete(itemName);
    }

}
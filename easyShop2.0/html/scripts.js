let resource = "easyShop2.0"
let currencyShort={
	"default": "$",
	"money": "$",
	"black_money": "💰"
}
let maxInventoryWeight=30000



let isLoggedIn=false
let shopName=null
let containerIsOpen=null
let FilteredCategory=null
let profilIsInit=false
let shopItemsShowCaseIsInit=false

let PlayerData=null
let ShopItemDatas=null
let CategoryShopItems=null

let ShopCartData=null

$(document).ready(function(){
	const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
	const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
	
	window.addEventListener('message', function(event) {
		var data=event.data
		switch (data.action){
			case 'close':
				CloseTablet()
				break;
			//#region EconomyTablet MainEvents
			case 'openShop':
                    try {
						$("#userName").text("")
						$("#pwd").text("")
						$("#displayShop").fadeIn()
						var tempItemDatas=JSON.parse(data.items)
						var itemDatas= Object.keys(tempItemDatas).map(key => ({
							name: key,
							...tempItemDatas[key]
						}));
						var playerData=JSON.parse(data.playerData)
						PreInitData(playerData, itemDatas)
						
						
						shopName=data.shopName
						if(IsNotUndefinedNorNullNorEmptyString(shopName)){
							$("#Login-ShopName").text(shopName)
							$("#Shop-Shopname").text(shopName)
						}else{
							$("#Login-ShopName").text("Shop")
							$("#Shop-Shopname").text("Shop")
						}
						LoadProfile()
                        if(!isLoggedIn){
							$("#Login-Content").fadeIn()
							var userNameInput=document.getElementById("userName")
							setTimeout(() => {
								simulateTyping(userNameInput, PlayerData.FirstName+PlayerData.LastName);
							}, 1000); 
							var passwordInput=document.getElementById("pwd")
							setTimeout(() => {
								simulateTyping(passwordInput, generateRandomString(12));
							}, 3000); 
							var loginButton=document.getElementById("loginButton")
							setTimeout(() => {
								loginButton.removeAttribute('disabled');
							}, 5400); 

						}else{
							OpenShopContent()
						}
                    } catch (error) {
                        $('#displayShop').fadeOut()
                        console.log("Error at open tablet: " + error.message);
						console.log("Stack trace: " + error.stack); 
                        $.post('https://' + resource +'/close', JSON.stringify({}));
                    }
                    
				break;

			default:
				console.log(resource+': unknown action!');
		}
		
	});

	$(document).keydown((event) => {
		if (event.which == 27) {
            CloseTablet()
		}
	})
});

function LogOut(){
	isLoggedIn=false
	CloseTablet()
}


$(document).on('click', "#loginButton", function(event) {
	event.preventDefault();
	isLoggedIn=true
	$("#Login-Content").fadeOut()
	OpenShopContent()
});

function PreInitData(playerData, itemDatas){
	PlayerData=new Player(playerData);
	ShopItemDatas = new Map();
    CategoryShopItems = new Map();
	profilIsInit=false
	shopItemsShowCaseIsInit=false


    // Process each item
    itemDatas.forEach(economyShopItem => {
        // Create a new ShopItem instance
        var item = new ShopItem(economyShopItem);
        var key = item.Name;

        // Store the item in ShopItemDatas
        ShopItemDatas.set(key, item);

        // Check if the category exists in CategoryShopItems
        if (!CategoryShopItems.has(item.Category)) {
            // Initialize an empty array for the category if it doesn't exist
            CategoryShopItems.set(item.Category, new Map());
        }

        // Get the category map and add the item to it using the key
        CategoryShopItems.get(item.Category).set(key, item);
    });

	var navCategoryDropdown= document.getElementById("Category-Dropdown");
	navCategoryDropdown.innerHTML = '';
	CategoryShopItems.forEach((shopItems, categoryName)=>{
		var newCategoryListItem=document.createElement("li");
		var newCategoryListLink=document.createElement("a");
		newCategoryListLink.className="dropdown-item";
		newCategoryListLink.innerHTML=categoryName;
		newCategoryListLink.onclick = function() {
			FilterByCategory(categoryName)
		};
		newCategoryListItem.appendChild(newCategoryListLink);
		navCategoryDropdown.appendChild(newCategoryListItem);
	})
	var navCashBankMoney= document.getElementById("nav_cashMoney");
	navCashBankMoney.innerHTML = currencyShort["money"]+PlayerData.CashAndBank;
	var navBlackMoney= document.getElementById("nav_black_money");
	navBlackMoney.innerHTML = currencyShort["black_money"]+PlayerData.BlackMoney;

	var navCurrentWeight= document.getElementById("nav_weightWithBuyItems");
	var navMaxWeight= document.getElementById("nav_maxWeight");
	navCurrentWeight.innerHTML=(Math.trunc(PlayerData.CurrentCarryWeight* 100) / 100)+"g";
	navMaxWeight.innerHTML="/"+maxInventoryWeight+"g";
	if(PlayerData.CurrentCarryWeight>=maxInventoryWeight){
		navCurrentWeight.style.color="red";
		navMaxWeight.style.color="red";
	}else{
		navCurrentWeight.style.color="#3dd40f";
		navMaxWeight.style.color="#3dd40f";
	}
	ShopCartData= new ShopCart(maxInventoryWeight, PlayerData.CurrentCarryWeight);
}	

function OpenShopContent(){
	if (!shopItemsShowCaseIsInit){
		CreateShopItemsShowCase()
		shopItemsShowCaseIsInit=true
	}
	FilterItemsIfNeeded()
	if(FilteredCategory!=null){
		ShopItemDatas.forEach((itemData, itemName)=>{
			if(!itemData.IsShowen){
				itemData.IsShowen=true;
				$("#"+itemName+"_col").fadeIn();
			}
		})
		FilteredCategory=null
	}
	if (containerIsOpen!="Item-Container")
	{
		if (containerIsOpen!=null){
			$("#"+containerIsOpen).fadeOut(function() {
				// Dieser Code wird nach dem Abschluss des fadeOut ausgeführt
				$("#Item-Container").fadeIn();
			});
		}else{
			$("#Item-Container").fadeIn();
			$("#Shop-Content").fadeIn();
		}
		containerIsOpen="Item-Container";
	}
}

function OpenShopCartContent(){
	CreateShopCart()
	FilterItemsIfNeeded()
	if (containerIsOpen!="ShopCart-Container")
	{
		if (containerIsOpen!=null){
			$("#"+containerIsOpen).fadeOut(function() {
				// Dieser Code wird nach dem Abschluss des fadeOut ausgeführt
				$("#ShopCart-Container").fadeIn();
			});
		}else{
			$("#ShopCart-Container").fadeIn();
		}
		containerIsOpen="ShopCart-Container";
	}
}

function OpenOrderSuccess(){
	if (containerIsOpen!=null){
		if(containerIsOpen!="OrderSuccess-Container")
		{
			$("#"+containerIsOpen).fadeOut(function() {
				// Dieser Code wird nach dem Abschluss des fadeOut ausgeführt
				$("#OrderSuccess-Container").fadeIn();
			});
		}
	}else{
		$("#OrderSuccess-Container").fadeIn();
	}
	containerIsOpen="OrderSuccess-Container"
}

function OpenProfile(){
	if(!profilIsInit){
		LoadProfile()
		profilIsInit=true
	}


	if (containerIsOpen!=null){
		if(containerIsOpen!="Profil-Container")
		{
			$("#"+containerIsOpen).fadeOut(function() {
				// Dieser Code wird nach dem Abschluss des fadeOut ausgeführt
				$("#Profil-Container").fadeIn();
			});
		}
	}else{
		$("#Profil-Container").fadeIn();
	}
	containerIsOpen="Profil-Container"
}


function CloseTablet(){
	$("#Login-Content").fadeOut()
	$("#Shop-Content").fadeOut()
	$("#Item-Container").fadeOut()
	$("#Item-Container").fadeOut()
	$("#ShopCart-Container").fadeOut()
	$("#OrderSuccess-Container").fadeOut()
	$("#Profil-Container").fadeOut()
	$('#displayShop').fadeOut()
	profilIsInit=false
	shopItemsShowCaseIsInit=false
	containerIsOpen=null
	ResetLoginHtml()
	$.post('https://' + resource +'/close', JSON.stringify({}));
}

function ResetLoginHtml(){
	document.getElementById("userName").value=""
	document.getElementById("pwd").value=""
	document.getElementById("loginButton").setAttribute('disabled',true)
}

//#region Load Data
function LoadProfile(){
	$("#Profil-PlayerName").text(PlayerData.FirstName+" "+PlayerData.LastName);
	$("#Profil-DOB").text(PlayerData.BirthDay);
	switch(PlayerData.Gender){
		case "m": $("#Profil-Geschlecht").text("Mann"); break;
		case "f": $("#Profil-Geschlecht").text("Frau"); break;
		default: $("#Profil-Geschlecht").text("Divers"); break;
	}
	$("#Profil-Job").text(PlayerData.Job.Label);
	$("#Profil-JobGrade").text(PlayerData.Job.GradeLabel);
	$("#Profil-Gehalt").text(currencyShort["default"]+PlayerData.Job.GradeSalary);

	$("#Profil-Cash").text(currencyShort["money"]+PlayerData.Cash);
	$("#Profil-Bank").text(currencyShort["default"]+PlayerData.Bank);
	$("#Profil-BlackMoney").text(currencyShort["black_money"]+PlayerData.BlackMoney);
}

function CreateShopItemsShowCase(){
	const shopItemsColContainer = document.getElementById('Item-Container-Col');
	shopItemsColContainer.innerHTML="";
	var sortedItems= new Map(
		[...ShopItemDatas.entries()].sort((a, b) => a[1].Label.localeCompare(b[1].Label))
	);
	sortedItems.forEach((shopItem, itemName) => {
		//Col
		var colDiv=document.createElement("div");
		shopItem.HtmlItem=colDiv
		colDiv.id=itemName+"_col"
		colDiv.className="col mb-4";
		colDiv.dataset.itemData=shopItem;
		shopItemsColContainer.appendChild(colDiv)
		//Card
		var cardDiv=document.createElement("div");
		cardDiv.className="card mb-1 rounded-3 shadow-sm border-info h-100";
		colDiv.appendChild(cardDiv);
		//CardHeader
		var cardHeader=document.createElement("div");
		cardHeader.className="card-header bg-info text-dark py-3";
		cardDiv.appendChild(cardHeader);
			//CardHeader h4
			var cardHeaderH4=document.createElement("h4");
			cardHeaderH4.className="my-0 fw-bold";
			cardHeaderH4.innerHTML=shopItem.Label
			cardHeader.appendChild(cardHeaderH4)
			//CardHeader h6
			var cardHeaderH6=document.createElement("h6");
			cardHeaderH6.className="my-0 fw-bold";
			cardHeaderH6.innerHTML="("+shopItem.Category+" | "+shopItem.ItemWeight+"g)"
			cardHeader.appendChild(cardHeaderH6)
		//CardBody
		var cardBody=document.createElement("div");
		cardBody.className="card-body";
		cardDiv.appendChild(cardBody)
			//Images
			var img = document.createElement('img');
			img.className="img-fluid mb-4 mt-4"
			img.src = `nui://ox_inventory/web/images/${itemName}.png`;
			img.onerror = (event) => {
				console.log(itemName+": Error by load image");
				img.src= "images/placeholder.png";
			}
			img.style.height = '100px'; // Höhe festlegen
			img.style.width = 'auto'; // Breite automatisch anpassen
			img.alt=shopItem.Label;
			cardBody.appendChild(img)
			//Liste ul
			var ul=document.createElement("ul");
			ul.className="list-unstyled";
			cardBody.appendChild(ul);
			//Kauf
			//listitem Kaufpreis
				//KaufHeader
				var buyListItemHeader=document.createElement("li");
				buyListItemHeader.className="d-flex justify-content-between align-items-center";
				ul.appendChild(buyListItemHeader);
					var buyPrizeLabel=document.createElement("span");
					buyPrizeLabel.className="fw-bold";
					buyPrizeLabel.innerHTML="Kaufpreis:";
					buyListItemHeader.appendChild(buyPrizeLabel);
					var buyPrize=document.createElement("span");
					buyPrize.className="fw-bold";
					buyListItemHeader.appendChild(buyPrize);
				//KaufBody
				var buyListItemBody=document.createElement("li");
				buyListItemBody.className="mb-2";
				ul.appendChild(buyListItemBody)
					//KaufInputGroup
					var buyListInputGroup=document.createElement("div");
					buyListInputGroup.className="input-group"
					buyListItemBody.appendChild(buyListInputGroup)
						var buyMinButton=document.createElement("button");
						buyMinButton.className="btn btn-secondary";
						buyMinButton.type="button";
						buyMinButton.innerHTML="Min";
						buyListInputGroup.appendChild(buyMinButton);
						var buyMinusButton=document.createElement("button");
						buyMinusButton.className="btn btn-danger";
						buyMinusButton.type="button";
						buyMinusButton.innerHTML="-";
						buyListInputGroup.appendChild(buyMinusButton);
						var buyInputField=document.createElement("input");
						buyInputField.id=shopItem.Name+"_buyInput"
						buyInputField.className="form-control text-center";
						buyInputField.type="text";
						buyInputField.placeholder="0"

						buyInputField.setAttribute("pattern", "\\d*"); 
						buyInputField.addEventListener('input', function (e) {
							e.target.value = e.target.value.replace(/[^0-9]/g, '');
							if(e.target.value == ""){
								e.target.value = 0;
							}
						});
						buyListInputGroup.appendChild(buyInputField);
						var buyPlusButton=document.createElement("button");
						buyPlusButton.className="btn btn-success";
						buyPlusButton.type="button";
						buyPlusButton.innerHTML="+";
						buyListInputGroup.appendChild(buyPlusButton);
						var buyMaxButton=document.createElement("button");
						buyMaxButton.className="btn btn-secondary";
						buyMaxButton.type="button";
						buyMaxButton.innerHTML="Max";
						buyListInputGroup.appendChild(buyMaxButton);
						buyMinButton.onclick = function() {
							if(shopItem.BuyAmount!=0){
								shopItem.BuyAmount=0;
								UpdateUi(shopItem);
							}
						};
						buyMinusButton.onclick = function() {
							BuyOrSellInteraction(buyMinusButton, shopItem, "buy")
						};
						buyPlusButton.onclick = function() {
							BuyOrSellInteraction(buyPlusButton, shopItem, "buy")
						};
						buyMaxButton.onclick = function() {
							BuyOrSellInteraction(buyMaxButton, shopItem, "buy")
						};
				if(shopItem.CanBuy){
					buyPrize.innerHTML=getCurrency(shopItem.BuyCurrency)+shopItem.CurrentBuyPrize;
				}else{
					buyListItemHeader.style="visibility: hidden"
					buyListItemBody.style="visibility: hidden"
				}
			//listitem Verkaufpreis
				//VerkaufHeader
				var sellListItemHeader=document.createElement("li");
				sellListItemHeader.className="d-flex justify-content-between align-items-center";
				ul.appendChild(sellListItemHeader);
					var sellPrizeLabel=document.createElement("span");
					sellPrizeLabel.className="fw-bold";
					sellPrizeLabel.innerHTML="Verkaufpreis:";
					sellListItemHeader.appendChild(sellPrizeLabel);
					var sellPrize=document.createElement("span");
					sellPrize.className="fw-bold";
					sellPrize.innerHTML=0;
					sellListItemHeader.appendChild(sellPrize);
				//VerkaufBody
				var sellListItemBody=document.createElement("li");
				sellListItemBody.className="mb-4";
				ul.appendChild(sellListItemBody)
					//VerkaufInputGroup
					var sellListInputGroup=document.createElement("div");
					sellListInputGroup.className="input-group"
					sellListItemBody.appendChild(sellListInputGroup)
						var sellMinButton=document.createElement("button");
						sellMinButton.className="btn btn-secondary";
						sellMinButton.type="button";
						sellMinButton.innerHTML="Min";
						sellListInputGroup.appendChild(sellMinButton);
						var sellMinusButton=document.createElement("button");
						sellMinusButton.className="btn btn-danger";
						sellMinusButton.type="button";
						sellMinusButton.innerHTML="-";
						sellListInputGroup.appendChild(sellMinusButton);
						var sellInputField=document.createElement("input");
						sellInputField.id=shopItem.Name+"_sellInput"
						sellInputField.className="form-control text-center";
						sellInputField.type="text";
						sellInputField.placeholder="0"
						sellInputField.addEventListener('input', function (e) {
							e.target.value = e.target.value.replace(/[^0-9]/g, '');
							if(e.target.value == ""){
								e.target.value = 0;
							}
						});
						sellListInputGroup.appendChild(sellInputField);
						var sellPlusButton=document.createElement("button");
						sellPlusButton.className="btn btn-success";
						sellPlusButton.type="button";
						sellPlusButton.innerHTML="+";
						sellListInputGroup.appendChild(sellPlusButton);
						var sellMaxButton=document.createElement("button");
						sellMaxButton.className="btn btn-secondary";
						sellMaxButton.type="button";
						sellMaxButton.innerHTML="Max";
						sellListInputGroup.appendChild(sellMaxButton);
						sellMinButton.onclick = function() {
							if(shopItem.SellAmount!=0){
								shopItem.SellAmount=0;
								UpdateUi(shopItem);
							}
						};
						sellMinusButton.onclick = function() {
							BuyOrSellInteraction(sellMinusButton, shopItem, "sell")
						};
						sellPlusButton.onclick = function() {
							BuyOrSellInteraction(sellPlusButton, shopItem, "sell")

						};
						sellMaxButton.onclick = function() {
							BuyOrSellInteraction(sellMaxButton, shopItem, "sell")
						};
				if(shopItem.CanSell){
					sellPrize.innerHTML=getCurrency(shopItem.SellCurrency)+shopItem.CurrentSellPrize;
				}else{
					sellListItemHeader.style="visibility: hidden"
					sellListItemBody.style="visibility: hidden"
				}
				//Summary
				var summaryItemBody=document.createElement("li");
				summaryItemBody.className="list-group-item";
				ul.appendChild(summaryItemBody);
					var summaryDivItemBody=document.createElement("div");
					summaryDivItemBody.className="d-flex justify-content-between align-items-center";
					summaryItemBody.appendChild(summaryDivItemBody);
						var summaryPayTypeItemBody=document.createElement("span");
						summaryPayTypeItemBody.id=shopItem.Name+"_summaryPayType";
						summaryPayTypeItemBody.className="fw-bold";
						summaryPayTypeItemBody.innerHTML="Zu zahlen/Gutschrift:"
						summaryDivItemBody.appendChild(summaryPayTypeItemBody);
						var summaryPayPrizeItemBody=document.createElement("span");
						summaryPayPrizeItemBody.id=shopItem.Name+"_summaryPrize";
						summaryPayPrizeItemBody.className="fw-bold";
						
						summaryPayPrizeItemBody.innerHTML=getCurrency("money")+0;
						summaryDivItemBody.appendChild(summaryPayPrizeItemBody);
				shopItem.IsShowen=true;
	})
}

function CreateShopCart(){
	var shopCartItems= document.getElementById("ShopCart-Items");
	shopCartItems.innerHTML="";
	if(ShopCartData.CartItems.size>0){
		var position=1
		ShopCartData.CartItems.forEach((cartItem, itemName)=>
			{
				var newRow=document.createElement("tr");
					newRow.className="table-light align-middle";
					shopCartItems.appendChild(newRow)
					var positionCell=document.createElement("td");
					positionCell.textContent=position;
					positionCell.className="text-center";
					position++;
					newRow.appendChild(positionCell)
					var nameCell=document.createElement("td");
					nameCell.className="text-center";
					nameCell.textContent=cartItem.Label;
					newRow.appendChild(nameCell)
					var amountCell=document.createElement("td");
					amountCell.className="text-center";
					newRow.appendChild(amountCell)
					var typeCell=document.createElement("td");
					typeCell.className="text-center";
					newRow.appendChild(typeCell)
					var singlePrizeCell=document.createElement("td");
					singlePrizeCell.className="text-center";
					newRow.appendChild(singlePrizeCell)
					var getOrPayCell=document.createElement("td");
					newRow.appendChild(getOrPayCell)
					var deleteButtonCell=document.createElement("td");
					deleteButtonCell.className="text-center";
					newRow.appendChild(deleteButtonCell)
					var deleteButton=document.createElement("button");
					deleteButton.type="button";
					deleteButton.className="btn btn-danger";
					deleteButton.onclick=function() {
						ResetShopItem(cartItem)
					};
					deleteButtonCell.appendChild(deleteButton)
					var buttonImg=document.createElement("i");
					buttonImg.className="bi bi-trash3-fill";
					deleteButton.appendChild(buttonImg)
				if(cartItem.CanSell && cartItem.SellAmount>0){
					amountCell.textContent=cartItem.SellAmount;
					typeCell.textContent="Verkauf";
					singlePrizeCell.textContent=getCurrency(cartItem.SellCurrency)+cartItem.CurrentSellPrize;
					getOrPayCell.textContent=getCurrency(cartItem.SellCurrency)+(cartItem.SellAmount*+cartItem.CurrentSellPrize);
				}else if(cartItem.CanBuy && cartItem.BuyAmount>0){
					amountCell.textContent=cartItem.BuyAmount;
					typeCell.textContent="Kauf";
					singlePrizeCell.textContent=getCurrency(cartItem.BuyCurrency)+cartItem.CurrentBuyPrize;
					getOrPayCell.textContent=getCurrency(cartItem.BuyCurrency)+(cartItem.BuyAmount*+cartItem.CurrentBuyPrize);
				}
			}
		)
		var shopCartSummaryMoney=document.createElement("tr");
		var summaryWordCellMoney=document.createElement("td");
		summaryWordCellMoney.colSpan="2"
		summaryWordCellMoney.textContent="Summe (Cash und Bank):"
		shopCartSummaryMoney.appendChild(summaryWordCellMoney);
		var summaryPayKindCellMoney=document.createElement("td");
		summaryPayKindCellMoney.colSpan="3";
		summaryPayKindCellMoney.className="text-end";
		shopCartSummaryMoney.appendChild(summaryPayKindCellMoney);
		var summaryPayPrizeCellMoney=document.createElement("td");
		summaryPayPrizeCellMoney.colSpan="2";
		shopCartSummaryMoney.appendChild(summaryPayPrizeCellMoney);
		shopCartItems.appendChild(shopCartSummaryMoney);
		var totalPrizeMoney=ShopCartData.GetShouldPay("money");
		if(totalPrizeMoney>=0){
			summaryPayKindCellMoney.textContent="Zu zahlen";
			summaryPayPrizeCellMoney.textContent=currencyShort["money"]+totalPrizeMoney;
		}else{
			summaryPayKindCellMoney.textContent="Gutschrift";
			summaryPayPrizeCellMoney.textContent=currencyShort["money"]+(totalPrizeMoney*-1);
		}

		var totalPrizeBlackMoney=ShopCartData.GetShouldPay("black_money");
		if(totalPrizeBlackMoney!=0){
			var shopCartSummaryBlackMoney=document.createElement("tr");
			var summaryWordCellBlackMoney=document.createElement("td");
			summaryWordCellBlackMoney.colSpan="2"
			summaryWordCellBlackMoney.textContent="Summe (Schwarz-Geld):"
			shopCartSummaryBlackMoney.appendChild(summaryWordCellBlackMoney);
			var summaryPayKindCellBlackMoney=document.createElement("td");
			summaryPayKindCellBlackMoney.colSpan="3";
			summaryPayKindCellBlackMoney.className="text-end";
			shopCartSummaryBlackMoney.appendChild(summaryPayKindCellBlackMoney);
			var summaryPayPrizeCellBlackMoney=document.createElement("td");
			summaryPayPrizeCellBlackMoney.colSpan="2";
			shopCartSummaryBlackMoney.appendChild(summaryPayPrizeCellBlackMoney);
			shopCartItems.appendChild(shopCartSummaryBlackMoney);
			
			if(totalPrizeBlackMoney>=0){
				summaryPayKindCellBlackMoney.textContent="Zu zahlen";
				summaryPayPrizeCellBlackMoney.textContent=currencyShort["black_money"]+totalPrizeBlackMoney;
			}else{
				summaryPayKindCellBlackMoney.textContent="Gutschrift";
				summaryPayPrizeCellBlackMoney.textContent=currencyShort["black_money"]+(totalPrizeBlackMoney*-1);
			}	
		}	


		var newRowOrderButton=document.createElement("tr");
		var orderButtonCell=document.createElement("td");
		orderButtonCell.colSpan="7";
		var orderButton=document.createElement("button");
		orderButton.className="btn btn-success w-100";
		orderButton.type="button";
		orderButton.innerHTML="Bestellen";
		orderButton.removeAttribute("disabled");
		newRowOrderButton.appendChild(orderButtonCell);
		orderButtonCell.appendChild(orderButton)
		shopCartItems.appendChild(newRowOrderButton);
	}else{
		var newRow=document.createElement("tr");
		newRow.className="table-light";
		var noItemCell=document.createElement("td");
		noItemCell.className="text-center";
		noItemCell.colSpan="7";
		noItemCell.innerHTML="Es befindet sich aktuell kein Item im Warenkorb!";
		newRow.appendChild(noItemCell);
		shopCartItems.appendChild(newRow)

		var newRowOrderButton=document.createElement("tr");
		var orderButtonCell=document.createElement("td");
		orderButtonCell.colSpan="7";
		var orderButton=document.createElement("button");
		orderButton.className="btn btn-success w-100";
		orderButton.type="button";
		orderButton.innerHTML="Bestellen";
		orderButton.setAttribute("disabled","true");
		newRowOrderButton.appendChild(orderButtonCell);
		orderButtonCell.appendChild(orderButton)
		shopCartItems.appendChild(newRowOrderButton);
	}

	orderButton.onclick=function(){
		SubmitOrderShopItems()
	}
}

//#endregion

function SubmitOrderShopItems(){
	var orderItems=[]
	ShopCartData.CartItems.forEach(item=>
		orderItems.push(item)
	)
	$.post('https://' + resource +'/orderItems', JSON.stringify(orderItems)).done(function(response) {
        if (response.success) {
			var tempItemDatas=JSON.parse(response.shopitems)
			var itemDatas= Object.keys(tempItemDatas).map(key => ({
				name: key,
				...tempItemDatas[key]
			}));
			var playerData=JSON.parse(response.playerdata)
			PreInitData(playerData, itemDatas)			
			OpenOrderSuccess()
        } else {
            console.log('Error processing order!');
            // Fehlerbehandlungscode hier
        }
    })
    .fail(function(jqXHR, textStatus, errorThrown) {
        console.error('Failed to communicate with server:', textStatus, errorThrown);
        // Fehlerbehandlungscode hier
    });
}

function ResetShopItem(cartItem){
	cartItem.SellAmount=0;
	cartItem.BuyAmount=0;
	UpdateUi(cartItem);
	CreateShopCart();
}

function FilterByCategory(categoryName){
	if(CategoryShopItems.has(categoryName) && FilteredCategory!=categoryName){
		var categoryItems= CategoryShopItems.get(categoryName);
		ShopItemDatas.forEach((itemData, itemName)=>{
			if(categoryItems.has(itemName)){
				var showItem=categoryItems.get(itemName)
				if(!showItem.IsShowen){
					showItem.IsShowen=true;
					$("#"+itemName+"_col").fadeIn();
				}
			}else if(itemData.IsShowen){
				itemData.IsShowen=false;
				$("#"+itemName+"_col").fadeOut();
			}
		})
	}
	FilteredCategory=categoryName
}

function BuyOrSellInteraction(button, shopItem, interactionType){
	if(interactionType=="sell"){//sell
		switch(button.innerHTML){
			case "Max": SellMax(shopItem); break;
			case "+": SellPlus(shopItem); break;
			case "-": SellMinus(shopItem); break;
			default: console.log("BuyOrSellInteraction Sell: False Interaction"); break;
		}
	}else{//buy
		switch(button.innerHTML){
			case "Max": BuyMax(shopItem); break;
			case "+": BuyPlus(shopItem); break;
			case "-": BuyMinus(shopItem); break;
			default: console.log("BuyOrSellInteraction Buy: False Interaction"); break;
		}
		
	}
}
//Sell
function SellMax(shopItem){
	var maxSellableItemCount = 0;
	if(PlayerData.Inventory.has(shopItem.Name) && PlayerData.Inventory.get(shopItem.Name).Count>0){
		maxSellableItemCount=PlayerData.Inventory.get(shopItem.Name).Count;
		shopItem.SellAmount=maxSellableItemCount;
		shopItem.BuyAmount=0;
		UpdateUi(shopItem);
	}else{
		console.log("SellMax: Nothing to sell in inventory");
	}
}
function SellPlus(shopItem){
	var tempSellAmount=0
	var tempBuyAmount=0

	tempSellAmount=shopItem.SellAmount+1

	if (shopItem.CanBuy && shopItem.BuyAmount>0) {
		tempBuyAmount=shopItem.BuyAmount
		if(shopItem.BuyAmount<=tempSellAmount){
			tempSellAmount=tempSellAmount-tempBuyAmount;
			tempBuyAmount=0;
		}else{
			tempBuyAmount=tempBuyAmount-tempSellAmount;
			tempSellAmount=0;
		}
	}
	
	if(tempSellAmount<=0 || PlayerData.Inventory.has(shopItem.Name) && PlayerData.Inventory.get(shopItem.Name).Count>=tempSellAmount){
		shopItem.SellAmount=tempSellAmount
		shopItem.BuyAmount=tempBuyAmount
		console.log(tempSellAmount)
		UpdateUi(shopItem);
	} else{
		console.log("SellPlus: Nothing to sell in inventory");
	}
}
function SellMinus(shopItem){
	var tempSellAmount=0
	if (shopItem.SellAmount>0) {
		shopItem.SellAmount=shopItem.SellAmount-1

		UpdateUi(shopItem);
	}
}
//Buy
function BuyMax(shopItem){
	var restCarryWeight=ShopCartData.MaxCarryWeight-ShopCartData.GetWouldCarryWeightForBuyItems()
	var playerMoney=PlayerData.GetMoneyByCurrency(shopItem.BuyCurrency)-ShopCartData.GetShouldPayForBuyItems(shopItem.BuyCurrency);

	if(shopItem.CanBuy && shopItem.BuyAmount>0){
		restCarryWeight=restCarryWeight+shopItem.BuyAmount*shopItem.ItemWeight
		playerMoney=playerMoney+shopItem.BuyAmount*shopItem.CurrentBuyPrize
	}

	if (playerMoney>=shopItem.CurrentBuyPrize){
		var maxBuyableItemCountByWeight = Math.trunc(restCarryWeight/shopItem.ItemWeight)
		var maxBuyableItemCountByMoney = Math.trunc(playerMoney/shopItem.CurrentBuyPrize)
		var smallerBuyableItemCount;
		if ( maxBuyableItemCountByWeight < maxBuyableItemCountByMoney ) {
			smallerBuyableItemCount = maxBuyableItemCountByWeight;
		} else {
			smallerBuyableItemCount = maxBuyableItemCountByMoney;
		}
		if(shopItem.BuyAmount!=smallerBuyableItemCount){
			shopItem.BuyAmount=smallerBuyableItemCount
			shopItem.SellAmount=0;
			UpdateUi(shopItem);
		}
	}else{
		console.log("BuyMax: Not enough money to buy something. You could reset sell!");
	}

}
function BuyPlus(shopItem){
	var tempSellAmount=0
	var tempBuyAmount=0

	tempBuyAmount=shopItem.BuyAmount+1

	if (shopItem.CanSell && shopItem.SellAmount>0) {
		tempSellAmount=shopItem.SellAmount
		if(tempSellAmount<=tempBuyAmount){
			tempBuyAmount=tempBuyAmount-tempSellAmount;
			tempSellAmount=0;
		}else{
			tempSellAmount=tempSellAmount-tempBuyAmount;
			tempBuyAmount=0;
		}
	}


	if(tempBuyAmount<=0 
		|| ((PlayerData.GetMoneyByCurrency(shopItem.BuyCurrency)>=ShopCartData.GetShouldPayForBuyItems(shopItem.BuyCurrency)+shopItem.CurrentBuyPrize)
			&& (ShopCartData.MaxCarryWeight>=ShopCartData.GetWouldCarryWeightForBuyItems()+shopItem.ItemWeight))){
		shopItem.SellAmount=tempSellAmount
		shopItem.BuyAmount=tempBuyAmount
		console.log(tempSellAmount)
		UpdateUi(shopItem);
	} else{
		console.log("BuyPlus: Not enough Money or not enough Space!");
	}
}
function BuyMinus(shopItem){
	
	if(shopItem.BuyAmount>0){
		shopItem.BuyAmount=shopItem.BuyAmount-1
		UpdateUi(shopItem);
	}
}



function UpdateUi(shopItem){
	//ItemCart
	var totalItemPrize=0
	if(shopItem.CanSell){
		var sellInput = document.getElementById(shopItem.Name+"_sellInput");
		sellInput.value = shopItem.SellAmount;
		totalItemPrize = shopItem.SellAmount*shopItem.CurrentSellPrize*-1;

	}
	if(shopItem.CanBuy){
		var buyInput = document.getElementById(shopItem.Name+"_buyInput");
		buyInput.value = shopItem.BuyAmount
		totalItemPrize = totalItemPrize + shopItem.BuyAmount * shopItem.CurrentBuyPrize
	}
	var summaryPayType=document.getElementById(shopItem.Name+"_summaryPayType");
	var summaryPrize=document.getElementById(shopItem.Name+"_summaryPrize");
	
	
	
	if(totalItemPrize==0){
		summaryPrize.style.color="black";
		summaryPayType.innerHTML="Zu zahlen/Gutschrift:";
		summaryPrize.innerHTML= getCurrency("money")+totalItemPrize;
	}else if(totalItemPrize<0){
		summaryPrize.style.color="green";
		summaryPayType.innerHTML="Gutschrift:";
		totalItemPrize=totalItemPrize*-1
		summaryPrize.innerHTML= getCurrency(shopItem.SellCurrency)+totalItemPrize;
	}else{
		summaryPrize.style.color="red";
		summaryPayType.innerHTML="Zu zahlen:";
		summaryPrize.innerHTML= getCurrency(shopItem.BuyCurrency)+totalItemPrize;
	}

	

	if(( !shopItem.CanBuy || shopItem.BuyAmount<=0 ) && ( !shopItem.CanSell || shopItem.SellAmount<=0 )){
		ShopCartData.RemoveItem(shopItem.Name);
	}else{
		ShopCartData.AddOrUpdateItem(shopItem);
	}

	//UpdateNavBar
	var navCashBankMoney= document.getElementById("nav_cashMoney");
	navCashBankMoney.innerHTML = currencyShort["money"]+(PlayerData.GetMoneyByCurrency("money")-ShopCartData.GetShouldPayForBuyItems("money"));
	var navBlackMoney= document.getElementById("nav_black_money");
	navBlackMoney.innerHTML = currencyShort["black_money"]+(PlayerData.GetMoneyByCurrency("black_money")-ShopCartData.GetShouldPayForBuyItems("black_money"));

	var navCurrentWeight= document.getElementById("nav_weightWithBuyItems");
	var navMaxWeight= document.getElementById("nav_maxWeight");
	var wouldCurrentCarryWeight=ShopCartData.GetWouldCarryWeightForBuyItems();
	navCurrentWeight.innerHTML=(Math.trunc(wouldCurrentCarryWeight* 100) / 100)+"g";
	if(wouldCurrentCarryWeight>=maxInventoryWeight){
		navCurrentWeight.style.color="red";
		navMaxWeight.style.color="red";
	}else{
		navCurrentWeight.style.color="#3dd40f";
		navMaxWeight.style.color="#3dd40f";
	}
}


function FilterItemsIfNeeded(){

}

function getCurrency(currency){
	switch(currency){
		case "money": return currencyShort["money"];
		case "black_money": return currencyShort["black_money"];
		default: return currencyShort["default"];
	}
}

function generateRandomString(length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Zeichensatz für die Auswahl
    let result = '';
    for (let i = 0; i < length; i++) {
        const randomIndex = Math.floor(Math.random() * characters.length);
        result += characters.charAt(randomIndex);
    }
    return result;
}

function simulateTyping(element, text, interval = 200) {
	let index = 0;
	element.value="";
	const typingInterval = setInterval(() => {
		if (index < text.length) {
			element.value += text[index];
			index++;
		} else {
			clearInterval(typingInterval);
		}
	}, interval);
}

function IsNotUndefinedNorNull(obj){
	if(obj!=undefined && obj!=null){
		return true;
	}
	return false;
}

function IsNotUndefinedNorNullNorEmptyString(obj){
	if(obj!=undefined && obj!=null && typeof obj === 'string' && obj.length > 0){
		return true;
	}
	return false;
}

function NotFoundConsole(message){
	console.log('FAILURE: '+message+' not found!')
}









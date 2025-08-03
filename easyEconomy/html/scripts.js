let resource = "easyEconomy"
let currencyShort="$"

$(document).ready(function(){
	const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
	const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
	
	window.addEventListener('message', function(event) {
		var data=event.data
		switch (data.action){
			case 'close':
                    document.getElementById('displayEconomy').style.display = "none"
				break;
			//#region EconomyTablet MainEvents
			case 'openEconomy':
                    try {
                        if( data.items!=undefined &&  data.items!=null){
							var featureSettings=JSON.parse(data.featureSettings)
                            var itemDatas=JSON.parse(data.items)
							var tableEconomyItemsHeader=document.getElementById("tableEconomyItemsHeader");
							CheckFeatureSettings(featureSettings)
							FillTableEconomyItemsBody(itemDatas, featureSettings)
							document.getElementById("tableItemsTitle").innerHTML=(data.stockMarket!=undefined && data.stockMarket!=null && data.stockMarket.length > 0 ) ? data.stockMarket : "StockMarket"
                        }
                        else{
                            throw Error("data.items is empty or null")
                        }
				        document.getElementById('displayEconomy').style.display = "block"
                    } catch (error) {
                        document.getElementById('displayEconomy').style.display = "none" 
                        console.log("Error at open tablet "+error)
                        $.post('https://' + resource +'/close', JSON.stringify({}));
                    }
                    
				break;
			//#endregion 
			default:
				console.log(resource+': unknown action!');
		}
		
	});

	//#region EconomyTabletCreate helper

	//#region filter EconomyItemTable
	const searchName = document.getElementById('searchName');
    const searchCategory = document.getElementById('searchCategory');
    const tableBody = document.getElementById('tableEconomyItemsBody');

    function filterTable() {
        const nameValue = searchName.value.toLowerCase();
        const categoryValue = searchCategory.value.toLowerCase();

        for (const row of tableBody.rows) {
            const nameCell = row.cells[1].textContent.toLowerCase();
            const categoryCell = row.cells[2].textContent.toLowerCase();

			if(nameValue!="" && categoryValue==""){
				row.style.display = (nameCell.includes(nameValue)) ? '' : 'none';
			}else if(nameValue=="" && categoryValue!=""){
				row.style.display = (categoryCell.includes(categoryValue)) ? '' : 'none';
			}else{
				row.style.display = (nameCell.includes(nameValue) && categoryCell.includes(categoryValue)) ? '' : 'none';
			}
        }
    }

    searchName.addEventListener('input', filterTable);
    searchCategory.addEventListener('input', filterTable);
	//#endregion
	//#endregion
	$(document).keydown((event) => {
		if (event.which == 27) {
            CloseTablet()
		}
	})
});

function CloseTablet(){
	document.getElementById('displayEconomy').style.display = "none"
	$.post('https://' + resource +'/close', JSON.stringify({}));
}

function CheckFeatureSettings(featureSettings){
	var tableEconomyItemsSellPrize=document.getElementById("tableEconomyItemsSellPrize");
	if (featureSettings.EconomyItemsList.ShowSellPrice) {
        tableEconomyItemsSellPrize.style.display = "table-cell"; // Ankaufspreisspalte anzeigen
    } else {
        tableEconomyItemsSellPrize.style.display = "none"; // Ankaufspreisspalte ausblenden
    }
	var tableEconomyItemsBuyPrize=document.getElementById("tableEconomyItemsBuyPrize");
	if (featureSettings.EconomyItemsList.ShowBuyPrice) {
        tableEconomyItemsBuyPrize.style.display = "table-cell"; // Verkaufspreisspalte anzeigen
    } else {
        tableEconomyItemsBuyPrize.style.display = "none"; // Verkaufspreisspalte ausblenden
    }
}
//#region EconomyTabletCreate Body helper
function FillTableEconomyItemsBody(itemDatas, featureSettings) {
    const tableBody = document.getElementById('tableEconomyItemsBody');
    tableBody.innerHTML = ''; // Leeren des Inhalts des tbody-Elements

    for (const key in itemDatas) {
        if (Object.hasOwnProperty.call(itemDatas, key)) {
            const value = itemDatas[key];
            
            // Erstellen der Tabellenzeile
            let row = document.createElement('tr');

            // Erstellen der Zellen und Hinzufügen der Inhalte
            let cell1 = document.createElement('td');
            cell1.className = "text-center";
            let img = document.createElement('img');
            img.src = `nui://ox_inventory/web/images/${key}.png`;
			img.onerror = (event) => {
				console.log(key+": Error by load image")
				img.src= "images/placeholder.png";
			}
			img.style.height = '100px'; // Höhe festlegen
			img.style.width = 'auto'; // Breite automatisch anpassen

            cell1.appendChild(img);
            row.appendChild(cell1);

            let cell2 = document.createElement('td');
            cell2.textContent = value.EconomyLabel;
			cell2.className="align-middle"
            row.appendChild(cell2);

            let cell3 = document.createElement('td');
            cell3.textContent = value.Category;
			cell3.className="text-center align-middle"
            row.appendChild(cell3);

			if (featureSettings.EconomyItemsList.ShowSellPrice) {
				let cell4 = document.createElement('td');
				cell4.className = "text-center align-middle";
				cell4.textContent = value.CurrentSellPrize.toFixed(2) + currencyShort;
				row.appendChild(cell4);
			}
			if (featureSettings.EconomyItemsList.ShowBuyPrice) {
				let cell5 = document.createElement('td');
				cell5.className = "text-center align-middle";
				cell5.textContent = value.CurrentBuyPrize.toFixed(2) + currencyShort;
				row.appendChild(cell5);
			}

            // Hinzufügen der Zeile zur Tabelle
            tableBody.appendChild(row);
        }
    }
}
//#endregion

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
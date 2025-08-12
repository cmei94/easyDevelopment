let resource = "easyLicenseShop"


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
						playerInfos = typeof data.playerInfos === 'string' ? JSON.parse(data.playerInfos) : data.playerInfos
						shopInfos = typeof data.shopInfos === 'string' ? JSON.parse(data.shopInfos) : data.shopInfos
						

						var shopName=shopInfos.ShopName
						if(IsNotUndefinedNorNullNorEmptyString(shopName)){
							$("#Login-ShopName").text(shopName)
							$("#Shop-Shopname").text(shopName)
						}else{
							$("#Login-ShopName").text("Shop")
							$("#Shop-Shopname").text("Shop")
						}

						$("#Login-Content").fadeIn()
						var userNameInput = document.getElementById("userName");
						var passwordInput = document.getElementById("pwd");
						var loginButton = document.getElementById("loginButton");

						// Then your existing code will work:
						simulateTyping(userNameInput, playerInfos.FirstName + playerInfos.LastName, () => {
							$(document).on('click', "#loginButton", function(event) {
								event.preventDefault();
								OpenShop(playerInfos, shopInfos)
							});
							// Simulate typing the password after username is typed
							simulateTyping(passwordInput, generateRandomString(12), () => {
								// Enable the login button after password is typed
								loginButton.removeAttribute('disabled');
								// No automatic click - user will click manually
							});
						});

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

function CloseTablet(){
	ResetAll()
	$.post('https://' + resource +'/close', JSON.stringify({}));
}

function ResetAll(){
	$('#displayShop').fadeOut()
	$("#Shop-Content").fadeOut()
	$("#Shop-Container").fadeOut()
}

function OpenShop(playerInfos, shopInfos){
	PreLoadShop(playerInfos,shopInfos)
	$("#Login-Content").fadeOut()
	$("#Shop-Content").fadeIn()
	$("#Shop-Container").fadeIn()
}

function PreLoadShop(playerInfos, shopInfos) {
	try {

		// Clear existing items in the shop
		$("#Shop-Container-Row").empty();
		
		// Load available licenses/items
		if (IsNotUndefinedNorNull(shopInfos) 
			&& IsNotUndefinedNorNull(shopInfos.ShopInfos) 
			&& IsNotUndefinedNorNull(shopInfos.ShopInfos.Licenses)) 
		{
			Object.entries(shopInfos.ShopInfos.Licenses).forEach(([licenseId, license]) => {
				
				let itemElement = `
					<div class="col">
						<div class="card mt-3 mb-4 rounded-3 shadow-sm border-primary h-100">
							<div class="card-header bg-primary text-white py-3">
								<h4 class="my-0 fw-bold">${license.Name}</h4>
							</div>
							<div class="card-body d-flex flex-column">
								<img id="image${licenseId}" src="" class="img-fluid mb-4 d-block mx-auto" style="max-height: 200px; object-fit: contain;" alt="Basic Versicherung">
								<p class="text-muted" style="min-height: 50px;">${license.Description}</p>
								
								<!-- Payment elements positioned at bottom -->
								<div class="mt-auto">
									<ul class="list-unstyled">
										<li class="mb-3">
											<div class="d-flex justify-content-between align-items-center">
												<span class="fw-bold">Zahlungsintervall:</span>
												<span class="fw-bold">${GetPayInterval(license.PayIntervalInHours)}</span>
											</div>
										</li>
										<li class="mb-4">
											<div class="d-flex justify-content-between align-items-center">
												<span class="fw-bold">Preis:</span>
												<span class="fw-bold fs-4">$${license.Price}</span>
											</div>
										</li>
										<li>
											${CreateSubmitButton(licenseId, license.Price, playerInfos,)}
										</li>
									</ul>
								</div>
							</div>
						</div>
					</div>
				`;	
				$("#Shop-Container-Row").append(itemElement);
				var img=document.getElementById("image"+licenseId);
				img.src = "images/"+license.Image;
				img.onerror = (event) => {
					console.log(itemName+": Error by load image");
					img.src= "images/placeholder.png";
				}
			});
			
			// Add event listeners to buy buttons
			$(".item-buy-btn").click(function() {
				const itemId = $(this).data("id");
				const itemType = $(this).data("type");
				if (itemType == "buyable") {
					PurchaseLicense(itemId, playerInfos, shopInfos);
				}else if (itemType == "owned") {
					CancelLicense(itemId, playerInfos, shopInfos);
				}
			});
		} else {
			$("#Shop-Items").append("<p>No items available</p>");
		}
	} catch (error) {
		console.log("Error in PreLoadShop: " + error.message);
		console.log("Stack trace: " + error.stack);
	}
}

function CreateSubmitButton(licenseId, price, playerInfos) {
	var check="buyable";
	if (IsNotUndefinedNorNull(playerInfos.Licenses) && IsNotUndefinedNorNull(playerInfos.Licenses[licenseId])) {
		check="owned"
	}
	var buttonText="Kaufen"

	if (check=="owned"){
		buttonText="Stornieren"
	}
	else if (check=="buyable" && HasPlayerNotEnoughMoney(playerInfos.Accounts, price)) {
		check="notEnoughMoney"
		buttonText="Du hast nicht genug Geld"
	}
	if (check=="notEnoughMoney"){
		return `<button type="button" class="btn btn-primary item-buy-btn w-100" data-type="${check}"data-id="${licenseId}" disabled>${buttonText}</button>`;
	}else
	{
		return `<button type="button" class="btn btn-primary item-buy-btn w-100" data-type="${check}" data-id="${licenseId}">${buttonText}</button>`;
	}
}

function HasPlayerNotEnoughMoney(accounts, price) {
	for (const account of Object.values(accounts)) {
		if (account.label == "Bank" || account.label == "Cash") {
			if (account.money >= price) {
				return false;
			}
		}
	}
	return true;
}


function PurchaseLicense(licenseId, playerInfos, shopInfos) {
	ResetAll()
	$.post('https://' + resource +'/buyLicense', JSON.stringify(licenseId))
}

function CancelLicense(licenseId, playerInfos, shopInfos){	
	ResetAll()
	$.post('https://' + resource +'/cancelLicense', JSON.stringify(licenseId))
}

//#region Utils

function GetPayInterval(payIntervalInHours) {
	if (payIntervalInHours == 1) {
		return "stündlich"
	} else if (payIntervalInHours == 24) {
		return "täglich"
	} else if (payIntervalInHours == 168) {
		return "wöchentlich"
	} else if (payIntervalInHours == 720) {
		return "monatlich"
	} else if (payIntervalInHours == 8760) {
		return "jährlich"
	} else {
		return "Alle "+payIntervalInHours+" Stunden"
	}
}

// Simulate typing the username
function simulateTyping(element, text, callback) {
	let i = 0;
	element.value = '';
	
	function typeNextChar() {
		if (i < text.length) {
			element.value += text.charAt(i);
			i++;
			// Random delay between 50ms and 150ms for realistic typing
			setTimeout(typeNextChar, Math.random() * 100 + 50);
		} else {
			if (typeof callback === 'function') {
				callback();
			}
		}
	}
	
	typeNextChar();
}

function generateRandomString(length) {
	const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()';
	let result = '';
	for (let i = 0; i < length; i++) {
		result += chars.charAt(Math.floor(Math.random() * chars.length));
	}
	return result;
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
//#endregion utils
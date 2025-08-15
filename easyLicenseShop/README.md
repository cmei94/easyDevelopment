Deutsch
-------

`easyLicenseShop` ist eine Ressource für FiveM, die auf dem `easyCore` und dem ESX-Framework aufbaut. Sie ermöglicht es Spielern, an verschiedenen Orten auf der Karte Lizenzen (z.B. Versicherungen) von NPCs oder an Markern zu kaufen und zu verwalten.

### Features

-   **Flexible Shop-Konfiguration**: Erstelle eine beliebige Anzahl von Lizenz-Shops mit NPCs oder Markern.

-   **Interaktives UI**: Eine Tablet-Benutzeroberfläche ermöglicht es den Spielern, Lizenzen zu kaufen und zu kündigen.

-   **Automatische Zahlungen**: Die Gebühren für Lizenzen werden in konfigurierbaren Intervallen automatisch vom Bankkonto des Spielers abgebucht.

-   **Hohe Konfigurierbarkeit**: Passe jeden Aspekt der Shops an, einschließlich der Position, des NPCs/Markers, der Blips und der angebotenen Lizenzen.

-   **Integration**: Vollständige Integration in das `easyCore`-Framework.

### Abhängigkeiten

Stelle sicher, dass die folgenden Ressourcen auf deinem Server installiert sind und vor `easyLicenseShop` gestartet werden:

-   `/onesync` (muss in der server.cfg aktiviert sein)

-   `oxmysql`

-   `easyCore`

-   `es_extended`

### Installation

1.  Lade das `easyLicenseShop`-Verzeichnis herunter.

2.  Platziere den Ordner in deinem `resources`-Verzeichnis.

3.  Füge `ensure easyLicenseShop` zu deiner `server.cfg` (oder `resources.cfg`) hinzu. Achte darauf, dass es nach den oben genannten Abhängigkeiten geladen wird.

4.  Passe die Konfigurationsdatei in `shared/config.lua` an deine Bedürfnisse an. Die notwendige Datenbanktabelle `easy_licenses` wird beim ersten Start automatisch erstellt, wenn sie noch nicht existiert.

### Konfiguration

Die gesamte Konfiguration des Skripts findet in der Datei `shared/config.lua` statt.

#### `Config.LicenseShops`

In dieser Tabelle definierst du die einzelnen Shops.

-   **Struktur**: Jeder Eintrag in der Tabelle ist ein Shop, identifiziert durch einen eindeutigen Namen (z.B. `["Augury Insurance"]`).

-   **`Position`**: Die `vector4`-Koordinaten, an denen der Shop erscheinen soll.

-   **`Ped` oder `Marker`**: Entscheide, ob der Shop durch einen NPC (`Ped`) oder einen Marker dargestellt wird.

-   **`Blip`**: Konfiguriere, ob und wie der Shop auf der Weltkarte angezeigt wird.

-   **`EnableOwnMultipleLicenses`**: Legt fest, ob ein Spieler mehrere Lizenzen aus diesem Shop gleichzeitig besitzen darf.

-   **`Licenses`**: Eine Tabelle mit den Lizenzen, die in diesem Shop verkauft werden.

    -   **`Price`**: Der Kaufpreis der Lizenz.

    -   **`PayIntervalInHours`**: Das Intervall in Stunden, in dem die Lizenzgebühr fällig wird.

    -   **`Name`**: Der Anzeigename der Lizenz im UI.

    -   **`Description`**: Eine Beschreibung der Lizenz.

    -   **`Image`**: Der Dateiname des Bildes für die Lizenz, das im `html/images`-Ordner liegt.

-   **`MoneyGoesTo`**: (Optional) Das Konto, auf das die Einnahmen aus dem Verkauf von Lizenzen fließen sollen (z.B. `society_ambulance`).

**Beispiel:**

Lua

```
Config.LicenseShops = {
    ["Augury Insurance"] = {
        Position=vector4(-291.5482, -430.3445, 30.2375, 316.9496),
        Ped = {
            Enable=true,
            Model="a_m_y_business_01",
        },
        Blip={
            Enable=true,
            BlipId=76,
        },
        EnableOwnMultipleLicenses=false,
        Licenses={
            ["healthinsurance_basic"] = {
                Price=3000,
                PayIntervalInHours=24*7,
                Name="Krankenversicherung Basic",
                Description="Deckungsbetrag: Zusatzkosten komplett und 20000$ der Behandlungskosten",
                Image="healthinsurance_basic.png",
            },
        },
    }
}

```

English
-------

`easyLicenseShop` is a resource for FiveM built upon the `easyCore` and ESX framework. It allows players to purchase and manage licenses (e.g., insurance) from NPCs or at markers at various locations on the map.

### Features

-   **Flexible Shop Configuration**: Create any number of license shops with NPCs or markers.

-   **Interactive UI**: A tablet-based user interface allows players to easily buy and cancel licenses.

-   **Automatic Payments**: License fees are automatically deducted from the player's bank account at configurable intervals.

-   **Highly Configurable**: Customize every aspect of the shops, including position, NPC/marker, blips, and the licenses offered.

-   **Integration**: Fully integrated with the `easyCore` framework.

### Dependencies

Ensure the following resources are installed on your server and started before `easyLicenseShop`:

-   `/onesync` (must be enabled in server.cfg)

-   `oxmysql`

-   `easyCore`

-   `es_extended`

### Installation

1.  Download the `easyLicenseShop` directory.

2.  Place the folder in your `resources` directory.

3.  Add `ensure easyLicenseShop` to your `server.cfg` (or `resources.cfg`), making sure it is loaded after the dependencies listed above.

4.  Customize the configuration file in `shared/config.lua` to your needs. The necessary database table `easy_licenses` will be created automatically on the first start if it does not already exist.

### Configuration

The entire configuration of the script is done in the `shared/config.lua` file.

#### `Config.LicenseShops`

In this table, you define the individual shops.

-   **Structure**: Each entry in the table is a shop, identified by a unique name (e.g., `["Augury Insurance"]`).

-   **`Position`**: The `vector4` coordinates where the shop should appear.

-   **`Ped` or `Marker`**: Decide whether the shop is represented by an NPC (`Ped`) or a marker.

-   **`Blip`**: Configure if and how the shop is displayed on the world map.

-   **`EnableOwnMultipleLicenses`**: Determines whether a player can own multiple licenses from this shop at the same time.

-   **`Licenses`**: A table containing the licenses sold in this shop.

    -   **`Price`**: The purchase price of the license.

    -   **`PayIntervalInHours`**: The interval in hours at which the license fee is due.

    -   **`Name`**: The display name of the license in the UI.

    -   **`Description`**: A description of the license.

    -   **`Image`**: The filename of the image for the license, located in the `html/images` folder.

-   **`MoneyGoesTo`**: (Optional) The account to which the revenue from the sale of licenses should flow (e.g., `society_ambulance`).

**Example:**

Lua

```
Config.LicenseShops = {
    ["Augury Insurance"] = {
        Position=vector4(-291.5482, -430.3445, 30.2375, 316.9496),
        Ped = {
            Enable=true,
            Model="a_m_y_business_01",
        },
        Blip={
            Enable=true,
            BlipId=76,
        },
        EnableOwnMultipleLicenses=false,
        Licenses={
            ["healthinsurance_basic"] = {
                Price=3000,
                PayIntervalInHours=24*7,
                Name="Health Insurance Basic",
                Description="Coverage: Additional costs fully covered and $20,000 of treatment costs",
                Image="healthinsurance_basic.png",
            },
        },
    }
}
```

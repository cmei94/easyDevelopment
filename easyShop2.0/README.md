Dieses Dokument ist in Deutsch und Englisch verfügbar. This document is available in German and English.

* * * * *

Deutsch
-------

`easyShop 2.0` ist ein flexibles Shopsystem für FiveM, das es Spielern ermöglicht, an verschiedenen Orten auf der Karte mit NPCs oder Markern zu interagieren, um Gegenstände zu kaufen und zu verkaufen. Es ist Teil einer größeren Systemfamilie und auf das dynamische Wirtschaftssystem von `easyEconomy` angewiesen, um die Preise zu verwalten.

### Features von easyShop 2.0

-   **Flexible Shop-Konfiguration**: Erstelle beliebig viele Shops mit NPCs oder Markern auf der Karte.

-   **Job- & Duty-basierter Zugriff**: Beschränke den Zugang zu Shops basierend auf dem Beruf des Spielers oder der Anzahl der Spieler, die gerade im Dienst sind.

-   **Dynamische Inventare**: Shop-Inventare für den Kauf und Verkauf von Gegenständen können detailliert konfiguriert werden. Die Preise werden dynamisch aus der `easyEconomy`-Ressource bezogen.

-   **Umfassende Benutzeroberfläche**: Eine intuitive und moderne Benutzeroberfläche ermöglicht es den Spielern, einfach mit dem Shop zu interagieren, Artikel zu durchsuchen, ihren Warenkorb zu verwalten und ihr Profil einzusehen.

### Abhängigkeiten

Damit `easyShop2.0` funktioniert, müssen die folgenden Ressourcen auf dem Server vorhanden und gestartet sein:

-   `/onesync` (muss in der `server.cfg` aktiviert sein)

-   `es_extended`

-   `oxmysql`

-   `ox_inventory`

-   `easyCore`

-   `easyEconomy`

### Installation von easyShop 2.0

1.  Stelle sicher, dass alle oben genannten Abhängigkeiten in deinem `resources`-Verzeichnis vorhanden sind.

2.  Platziere den `easyShop2.0`-Ordner ebenfalls in deinem `resources`-Verzeichnis.

3.  Füge `ensure easyShop2.0` zu deiner `server.cfg` hinzu. Achte darauf, dass es **nach** den Abhängigkeiten gestartet wird. Die korrekte Lade-Reihenfolge ist entscheidend:

    Code-Snippet

    ```
    # Beispiel für die korrekte Reihenfolge in server.cfg
    ensure es_extended
    ensure oxmysql
    ensure ox_inventory

    ensure easyCore
    ensure easyEconomy

    ensure easyShop2.0

    ```

4.  Die Konfiguration der Shops erfolgt nach der Installation.

### Konfiguration

Die gesamte Konfiguration der Shops findet in der Datei `easyShop2.0/shared/shops-config.lua` statt. Die Einrichtung erfolgt in zwei Schritten: Zuerst wird das Inventar des Shops definiert und danach der Shop selbst auf der Karte platziert und konfiguriert.

#### Schritt 1: Das Inventar definieren (`Config.ShopInventories`)

In der Tabelle `Config.ShopInventories` legst du fest, welche Gegenstände ein Shop an- oder verkauft.

-   **Struktur**: Du erstellst einen Eintrag mit einem eindeutigen Namen, z.B. `["Fischmarkt"]`.

-   **`Buy`**: In dieser Tabelle listest du alle Items auf, die Spieler im Shop **kaufen** können.

-   **`Sell`**: Hier listest du alle Items auf, die Spieler an den Shop **verkaufen** können.

-   **`Currency`**: Lege fest, mit welcher Währung gehandelt wird (z.B. `'money'`, `'black_money'`).

-   **`Prize`**: Du kannst einen festen Preis eintragen. Wenn du den Wert auf `nil` setzt, wird der Preis dynamisch und automatisch aus `easyEconomy` bezogen.

**Beispiel für ein Inventar:**

Lua

```
Config.ShopInventories = {
    ["Fischmarkt"] = {
        Buy = {
            -- Spieler können Wasser kaufen, Preis kommt aus easyEconomy
            ["water"] = {Prize = nil, Currency = "money"},
        },
        Sell = {
            -- Spieler können verschiedene Fische verkaufen, Preise kommen aus easyEconomy
            ["tuna"] = {Currency = 'money', Prize = nil},
            ["salmon"] = {Currency = 'money', Prize = nil},
            -- Spieler können rohes Fleisch für Schwarzgeld verkaufen
            ["raw_meat"] = {Currency = 'black_money', Prize = nil},
        },
    },
}

```

#### Schritt 2: Den Shop erstellen (`Config.Shops`)

In der Tabelle `Config.Shops` konfigurierst du die eigentlichen Shops auf der Karte.

-   **`Position`**: Die `vector4`-Koordinaten, an denen der Shop erscheinen soll.

-   **`Marker` oder `Ped`**: Entscheide, ob der Shop durch einen Marker oder einen NPC (Ped) dargestellt wird. Du musst eine der beiden Optionen aktivieren (`Enable=true`).

-   **`Blip`**: Aktiviere hier, ob der Shop auf der Weltkarte mit einem Icon markiert werden soll.

-   **Zugriffsbeschränkungen**:

    -   `JobAccess`: Legt fest, welcher Job (`["police"]`) mit welchem Mindest-Rang (`=0`) Zugriff hat.

    -   `OpenByJobDutyCount`: Erfordert eine Mindestanzahl an Spielern im Dienst (`["police"]=1`), damit der Shop zugänglich ist.

-   **`Inventory`**: Hier verknüpfst du den Shop mit einem zuvor definierten Inventar aus `Config.ShopInventories` (z.B. `Config.ShopInventories["Fischmarkt"]`).

**Beispiel für einen Shop:**

Lua

```
Config.Shops = {
    ["Fischverkaeufer_am_Pier"] = {
        Position = vector4(-187.95, -744.13, 219.07, 71.76),
        Ped = {
            Enable = true,
            PedModel = "a_m_m_acult_01"
        },
        Marker = {
            Enable = false,
        },
        Blip = {
            Enable = true,
            BlipId = 476,
        },
        JobAccess = {
            ["fisher"] = 0 -- Nur Fischer (alle Ränge) haben Zugriff
        },
        Inventory = Config.ShopInventories["Fischmarkt"]
    }
}

```

* * * * *

English
-------

`easyShop 2.0` is a flexible shop system for FiveM that allows players to interact with NPCs or markers at various locations on the map to buy and sell items. It is part of a larger ecosystem and relies on the `easyEconomy` resource to manage dynamic pricing.

### Features of easyShop 2.0

-   **Flexible Shop Configuration**: Create an unlimited number of shops using either NPCs or map markers.

-   **Job & Duty-Based Access**: Restrict shop access based on a player's job or the number of players currently on duty for a specific job.

-   **Dynamic Inventories**: Shop inventories for buying and selling items can be configured in detail. Prices are dynamically pulled from the `easyEconomy` resource.

-   **Comprehensive User Interface**: An intuitive and modern UI allows players to easily interact with the shop, browse items, manage their cart, and view their profile.

### Dependencies

For `easyShop2.0` to work, the following resources must be present and started on the server:

-   `/onesync` (must be enabled in `server.cfg`)

-   `es_extended`

-   `oxmysql`

-   `ox_inventory`

-   `easyCore`

-   `easyEconomy`

### Installing easyShop 2.0

1.  Ensure all the dependencies listed above are present in your `resources` directory.

2.  Place the `easyShop2.0` folder into your `resources` directory as well.

3.  Add `ensure easyShop2.0` to your `server.cfg`. Make sure it is started **after** its dependencies. The correct load order is crucial for it to work:

    Code-Snippet

    ```
    # Example of the correct order in server.cfg
    ensure es_extended
    ensure oxmysql
    ensure ox_inventory

    ensure easyCore
    ensure easyEconomy

    ensure easyShop2.0

    ```

4.  Shop configuration can be done after the installation.

### Configuration

All shop configuration is handled in the `easyShop2.0/shared/shops-config.lua` file. The setup is a two-step process: First, you define the shop's inventory, and then you place and configure the shop itself on the map.

#### Step 1: Defining the Inventory (`Config.ShopInventories`)

In the `Config.ShopInventories` table, you specify which items a shop buys or sells.

-   **Structure**: You create an entry with a unique name, e.g., `["FishMarket"]`.

-   **`Buy`**: In this table, you list all items that players can **buy** from the shop.

-   **`Sell`**: Here, you list all items that players can **sell** to the shop.

-   **`Currency`**: Define the currency used for transactions (e.g., `'money'`, `'black_money'`).

-   **`Prize`**: You can set a fixed price. If you set the value to `nil`, the price will be dynamically and automatically fetched from `easyEconomy`.

**Example of an inventory:**

Lua

```
Config.ShopInventories = {
    ["FishMarket"] = {
        Buy = {
            -- Players can buy water, price comes from easyEconomy
            ["water"] = {Prize = nil, Currency = "money"},
        },
        Sell = {
            -- Players can sell various fish, prices come from easyEconomy
            ["tuna"] = {Currency = 'money', Prize = nil},
            ["salmon"] = {Currency = 'money', Prize = nil},
            -- Players can sell raw meat for black money
            ["raw_meat"] = {Currency = 'black_money', Prize = nil},
        },
    },
}

```

#### Step 2: Creating the Shop (`Config.Shops`)

In the `Config.Shops` table, you configure the actual shops on the map.

-   **`Position`**: The `vector4` coordinates where the shop should appear.

-   **`Marker` or `Ped`**: Decide whether the shop is represented by a marker or an NPC (Ped). You must enable one of the two options (`Enable=true`).

-   **`Blip`**: Enable this to mark the shop on the world map with an icon.

-   **Access Restrictions**:

    -   `JobAccess`: Defines which job (`["police"]`) with which minimum grade (`=0`) has access.

    -   `OpenByJobDutyCount`: Requires a minimum number of players on duty (`["police"]=1`) for the shop to be accessible.

-   **`Inventory`**: Here, you link the shop to a previously defined inventory from `Config.ShopInventories` (e.g., `Config.ShopInventories["FishMarket"]`).

**Example of a shop:**

Lua

```
Config.Shops = {
    ["FishVendor_At_The_Pier"] = {
        Position = vector4(-187.95, -744.13, 219.07, 71.76),
        Ped = {
            Enable = true,
            PedModel = "a_m_m_acult_01"
        },
        Marker = {
            Enable = false,
        },
        Blip = {
            Enable = true,
            BlipId = 476,
        },
        JobAccess = {
            ["fisher"] = 0 -- Only fishers (all grades) have access
        },
        Inventory = Config.ShopInventories["FishMarket"]
    }
}
```
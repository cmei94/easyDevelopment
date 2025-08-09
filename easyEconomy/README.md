easyEconomy - Dokumentation / Documentation
===========================================

Dieses Dokument ist in Deutsch und Englisch verfügbar.

This document is available in German and English.

Deutsch
-------

`easyEconomy` ist eine Ressource für FiveM, die auf dem `easyCore` und dem ESX-Framework aufbaut. Sie implementiert ein dynamisches Wirtschaftssystem, das auf Angebot und Nachfrage basiert, um die Preise von Gegenständen variabel zu gestalten und so eine realistische und sich über die Zeit verändernde Wirtschaft auf deinem Server zu simulieren.

### Features

-   Dynamisches Preissystem: Kauf- und Verkaufspreise passen sich automatisch an, je nachdem, wie oft Gegenstände von Spielern ge- oder verkauft werden.

-   Komplexe Einflussfaktoren: Die Wirtschaft wird nicht nur durch Angebot und Nachfrage, sondern auch durch konfigurierbare Quer-Einflüsse zwischen Gegenständen, Kategorien und sogar Spieler-Berufen beeinflusst.

-   Börsen (Stock Markets): Du kannst beliebig viele Orte (sowohl mit als auch ohne NPC) auf der Karte definieren, an denen Spieler die aktuellen Preise einsehen und handeln können.

-   Tablet-UI: Eine übersichtliche Benutzeroberfläche zeigt die aktuellen Marktpreise an. Sie ist über eine konfigurierbare Taste an den Börsen zugänglich.

-   Hohe Konfigurierbarkeit: Nahezu jeder Aspekt des Systems lässt sich über gut strukturierte Konfigurationsdateien anpassen.

-   Logging: Vollständige Integration in das Logging-System von `easyCore`, um alle wichtigen wirtschaftlichen Transaktionen nachzuverfolgen.

-   Automatischer Preis-Reset: Die Preise können nach einer einstellbaren Zeitspanne automatisch auf ihre Standardwerte zurückgesetzt werden, um eine unkontrollierte Inflation oder Deflation zu verhindern.

### Abhängigkeiten

Stelle sicher, dass die folgenden Ressourcen auf deinem Server installiert sind und vor `easyEconomy` gestartet werden:

-   `/onesync` (muss in der server.cfg aktiviert sein)

-   `oxmysql`

-   `easyCore`

-   `es_extended`

-   `ox_inventory` (wird für die Anzeige von Gegenstandsbildern in der UI benötigt)

### Installation

1.  Lade das `easyEconomy`-Verzeichnis herunter.

2.  Platziere den Ordner in deinem `resources`-Verzeichnis.

3.  Füge `ensure easyEconomy` zu deiner `server.cfg` (oder `resources.cfg`) hinzu. Achte darauf, dass es nach den oben genannten Abhängigkeiten geladen wird.

4.  Passe die Konfigurationsdateien im `shared/`-Verzeichnis an deine Bedürfnisse an. Die notwendigen Datenbanktabellen werden beim Start der Ressource automatisch erstellt, falls sie noch nicht existieren.

### Konfiguration im Detail

Die gesamte Konfiguration des Skripts findet in den Lua-Dateien im `shared/`-Verzeichnis statt. Hier kannst du das System bis ins kleinste Detail anpassen.

#### `shared/config.lua` - Die Hauptkonfiguration

Diese Datei enthält die grundlegenden Einstellungen für das Wirtschaftssystem.

-   `Config.Features`

    -   `useLogging`: (`true`/`false`) - Aktiviert das Logging von Kauf- und Verkaufsaktionen über `easyCore`.

    -   `autoInitItemsInDatabase`: (`true`/`false`) - Wenn `true`, sorgt das Skript beim Start dafür, dass alle in `ox_inventory` registrierten Items in der Datenbank vorhanden sind. Es wird empfohlen, diese Einstellung auf `true` zu belassen.

    -   `autoResetItemsToDefaultPrice`: (`true`/`false`) - Aktiviert den automatischen Preis-Reset.

    -   `resetTimer`: (Zahl in Minuten) - Definiert das Intervall für den automatischen Preis-Reset (z.B. `1440` für 24 Stunden).

-   `Config.Database`: Definiert die Namen der Datenbanktabellen.

-   `Config.Tablet`: Einstellungen für das Tablet-UI.

-   `Config.StockMarket`: Definiere einzelne Börsen mit Koordinaten, NPCs, Markern, Blips und spezifischen Handels-Einstellungen (`items`, `categories`, `showAllItems`).

#### `shared/influence.lua` - Die Beeinflussungs-Logik

Diese Datei ist das Herzstück der dynamischen Wirtschaft. Hier legst du fest, wie sich verschiedene Aktionen auf die Preise auswirken.

##### Wichtige Information: Priorität der Einflüsse

Das Skript prüft die Konfiguration in einer festen Reihenfolge. Sobald eine passende Regel gefunden wird, wird diese angewendet:

1.  Höchste Priorität: `Config.ItemInfluence`

2.  Zweite Priorität: `Config.CategoryInfluence`

3.  Letzte Priorität: Standard-Verhalten

Zusammenfassung der Priorität: `ItemInfluence` -> `CategoryInfluence` -> `Standard-Verhalten`

Absolut Wichtig: Unabhängig von den oben genannten Regeln wird der Preis des gehandelten Items selbst immer beeinflusst. Die Konfigurationen fügen nur zusätzliche Effekte hinzu.

##### `Config.ItemInfluence` (Höchste Priorität)

Hier definierst du Regeln für einzelne, spezifische Items.

-   Struktur: Der Schlüssel der Tabelle ist der Name des Items (z.B. `["wool"]`).

    -   `InfluenceToCategories`: Eine Liste von Kategorie-Namen, deren Preise ebenfalls beeinflusst werden sollen.

    -   `InfluenceToItems`: Eine Liste von Item-Namen, deren Preise ebenfalls beeinflusst werden sollen.

    -   `InfluenceByJob`: Eine Tabelle, um temporäre Preisänderungen basierend auf der Anzahl der Spieler in einem bestimmten Beruf zu definieren.

Code-Beispiel:

Lua

```
Config.ItemInfluence = {
    ["wool"] = { -- Wenn "Wolle" gehandelt wird...
        -- Beeinflusse zusätzlich die Preise aller Items in der Kategorie "clothing"
        InfluenceToCategories = { "clothing" },

        -- Beeinflusse zusätzlich die Preise der Items "fabric" und "thread"
        InfluenceToItems = { "fabric", "thread" },

        -- Wenn mindestens 2 Schneider ("tailor") online sind...
        InfluenceByJob = {
            ["tailor"] = {
                Count = 2,
                SellPriceInfluence = 15,  -- ...erhöhe den Verkaufspreis für Wolle um 15
                BuyPriceInfluence = -5, -- ...und senke den Einkaufspreis für Wolle um 5
            },
        }
    },
    ["eisenbarren"] = { -- Wenn "Eisenbarren" gehandelt werden...
        -- Beeinflusse nur spezifische Items, keine ganzen Kategorien
        InfluenceToItems = { "stahlbarren", "advancedlockpick" },
    }
}

```

##### `Config.CategoryInfluence` (Zweite Priorität)

Dies ist der Fallback, wenn keine `ItemInfluence`-Regel gefunden wurde.

-   Struktur: Der Schlüssel der Tabelle ist der Name der Kategorie (z.B. `["drugs"]`).

    -   `InfluenceToCategories`: Eine Liste von anderen Kategorie-Namen, die ebenfalls beeinflusst werden sollen.

    -   `InfluenceByJob`: Funktioniert exakt wie bei `ItemInfluence`, beeinflusst aber alle Items der hier definierten Kategorie.

Code-Beispiel:

Lua

```
Config.CategoryInfluence = {
    ["drugs"] = { -- Wenn ein Item der Kategorie "drugs" gehandelt wird...
        -- ...und keine spezifische Regel in ItemInfluence existiert...

        -- Beeinflusse auch die Preise aller Items in der Kategorie "weapons"
        InfluenceToCategories = { "weapons" },

        InfluenceByJob = {
            ["police"] = {
                Count = 5,
                SellPriceInfluence = 50, -- Erhöhe den Verkaufspreis für alle Drogen um 50
                BuyPriceInfluence = -30, -- Senke den Einkaufspreis für alle Drogen um 30
            },
        }
    },
}

```

### API-Nutzung & Events

-   API-Funktionen:

    -   Export holen:

        Lua

        ```
        -- In einem client- oder serverseitigen Skript
        local EasyEconomy = exports['easyEconomy']:GetEconomySystem()

        ```

    -   Preise abfragen:

        Lua

        ```
        -- Alle Preise abfragen
        local allItems = EasyEconomy.GetEconomyItems()

        -- Preise für spezifische Items abfragen
        local specificItems = EasyEconomy.GetEconomyItems({ "bread", "water" })

        ```

    -   Verkauf melden:

        Lua

        ```
        -- Spieler verkauft 10 Brote und 5 Wasser
        local soldItems = {
            ["bread"] = 10,
            ["water"] = 5
        }
        EasyEconomy.SellItems(soldItems)

        ```

    -   Kauf melden:

        Lua

        ```
        -- Spieler kauft 2 Dietriche
        local boughtItems = {
            ["lockpick"] = 2
        }
        EasyEconomy.BuyItems(boughtItems)

        ```

-   Hook-System:

    -   Hook registrieren:

        Lua

        ```
        -- In einem serverseitigen Skript
        local EasyEconomy = exports['easyEconomy']:GetEconomySystem()

        EasyEconomy.RegisterHook("refreshReadEconomyItems", function(payload)
            if payload.WasRefreshed then
                print("Die Wirtschaftspreise wurden aktualisiert. Auslöser: " .. payload.TrigeredBy)
                -- Hier könntest du z.B. eine Discord-Nachricht senden.
            end
        end)

        ```

    -   `EasyEconomy.RemoveHook(id)`: Entfernt einen Hook.

    -   Verfügbares Event: `refreshReadEconomyItems` (wird bei Preis-Updates ausgelöst).

English
-------

`easyEconomy` is a resource for FiveM, built upon the `easyCore` and ESX framework. It implements a dynamic economy system based on supply and demand to create variable item prices, simulating a realistic and evolving economy on your server.

### Features

-   Dynamic Pricing System: Buy and sell prices automatically adjust based on how often items are bought or sold by players.

-   Complex Influence Factors: The economy is influenced not just by supply and demand, but also by configurable cross-influences between items, categories, and even player jobs.

-   Stock Markets: You can define any number of locations (with or without NPCs) on the map where players can view current prices and trade items.

-   Tablet UI: A clean user interface displays the current market prices, accessible via a configurable key at the stock markets.

-   Highly Configurable: Nearly every aspect of the system can be customized through well-structured configuration files.

-   Logging: Full integration with the `easyCore` logging system to track all important economic transactions.

-   Automatic Price Reset: Prices can be automatically reset to their default values after a configurable amount of time to prevent uncontrolled inflation or deflation.

### Dependencies

Ensure the following resources are installed on your server and started before `easyEconomy`:

-   `/onesync` (must be enabled in server.cfg)

-   `oxmysql`

-   `easyCore`

-   `es_extended`

-   `ox_inventory` (required for displaying item images in the UI)

### Installation

1.  Download the `easyEconomy` directory.

2.  Place the folder in your `resources` directory.

3.  Add `ensure easyEconomy` to your `server.cfg` (or `resources.cfg`), making sure it is loaded after the dependencies listed above.

4.  Customize the configuration files in the `shared/` directory to your needs. The necessary database tables will be created automatically when the resource starts if they do not already exist.

### Configuration in Detail

The entire configuration of the script is done in the Lua files within the `shared/` directory.

#### `shared/config.lua` - Main Configuration

This file contains the basic settings for the economy system.

-   `Config.Features`

    -   `useLogging`: (`true`/`false`) - Enables logging of buy and sell actions via `easyCore`.

    -   `autoInitItemsInDatabase`: (`true`/`false`) - If `true`, the script ensures that all items registered in `ox_inventory` exist in the database on startup. It's recommended to keep this `true`.

    -   `autoResetItemsToDefaultPrice`: (`true`/`false`) - Enables the automatic price reset.

    -   `resetTimer`: (Number in minutes) - Defines the interval for the automatic price reset (e.g., `1440` for 24 hours).

-   `Config.Database`: Defines the names of the database tables.

-   `Config.Tablet`: Settings for the tablet UI.

-   `Config.StockMarket`: Define individual stock markets with coordinates, NPCs, markers, blips, and specific trading settings (`items`, `categories`, `showAllItems`).

#### `shared/influence.lua` - The Influence Logic

This file is the core of the dynamic economy.

##### IMPORTANT INFORMATION: Priority of Influences

The script checks the configuration in a specific order. The first matching rule found is applied:

1.  Highest Priority: `Config.ItemInfluence`

2.  Second Priority: `Config.CategoryInfluence`

3.  Last Priority: Default Behavior

Summary of Priority: `ItemInfluence` -> `CategoryInfluence` -> `Default Behavior`

Crucially Important: Regardless of the rules above, the price of the traded item itself is always influenced. The configurations only add extra effects.

##### `Config.ItemInfluence` (Highest Priority)

Define rules for specific, individual items.

-   Structure: The key of the table is the item name (e.g., `["wool"]`).

    -   `InfluenceToCategories`: A list of category names whose prices should also be influenced.

    -   `InfluenceToItems`: A list of item names whose prices should also be influenced.

    -   `InfluenceByJob`: A table to define temporary price changes based on the number of players in a specific job.

Code Example:

Lua

```
Config.ItemInfluence = {
    ["wool"] = { -- When "wool" is traded...
        -- Also influence the prices of all items in the "clothing" category
        InfluenceToCategories = { "clothing" },

        -- Also influence the prices of the items "fabric" and "thread"
        InfluenceToItems = { "fabric", "thread" },

        -- If at least 2 tailors are online...
        InfluenceByJob = {
            ["tailor"] = {
                Count = 2,
                SellPriceInfluence = 15,  -- ...increase the sell price for wool by 15
                BuyPriceInfluence = -5, -- ...and decrease the buy price for wool by 5
            },
        }
    },
    ["iron_ingot"] = { -- When "iron_ingot" is traded...
        -- Only influence specific items, not whole categories
        InfluenceToItems = { "steel_ingot", "advancedlockpick" },
    }
}

```

##### `Config.CategoryInfluence` (Second Priority)

This is the fallback if no `ItemInfluence` rule is found.

-   Structure: The key of the table is the category name (e.g., `["drugs"]`).

    -   `InfluenceToCategories`: A list of other category names to be influenced.

    -   `InfluenceByJob`: Works exactly like in `ItemInfluence`, but affects all items in the defined category.

Code Example:

Lua

```
Config.CategoryInfluence = {
    ["drugs"] = { -- When an item from the "drugs" category is traded...
        -- ...and no specific rule exists in ItemInfluence...

        -- Also influence the prices of all items in the "weapons" category
        InfluenceToCategories = { "weapons" },

        InfluenceByJob = {
            ["police"] = {
                Count = 5,
                SellPriceInfluence = 50, -- Increase the sell price for all drugs by 50
                BuyPriceInfluence = -30, -- Decrease the buy price for all drugs by 30
            },
        }
    },
}

```

### API Usage & Events

-   API Functions:

    -   Get the export:

        Lua

        ```
        -- In a client or server-side script
        local EasyEconomy = exports['easyEconomy']:GetEconomySystem()

        ```

    -   Get prices:

        Lua

        ```
        -- Get all prices
        local allItems = EasyEconomy.GetEconomyItems()

        -- Get prices for specific items
        local specificItems = EasyEconomy.GetEconomyItems({ "bread", "water" })

        ```

    -   Report a sale:

        Lua

        ```
        -- Player sells 10 bread and 5 water
        local soldItems = {
            ["bread"] = 10,
            ["water"] = 5
        }
        EasyEconomy.SellItems(soldItems)

        ```

    -   Report a purchase:

        Lua

        ```
        -- Player buys 2 lockpicks
        local boughtItems = {
            ["lockpick"] = 2
        }
        EasyEconomy.BuyItems(boughtItems)

        ```

-   Hook System:

    -   Register a hook:

        Lua

        ```
        -- In a server-side script
        local EasyEconomy = exports['easyEconomy']:GetEconomySystem()

        EasyEconomy.RegisterHook("refreshReadEconomyItems", function(payload)
            if payload.WasRefreshed then
                print("Economy prices have been updated. Triggered by: " .. payload.TrigeredBy)
                -- You could, for example, send a Discord message here.
            end
        end)

        ```

    -   `EasyEconomy.RemoveHook(id)`: Removes a hook.

    -   Available Event: `refreshReadEconomyItems` (triggered on price updates).

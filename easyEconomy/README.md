# easyEconomy - Dokumentation / Documentation

Dieses Dokument ist in Deutsch und Englisch verfügbar.

This document is available in German and English.

## Deutsch

### Features

- Dynamisches Preissystem: Kauf- und Verkaufspreise passen sich automatisch an, je nachdem, wie oft Gegenstände von Spielern ge- oder verkauft werden.
- Komplexe Einflussfaktoren: Die Wirtschaft wird nicht nur durch Angebot und Nachfrage, sondern auch durch konfigurierbare Quer-Einflüsse zwischen Gegenständen, Kategorien und sogar Spieler-Berufen beeinflusst.
- Börsen (Stock Markets): Du kannst beliebig viele Orte (sowohl mit als auch ohne NPC) auf der Karte definieren, an denen Spieler die aktuellen Preise einsehen und handeln können.
- Tablet-UI: Eine übersichtliche Benutzeroberfläche zeigt die aktuellen Marktpreise an. Sie ist über eine konfigurierbare Taste an den Börsen zugänglich.
- Hohe Konfigurierbarkeit: Nahezu jeder Aspekt des Systems lässt sich über gut strukturierte Konfigurationsdateien anpassen.
- Logging: Vollständige Integration in das Logging-System von `easyCore`, um alle wichtigen wirtschaftlichen Transaktionen nachzuverfolgen.
- Automatischer Preis-Reset: Die Preise können nach einer einstellbaren Zeitspanne automatisch auf ihre Standardwerte zurückgesetzt werden, um eine unkontrollierte Inflation oder Deflation zu verhindern.

### Abhängigkeiten

Stelle sicher, dass die folgenden Ressourcen auf deinem Server installiert sind und vor `easyEconomy` gestartet werden:

- `/onesync` (muss in der server.cfg aktiviert sein)
- `oxmysql`
- `easyCore`
- `es_extended`
- `ox_inventory` (wird für die Anzeige von Gegenstandsbildern in der UI benötigt)

### Installation

1.  Lade das `easyEconomy`-Verzeichnis herunter.
2.  Platziere den Ordner in deinem `resources`-Verzeichnis.
3.  Füge `ensure easyEconomy` zu deiner `server.cfg` (oder `resources.cfg`) hinzu. Achte darauf, dass es nach den oben genannten Abhängigkeiten geladen wird.
    ```
    # Beispiel für die Lade-Reihenfolge
    ensure es_extended
    ensure oxmysql
    ensure easyCore
    ensure ox_inventory

    ensure easyEconomy
    ```
4.  Passe die Konfigurationsdateien im `shared/`-Verzeichnis an deine Bedürfnisse an. Die notwendigen Datenbanktabellen werden beim Start der Ressource automatisch erstellt, falls sie noch nicht existieren.

### Konfiguration im Detail

Die gesamte Konfiguration des Skripts findet in den Lua-Dateien im `shared/`-Verzeichnis statt. Hier kannst du das System bis ins kleinste Detail anpassen.

#### `shared/config.lua` - Die Hauptkonfiguration

Diese Datei enthält die grundlegenden Einstellungen für das Wirtschaftssystem.

- `Config.Features`
    - `useLogging`: (`true`/`false`) - Aktiviert das Logging von Kauf- und Verkaufsaktionen über `easyCore`.
    - `autoInitItemsInDatabase`: (`true`/`false`) - Wenn `true`, sorgt das Skript beim Start dafür, dass alle in `ox_inventory` registrierten Items in der Datenbank vorhanden sind. Es wird empfohlen, diese Einstellung auf `true` zu belassen.
    - `autoResetItemsToDefaultPrice`: (`true`/`false`) - Aktiviert den automatischen Preis-Reset.
    - `resetTimer`: (Zahl in Minuten) - Definiert das Intervall für den automatischen Preis-Reset (z.B. `1440` für 24 Stunden).
- `Config.Database`: Definiert die Namen der Datenbanktabellen.
- `Config.Tablet`: Einstellungen für das Tablet-UI.
- `Config.StockMarket`: Definiere einzelne Börsen mit Koordinaten, NPCs, Markern, Blips und spezifischen Handels-Einstellungen (`items`, `categories`, `showAllItems`).

#### `shared/influence.lua` - Die Beeinflussungs-Logik

Diese Datei ist das Herzstück der dynamischen Wirtschaft. Hier legst du fest, wie sich verschiedene Aktionen auf die Preise auswirken.

##### Wichtige Information: Priorität der Einflüsse

Das Skript prüft die Konfiguration in einer festen Reihenfolge. Sobald eine passende Regel gefunden wird, wird diese angewendet:

1.  Höchste Priorität: `Config.ItemInfluence`
    - Das Skript prüft zuerst, ob für das gehandelte Item ein spezifischer Eintrag hier existiert.
2.  Zweite Priorität: `Config.CategoryInfluence`
    - Wenn für das Item kein Eintrag in `ItemInfluence` gefunden wird, wird geprüft, ob für die Kategorie des Items ein Eintrag hier existiert.
3.  Letzte Priorität: Standard-Verhalten
    - Wird in keiner der beiden Konfigurationen eine Regel gefunden, wird nur die Kategorie des gehandelten Items selbst beeinflusst.

Zusammenfassung der Priorität: `ItemInfluence` -> `CategoryInfluence` -> `Standard-Verhalten`

Absolut Wichtig: Unabhängig von den oben genannten Regeln wird der Preis des gehandelten Items selbst immer beeinflusst. Die Konfigurationen fügen nur zusätzliche Effekte hinzu.

##### `Config.ItemInfluence` (Höchste Priorität)

Hier definierst du Regeln für einzelne, spezifische Items.

- Struktur: Der Schlüssel der Tabelle ist der Name des Items (z.B. `["wool"]`).
    - `InfluenceToCategories`: Eine Liste von Kategorie-Namen, deren Preise ebenfalls beeinflusst werden sollen.
    - `InfluenceToItems`: Eine Liste von Item-Namen, deren Preise ebenfalls beeinflusst werden sollen.
    - `InfluenceByJob`: Eine Tabelle, um temporäre Preisänderungen basierend auf der Anzahl der Spieler in einem bestimmten Beruf zu definieren.
        - `Count`: Die Mindestanzahl an Spielern in diesem Job, damit die Regel aktiv wird.
        - `SellPriceInfluence`: Ein Wert, der zum Verkaufspreis addiert (positiv) oder subtrahiert (negativ) wird.
        - `BuyPriceInfluence`: Ein Wert, der zum Kaufpreis addiert oder subtrahiert wird.

##### `Config.CategoryInfluence` (Zweite Priorität)

Dies ist der Fallback, wenn keine `ItemInfluence`-Regel gefunden wurde.

- Struktur: Der Schlüssel der Tabelle ist der Name der Kategorie (z.B. `["drugs"]`).
    - `InfluenceToCategories`: Eine Liste von anderen Kategorie-Namen, die ebenfalls beeinflusst werden sollen.
    - `InfluenceByJob`: Funktioniert exakt wie bei `ItemInfluence`, beeinflusst aber alle Items der hier definierten Kategorie.

### API-Nutzung & Events

- API-Funktionen:
    - Export holen:
        ```
        -- In einem client- oder serverseitigen Skript
        local EasyEconomy = exports['easyEconomy']:GetEconomySystem()
        ```
    - Preise abfragen:
        ```
        -- Alle Preise abfragen
        local allItems = EasyEconomy.GetEconomyItems()

        -- Preise für spezifische Items abfragen
        local specificItems = EasyEconomy.GetEconomyItems({ "bread", "water" })
        ```
    - Verkauf melden:
        ```
        -- Spieler verkauft 10 Brote und 5 Wasser
        local soldItems = {
            ["bread"] = 10,
            ["water"] = 5
        }
        EasyEconomy.SellItems(soldItems)
        ```
    - Kauf melden:
        ```
        -- Spieler kauft 2 Dietriche
        local boughtItems = {
            ["lockpick"] = 2
        }
        EasyEconomy.BuyItems(boughtItems)
        ```
- Hook-System:
    - Hook registrieren:
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
    - `EasyEconomy.RemoveHook(id)`: Entfernt einen Hook.
    - Verfügbares Event: `refreshReadEconomyItems` (wird bei Preis-Updates ausgelöst).

## English

### Features

- Dynamic Pricing System: Buy and sell prices automatically adjust based on how often items are bought or sold by players.
- Complex Influence Factors: The economy is influenced not just by supply and demand, but also by configurable cross-influences between items, categories, and even player jobs.
- Stock Markets: You can define any number of locations (with or without NPCs) on the map where players can view current prices and trade items.
- Tablet UI: A clean user interface displays the current market prices, accessible via a configurable key at the stock markets.
- Highly Configurable: Nearly every aspect of the system can be customized through well-structured configuration files.
- Logging: Full integration with the `easyCore` logging system to track all important economic transactions.
- Automatic Price Reset: Prices can be automatically reset to their default values after a configurable amount of time to prevent uncontrolled inflation or deflation.

### Dependencies

Ensure the following resources are installed on your server and started before `easyEconomy`:

- `/onesync` (must be enabled in server.cfg)
- `oxmysql`
- `easyCore`
- `es_extended`
- `ox_inventory` (required for displaying item images in the UI)

### Installation

1.  Download the `easyEconomy` directory.
2.  Place the folder in your `resources` directory.
3.  Add `ensure easyEconomy` to your `server.cfg` (or `resources.cfg`), making sure it is loaded after the dependencies listed above.
    ```
    # Example load order
    ensure es_extended
    ensure oxmysql
    ensure easyCore
    ensure ox_inventory

    ensure easyEconomy
    ```
4.  Customize the configuration files in the `shared/` directory to your needs. The necessary database tables will be created automatically when the resource starts if they do not already exist.

### Configuration in Detail

The entire configuration of the script is done in the Lua files within the `shared/` directory.

#### `shared/config.lua` - Main Configuration

This file contains the basic settings for the economy system.

- `Config.Features`
    - `useLogging`: (`true`/`false`) - Enables logging of buy and sell actions via `easyCore`.
    - `autoInitItemsInDatabase`: (`true`/`false`) - If `true`, the script ensures that all items registered in `ox_inventory` exist in the database on startup. It's recommended to keep this `true`.
    - `autoResetItemsToDefaultPrice`: (`true`/`false`) - Enables the automatic price reset.
    - `resetTimer`: (Number in minutes) - Defines the interval for the automatic price reset (e.g., `1440` for 24 hours).
- `Config.Database`: Defines the names of the database tables.
- `Config.Tablet`: Settings for the tablet UI.
- `Config.StockMarket`: Define individual stock markets with coordinates, NPCs, markers, blips, and specific trading settings (`items`, `categories`, `showAllItems`).

#### `shared/influence.lua` - The Influence Logic

This file is the core of the dynamic economy.

##### IMPORTANT INFORMATION: Priority of Influences

The script checks the configuration in a specific order. The first matching rule found is applied:

1.  Highest Priority: `Config.ItemInfluence`
    - The script first checks if a specific entry exists for the traded item here.
2.  Second Priority: `Config.CategoryInfluence`
    - If no entry is found for the item in `ItemInfluence`, the script checks if an entry exists for the item's category here.
3.  Last Priority: Default Behavior
    - If no rule is found in either configuration, only the category of the traded item itself is influenced.

Summary of Priority: `ItemInfluence` -> `CategoryInfluence` -> `Default Behavior`

Crucially Important: Regardless of the rules above, the price of the traded item itself is always influenced. The configurations only add extra effects.

##### `Config.ItemInfluence` (Highest Priority)

Define rules for specific, individual items.

- Structure: The key of the table is the item name (e.g., `["wool"]`).
    - `InfluenceToCategories`: A list of category names whose prices should also be influenced.
    - `InfluenceToItems`: A list of item names whose prices should also be influenced.
    - `InfluenceByJob`: A table to define temporary price changes based on the number of players in a specific job.
        - `Count`: The minimum number of players required in the job for the rule to be active.
        - `SellPriceInfluence`: A value that is added to (positive) or subtracted from (negative) the sell price.
        - `BuyPriceInfluence`: A value that is added to or subtracted from the buy price.

##### `Config.CategoryInfluence` (Second Priority)

This is the fallback if no `ItemInfluence` rule is found.

- Structure: The key of the table is the category name (e.g., `["drugs"]`).
    - `InfluenceToCategories`: A list of other category names to be influenced.
    - `InfluenceByJob`: Works exactly like in `ItemInfluence`, but affects all items in the defined category.

### API Usage & Events

- API Functions:
    - Get the export:
        ```
        -- In a client or server-side script
        local EasyEconomy = exports['easyEconomy']:GetEconomySystem()
        ```
    - Get prices:
        ```
        -- Get all prices
        local allItems = EasyEconomy.GetEconomyItems()

        -- Get prices for specific items
        local specificItems = EasyEconomy.GetEconomyItems({ "bread", "water" })
        ```
    - Report a sale:
        ```
        -- Player sells 10 bread and 5 water
        local soldItems = {
            ["bread"] = 10,
            ["water"] = 5
        }
        EasyEconomy.SellItems(soldItems)
        ```
    - Report a purchase:
        ```
        -- Player buys 2 lockpicks
        local boughtItems = {
            ["lockpick"] = 2
        }
        EasyEconomy.BuyItems(boughtItems)
        ```
- Hook System:
    - Register a hook:
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
    - `EasyEconomy.RemoveHook(id)`: Removes a hook.
    - Available Event: `refreshReadEconomyItems` (triggered on price updates).
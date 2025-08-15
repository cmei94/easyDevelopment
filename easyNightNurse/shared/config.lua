--=================================================================================
--== CONFIGURATION: easyNightNurse
--=================================================================================

Config = {}

--=================================================================================
--== FEATURES
--=================================================================================

Config.Features = {
    -- true: Use okokTextUI for interaction prompts.
    -- false: Use default ESX text UI.
    UseOkOkTextUi = false,

    -- true: Money earned will be deposited into society accounts.
    -- false: Money will be removed from the player but not deposited anywhere.
    EnableSetMoneyToSociety = true,

    -- Defines the society accounts to which the money will be paid.
    -- Names must match `addon_account_data.account_name` in your database.
    PaySocieties = {
        "society_ambulance"
    }
}

--=================================================================================
--== CLIENT-SIDE FUNCTIONS (Health System Integration)
--=================================================================================
-- These functions MUST be adapted to your specific health/death system.

Config.ClientFunctions = {
    -- Checks the player's health status.
    -- MUST return an object with `state` and `health`.
    -- HealthGradeEnum: 0 = Healthy, 1 = Injured, 2 = Dead/Downed
    HealthCheck = function()
        local playerPed = PlayerPedId()
        local playerHealth = GetEntityHealth(playerPed)
        local isDead = IsEntityDead(playerPed) or playerHealth <= 100 -- Standard ESX check
        local isInjured = false

        -- You might need to check your specific death system here, e.g.:
        -- brutal_ambulancejob
        -- if exports.brutal_ambulancejob:IsDead() then isDead = true end
        --
        -- visn_are
        -- local healthBuffer= exports["visn_are"]:GetHealthBuffer()
        -- local visnareFunctions = exports["visn_are"]:GetSharedFunctions()
        -- local injuries=visnareFunctions.GetInjuries(healthBuffer)
        -- local injuriesCount=0
        -- for k,v in pairs(injuries) do
        --     injuriesCount=injuriesCount+1
        -- end
        --
        -- if healthBuffer.unconscious then isDead = true end
        -- if injuriesCount > 0 or healthBuffer.painLevel > 0 then isInjured = true end

        if isDead then
            return { state = 2, health = playerHealth } -- DEAD
        elseif playerHealth < GetEntityMaxHealth(playerPed) or isInjured then
            return { state = 1, health = playerHealth } -- INJURED
        else
            return { state = 0, health = playerHealth } -- HEALTHY
        end
    end,

    -- Function called to heal an injured player.
    HealPlayer = function(playerId)
        -- Adapt this to your needs
        TriggerEvent('esx_basicneeds:healPlayer', GetPlayerServerId(playerId)) -- Example for esx_basicneeds
        -- TriggerEvent('visn_are:resetHealthBuffer', playerId) --visn_are
        -- TriggerEvent('brutal_ambulancejob:revive') --brutal_ambulancejob

        Wait(500)
        StopAllScreenEffects()
    end,

    -- Function called to revive a dead/downed player.
    RevivePlayer = function(playerId)
        -- Adapt this to your needs
        TriggerEvent('esx_basicneeds:healPlayer', playerId) -- Example for esx_basicneeds
        TriggerEvent("esx_ambulancejob:revive") -- Example for esx_ambulancejob
        -- TriggerEvent('visn_are:resetHealthBuffer', playerId) --visn_are
        -- TriggerEvent('brutal_ambulancejob:revive') --brutal_ambulancejob
        Wait(500)
        StopAllScreenEffects()
    end
}


--=================================================================================
--== GENERAL SETTINGS
--=================================================================================

Config.General = {
    -- Key for interacting with the Night Nurse.
    -- Find key names here: https://docs.fivem.net/docs/game-references/controls/
    InteractKey = "E",

    -- Distance at which the nurse's marker/ped is created.
    CreateDistance = 30.0
}


--=================================================================================
--== NURSE STATIONS
--=================================================================================

Config.Nurses = {
    ---Example
--    ["Eclipse_Rezeption"] = {
--         -- NAME: What should this station be called on the map or in notifications?
--         Label = "Eclipse Reception",

--         -- POSITION: Where should the nurse stand?
--         -- vector4(x, y, z, heading)
--         -- x, y, z = The coordinates in the game world.
--         -- heading = Which direction should the NPC face? (0-360 degrees)
--         Position = vector4(1141.5868, -1540.7610, 35.3805, 326.5262),

--         -- INTERACTION DISTANCE: How close does the player need to be to the NPC to interact? (in game units)
--         InteractDistance = 5.0,
        
--         -- APPEARANCE: How should the station look in the game world?
--         Display = {
--             -- SHOULD AN NPC (PED) BE USED?
--             -- true = A ped (person) will be placed at the position.
--             -- false = Only a marker (e.g., a glowing cylinder) will be displayed.
--             UsePed = true,
--             -- NPC MODEL: What should the NPC look like?
--             -- A list of all ped models can be found here: https://docs.fivem.net/docs/game-references/ped-models/
--             PedModel = "s_f_y_scrubs_01",
            
--             -- MARKER SETTINGS (these are only loaded if 'UsePed = false')
--             --------------------------------------------------------------------
--             -- MARKER TYPE: What shape should the marker have?
--             -- A list of all marker types can be found here: https://docs.fivem.net/docs/game-references/markers/
--             MarkerId = 24,
--             -- MARKER SIZE: How large should the marker be? (x = width, y = depth, z = height)
--             MarkerScale = { x = 1.0, y = 1.0, z = 1.5 },
--             -- MARKER COLOR: What color should the marker have?
--             -- r = Red, g = Green, b = Blue (values from 0-255)
--             -- a = Alpha/Transparency (0 = invisible, 255 = fully visible)
--             MarkerColor = { r = 0, g = 0, b = 0, a = 100 },
--             -- SHOULD THE MARKER BOB UP AND DOWN?
--             -- true = yes, false = no.
--             BobUpAndDown = true,
--         },
        
--         -- MAP ICON (Blip): Should the station be displayed on the world map?
--         Blip = {
--             -- ENABLE OR DISABLE?
--             -- true = Yes, the icon will be shown on the map.
--             -- false = No, the station will not have a map icon.
--             Enable = false,
--             -- BLIP ICON: Which icon should be displayed on the map?
--             -- A list of all Blip IDs can be found here: https://docs.fivem.net/docs/game-references/blips/
--             BlipId = 24,
--             -- BLIP SCALE: How large should the icon be on the map? (Default is approx. 0.8-1.0)
--             BlipScale = 0.8,
--             -- BLIP COLOR: What color should the icon have?
--             -- A list of color IDs can also be found on the Blip page in the FiveM Docs.
--             BlipColor = 1,
--         },

--         -- PRICES: How much does the treatment cost?
--         RevivePrice = 8000,   -- Price for a revival (when the player is "dead").
--         HealingPrice = 4000,  -- Price for healing (when the player is only injured).

--         -- DEACTIVATION CONDITION: When should this station NOT be available?
--         DisableCondition = {
--             -- JOBS TO COUNT: Which jobs should be counted? (e.g., medics, police, etc.)
--             -- The job names must be exactly the same as in your 'jobs' table in the database.
--             NeededJobs = { "ambulance" },
--             -- ON-DUTY COUNT: At how many players on duty in the jobs above should the station be deactivated?
--             -- Example: 3 means if 3 or more medics are on duty, the night nurse will no longer be available.
--             OnDutyCount = 3,
--         },

--         -- TREATMENT BEDS: Where and how do treatments take place?
--         TreatmentPositions = {
--             -- You can add multiple beds, e.g., ["Bed1"], ["Bed2"], etc.
--             ["Bed1"] = {
--                 -- PLAYER'S POSITION & HEADING IN THE BED:
--                 -- vector4(x, y, z, heading)
--                 BedPositionAndHeading = vector4(1121.2632, -1538.3645, 35.8954, 185.4822), 
--                 -- EXIT POSITION: Where will the player be placed after treatment?
--                 ExitCoord = vector3(1142.2717, -1547.6118, 35.3805),

--                 -- TIMINGS (in milliseconds, 1000 = 1 second)
--                 TransportTimeToBed = 10000,   -- Duration of the transport from the NPC to the bed.
--                 HealTime = 20000,             -- Duration of the actual treatment in the bed.
--                 TransportTimeToExit = 10000,  -- Duration of the "transport" from the bed to the exit.

--                 -- PLAYER ANIMATION: Which animation should the player perform in the bed?
--                 BedPatientAnimation = { animDict = "anim@gangops@morgue@table@", animName = "body_search", flag = 1 },
                
--                 -- SHOULD A DOCTOR NPC APPEAR?
--                 UseDoctorNPC = true,
--                 Doctor = {
--                     -- DOCTOR'S MODEL:
--                     Model = "s_m_m_doctor_01",
--                     -- WAYPOINTS: A list of coordinates the doctor will walk through.
--                     -- The first point is the spawn point, the last one should be at the player's bed.
--                     -- The NPC will walk the path in reverse to leave before disappearing.
--                     WalkPositions = {
--                         { position = vector3(1131.8262, -1550.8301, 35.3750), heading =90.3733 }, -- Point 1 (Start)
--                         { position = vector3(1118.1772, -1549.9492, 34.9730), heading = nil },      -- Point 2
--                         { position = vector3(1120.0842, -1540.8176, 34.9730), heading = nil },      -- Point 3
--                         { position = vector3(1120.2654, -1538.3730, 34.9730), heading = 261.5941 }, -- Point 4 (End, at the bed)
--                     },
--                     -- DOCTOR'S ANIMATIONS:
--                     HealAnimation = { animDict = "mini@repair", animName = "fixing_a_ped", flag = 1 },         -- For normal healing.
--                     ReviveAnimation = { animDict = "mini@cpr@char_a@cpr_str", animName = "cpr_pumpchest", flag = 51 }, -- For revival.
--                 }
--             },
--         },
--     },
    -- You can add more nurse stations here
}
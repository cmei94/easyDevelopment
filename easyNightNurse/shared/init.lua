---
--- Initializes global variables for quick access within the resource.
--- This is loaded on both the client and server side.
---

EasyCore = exports['easyCore']:getCore()

ESX = EasyCore.FrameworkHelper.Framework

---@type string
RessourceName = GetCurrentResourceName()
Config.ShopInventories={
    ["Fischmarkt"]={
        Buy={--empty or nil if not needed
            -- ["water"]={Prize=nil, Currency="money"},--prize=nil taken from economySystem
        },
        Sell={--empty or nil if not needed
            ["tuna"] = {Currency = 'money', Prize = nil},--prize=nil taken from economySystem
            ["redfish"] = {Currency = 'money', Prize = nil},
            ["salmon"] = {Currency = 'money', Prize = nil},
            ["catfish"] = {Currency = 'money', Prize = nil},
            ["bluefish"] = {Currency = 'money', Prize = nil},
            ["largemouthbass"] = {Currency = 'money', Prize = nil},
            ["stripedbass"] = {Currency = 'money', Prize = nil},
            ["trout"] = {Currency = 'money', Prize = nil},
            ["anchovy"] = {Currency = 'money', Prize = nil},
            ["raw_meat"] = {Currency = 'black_money', Prize = nil},
        },
    },
}

Config.Shops={
    --#region Beispiele
    -- ["TestMarkt1"]={
    --     Position=vector4(-187.9504, -744.1328, 219.0721, 71.7631),
    --     Marker={
    --         Enable=true,
    --         MarkerId=27,
    --         MarkerColor={r=0,g=255,b=0}
    --     },
    --     Ped={
    --         Enable=false,
    --         PedModel="a_m_m_acult_01"
    --     },
    --     CreateDistance=30,
    --     Blip={
    --         Enable=true,
    --         BlipId=476,
    --     },
    --     OpenByJobDutyCount={--or referenced (one must be true)
    --         --[job]=ondutycount
    --         ["police"]=1
    --     },
    --     Inventory=Config.ShopInventories["Fischmarkt"]
    -- },
    -- ["TestMarkt2"]={
    --     Position=vector4(-214.8764, -742.6223, 219.5223, 255.8526),
    --     Marker={
    --         Enable=false,
    --         MarkerId=27,
    --         MarkerColor={r=0,g=255,b=0}
    --     },
    --     Ped={
    --         Enable=true,
    --         PedModel="S_M_M_HazmatWorker_01"
    --     },
    --     CreateDistance=30,
    --     Blip={
    --         Enable=true,
    --         BlipId=476,
    --     },
    --     JobAccess={
    --         --[job]=grade
    --         ["police"]=0
    --     },
    --     Inventory=Config.ShopInventories["Fischmarkt"]
    -- }
    --#endregion
    
}
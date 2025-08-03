if not Config then
    Config={}
end


Config.Locale="de"

Config.Enum={}
Config.Enum.SupportedInventory={
    OX_INVENTORY=0
}

Config.UsedInventory=Config.Enum.SupportedInventory.OX_INVENTORY

Config.Features={
    EnableLog=true,
    EnableDatabaseTableInit=true,
    EnableItemDatabaseAutoInit=true,
    EnableAutoItemsDelete=true,
    DefaultPrizeItemReset={
        Enable=true,
        ResetToDefaultValueAfterDays=7
    },
    RefreshPublicEconomyItems={--if nil or empty it's default disabled 
        Enable=true,--if nil it's default false 
        RefreshAfterMinutes=30
    }
}

Config.Database={
    CategoryTable="easyEcoCategory",
    ItemTable="easyEcoItem",
    DefaultCategory={
        Name="Default"
    }
}

Config.Time = {
    RefreshJobOnDutyCountAfterSeconds=10*60 --min is 120 seconds=2Min
}

Config.Tablet={
    OpenTabletKey="E",
    Animation={
        PropModel='prop_cs_tablet',
        AnimationDictionary="amb@world_human_tourist_map@male@base",
        Bone=28422
    }
}

Config.StockMarket={
    -- --[Label]=Infos
    ['Zentralbank-Börse']={
        Position=vector4(-201.6995, -728.7043, 216.9059, 358.1938),
        Marker={
            Enable=true,
            MarkerId=27,
            MarkerColor={r=0,g=255,b=0}
        },
        Ped={
            Enable=false,
            PedModel="a_m_m_acult_01"
        },
        CreateDistance=30,
        Blip={
            Enable=true,
            BlipId=476,
        },
        FeatureSettings={
            EconomyItemsList={
                ShowSellPrice=true,
                ShowBuyPrice=true,
            }
        },
        WhiteList={--if nil or empty all items
            Categories={},--items of categories
            Items={}--special items
        }
    },
    -- ['Schwarzmarkt-Börse']={
    --     Position=vector4(1532.3187, 3780.0994, 33.5142, 211.0),
    --     Marker={
    --         Enable=false,
    --         MarkerId=27,
    --         MarkerColor={r=0,g=255,b=0}
    --     },
    --     Ped={
    --         Enable=true,
    --         PedModel="u_m_y_staggrm_01"
    --     },
    --     CreateDistance=30,--distance for create marker or ped
    --     Blip={
    --         Enable=true,
    --         BlipId=476,
    --     },
    --     FeatureSettings={
    --         EconomyItemsList={
    --             ShowSellPrice=true,
    --             ShowBuyPrice=false,
    --         }
    --     },
    --     WhiteList={--if nil or empty all items
    --         Categories={},--items of categories
    --         Items={"wool"}--special items
    --     }
    -- }
}

if not Config then
    Config={}
end

--IMPORTANT INFORMATION
--Priority of configurable influences:
-- Highest priority: 
-- -->ItemInfluence. If the corresponding item is not found here, 
-- -->CategoryInfluence is checked. If the item's category is not configured here either, 
-- -->the default procedure is used. In this case, the item's category is influenced.
-- The item themself will be influenced allways

--Short summary:
--ItemInfluence -> CategoryInfluence -> Default Influence

Config.CategoryInfluence={
    -- ["Default"]={
    --     InfluenceToCategories={-- if empty or nil Default: just influence on themself
    --         "Default",--name of Category which items will be influenced by buy or sell
    --     },
    --     InfluenceByJob={-- the influence will be add up if many are configured
    --         ["police"]={--influence will be added if player count in job is equal or greater, this change is just temporary
    --             Count=3,
    --             SellPriceInfluence=10,--value the sell prize will changed
    --             BuyPriceInfluence=-10--value the buy prize will changed
    --         },
    --         ["swat"]={
    --             Count=3,
    --             SellPriceInfluence=10,
    --             BuyPriceInfluence=-10
    --         },
    --     }
    -- },
}

Config.ItemInfluence={
    -- ["wool"]={
    --     --    if InfluenceToCategories (set) and  InfluenceToItems (set) both will taken
    --     --    if InfluenceToCategories (set) and  InfluenceToItems (empty or nil) just InfluenceToCategories will taken
    --     --    if InfluenceToCategories (empty or nil) and  InfluenceToItems (set) just InfluenceToItems will taken
    --     --    if InfluenceToCategories (empty or nil) and  InfluenceToItems (empty or nil) looking for in CategoryInfluence
    --     InfluenceToCategories={--only registered Categories will be influenced
    --         --"Default"--name of Category which items will be influenced by buy or sell
    --     },
    --     InfluenceToItems={-- if empty or nil
    --         "wool",--name of Category which items will be influenced by buy or sell
    --         "bread"
    --     },
    --     InfluenceByJob={-- the influence will be add up if many are configured
    --         ["police"]={--influence will be added if player count in job is equal or greater, this change is just temporary
    --             Count=1,
    --             SellPriceInfluence=10,--value the sell prize will changed
    --             BuyPriceInfluence=-10--value the buy prize will changed
    --         },
    --         ["swat"]={
    --             Count=3,
    --             SellPriceInfluence=10,
    --             BuyPriceInfluence=-10
    --         },
    --     }
    -- },
}
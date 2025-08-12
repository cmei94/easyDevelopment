Config={}
Config.Keys={['ESC']=322,['F1']=288,['F2']=289,['F3']=170,['F5']=166,['F6']=167,['F7']=168,['F8']=169,['F9']=56,['F10']=57,['~']=243,['1']=157,['2']=158,['3']=160,['4']=164,['5']=165,['6']=159,['7']=161,['8']=162,['9']=163,['-']=84,['=']=83,['BACKSPACE']=177,['TAB']=37,['Q']=44,['W']=32,['E']=38,['R']=45,['T']=245,['Y']=246,['U']=303,['P']=199,['[']=39,[']']=40,['ENTER']=18,['CAPS']=137,['A']=34,['S']=8,['D']=9,['F']=23,['G']=47,['H']=74,['K']=311,['L']=182,['LEFTSHIFT']=21,['Z']=20,['X']=73,['C']=26,['V']=0,['B']=29,['N']=249,['M']=244,[',']=82,['.']=81,['LEFTCTRL']=36,['LEFTALT']=19,['SPACE']=22,['RIGHTCTRL']=70,['HOME']=213,['PAGEUP']=10,['PAGEDOWN']=11,['DELETE']=178,['LEFTARROW']=174,['RIGHTARROW']=175,['TOP']=27,['DOWNARROW']=173,['NENTER']=201,['N4']=108,['N5']=60,['N6']=107,['N+']=96,['N-']=97,['N7']=117,['N8']=61,['N9']=118,['UPARROW']=172,['INSERT']=121}

Config.DB = {}
Config.DB.LicenseDB = {
    EnableDatabaseTableInit = true,
    TableName = "easy_licenses" 
}

Config.Tablet={
    ShopInteractionKey = "E",
    Animation={
        PropModel='prop_cs_tablet',
        AnimationDictionary="amb@world_human_tourist_map@male@base",
        Bone=28422
    }
}

Config.LicenseShops = {
    ["Augury Insurance"] = {
        Position=vector4(-291.5482, -430.3445, 30.2375, 316.9496),
        CreateDistance=30.0,
        Ped = {
            Enable=true,
            Model="a_m_y_business_01",
            Position=vector4(-291.5482, -430.3445, 29.2375, 316.9496),--if nil Position of shop will be used
            InteractionDistance=5.0,
        },
        Marker={--if ped is enabled marker will not used
            Enable=false,
            MarkerId=27,
            MarkerColor={r=0,g=255,b=0}
        },
        Blip={
            Enable=true,
            BlipId=76,
            Size = 0.5,
        },
        EnableOwnMultipleLicenses=false, --is it allowed to own more than one of "Licenses" in the same time
        Licenses={
            ["healthinsurance_basic"] = {
                Price=3000,
                PayIntervalInHours=24*7,
                Name="Krankenversicherung Basic",
                Description="Deckungsbetrag: Zusatzkosten komplett und 20000$ der Behandlungskosten",
                Image="healthinsurance_basic.png",
            },
            ["healthinsurance_gold"] = {
                Price=7500,
                PayIntervalInHours=24*7,
                Name="Krankenversicherung Gold",
                Description="Deckungsbetrag: Zusatzkosten und Behandlungskosten komplett",
                Image="healthinsurance_gold.png",
            },
        },
        TabletInfos={
            Name="Augury Insurance Gesundheitsvorsorge",
            BackgroundPicture="helthInsuranceBackground.png"
        },
        MoneyGoesTo={--if not needed set empty or nil
            "society_ambulance"
        }
    }
}
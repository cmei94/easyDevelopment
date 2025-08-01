if not Config then
    Config={}
end
Config.RepositoryPath="easyCore"--%2F for /
Config.LicenseKey=""


--Timeouts
Config.Timeout={}
Config.Timeout.TimeUntilTryAgainInMs=100
Config.Timeout.TotalTrys=10

--Cache
Config.Cache={}
--ClientCache
Config.Cache.Client={}
Config.Cache.Client.Folder="cache"
Config.Cache.Client.FileName="clientCache.json"

Config.UsedScripts={}
Config.UsedScripts.Notifications=""--okokNotify

Config.MarkerModelToHash = {
    ["prop_mk_cylinder"]=0x94FDAE17,   --modelName 	prop_mk_cylinder
    ["prop_mk_ring"]=0xEC032ADD,   --modelName 	prop_mk_ring
    ["prop_mk_num_0"]=0x29FE305A,   --modelName 	prop_mk_num_0
    ["prop_mk_num_1"]=0xE3C923F1,   --modelName 	prop_mk_num_1
    ["prop_mk_num_2"]=0xD57F875E,   --modelName 	prop_mk_num_2
    ["prop_mk_num_3"]=0x40675D1C,   --modelName 	prop_mk_num_3
    ["prop_mk_num_4"]=0x4E94F977,   --modelName 	prop_mk_num_4
    ["prop_mk_num_5"]=0x234BA2E5,   --modelName 	prop_mk_num_5
    ["prop_mk_num_6"]=0xF9B24FB3,   --modelName 	prop_mk_num_6
    ["prop_mk_num_7"]=0x075FEB0E,   --modelName 	prop_mk_num_7
    ["prop_mk_num_8"]=0xDD839756,   --modelName 	prop_mk_num_8
    ["prop_mk_num_9"]=0xE9F6303B,   --modelName 	prop_mk_num_9
    ["prop_mp_halo"]=0x6903B113,   --modelName 	prop_mp_halo
    ["prop_mp_halo_point"]=0xD6445746,   --modelName 	prop_mp_halo_point
    ["prop_mp_halo_rotate"]=0x07DCE236,   --modelName 	prop_mp_halo_rotate
    ["prop_mk_sphere"]=0x50638AB9,   --modelName 	prop_mk_sphere
    ["prop_mk_cube"]=0x6EB7D3BB,   --modelName 	prop_mk_cube
    ["s_racecheckpoint01x"]=0xE60FF3B9,   --modelName 	s_racecheckpoint01x
    ["s_racefinish01x"]=0x664669A6,   --modelName 	s_racefinish01x
    ["p_canoepole01x"]=0xE03A92AE,   --modelName  	p_canoepole01x
    ["p_buoy01x"]=0x751F27D6,   --modelName  	p_buoy01x
    ["0xD9F7183F"]=0x8C5F9CEE,   --modelName  	0xD9F7183F
}

Config.Keys = {
    ['ESC']=322,['F1']=288,['F2']=289,['F3']=170,['F5']=166,['F6']=167,['F7']=168,['F8']=169,['F9']=56,['F10']=57,['~']=243,['1']=157,['2']=158,['3']=160,['4']=164,['5']=165,['6']=159,['7']=161,['8']=162,['9']=163,['-']=84,['=']=83,['BACKSPACE']=177,['TAB']=37,['Q']=44,['W']=32,['E']=38,['R']=45,['T']=245,['Y']=246,['U']=303,['P']=199,['[']=39,[']']=40,['ENTER']=18,['CAPS']=137,['A']=34,['S']=8,['D']=9,['F']=23,['G']=47,['H']=74,['K']=311,['L']=182,['LEFTSHIFT']=21,['Z']=20,['X']=73,['C']=26,['V']=0,['B']=29,['N']=249,['M']=244,[',']=82,['.']=81,['LEFTCTRL']=36,['LEFTALT']=19,['SPACE']=22,['RIGHTCTRL']=70,['HOME']=213,['PAGEUP']=10,['PAGEDOWN']=11,['DELETE']=178,['LEFTARROW']=174,['RIGHTARROW']=175,['TOP']=27,['DOWNARROW']=173,['NENTER']=201,['N4']=108,['N5']=60,['N6']=107,['N+']=96,['N-']=97,['N7']=117,['N8']=61,['N9']=118,['UPARROW']=172,['INSERT']=121
}
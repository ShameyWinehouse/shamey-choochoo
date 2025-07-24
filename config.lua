
Config = {}

Config.TicketLabel = "Train Ticket"
Config.TicketPrice = 4.0
Config.TicketItemName = "train_ticket"

Config.Stops = {
	-- ["Valentine"] = {
	-- 	coords = vector3(-163.45, 627.91, 113.42),
	-- },
	["Valentine"] = {
		id = "Valentine",
		label = "Valentine Station",
		coords = vector3(-142.42, 654.85, 116.1), -- valentine
	},
	["Emerald"] = {
		id = "Emerald",
		label = "Emerald Station",
		coords = vector3(1466.52, 269.33, 94.59), -- emerald
	},
	["StDenis"] = {
		id = "StDenis",
		label = "St. Denis Station",
		coords = vector3(2751.82, -1429.81, 48.46), -- st denis
	},
	["Annesburg"] = {
		id = "Annesburg",
		label = "Annesburg Station",
		coords = vector3(2975.75, 1336.95, 46.4), -- annesburg
	},
	["Wallace"] = {
		id = "Wallace",
		label = "Wallace Station",
		coords = vector3(-1331.42, 375.29, 98.34), -- wallace station
	},
	["Riggs"] = {
		id = "Riggs",
		label = "Riggs Station",
		coords = vector3(-1068.67, -602.61, 81.76), -- riggs
	},
	["Flatneck"] = {
		id = "Flatneck",
		label = "Flatneck Station",
		coords = vector3(-333.73, -346.5, 90.38), -- flatneck
	},

	-- Oil vector3(487.27, 654.81, 115.57)
}

Config.EasternLine = {

	LineLabel = "Rainbow Express East Line",

	CounterNpcs = {
		["Valentine"] = vector4(-175.27000427246094, 631.9388427734375, 114.08966064453125, -40.0),
		["Emerald"] = vector4(1523.640000, 442.660000, 90.580000, 270.41),
		["StDenis"] = vector4(2747.830000, -1396.450000, 46.080000, 32.31),
		["Annesburg"] = vector4(2933.080000, 1282.520000, 44.550000, 72.86),
		["Wallace"] = vector4(-1299.920000, 400.750000, 95.350000, 329.07),
		["Riggs"] = vector4(-1094.350000, -577.660000, 82.310000, 43.17),
	},
	CounterNpcDistance = 2.3,

	Blips = {
		Label = "Train Ticket Counter",
		HashName = "blip_shop_train",
		Coords = {
			["Valentine"] = vector3(-175.27000427246094, 631.9388427734375, 114.08966064453125),
			["Emerald"] = vector3(1523.640000, 442.660000, 90.580000),
			["StDenis"] = vector3(2747.830000, -1396.450000, 46.080000),
			["Annesburg"] = vector3(2933.080000, 1282.520000, 44.550000),
			["Wallace"] = vector3(-1299.920000, 400.750000, 95.350000),
			["Riggs"] = vector3(-1094.350000, -577.660000, 82.310000),
		},
	},

	Automated = {
		SpawnOrigin = vector3(-200.23, 549.41, 113.46),
		TrainModel = 0x592A5CD0,
		TrainSpeed = 1.0,
		TrainCruiseSpeed = 13.0,
		TrainMaxSpeed = 13.0,
		StationTimeInSeconds = 30,
		OffsetFromStation = 0.0,
		TicketNpcModel = `U_M_M_BlWTrainStationWorker_01`,
		TicketNpcDistance = 2.3,
		CounterNpcModel = `A_F_M_MiddleSDTownfolk_02`,
		CounterNpcOutfit = 11,

		CrewNpcs = {
			["Valentine"] = vector4(-167.13, 630.15, 113.93209838867188, 54.85),
			["Emerald"] = vector4(1526.39, 431.48, 90.58, 82.19),
			["StDenis"] = vector4(2733.88, -1441.49, 46.11, 83.47),
			["Annesburg"] = vector4(2978.99, 1325.24, 43.96, 297.26),
			["Wallace"] = vector4(-1301.9, 411.6, 95.28, 248.99),
			["Riggs"] = vector4(-1100.5, -576.84, 82.29, 314.8), 
			["Flatneck"] = vector4(-331.0, -348.8, 87.93, 210.37),
		}
	},
	Played = {
		SpawnOrigin = vector3(-158.49, 634.99, 114.66),
		TrainModel = 0x592A5CD0,
		TrainSpeed = 1.0,
		TrainCruiseSpeed = 27.0,
		TrainMaxSpeed = 27.0,
		OffsetFromStation = 0.0,
	},
}

Config.Tram = {
	LineLabel = "Bayou Boot Scoot",
	SpawnOrigin = vector3(2608.52, -1223.81, 53.29),
	-- SpawnOrigin = vector3(2608.8, -1201.13, 53.25),
	Automated = {
		TrainModel = 0xBF69518F,
		TrainSpeed = 1.0,
		TrainCruiseSpeed = 6.0,
		TrainMaxSpeed = 6.0,
		-- StationTimeInSeconds = 2 * 60,
		StationTimeInSeconds = 15,
		OffsetFromStation = 0.0,
	},
}

Config.PreventNpcConductorTakeover = true

--------

Config.Jobs = {
	{
		job = "train",
		jobGrade = {
			{grade = 1, paycheck = 8, abilities = {"tickets", "fuel"}}, -- "Conductor" (assistant)
			{grade = 2, paycheck = 10, abilities = {"tickets", "drive", "fuel", "gauge", "repair"}}, -- "Engineer"
		},
	},
}

Config.JobTimer = 12

Config.ShovelAnimPositions = {
	Female = {    
		["BoneID"] = 285,
        ["PX"] = 0.01,
        ["PY"] = -0.17,
        ["PZ"] = -0.56,
        ["PRX"] = -10.2,
        ["PRY"] = 10.0,
        ["PRZ"] = 40.0,
	},
	Male = {
        ["BoneID"] = 227,
        ["PX"] = 0.01,
        ["PY"] = -0.17,
        ["PZ"] = -0.61,
        ["PRX"] = -10.2,
        ["PRY"] = 10.0,
        ["PRZ"] = 40.0,
    },
}

--------

Config.EastJunctions = {

	-- Flatneck Station
    { coords = vector3(-281.1323, -319.6579, 89.02458), trainTrack = -705539859,  junctionIndex = 2,  enabled = 1 },
	-- Heartlands Oil
    { coords = vector3(357.959, 596.374, 115.6759),     trainTrack = 1499637393,  junctionIndex = 4,  enabled = 0 },
	-- Emerald (just to right of N in Hanover)
    { coords = vector3(1481.54, 648.331, 92.30682),     trainTrack = 1499637393,  junctionIndex = 2,  enabled = 1 },
	-- St. Denis
    { coords = vector3(2464.55, -1475.74, 46.15192),    trainTrack = -760570040,  junctionIndex = 5,  enabled = 1 },
	-- St. Denis (by Pier sign)
    { coords = vector3(2654.026, -1477.149, 45.75834),  trainTrack = -1242669618, junctionIndex = 2,  enabled = 1 },
	-- North of St. Denis, switches btwn Van Horn and west (0 is Van Horn when northbound)
    { coords = vector3(2659.79, -435.7114, 43.38848),   trainTrack = -705539859,  junctionIndex = 13, enabled = 0 },
	-- Bacchus Station (east)
    { coords = vector3(610.3571, 1661.904, 187.3867),   trainTrack = -705539859,  junctionIndex = 8,  enabled = 1 },
	-- Bacchus Station (west)
    { coords = vector3(556.65, 1725.99, 187.7966),      trainTrack = -705539859,  junctionIndex = 7,  enabled = 1 },
	-- St. Denis (by storage)
    { coords = vector3(2588.54, -1482.19, 46.04693),    trainTrack = -705539859,  junctionIndex = 18, enabled = 1 },

}

Config.TramJunctions = {

	-- by deliveries, NE of post office -- switch is facing west
    { coords = vector3(2775.01, -1350.06, 46.14),       trainTrack = -1739625337,  junctionIndex = 0,  enabled = 0 },

	-- top of roundabout -- facing south
    -- { coords = vector3(2686.55, -1385.46, 46.36679),    trainTrack = -1739625337,  junctionIndex = 3,  enabled = 1 },

	-- just west of Bank, straight to go north or right to go east towards E in Denis
    { coords = vector3(2621.25, -1295.36, 52.01),       trainTrack = -1739625337,  junctionIndex = 5,  enabled = 0 },
    -- { coords = vector3(2615.05, -1281.2, 52.34358),     trainTrack = -1739625337,  junctionIndex = 6,  enabled = 1 },
    -- { coords = vector3(2608.49, -1254.66, 52.66566),    trainTrack = -1739625337,  junctionIndex = 7,  enabled = 1 },

	-- main T east of clothing shop
    { coords = vector3(2608.6, -1155.59, 51.69),        trainTrack = -1739625337,  junctionIndex = 10, enabled = 0 },
	-- main T -- turn left to go south down main drag
    { coords = vector3(2624.4, -1139.85, 51.51707),     trainTrack = -1739625337,  junctionIndex = 11, enabled = 1 },
	-- NE of barber, turn right to head directly south towards E in Denis
    { coords = vector3(2700.96, -1139.82, 50.29),       trainTrack = -1739625337,  junctionIndex = 13, enabled = 0 },
	-- just west of Bank, left to go south or right to go north
    { coords = vector3(2625.46, -1284.62, 52.14),       trainTrack = 1751550675,   junctionIndex = 1,  enabled = 1 },

	-- just SW of post office -- facing west
    -- { coords = vector3(2738.41, -1414.91, 45.85),       trainTrack = -1748581154,  junctionIndex = 1,  enabled = 1 },

	-- main T -- facing east, straight to go east or right to go south
    -- { coords = vector3(2599.47, -1137.39, 51.3),        trainTrack = -1716490906,  junctionIndex = 4,  enabled = 1 },

}

--------

Config.Debug = false

Config.DebugEast = false

Config.DebugTram = false

Config.DebugCommands = false

Config.DebugShowBlip = false

Config.DebugMissionTrains = {

	0x005E03AD, -- central union pass, 8 wagon
	0x0392C83A, -- Lannahechee wooden flatbed, 7 wagon
	0x0660E567, -- central union boxcar, 12 wagon
	0x0941ADB7,		-- net_fetch_train_vip_rescue_00, s&e, boxcar, 9 wagon
	0x09B679D6, -- st denis tram, 1 car
	0x0CCC2F70, -- Lannahechee, coal, 7 wagon
	0x0D03C58D, -- s&e, boxcar, 7 wagon
	0x0E62D710,		-- ghost_train_config
	0x10461E19, -- s&e nice passenger, 9 wagon
	0x124A1F89, -- central union pass, 8 wagon
	0x19A0A288, -- central union boxcar, 18 wagon
	0x1C043595, -- s&e nice passenger, 9 wagon
	0x1C9936BB, -- s&e nice passenger, 9 wagon
	0x1EEC5C2A, -- central union boxcar, 18 wagon
	0x1EF82A51, -- Lannahechee, boxcar, 15 wagon
	0x25E5D8FF, -- Army, mixed sleeper, 18
	0x26509FBB,		-- dummy_engine_config
	0x29C81ACB, -- broken??
	0x2D1A6F0C, -- central union, boxcar, 9 wagon
	0x2D3645FA, -- pacific union, nice passenger, 8 wagon
	0x31656D23, -- Bayou route, boxcar, 16 wagon
	0x3260CE89,		-- engine_config -- just the engine
	0x35D17C43, -- s&e, passenger mixed, 11 wagon
	0x3ADC4DA9, -- s&e passenger, 9 wagon
	0x3D72571D,		-- gunslinger3_config, s&e pass mixed 10
	0x3EDA466D,		-- handcart_config, need 2 ppl
	0x41436136, -- central pass 10 -- wood seats
	0x487B2BE7,		-- winter4_config -- s&e pass mixed 9
	0x4A73E49C, -- central pass 9
	0x4C9CCB22, -- central pass 9 -- wood seats
	0x515E31ED,		-- prisoner_escort_config
	0x57C209C4, -- central mixed 10
	0x592A5CD0, -- cen pass 6 (2 pass, 1 flatbed) -- wood messy / green seats lil mess
	0x5AA369CA,		-- gunslinger4_config
	0x5D9928A4, -- Lannahechee boxcar 12
	0x68CF495F, -- cen flat/utility 8
	0x6CC26E27, -- s&e boxcar 10
	0x6D69A954, -- s&e boxcar 12
	0x73722125, -- st denis tram
	0x761CE0AD,		-- net_fetch_train_camp_resupply_00
	0x767DEB32,		-- industry2_config
	0x7BD58C4D, -- Lannahechee flatbed/boxcar 12
	0x8864D73A, -- s&e/cen pass 9
	0x8D0766BC, -- central utility/flat 11
	0x8EAC625C,		-- appleseed_config
	0x90CB53CA, -- st denis tram
	0x9296570E, -- Lannahechee box/flat 10
	0x96563327, -- nother handcart
	0x98427740, -- cen pass 5 -- wood seats, only 1 is pass other is utility
	0x9897FF51, -- cen box 10
	0x998A0CBC, -- s&e pass 13
	0x9CBE6FEC, -- cen flatbed/pass 6
	0x9E096E46, -- st denis tram
	0xA3BF0BEB,		-- net_fetch_train_kidnapped_buyer_00
	0xA8B1CEB7, -- cen pass 6 -- green seats, messy dirty
	0xA91041A2, -- cen pass 8
	0xAA3E691E, -- Lannahechee boxcar 15
	0xAC18A9F4, -- Lannahechee flatbed w/strongcar 9
	0xAE47CA77,		-- net_fetch_train_bounty_horde_00
	0xAEE0ECF5, -- st denis tram pacific
	0xB1F69614, -- cen boxcar/flatbed 15
	0xBF69518F,		-- trolley_config
	0xC1F1DD80, -- army boxcar/flatbed 6
	0xC732CDC8, -- cen pass 6 -- green seats, messy dirty
	0xC75AA08C,		-- minecart_config
	0xCA19C62A, -- cen pass 12
	0xCD2C7CA1, -- s&e pass 8
	0xD233B18D,		-- net_fetch_train_moving_bounty_1
	0xD42DD3EE, -- cen flatbed 8
	0xD5DF2D82, -- cen boxcar 10
	0xD8CF6395, -- cen pass 11
	0xD92B16AE, -- cen flatbed/passenger 7 -- wood seats
	0xD93C36C2, -- cen boxcar 5
	0xDA2EDE2F, -- pac boxcar 10
	0xDC9DD041, -- s&e dining/box 4 
	0xDD920DAF, -- central pass/box/caboose 5 -- green seats
	0xE0898B89, -- central flatbed 11
	0xE16CA3EF, -- pacific passenger 9
	0xEB8B2439, -- central boxcar 8
	0xEF9FC71D, -- central flatbed/pass 6 -- cute green seats
	0xEFBFBDD8, -- st denis tram
	0xF19E48CA, -- pacific boxcar 7
	0xF6AA98F4, -- central pass 9
	0xF9B038FC,		-- bountyhunter_config, Lannahechee boxcar 20
	0xFAB2FFB9, -- s&e pass 8
	0xFAC328F0, -- pacific boxcar 12
	0xFD8810E8, -- Lannahechee coal 6

}
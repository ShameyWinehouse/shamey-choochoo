VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)
RainbowCore = exports["rainbow-core"]:initiate()

local counterNpcs = {}

local counterShopPromptGroup
local counterShopPrompt
local counterLocateEastTrainPrompt

local counterStaffClockInPrompt
local counterStaffClockOutPrompt
local counterEngineerSpawnPrompt
local counterConductorDepositPrompt

local ticketerPromptGroup
local ticketerPrompt

onDuty = false


if Config.Debug then
    RegisterCommand("conductEastTrain", function(source, args, rawCommand)
        TriggerServerEvent("rainbow_choochoo:ConductEasternTrain")
    end, false)
end


Citizen.CreateThread(function()

    -- Spawn the Counter NPCs
    SpawnCounterNpcs()

end)

-- Counter prompts
Citizen.CreateThread(function()

    counterShopPromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local promptLabel = "Buy 1 " .. Config.TicketLabel .. "  |  Price: ~o~$" ..string.format("%.2f", Config.TicketPrice)
    -- G to buy
    counterShopPrompt = counterShopPromptGroup:RegisterPrompt(promptLabel, 0x760A9C6F, 1, 1, false, 'hold', {timedeventhash = "SHORT_TIMED_EVENT_MP"})
    -- R to check location
    counterLocateEastTrainPrompt = counterShopPromptGroup:RegisterPrompt("Check Location of East Train", 0xE30CD707, 1, 1, false, 'click', nil)

    -- 1 to clock in
    counterStaffClockInPrompt = counterShopPromptGroup:RegisterPrompt("Clock In", 0xE6F612E4, 1, 0, false, 'click', nil)
    -- 2 to clock out
    counterStaffClockOutPrompt = counterShopPromptGroup:RegisterPrompt("Clock Out", 0x1CE6D9EB, 1, 0, false, 'click', nil)
    -- ENTER to spawn train
    counterEngineerSpawnPrompt = counterShopPromptGroup:RegisterPrompt("Reestablish East Train", 0xC7B5340A, 1, 0, false, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    -- DOWN to dump tickets
    counterConductorDepositPrompt = counterShopPromptGroup:RegisterPrompt("Deposit All Tickets", 0x05CA7C52, 1, 0, false, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})

    while true do
        local sleep = 1000

        if playerCoords then
            for k,v in pairs(Config.EasternLine.CounterNpcs) do

                if #(playerCoords - vector3(v.x, v.y, v.z)) < Config.EasternLine.CounterNpcDistance then
                    sleep = 0

                    counterShopPromptGroup:ShowGroup("Train Ticket Counter")

                    -- Allow clocking in/out
                    if hasStaffJob() then
                        if onDuty then
                            counterStaffClockInPrompt:TogglePrompt(false)
                            counterStaffClockOutPrompt:TogglePrompt(true)
                        else
                            counterStaffClockInPrompt:TogglePrompt(true)
                            counterStaffClockOutPrompt:TogglePrompt(false)
                        end
                    end

                    -- Allow Engineers to "re-establish" (respawn) the train
                    if hasAbility("drive") then
                        if getNearestTrainStop(playerCoords) == "Valentine" then
                            counterEngineerSpawnPrompt:TogglePrompt(true)
                        else
                            counterEngineerSpawnPrompt:TogglePrompt(false)
                        end
                    else
                        counterEngineerSpawnPrompt:TogglePrompt(false)
                    end

                    -- Allow depositing of tickets
                    if hasAbility("tickets") then
                        counterConductorDepositPrompt:TogglePrompt(true)
                    else
                        counterConductorDepositPrompt:TogglePrompt(false)
                    end


                    -- COMPLETIONS

                    if counterShopPrompt:HasCompleted() then
                        TriggerServerEvent("rainbow_choochoo:BuyTicket")
                    end
                    if counterLocateEastTrainPrompt:HasCompleted() then
                        TriggerServerEvent("rainbow_choochoo:CheckEastTrainLocation")
                    end

                    if counterStaffClockInPrompt:HasCompleted() then
                        SetDuty(true)
                    end
                    if counterStaffClockOutPrompt:HasCompleted() then
                        SetDuty(false)
                    end
                    if counterEngineerSpawnPrompt:HasCompleted() then
                        if Config.Debug then print("calling conduct") end
                        TriggerServerEvent("rainbow_choochoo:ConductEasternTrain")
                    end
                    if counterConductorDepositPrompt:HasCompleted() then
                        if Config.Debug then print("despoting tickets") end
                        TriggerServerEvent("rainbow_choochoo:Staff:DepositTickets")
                    end

                end

            end
        end

        Citizen.Wait(sleep)

    end

end)

-- Train ticket-taker NPC prompt handler
Citizen.CreateThread(function()

    ticketerPromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local promptLabel = "Give the Ticket-Taker 1 Train Ticket"
    ticketerPrompt = ticketerPromptGroup:RegisterPrompt(promptLabel, 0x760A9C6F, 1, 1, false, 'hold', {timedeventhash = "SHORT_TIMED_EVENT_MP"})

    while true do
        local sleep = 1000

        if easternTrainNpcTicket then
            if #(playerCoords - GetEntityCoords(easternTrainNpcTicket)) < Config.EasternLine.Automated.TicketNpcDistance then
                sleep = 0
                ticketerPromptGroup:ShowGroup("Train Ticket-Taker")
                if ticketerPrompt:HasCompleted() then
                    TriggerServerEvent("rainbow_choochoo:GiveTicket")
                end
            end
        end

        Citizen.Wait(sleep)
    end

end)


function SpawnCounterNpcs()
    for k, v in pairs(Config.EasternLine.CounterNpcs) do
        SpawnCounterNpc(v.x, v.y, v.z, v.w)
    end
end

function SpawnCounterNpc(x, y, z, heading)
    local npc = SpawnNpc(Config.EasternLine.Automated.CounterNpcModel, x, y, z, heading)
    SetPedOutfitPreset(npc, Config.EasternLine.Automated.CounterNpcOutfit)
    TaskStartScenarioInPlace(npc, `WORLD_HUMAN_SHOPKEEPER_CATALOG`, -1, true, false, false, false)
    table.insert(counterNpcs, npc)
end

-------- STAFF

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.JobTimer * 60 * 1000)
		if onDuty then
			TriggerServerEvent("rainbow_choochoo:Staff:GetPaycheck")
		end
	end
end)

function SetDuty(isOnDuty)
	if Config.ShameyDebug then print("SetDuty: ", isOnDuty) end
	onDuty = isOnDuty
	TriggerServerEvent("rainbow_choochoo:Staff:SetDuty", isOnDuty)
	
	-- Alert the user
	local tipText = "You are now clocked in and will start to receive pay."
	if isOnDuty == false then
		tipText = "You are now clocked out."
	end
	TriggerEvent('vorp:Tip', tipText, 10000)
end

function hasStaffJob()
    return RainbowCore.AbsolutelyHasJobInJoblistClient(getJobList())
end

-- Check if the player has the ability based on their job grade
function hasAbility(ability)
    for k,v in pairs(Config.Jobs) do
        for k2,v2 in pairs(v.jobGrade) do
			
			local hasJobAndGrade = RainbowCore.AbsolutelyHasJobAndGradeClient(v.job, v2.grade)

            if hasJobAndGrade then
                for k3,v3 in pairs(v2.abilities) do
                    if Config.ShameyDebug then print("v3", v3) end
                    if v3 == ability then
                        if Config.ShameyDebug then print("has ability: ", ability) end
                        return true
                    end
                end
            end
        end
    end
    if Config.ShameyDebug then print("doesn't have ability: ", ability) end
    return false
end

function getJobList()
	local jobList = {}
	for k,v in pairs(Config.Jobs) do
		jobList[#jobList+1] = v.job
	end
	return jobList
end

--------

RegisterNetEvent("rainbow_core:Jobs:Client:OnSwitchedJob")
AddEventHandler("rainbow_core:Jobs:Client:OnSwitchedJob", function()
    if onDuty then
        SetDuty(false)
    end
end)

--------

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
        -- Delete the counter NPCs
        for k, v in pairs(counterNpcs) do
            DeleteEntity(v)
        end
        counterNpcs = {}
    end
end)
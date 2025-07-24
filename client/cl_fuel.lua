VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local progressbar = exports.vorp_progressbar:initiate()

local isOnTrain = false
isInEastTrainEngineCar = false
isInEastTrainCoalCar = false
trainEngineCar = nil
trainCoalCar = nil

local animEnterDict = "amb_work@world_human_coal_shovel@male_a@stand_enter_withprop"
local animEnter = "enter_back_lf"
local animExitDict = "amb_work@world_human_coal_shovel@male_a@stand_exit_withprop"
local animExit = "exit_front"
local shovelProp

local shovelPromptGroup
local shovelPrompt


local ShovelAnimation = {}

if Config.DebugCommands then
    RegisterCommand("setShovelAnimation", function(source, args, rawCommand)
        ShovelAnimation = {
            ["BoneID"] = tonumber(args[1]),
            -- ["BoneID"] = 370,
            ["PX"] = tonumber(args[2]),
            ["PY"] = tonumber(args[3]),
            ["PZ"] = tonumber(args[4]),
            ["PRX"] = tonumber(args[5]),
            ["PRY"] = tonumber(args[6]),
            -- ["PRZ"] = 270.0,
            ["PRZ"] = tonumber(args[7]),
        }
        if Config.Debug then print(ShovelAnimation) end
    end, false)
end

if Config.DebugCommands then
    RegisterCommand("playShovelAnimation", function(source, args, rawCommand)
        playShovelAnimation()
    end, false)

    RegisterCommand("resetShovelAnimation", function(source, args, rawCommand)
        resetShovelAnimation()
    end, false)
end

-- Set the shovel animation when they select a character (and we know the body type)
RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
	Wait(3000)

	resetShovelAnimation()
end)

-- Get location on carriages
CreateThread(function()
    while true do
        local sleep = 250

        if easternTrainClass then

            -- if hasAbility("fuel") then
                isOnTrain = Citizen.InvokeNative(0x6F972C1AB75A1ED0, PlayerPedId()) -- IS_PED_IN_ANY_TRAIN
                
                trainEngineCar = Citizen.InvokeNative(0xD0FB093A4CDB932C, NetToVeh(easternTrainClass:getNetId()), 0)
                trainCoalCar = Citizen.InvokeNative(0xD0FB093A4CDB932C, NetToVeh(easternTrainClass:getNetId()), 1)

                isInEastTrainEngineCar = Citizen.InvokeNative(0x9A2304A64C3C8423, PlayerPedId(), trainEngineCar)
                isInEastTrainCoalCar = Citizen.InvokeNative(0x9A2304A64C3C8423, PlayerPedId(), trainCoalCar)
            -- end

        end

        Citizen.Wait(sleep)
    end
end)

-- Show the "Add Fuel" prompt
CreateThread(function()

    shovelPromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local promptLabel = "Add Fuel"
    -- G
    shovelPrompt = shovelPromptGroup:RegisterPrompt(promptLabel, 0x760A9C6F, 1, 1, false, 'click', nil)

    while true do
        local sleep = 1000

        -- Show prompt to Conductors
        if hasAbility("fuel") and isOnTrain and isInEastTrainCoalCar then

            sleep = 1

            shovelPromptGroup:ShowGroup("Train Conductor")

            if shovelPrompt:HasCompleted() then

                local inputs = dialogAddFuel()
                if Config.Debug then print("inputs", inputs) end
                if inputs then

                    -- Will call back to `rainbow_choochoo:East:CanAddFuelCheckReturn` event
                    TriggerServerEvent("rainbow_choochoo:East:CanAddFuelCheck", inputs.fuelType, tonumber(inputs.amount))

                    Citizen.Wait(1000)
                    
                end

                if Config.Debug then print("AddFuel") end
            end
        end

        Citizen.Wait(sleep)
    end
end)


-------- EVENTS

RegisterNetEvent("rainbow_choochoo:East:CanAddFuelCheckReturn")
AddEventHandler("rainbow_choochoo:East:CanAddFuelCheckReturn", function(doesHaveAmount, fuelType, amount)
    if Config.Debug then print("East:CanAddFuelCheckReturn", doesHaveAmount) end

    if doesHaveAmount == true then
        -- Double-check permissions
        if hasAbility("fuel") and isOnTrain and isInEastTrainCoalCar then
            progressbar.start("Shoveling...", 3*6000, function ()
                TriggerServerEvent("rainbow_choochoo:East:AddFuel", fuelType, amount)
            end, nil, "rgba(129, 0, 129, 0.5)")
            playShovelAnimation()
        end
    else
        VORPcore.NotifyRightTip("You don't have that amount of that fuel type.", 4000)
    end
end)


function dialogAddFuel()
    local dialog = exports['rsg-input']:ShowInput({
        header = "Fuel",
        submitText = "Add",
        inputs = {
            {
                text = "Fuel Type",
                name = "fuelType",
                type = "radio",
                options = {
                    { value = "wood", text = "Soft Wood" },
                    { value = "hwood", text = "Hard Wood" },
                    { value = "coal", text = "Coal" },
                },
                isRequired = true,
            },
            {
                text = "Amount",
                name = "amount",
                type = "number",
                isRequired = true,
            },
        },
    })

    -- Check for bad inputs
    if dialog == nil or dialog == "" then VORPcore.NotifyRightTip("You didn't enter anything.", 4000) return false end
    if dialog.fuelType == "" then VORPcore.NotifyRightTip("You must choose a fuel type.", 4000) return false end
    if not dialog.amount or tonumber(dialog.amount) <= 0 then VORPcore.NotifyRightTip("You must enter an amount.", 4000) return false end

    return dialog
end


function resetShovelAnimation()
    local playerPed = PlayerPedId()
    if IsPedMale(playerPed) then
        ShovelAnimation = Config.ShovelAnimPositions.Male
    else
        ShovelAnimation = Config.ShovelAnimPositions.Female
    end
end

function playShovelAnimation()
    if Config.Debug then print("playShovelAnimation") end

    deleteShovel()

    local playerPed = PlayerPedId()

    -- Get the prop
    local model = `p_shovel01x`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end

    shovelProp = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    SetModelAsNoLongerNeeded(model)

    local attach = ShovelAnimation


    AttachEntityToEntity(shovelProp, playerPed, attach.BoneID, attach.PX, attach.PY, attach.PZ, attach.PRX, attach.PRY, attach.PRZ, false, false, true, false, 0, true, false, false)


    -- Play the anims
    playShovelAnimationLoop(playerPed)


    deleteShovel()

end

function playShovelAnimationLoop(playerPed)

    RequestAnimDict(animEnterDict)
    while not HasAnimDictLoaded(animEnterDict) do
        Wait(100)
    end

    RequestAnimDict(animExitDict)
    while not HasAnimDictLoaded(animExitDict) do
        Wait(100)
    end

    local loopCountMax = 3
    for i=1,loopCountMax do
        TaskPlayAnim(playerPed, animEnterDict, animEnter, 1.0, 8.0, 3000, 1, 1.0, true, 0, false, 0, false)
        Wait(3000)

        if i == loopCountMax then
            TaskPlayAnim(playerPed, animExitDict, animExit, 8.0, 1.0, 3000, 1, 1.0, true, 0, false, 0, false)
            Wait(3000)
        else
            TaskPlayAnim(playerPed, animExitDict, animExit, 8.0, 8.0, 3000, 1, 1.0, true, 0, false, 0, false)
            Wait(3000)
        end
    end

end

function deleteShovel()
    if shovelProp ~= nil then
        DeleteObject(shovelProp)
        SetEntityAsNoLongerNeeded(shovelProp)
        shovelProp = nil
        ClearPedTasks(PlayerPedId())
    end
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
    deleteShovel()
end)
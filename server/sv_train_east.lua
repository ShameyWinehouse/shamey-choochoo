VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)

local VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local easternTrainSpawnTriggered = false
local easternTrainLocation = "Valentine"

local easternTrainClass


if Config.DebugCommands then
    RegisterCommand("eastSetFuel", function(source, args, rawCommand)
        if args[1] then
            easternTrainClass:setFuelAmount(args[1])
        end
    end, false)
end

if Config.DebugCommands then
    RegisterCommand("eastAddFuel", function(source, args, rawCommand)
        if args[1] then
            easternTrainClass:addFuel(args[1])
        end
    end, false)
end

-- For Admin resetting
RegisterCommand("resetEastTrain", function(source, args, rawCommand)
    resetEastAndAlertAllClients()
end, true)


-- Check if there's no players left and, if so, clear out the trains.
Citizen.CreateThread(function()

    while true do

        Citizen.Wait(10 * 1000)

        local playersCount = GetPlayersCount()

        if playersCount < 1 then
            if easternTrainClass then
                easternTrainClass = nil
                easternTrainSpawnTriggered = false
                if Config.DebugEast then print("Cleared eastern train.") end
            end
        end

    end

end)

Citizen.CreateThread(function()

    while true do

        Citizen.Wait(10 * 1000)

        if easternTrainClass then
            if Config.DebugEast then print('easternTrainNetId', easternTrainClass:getNetId()) end
            if Config.DebugEast then print('isModeAutomated', easternTrainClass:getIsAutomated()) end
            if easternTrainClass:getNetId() then
                local easternTrainEntity = NetworkGetEntityFromNetworkId(easternTrainClass:getNetId())
                if easternTrainEntity then
                    if Config.DebugEast then print("east train check:", easternTrainEntity, GetEntityCoords(easternTrainEntity)) end
                    local conductorEntity = NetworkGetEntityFromNetworkId(easternTrainClass:getConductorNetId())
                    if Config.DebugEast then print("east train conductor check:", conductorEntity, GetEntityCoords(conductorEntity)) end
                    if Config.DebugEast then print("east train owner check:", easternTrainClass:getOwnerNetId()) end
                else
                    if Config.DebugEast then print('no east train entity') end
                end
            end
        end

    end

end)

RegisterServerEvent("rainbow_choochoo:East:CanAddFuelCheck")
AddEventHandler("rainbow_choochoo:East:CanAddFuelCheck", function(fuelType, amount)
    local _source = source

    local hasAmount = VorpInv.getItemCount(_source, fuelType)

    local doesHaveAmount = hasAmount >= amount
    TriggerClientEvent("rainbow_choochoo:East:CanAddFuelCheckReturn", _source, doesHaveAmount, fuelType, amount)
end)

RegisterServerEvent("rainbow_choochoo:East:SubFuel")
AddEventHandler("rainbow_choochoo:East:SubFuel", function(amount)
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:East:SubFuel") end

    if easternTrainClass:getFuelAmount() > 0 then
        easternTrainClass:subFuel(amount)
    end

    TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", _source, easternTrainClass)
end)

RegisterServerEvent("rainbow_choochoo:East:AddFuel")
AddEventHandler("rainbow_choochoo:East:AddFuel", function(fuelType, amount)
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:East:AddFuel", _source, fuelType, amount) end

    local hasAmount = VorpInv.getItemCount(_source, fuelType)

    if hasAmount >= amount then
        VorpInv.subItem(_source, fuelType, amount)
        easternTrainClass:addFuel(amount)
        VORPcore.NotifyRightTip(_source, "Fuel has been added.", 4000)
    else
        VORPcore.NotifyRightTip(_source, "You do not have enough of this item.", 4000)
    end



end)

RegisterServerEvent("rainbow_choochoo:RequestTrainClassRefresh")
AddEventHandler("rainbow_choochoo:RequestTrainClassRefresh", function()
    local _source = source

    TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", _source, easternTrainClass)
end)

RegisterServerEvent("rainbow_choochoo:CheckEasternTrain")
AddEventHandler("rainbow_choochoo:CheckEasternTrain", function()
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:CheckEasternTrain", _source) end

    if easternTrainSpawnTriggered then
        TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", _source, easternTrainClass)
    else
        -- Check if player is near the spawn spot
        if Config.DebugEast then print("CheckEasternTrain - player spot:", _source, GetEntityCoords(NetworkGetEntityFromNetworkId(_source))) end
        if #(GetEntityCoords(NetworkGetEntityFromNetworkId(_source)) - Config.EasternLine.Automated.SpawnOrigin) < 200.0 then
            easternTrainSpawnTriggered = true
            if Config.DebugEast then print("calling singlespawn for east", _source) end
            TriggerClientEvent("rainbow_choochoo:SingleSpawnEasternTrain", _source, true)
        else
            TriggerClientEvent("rainbow_choochoo:Debug:CouldntBeSingleSpawnEasternTrain", _source)
            if Config.DebugEast then print(_source, "was supposed to be singlespawn for easttrain but not in range") end
        end
    end

end)

RegisterServerEvent("rainbow_choochoo:SpawnedEasternTrain")
AddEventHandler("rainbow_choochoo:SpawnedEasternTrain", function(spawnedEasternTrainNetId, spawnedEasternTrainNpcConductorNetId, isForAutomated)
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:SpawnedEasternTrain", spawnedEasternTrainNetId, spawnedEasternTrainNpcConductorNetId) end

    if isForAutomated then
        easternTrainClass = Train:New({
            name = "east",
            netId = spawnedEasternTrainNetId,
            conductorNetId = spawnedEasternTrainNpcConductorNetId,
            ownerNetId = _source,
            isAutomated = true
        })
    else
        MySQL.query('SELECT * FROM trains WHERE name=@name', {['name'] = "east"}, function(result)
            print('result', result)
            if result and result[1] then
                local resTrain = result[1]
    
                easternTrainClass = Train:New({
                    name = resTrain.name,
                    netId = spawnedEasternTrainNetId,
                    conductorNetId = spawnedEasternTrainNpcConductorNetId,
                    ownerNetId = _source,
                    isAutomated = false,
                    fuelAmount = resTrain.fuel
                })
                print('easternTrainClass', easternTrainClass)
                
            else
                print("ERROR: Couldn't get train DB record.")
            end
        end)
    end

    -- TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", _source, easternTrainClass)

    -- TriggerClientEvent("rainbow_choochoo:SetEasternTrain", -1, easternTrainNetId, easternTrainNpcConductorNetId)
    TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", -1, easternTrainClass)
end)

RegisterServerEvent("rainbow_choochoo:GetEasternTrain")
AddEventHandler("rainbow_choochoo:GetEasternTrain", function()
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:GetEasternTrain", _source, easternTrainClass:getNetId()) end

    TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", _source, easternTrainClass)
end)

RegisterServerEvent("rainbow_choochoo:SetEasternTrainOwnership")
AddEventHandler("rainbow_choochoo:SetEasternTrainOwnership", function()
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:SetEasternTrainOwnership", _source) end

    easternTrainClass:setOwnerNetId(_source)

    -- Alert all of the change
    TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", -1, easternTrainClass)
end)

RegisterServerEvent("rainbow_choochoo:UpdateEasternTrainLocation")
AddEventHandler("rainbow_choochoo:UpdateEasternTrainLocation", function(currentStop)
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:UpdateEasternTrainLocation", _source, currentStop) end

    easternTrainLocation = currentStop
end)

RegisterServerEvent("rainbow_choochoo:CheckEastTrainLocation")
AddEventHandler("rainbow_choochoo:CheckEastTrainLocation", function()
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:CheckEastTrainLocation", _source) end

    local msg = string.format("East Train last spotted at %s.", Config.Stops[easternTrainLocation].label)

    VORPcore.NotifyRightTip(_source, msg, 4000)
end)

RegisterServerEvent("rainbow_choochoo:ConductEasternTrain")
AddEventHandler("rainbow_choochoo:ConductEasternTrain", function()
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:ConductEasternTrain", _source) end

    resetEastAndAlertAllClients()
    easternTrainSpawnTriggered = true

    if Config.DebugEast then print("rainbow_choochoo:ConductEasternTrain - easternTrainClass", easternTrainClass) end

    TriggerClientEvent("rainbow_choochoo:SingleSpawnEasternTrain", _source, false)

end)


AddEventHandler('playerDropped', function(reason)
    local _source = source

    if easternTrainClass then
        if Config.DebugEast then print("east - rainbow_choochoo:playerDropped", _source, easternTrainClass:getOwnerNetId()) end

        if _source == easternTrainClass:getOwnerNetId() then
            -- The client owner of the train left
            
            -- Make sure at least 1 person is still online
            if GetPlayersCount() < 1 then
                return
            end

            -- Get the coords of the train
            local foundPlayerInRangeOfTrain = false
            local playerInRangeOfTrain
            local trainCoords = GetEntityCoords(NetworkGetEntityFromNetworkId(easternTrainClass:getNetId()))
            if Config.DebugEast then print("rainbow_choochoo:playerDropped -- trainCoords:", trainCoords) end
            for k,v in pairs(GetPlayers()) do
                local playerCoords = GetEntityCoords(GetPlayerPed(v))
                if #(playerCoords - trainCoords) < 200.0 then
                    foundPlayerInRangeOfTrain = true
                    playerInRangeOfTrain = v
                    if Config.DebugEast then print("rainbow_choochoo:playerDropped -- found playerInRangeOfTrain", v) end
                    break
                end
            end

            if foundPlayerInRangeOfTrain == true then
                if Config.DebugEast then print("rainbow_choochoo:playerDropped -- found playerInRangeOfTrain, sending requestOwnership") end
                -- Restart it with the near person
                local nextOwner = playerInRangeOfTrain
                TriggerClientEvent("rainbow_choochoo:RequestOwnershipEasternTrain", nextOwner)
            else
                if Config.DebugEast then print("rainbow_choochoo:playerDropped -- NOT found playerInRangeOfTrain, sending easttrain nil") end
                -- Nobody near; just start fresh
                resetEastAndAlertAllClients()
            end
            
        end

    end
end)



RegisterServerEvent("rainbow_choochoo:Admin:ResetEastTrain")
AddEventHandler("rainbow_choochoo:Admin:ResetEastTrain", function()
    local _source = source

    if Config.DebugEast then print("rainbow_choochoo:Admin:ResetEastTrain", _source) end

    resetEastAndAlertAllClients()

    VORPcore.NotifyRightTip(_source, "ADMIN: East train reset triggered.", 4000)
end)

function resetEastAndAlertAllClients()
    resetEastTrain()
    TriggerClientEvent("rainbow_choochoo:RefreshTrainClass", -1, nil)
end

function resetEastTrain()
    if easternTrainClass then
        DeleteEntity(NetworkGetEntityFromNetworkId(easternTrainClass:getNetId()))
        DeleteEntity(NetworkGetEntityFromNetworkId(easternTrainClass:getConductorNetId()))
        easternTrainClass = nil
    end

    easternTrainSpawnTriggered = false
    easternTrainLocation = "Valentine"
end


AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
        resetEastTrain()
	end
end)
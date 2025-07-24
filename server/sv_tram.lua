VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


local isModeAutomated = true

local tramOwnerId
local tramNetId
local tramNpcConductorNetId
local tramSpawnTriggered = false
local tramLocation = "Valentine"


-- For Admin resetting
RegisterCommand("resettram", function(source, args, rawCommand)
    resetTramAndAlertAllClients()
end, true)

-- Check if there's no players left and, if so, clear out the trains.
Citizen.CreateThread(function()

    while true do

        Citizen.Wait(10 * 1000)

        local playersCount = GetPlayersCount()

        if playersCount < 1 then
            if tramNetId then
                tramNetId = nil
                tramSpawnTriggered = false
                if Config.DebugTram then print("Cleared tram.") end
            end
        end

    end

end)

Citizen.CreateThread(function()

    while true do

        Citizen.Wait(10 * 1000)

        if Config.DebugTram then print('tramNetId', tramNetId) end
        if tramNetId then
            local tramEntity = NetworkGetEntityFromNetworkId(tramNetId)
            if tramEntity then
                if Config.DebugTram then print("tram check:", tramEntity, GetEntityCoords(tramEntity)) end
                local conductorEntity = NetworkGetEntityFromNetworkId(tramNpcConductorNetId)
                if Config.DebugTram then print("tram conductor check:", tramNpcConductorNetId, conductorEntity, GetEntityCoords(conductorEntity)) end
            else
                if Config.DebugTram then print('no tram entity') end
            end
        end

    end

end)

RegisterServerEvent("rainbow_choochoo:CheckTram")
AddEventHandler("rainbow_choochoo:CheckTram", function()
    local _source = source

    -- if Config.DebugTram then print("rainbow_choochoo:CheckTram", _source) end

    if tramSpawnTriggered then
        TriggerClientEvent("rainbow_choochoo:SetTram", _source, tramNetId, tramNpcConductorNetId)
    else
        -- Check if player is near the spawn spot
        -- if Config.DebugTram then print("CheckTRAM - player spot:", _source, GetEntityCoords(NetworkGetEntityFromNetworkId(_source))) end
        if #(GetEntityCoords(NetworkGetEntityFromNetworkId(_source)) - Config.Tram.SpawnOrigin) < 424.0 then
            tramSpawnTriggered = true
            if Config.DebugTram then print("calling singlespawn for TRAM", _source) end
            TriggerClientEvent("rainbow_choochoo:SingleSpawnTram", _source)
        else
            TriggerClientEvent("rainbow_choochoo:Debug:CouldntBeSingleSpawnTram", _source)
            -- if Config.DebugTram then print(_source, "was supposed to be singlespawn for TRAM but not in range") end
        end
    end

end)

RegisterServerEvent("rainbow_choochoo:SpawnedTram")
AddEventHandler("rainbow_choochoo:SpawnedTram", function(spawnedTramNetId, spawnedTramNpcConductorNetId)
    local _source = source

    if Config.DebugTram then print("rainbow_choochoo:SpawnedTRAM", spawnedTramNetId, spawnedTramNpcConductorNetId) end

    tramNetId = spawnedTramNetId

    tramNpcConductorNetId = spawnedTramNpcConductorNetId
    tramOwnerId = _source

    TriggerClientEvent("rainbow_choochoo:SetTram", -1, tramNetId, tramNpcConductorNetId)

end)

RegisterServerEvent("rainbow_choochoo:GetTram")
AddEventHandler("rainbow_choochoo:GetTram", function()
    local _source = source

    if Config.DebugTram then print("rainbow_choochoo:GetTram", _source, tramNetId) end

    TriggerClientEvent("rainbow_choochoo:SetTram", _source, tramNetId, tramNpcConductorNetId)
end)

RegisterServerEvent("rainbow_choochoo:SetTramOwnership")
AddEventHandler("rainbow_choochoo:SetTramOwnership", function()
    local _source = source

    if Config.DebugTram then print("rainbow_choochoo:SetTramOwnership", _source) end

    tramOwnerId = _source
end)

RegisterServerEvent("rainbow_choochoo:UpdateTramLocation")
AddEventHandler("rainbow_choochoo:UpdateTramLocation", function(currentStop)
    local _source = source

    if Config.DebugTram then print("rainbow_choochoo:UpdateTramLocation", _source, currentStop) end

    tramLocation = currentStop
end)

RegisterServerEvent("rainbow_choochoo:CheckTramLocation")
AddEventHandler("rainbow_choochoo:CheckTramLocation", function()
    local _source = source

    if Config.DebugTram then print("rainbow_choochoo:CheckTramLocation", _source) end

    local msg = string.format("Bayou Boot Scoot last spotted at %s.", Config.Stops[tramLocation].label)

    VORPcore.NotifyRightTip(_source, msg, 4000)
end)


AddEventHandler('playerDropped', function(reason)
    local _source = source

    if Config.DebugTram then print("tram - rainbow_choochoo:playerDropped", _source, tramOwnerId) end

    if _source == tramOwnerId then
        -- The client owner of the train left
        
        -- Make sure at least 1 person is still online
        if GetPlayersCount() < 1 then
            return
        end

        -- Get the coords of the tram
        local foundPlayerInRangeOfTram = false
        local playerInRangeOfTram
        local tramCoords = GetEntityCoords(NetworkGetEntityFromNetworkId(tramNetId))
        if Config.DebugTram then print("rainbow_choochoo:playerDropped -- TRAMCoords:", tramCoords) end
        for k,v in pairs(GetPlayers()) do
            local playerCoords = GetEntityCoords(GetPlayerPed(v))
            if #(playerCoords - tramCoords) < 424.0 then
                foundPlayerInRangeOfTram = true
                playerInRangeOfTram = v
                if Config.DebugTram then print("rainbow_choochoo:playerDropped -- tram - found playerInRangeOfTRAM", v) end
                break
            end
        end

        if foundPlayerInRangeOfTram == true then
            if Config.DebugTram then print("rainbow_choochoo:playerDropped -- tram -- found playerInRangeOfTRAM, sending requestOwnership") end
            -- Restart it with the near person
            local nextOwner = playerInRangeOfTram
            TriggerClientEvent("rainbow_choochoo:RequestOwnershipTram", nextOwner)
        else
            if Config.DebugTram then print("rainbow_choochoo:playerDropped -- tram -- NOT found playerInRangeOfTRAM, sending TRAM nil") end
            -- Nobody near; just start fresh
            resetTramAndAlertAllClients()
        end
    end
end)

function resetTramAndAlertAllClients()
    resetTram()
    TriggerClientEvent("rainbow_choochoo:SetTram", -1, nil, nil)
end

function resetTram()
    DeleteEntity(NetworkGetEntityFromNetworkId(tramNetId))
    DeleteEntity(NetworkGetEntityFromNetworkId(tramNpcConductorNetId))
    tramNetId = nil
    tramNpcConductorNetId = nil

    tramSpawnTriggered = false
end


AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
        resetTram()
	end
end)
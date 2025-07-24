VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


local isOwningPlayer = false
local isModeAutomated = true

local tramNetId
local tramNpcConductorNetId
tramLocation = nil




-- For debugging
-- Citizen.CreateThread(function()

--     while true do

--         Citizen.Wait(10 * 1000)

--         if Config.DebugTram then print('easternTrainNetId', easternTrainNetId) end
--         if easternTrainNetId then
--             if Citizen.InvokeNative(0x18A47D074708FD68, easternTrainNetId) then -- NetworkDoesEntityExistWithNetworkId
--                 local easternTrainEntity = NetworkGetEntityFromNetworkId(easternTrainNetId)
--                 if Config.DebugTram then print("train check:", easternTrainEntity, GetEntityCoords(easternTrainEntity)) end
--             end
--         else
--             if Config.DebugTram then print('no train entity') end
--         end

--         if isOwningPlayer then
--             if Config.DebugTram then print('isOwningPlayer') end
--         end

--     end

-- end)

-- Debugging: show train blip
if Config.DebugShowBlip then
    local trainBlip = VORPutils.Blips:SetBlip('Bayou Boot Scoot', 'blip_special_series_1', 0.2, 0.0, 0.0, 0.0, nil)
    CreateThread(function()
        
        while true do
            Wait(1000)
            if tramNetId and Citizen.InvokeNative(0x18A47D074708FD68, tramNetId) then
                local rawblip = trainBlip.rawblip
                SetBlipCoords(rawblip, GetEntityCoords(NetToVeh(tramNetId)))
            end
        end
        
    end)
    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() == resourceName then
            trainBlip:Remove()
        end
    end)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10 * 1000)
        if not tramNetId or tramNetId == 0 then
            -- if Config.DebugTram then print('calling server for CheckTram') end
            TriggerServerEvent("rainbow_choochoo:CheckTram")
        end
    end
end)

-- Handle the track switches
Citizen.CreateThread(function()

    while true do

        Citizen.Wait(500)

        if tramNetId then

            local tramCoords = GetEntityCoords(NetToVeh(tramNetId))

            for i = 1, #Config.TramJunctions do
                if #(tramCoords - Config.TramJunctions[i].coords) < 10 then
                    if Config.DebugTram then print('near junction', Config.TramJunctions[i]) end

                    -- TODO: player controlled -- allow them to choose switch

                    if isModeAutomated then
                        Citizen.InvokeNative(0xE6C5E2125EB210C1, Config.TramJunctions[i].trainTrack, Config.TramJunctions[i].junctionIndex, Config.TramJunctions[i].enabled)
                        Citizen.InvokeNative(0x3ABFA128F5BF5A70, Config.TramJunctions[i].trainTrack, Config.TramJunctions[i].junctionIndex, Config.TramJunctions[i].enabled)
                    end
                end
            end

        end

    end

end)

-- Loop to handle train stops of the Tram
-- Citizen.CreateThread(function()

--     while true do
--         Citizen.Wait(1000)

--         if tramNetId then

--             if Citizen.InvokeNative(0x18A47D074708FD68, tramNetId) then -- NetworkDoesEntityExistWithNetworkId
--                 local tramEntity = NetToVeh(tramNetId)

--                 -- If train is waiting at station
--                 if Citizen.InvokeNative(0xE887BD31D97793F6, tramEntity) then -- IsTrainWaitingAtStation

--                     Citizen.InvokeNative(0x3660BCAB3A6BB734, tramEntity) -- SetTrainHalt

--                     local currentStop = getNearestTrainStop(GetEntityCoords(tramEntity))
--                     updateEasternTrainLocation(currentStop)

--                     if isModeAutomated then
--                         spawnEasternNpcTicket(currentStop)
--                     end

--                     print('halted')
--                     Citizen.Wait(Config.EasternLine.Automated.StationTimeInSeconds * 1000)

--                     if isModeAutomated then
--                         despawnEasternNpcTicket()
--                     end

--                     Citizen.InvokeNative(0x787E43477746876F, easternTrainEntity) -- SetTrainLeaveStation
--                 end
--             end
--         end

--     end
-- end)

function updateTramLocation(currentStop)
    tramLocation = currentStop
    TriggerServerEvent("rainbow_choochoo:UpdateTramLocation", currentStop)
end

-- function spawnEasternNpcTicket(stopIndex)

--     if Config.DebugTram then print('spawnEasternNpcTicket()', stopIndex) end

--     -- Create NPC crew person for taking tickets
--     local locationVector4 = Config.EasternLine.Automated.CrewNpcs[stopIndex]
--     easternTrainNpcTicket = SpawnNpc(Config.EasternLine.Automated.TicketNpcModel, locationVector4.x, locationVector4.y, locationVector4.z, locationVector4.w)
--     SetPedOutfitPreset(easternTrainNpcTicket, 0)
--     TaskStartScenarioInPlace(easternTrainNpcTicket, `WORLD_HUMAN_STARE_STOIC`, -1, true, false, false, false)
--     print('easternTrainNpcTicket', easternTrainNpcTicket)
-- end

-- function despawnEasternNpcTicket()

--     if not easternTrainNpcTicket then
--         return
--     end

--     local easternTrainEntity = NetToVeh(easternTrainNetId)

--     ClearPedTasks(easternTrainNpcTicket)
--     TaskEnterVehicle(easternTrainNpcTicket, easternTrainEntity, 5000, -1, 1.0, 0, 0)
--     Citizen.Wait(5000)

--     DeleteEntity(easternTrainNpcTicket)
--     easternTrainNpcTicket = nil
--     print('deleted easternTrainNpcTicket')
-- end

-- Prevent players from taking over from the conductor
CreateThread(function()
    while true do
        local sleep = 100
        if Config.PreventNpcConductorTakeover then
            if tramNpcConductorNetId and playerCoords and Citizen.InvokeNative(0x18A47D074708FD68, tramNpcConductorNetId) then
                if #(GetEntityCoords(NetToPed(tramNpcConductorNetId)) - playerCoords) < 15.0 then
                    sleep = 1
                    Citizen.InvokeNative(0xFC094EF26DD153FA, 12) -- UiPromptDisablePromptTypeThisFrame
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


-------- EVENTS

RegisterNetEvent("rainbow_choochoo:SingleSpawnTram")
AddEventHandler("rainbow_choochoo:SingleSpawnTram", function()
    if Config.DebugTram then print("SingleSpawnTram") end

    Citizen.Wait(10 * 1000)

    SpawnTram(Config.Tram.Automated.TrainModel)
    isOwningPlayer = true
end)

-- For non-first-players to get a reference to the Tram
RegisterNetEvent("rainbow_choochoo:SetTram")
AddEventHandler("rainbow_choochoo:SetTram", function(_tramNetId, _tramNpcConductorNetId)
    if Config.DebugTram then print("SetTram", _tramNetId, _tramNpcConductorNetId) end

    tramNetId = _tramNetId
    tramNpcConductorNetId = _tramNpcConductorNetId
end)

RegisterNetEvent("rainbow_choochoo:RequestOwnershipTram")
AddEventHandler("rainbow_choochoo:RequestOwnershipTram", function()
    if Config.DebugTram then print("RequestOwnershipTram") end

    -- Get control of the tram
    local gotControlOfTram = NetworkRequestControlOfNetworkId(tramNetId)
    if Config.DebugTram then print("RequestOwnershipTRAM - gotControlOfTRAM", gotControlOfTram) end

    -- Get control of the conductor
    local gotControlOfConductor = NetworkRequestControlOfNetworkId(tramNpcConductorNetId)
    if Config.DebugTram then print("RequestOwnershipEasternTRAM - gotControlOfConductor", gotControlOfConductor) end

    TriggerServerEvent("rainbow_choochoo:SetTramOwnership")

    isOwningPlayer = true
end)

RegisterNetEvent("rainbow_choochoo:Debug:CouldntBeSingleSpawnTram")
AddEventHandler("rainbow_choochoo:Debug:CouldntBeSingleSpawnTram", function()
    if Config.DebugTram then print("CouldntBeSingleSpawnTram", GetEntityCoords(PlayerPedId())) end
end)



-------- FUNCTIONS


local trainHash
function SpawnTram(trainModel)

    if Config.DebugTram then print("SpawnTram()") end

    -- Clear the area
    -- Citizen.InvokeNative(0x3B882A96EA77D5B1, Config.EasternLine.SpawnOrigin.x, Config.EasternLine.SpawnOrigin.y, Config.EasternLine.SpawnOrigin.z, 20.0, 0)


    if tonumber(trainModel) then
        if trainModel > 0 and trainModel < 100 then
            trainHash = Config.DebugMissionTrains[trainModel]
        else
            trainHash = trainModel
        end
    else
        trainHash = GetHashKey(n)
    end


    Citizen.InvokeNative(0x76B02E21ED27A469, 1) -- ReserveNetworkMissionVehicles

    local trainWagons = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash) -- GetNumCarsFromTrainConfig
    if Config.DebugTram then print("trainWagons", trainWagons) end

    for i = 0, trainWagons - 1 do
        local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, i) -- GetTrainModelFromTrainConfigByCarIndex
        RequestModel(trainWagonModel)
        while not HasModelLoaded(trainWagonModel) do
            Citizen.Wait(1)
        end
    end

    if Config.DebugTram then print("choo choo2") end


    local tram = Citizen.InvokeNative(0xC239DBD9A57D2A71, trainHash, Config.Tram.SpawnOrigin, true, false, true, isModeAutomated) -- CreateMissionTrain
    Citizen.Wait(50) -- Required to get correct NetId?

    if Config.DebugTram then print("choo choo3") end

    if isModeAutomated then
        -- Set the speeds and the stop settings
        Citizen.SetTimeout(3000, function() 
            Citizen.InvokeNative(0xC239DBD9A57D2A71, tram, Config.Tram.Automated.TrainSpeed) -- SetTrainSpeed
        end)
        
        Citizen.InvokeNative(0x01021EB2E96B793C, tram, Config.Tram.Automated.TrainCruiseSpeed) -- SetTrainCruiseSpeed
        Citizen.InvokeNative(0x9F29999DFDF2AEB8, tram, Config.Tram.Automated.TrainMaxSpeed) -- SetTrainMaxSpeed
        Citizen.InvokeNative(0x4182C037AA1F0091, tram, true) -- SetTrainStopsForStations
        Citizen.InvokeNative(0x8EC47DD4300BF063, tram, Config.Tram.Automated.OffsetFromStation) -- SetTrainOffsetFromStation

        -- TODO: not automated (player-controlled)
    end

    if Config.DebugTram then print("choo choo3a") end

    -- Register the train with the network (prevent de-spawning)
    NetworkRegisterEntityAsNetworked(tram)
    Citizen.Wait(1000)
    if Config.DebugTram then print("choo choo3aaaa") end
    if Config.DebugTram then print("tram", tram) end
    local netId = NetworkGetNetworkIdFromEntity(tram)
    if Config.DebugTram then print("netId", netId) end
    SetNetworkIdExistsOnAllMachines(netId, true)
    Citizen.InvokeNative(0xA8A024587329F36A, netId, PlayerId(), true) -- SetNetworkIdAlwaysExistsForPlayer


    if Config.DebugTram then print("choo choo3b, VehToNet", netId) end

    -- Get the conductor & modify them
    if isModeAutomated then
        tramNpcConductor = GetPedInVehicleSeat(tram, -1)
        while not tramNpcConductor or tramNpcConductor == 0 do
            tramNpcConductor = GetPedInVehicleSeat(tram, -1)
            Citizen.Wait(1)
        end
        Citizen.Wait(50) -- Required to get correct NetId?

        if Config.DebugTram then print("choo choo3c") end

        -- Prevent de-spawning
        SetEntityAsMissionEntity(tramNpcConductor, true, true)
        NetworkRegisterEntityAsNetworked(tramNpcConductor)
        SetNetworkIdExistsOnAllMachines(PedToNet(tramNpcConductor), true)

        -- Prevent conductor from being killed
        if Config.PreventNpcConductorTakeover then
            MakePedInvincible(tramNpcConductor, false)
            SetTimeout(3000, function()
                FreezeEntityPosition(tramNpcConductor, true)
            end)
        end

        if Config.DebugTram then print("choo choo3d") end
    end

    tramNetId = netId

    -- Let the server know the tram was spawned
    TriggerServerEvent("rainbow_choochoo:SpawnedTram", netId, PedToNet(tramNpcConductor))


    if Config.DebugTram then print("choo choo4") end
end


--------

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then

        tramNetId = nil
    end

end)
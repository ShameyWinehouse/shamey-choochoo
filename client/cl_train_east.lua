VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


local isOwningPlayer = false

easternTrainNpcTicket = nil
easternTrainLocation = nil

isNearEastTrainEngine = false

easternTrainClass = nil



-- -- For Admin resetting
-- RegisterNetEvent("vorp:SelectedCharacter")
-- AddEventHandler("vorp:SelectedCharacter", function(charid)
-- 	Wait(3000)

-- 	TriggerServerEvent("bulgar_prison:check_prison_time")
-- end)

-- For debugging
Citizen.CreateThread(function()

    while true do

        Citizen.Wait(10 * 1000)

        if easternTrainClass then

            if Config.DebugEast then print('easternTrainNetId', easternTrainClass:getNetId()) end
            if Config.DebugEast then print('isModeAutomated', easternTrainClass:getIsAutomated()) end
            if easternTrainClass:getNetId() then
                if NetworkDoesEntityExistWithNetworkId(easternTrainClass:getNetId()) then
                    local easternTrainEntity = NetworkGetEntityFromNetworkId(easternTrainClass:getNetId())
                    if Config.DebugEast then print("east train check:", easternTrainEntity, GetEntityCoords(easternTrainEntity)) end
                    if NetworkDoesEntityExistWithNetworkId(easternTrainClass:getConductorNetId()) then
                        local conductorEntity = NetworkGetEntityFromNetworkId(easternTrainClass:getConductorNetId())
                        if Config.DebugEast then print("east train conductor check:", conductorEntity, GetEntityCoords(conductorEntity)) end
                    else
                        if Config.DebugEast then print("east train conductor has netId but isn't networked", easternTrainClass:getConductorNetId()) end
                    end
                else
                    if Config.DebugEast then print("east train has netId but isn't networked", easternTrainClass:getNetId()) end
                end
            else
                if Config.DebugEast then print('no train entity') end
            end

            if isOwningPlayer then
                if Config.DebugEast then print('isOwningPlayer') end
            end

        end

    end

end)

-- Debugging: show train blip
if Config.DebugShowBlip then
    local trainBlip = VORPutils.Blips:SetBlip('East Train', 'blip_special_series_1', 0.2, 0.0, 0.0, 0.0, nil)
    CreateThread(function()
        
        while true do
            Wait(1000)
            if easternTrainClass and easternTrainClass:getNetId() and Citizen.InvokeNative(0x18A47D074708FD68, easternTrainClass:getNetId()) then
                local rawblip = trainBlip.rawblip
                SetBlipCoords(rawblip, GetEntityCoords(NetToVeh(easternTrainClass:getNetId())))
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
        if not easternTrainClass or not easternTrainClass:getNetId() or easternTrainClass:getNetId() == 0 then
            if Config.DebugEast then print('calling server for CheckEasternTrain') end
            TriggerServerEvent("rainbow_choochoo:CheckEasternTrain")
        end
    end
end)

-- Check for empty fuel
Citizen.CreateThread(function()

    while true do

        local sleep = 1000

        if easternTrainClass and not easternTrainClass:getIsAutomated() and hasStaffJob() then
            TriggerServerEvent("rainbow_choochoo:RequestTrainClassRefresh")
            Wait(200)
        end

        -- If the train isn't automated and they're the driving Engineer
        if easternTrainClass and not easternTrainClass:getIsAutomated() and IsPlayerDriverOfVehicle(NetToVeh(easternTrainClass:getNetId())) then
            -- print('GetVehicleDashboardSpeed', GetVehicleDashboardSpeed(trainEngineCar))

            local eastTrainVeh = NetToVeh(easternTrainClass:getNetId())
            local speed = GetEntitySpeed(eastTrainVeh)

            -- Make low fuel stop the train
            if easternTrainClass:getFuelAmount() <= 0 then
                Citizen.InvokeNative(0x9F29999DFDF2AEB8, eastTrainVeh, 0.1) -- _SET_TRAIN_MAX_SPEED
                -- SetVehicleEngineHealth(eastTrainVeh, -3000.0)
            else
                Citizen.InvokeNative(0x9F29999DFDF2AEB8, eastTrainVeh, Config.EasternLine.Played.TrainMaxSpeed) -- _SET_TRAIN_MAX_SPEED
            end

            -- Show the gauge if they have the ability and are in the engine car
            if isInEastTrainEngineCar and hasAbility("gauge") then
                NUIEvents.ShowHUD(true)
                NUIEvents.UpdateHUD(easternTrainClass, speed)
            else
                NUIEvents.ShowHUD(false)
            end
        else
            NUIEvents.ShowHUD(false)
        end

        

        Citizen.Wait(sleep)

    end

end)

-- Lower the fuel
Citizen.CreateThread(function()

    while true do

        local sleep = 5 * 60 * 1000 -- 5 mins

        if easternTrainClass and not easternTrainClass:getIsAutomated() and IsPlayerDriverOfVehicle(NetToVeh(easternTrainClass:getNetId())) then
            -- print('GetVehicleDashboardSpeed', GetVehicleDashboardSpeed(trainEngineCar))

            local eastTrainVeh = NetToVeh(easternTrainClass:getNetId())
            local speed = GetEntitySpeed(eastTrainVeh)

            if Config.DebugEast then print('GetEntitySpeed', GetEntitySpeed(eastTrainVeh)) end
            -- if Config.DebugEast then print('GetVehicleFuelLevel', GetEntitySpeed(eastTrainVeh)) end

            -- If the train is moving at all and there's still fuel left
            if speed > 0.2 and easternTrainClass:getFuelAmount() > 0 then

                local amountToSub = 1
                if speed > 15.0 then
                    amountToSub = math.random(1, 2)
                end

                if Config.DebugEast then print("calling rainbow_choochoo:East:SubFuel") end

                -- easternTrainClass:subFuel(1)
                TriggerServerEvent("rainbow_choochoo:East:SubFuel", amountToSub)
            end
        end

        Citizen.Wait(sleep)

    end

end)



-- Handle the track switches
Citizen.CreateThread(function()

    while true do

        local sleep = 1000

        if easternTrainClass and easternTrainClass:getNetId() and Citizen.InvokeNative(0x18A47D074708FD68, easternTrainClass:getNetId()) then

            sleep = 200

            local trainCoords = GetEntityCoords(NetToVeh(easternTrainClass:getNetId()))

            for i = 1, #Config.EastJunctions do
                if #(trainCoords - Config.EastJunctions[i].coords) < 25 then
                    if Config.DebugEast then print('near junction', Config.EastJunctions[i]) end

                    -- TODO: player controlled -- allow them to choose switch

                    -- if isModeAutomated then
                        Citizen.InvokeNative(0xE6C5E2125EB210C1, Config.EastJunctions[i].trainTrack, Config.EastJunctions[i].junctionIndex, Config.EastJunctions[i].enabled)
                        Citizen.InvokeNative(0x3ABFA128F5BF5A70, Config.EastJunctions[i].trainTrack, Config.EastJunctions[i].junctionIndex, Config.EastJunctions[i].enabled)
                        sleep = 500
                    -- end
                end
            end

        end

        Citizen.Wait(sleep)

    end

end)

-- Loop to handle train stops of the Eastern Line
Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000)

        if easternTrainClass and easternTrainClass:getNetId() then

            if easternTrainClass:getIsAutomated() then

                if Citizen.InvokeNative(0x18A47D074708FD68, easternTrainClass:getNetId()) then -- NetworkDoesEntityExistWithNetworkId
                    local easternTrainEntity = NetToVeh(easternTrainClass:getNetId())

                    -- If train is waiting at station
                    if Citizen.InvokeNative(0xE887BD31D97793F6, easternTrainEntity) then -- IsTrainWaitingAtStation

                        Citizen.InvokeNative(0x3660BCAB3A6BB734, easternTrainEntity) -- SetTrainHalt

                        Citizen.Wait(100)

                        local currentStop = getNearestTrainStop(GetEntityCoords(easternTrainEntity))
                        updateEasternTrainLocation(currentStop)

                        Citizen.Wait(100)

                        spawnEasternNpcTicket(currentStop)

                        print('halted')
                        Citizen.Wait(Config.EasternLine.Automated.StationTimeInSeconds * 1000)

                        despawnEasternNpcTicket()

                        Citizen.InvokeNative(0x787E43477746876F, easternTrainEntity) -- SetTrainLeaveStation
                    end
                end

            end
        end

    end
end)

function updateEasternTrainLocation(currentStop)
    easternTrainLocation = currentStop
    TriggerServerEvent("rainbow_choochoo:UpdateEasternTrainLocation", currentStop)
end

function spawnEasternNpcTicket(stopIndex)

    if Config.DebugEast then print('spawnEasternNpcTicket()', stopIndex) end

    -- Create NPC crew person for taking tickets
    local locationVector4 = Config.EasternLine.Automated.CrewNpcs[stopIndex]
    easternTrainNpcTicket = SpawnNpc(Config.EasternLine.Automated.TicketNpcModel, locationVector4.x, locationVector4.y, locationVector4.z, locationVector4.w)
    SetPedOutfitPreset(easternTrainNpcTicket, 0)
    TaskStartScenarioInPlace(easternTrainNpcTicket, `WORLD_HUMAN_STARE_STOIC`, -1, true, false, false, false)
    if Config.DebugEast then print('easternTrainNpcTicket', easternTrainNpcTicket) end
end

function despawnEasternNpcTicket()

    if not easternTrainNpcTicket then
        return
    end

    local easternTrainEntity = NetToVeh(easternTrainClass:getNetId())

    ClearPedTasks(easternTrainNpcTicket)
    TaskEnterVehicle(easternTrainNpcTicket, easternTrainEntity, 5000, -1, 1.0, 0, 0)
    Citizen.Wait(5000)

    DeleteEntity(easternTrainNpcTicket)
    easternTrainNpcTicket = nil
    if Config.DebugEast then print('deleted easternTrainNpcTicket') end
end

-- Prevent players from taking over from the conductor
CreateThread(function()
    while true do
        local sleep = 100

        -- Prevent players from taking over from the conductor
        if easternTrainClass and Config.PreventNpcConductorTakeover and easternTrainClass:getIsAutomated() then
            if easternTrainClass:getConductorNetId() and playerCoords and Citizen.InvokeNative(0x18A47D074708FD68, easternTrainClass:getConductorNetId()) then
                if #(GetEntityCoords(NetToPed(easternTrainClass:getConductorNetId())) - playerCoords) < 15.0 then
                    sleep = 1
                    Citizen.InvokeNative(0xFC094EF26DD153FA, 12) -- UiPromptDisablePromptTypeThisFrame
                end
            end
        end

        -- Prevent non-Engineers from driving the train
        if not hasAbility("drive") then

            isNearEastTrainEngine = false

            local nearbyObjects = GetNearbyObjects(playerCoords, 7.0)

            for _, object in ipairs(nearbyObjects) do
                local entityModel = GetEntityModel(object)
                if entityModel == `p_steamer_coal_fire` then
                    isNearEastTrainEngine = true
                end
            end
            
            if isNearEastTrainEngine or isInEastTrainEngineCar then
                sleep = 1
                Citizen.InvokeNative(0xFC094EF26DD153FA, 12) -- UiPromptDisablePromptTypeThisFrame
            end
        end

        -- print('GetNearbyVehicles', GetNearbyVehicles(PlayerPedId()))

        -- print('GET_CLOSEST_VEHICLE', Citizen.InvokeNative(0x52F45D033645181B, playerCoords, 5.0, 0, ))

        Citizen.Wait(sleep)
    end
end)


-------- EVENTS

RegisterNetEvent("rainbow_choochoo:RefreshTrainClass")
AddEventHandler("rainbow_choochoo:RefreshTrainClass", function(_easternTrainClass)
    -- if Config.DebugEast then print("RefreshTrainClass", _easternTrainClass) end

    -- If we're blanking out the train
    if not _easternTrainClass then
        -- If there was a train before
        if easternTrainClass then
            DeleteEntity(NetToEnt(easternTrainClass:getNetId()))
            if easternTrainClass:getConductorNetId() then
                DeleteEntity(NetToEnt(easternTrainClass:getConductorNetId()))
            end
        end
        easternTrainClass = nil
    else
        easternTrainClass = Train:New(_easternTrainClass)
    end
end)

RegisterNetEvent("rainbow_choochoo:SingleSpawnEasternTrain")
AddEventHandler("rainbow_choochoo:SingleSpawnEasternTrain", function(isForAutomated)
    if Config.DebugEast then print("SingleSpawnEasternTrain") end

    Citizen.Wait(3 * 1000)

    SpawnEasternTrain(Config.EasternLine.Automated.TrainModel, isForAutomated)
    isOwningPlayer = true
    
end)

-- For non-first-players to get a reference to the Eastern Train
-- RegisterNetEvent("rainbow_choochoo:SetEasternTrain")
-- AddEventHandler("rainbow_choochoo:SetEasternTrain", function(_easternTrainNetId, _easternTrainNpcConductorNetId)
--     if Config.DebugEast then print("SetEasternTrain", _easternTrainNetId, _easternTrainNpcConductorNetId) end

--     easternTrainNetId = _easternTrainNetId
--     easternTrainNpcConductorNetId = _easternTrainNpcConductorNetId
-- end)

RegisterNetEvent("rainbow_choochoo:RequestOwnershipEasternTrain")
AddEventHandler("rainbow_choochoo:RequestOwnershipEasternTrain", function()
    if Config.DebugEast then print("RequestOwnershipEasternTrain") end

    -- Get control of the train
    local gotControlOfTrain = NetworkRequestControlOfNetworkId(easternTrainClass:getNetId())
    if Config.DebugEast then print("RequestOwnershipEasternTrain - gotControlOfTrain", gotControlOfTrain) end

    -- Get control of the conductor
    local gotControlOfConductor = NetworkRequestControlOfNetworkId(easternTrainClass:getConductorNetId())
    if Config.DebugEast then print("RequestOwnershipEasternTrain - gotControlOfConductor", gotControlOfConductor) end

    TriggerServerEvent("rainbow_choochoo:SetEasternTrainOwnership")

    isOwningPlayer = true
end)

RegisterNetEvent("rainbow_choochoo:Debug:CouldntBeSingleSpawnEasternTrain")
AddEventHandler("rainbow_choochoo:Debug:CouldntBeSingleSpawnEasternTrain", function()
    if Config.DebugEast then print("CouldntBeSingleSpawnEasternTrain", GetEntityCoords(PlayerPedId())) end
end)



-------- FUNCTIONS


local trainHash
function SpawnEasternTrain(trainModel, isForAutomated)

    if Config.DebugEast then print("SpawnEasternTrain()") end

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
    if Config.DebugEast then print("trainWagons", trainWagons) end

    for i = 0, trainWagons - 1 do
        local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, i) -- GetTrainModelFromTrainConfigByCarIndex
        RequestModel(trainWagonModel)
        while not HasModelLoaded(trainWagonModel) do
            Citizen.Wait(1)
        end
    end

    if Config.DebugEast then print("choo choo2") end

    local easternTrain
    if isForAutomated then
        easternTrain = Citizen.InvokeNative(0xC239DBD9A57D2A71, trainHash, Config.EasternLine.Automated.SpawnOrigin, false, false, true, true) -- CreateMissionTrain
    else
        easternTrain = Citizen.InvokeNative(0xC239DBD9A57D2A71, trainHash, Config.EasternLine.Played.SpawnOrigin, false, false, true, false) -- CreateMissionTrain
    end
    Citizen.Wait(50) -- Required to get correct NetId?

    if Config.DebugEast then print("choo choo3") end

    if isForAutomated then
        -- Set the speeds and the stop settings
        Citizen.InvokeNative(0xC239DBD9A57D2A71, easternTrain, Config.EasternLine.Automated.TrainSpeed) -- SetTrainSpeed
        Citizen.InvokeNative(0x01021EB2E96B793C, easternTrain, Config.EasternLine.Automated.TrainCruiseSpeed) -- SetTrainCruiseSpeed
        Citizen.InvokeNative(0x9F29999DFDF2AEB8, easternTrain, Config.EasternLine.Automated.TrainMaxSpeed) -- SetTrainMaxSpeed
        Citizen.InvokeNative(0x4182C037AA1F0091, easternTrain, true) -- SetTrainStopsForStations
        Citizen.InvokeNative(0x8EC47DD4300BF063, easternTrain, Config.EasternLine.Automated.OffsetFromStation) -- SetTrainOffsetFromStation
    else
        -- Player-controlled
        Citizen.InvokeNative(0xC239DBD9A57D2A71, easternTrain, Config.EasternLine.Played.TrainSpeed) -- SetTrainSpeed
        Citizen.InvokeNative(0x01021EB2E96B793C, easternTrain, Config.EasternLine.Played.TrainCruiseSpeed) -- SetTrainCruiseSpeed
        Citizen.InvokeNative(0x9F29999DFDF2AEB8, easternTrain, Config.EasternLine.Played.TrainMaxSpeed) -- SetTrainMaxSpeed
        -- Citizen.InvokeNative(0x4182C037AA1F0091, easternTrain, true) -- SetTrainStopsForStations
        Citizen.InvokeNative(0x8EC47DD4300BF063, easternTrain, Config.EasternLine.Played.OffsetFromStation) -- SetTrainOffsetFromStation
        
        Citizen.InvokeNative(0x3660BCAB3A6BB734, easternTrain) -- SetTrainHalt
    end

    if Config.DebugEast then print("choo choo3a") end

    -- Register the train with the network (prevent de-spawning)
    NetworkRegisterEntityAsNetworked(easternTrain)
    Citizen.Wait(1000)
    if Config.DebugEast then print("choo choo3aaaa") end
    if Config.DebugEast then print("easternTrain", easternTrain) end
    local netId = NetworkGetNetworkIdFromEntity(easternTrain)
    if Config.DebugEast then print("netId", netId) end
    SetNetworkIdExistsOnAllMachines(netId, true)
    Citizen.InvokeNative(0xA8A024587329F36A, netId, PlayerId(), true) -- SetNetworkIdAlwaysExistsForPlayer


    if Config.DebugEast then print("choo choo3b, VehToNet", netId) end

    -- Get the conductor & modify them
    if isForAutomated then
        easternTrainNpcConductor = GetPedInVehicleSeat(easternTrain, -1)
        while not easternTrainNpcConductor or easternTrainNpcConductor == 0 do
            easternTrainNpcConductor = GetPedInVehicleSeat(easternTrain, -1)
            Citizen.Wait(1)
        end
        Citizen.Wait(50) -- Required to get correct NetId?

        if Config.DebugEast then print("choo choo3c") end

        -- Prevent de-spawning
        SetEntityAsMissionEntity(easternTrainNpcConductor, true, true)
        NetworkRegisterEntityAsNetworked(easternTrainNpcConductor)
        SetNetworkIdExistsOnAllMachines(PedToNet(easternTrainNpcConductor), true)

        -- Prevent conductor from being killed
        if Config.PreventNpcConductorTakeover then
            MakePedInvincible(easternTrainNpcConductor, true)
            SetTimeout(3000, function()
                FreezeEntityPosition(easternTrainNpcConductor, true)
            end)
        end

        if Config.DebugEast then print("choo choo3d") end
    end

    -- Let the server know the eastern line was spawned
    if isForAutomated then
        TriggerServerEvent("rainbow_choochoo:SpawnedEasternTrain", netId, PedToNet(easternTrainNpcConductor), isForAutomated)
    else
        TriggerServerEvent("rainbow_choochoo:SpawnedEasternTrain", netId, GetPlayerServerId(PlayerId()), isForAutomated)
    end


    if Config.DebugEast then print("choo choo4") end
end

--------

function GetNearbyObjects(coords, radius)
	local itemset = CreateItemset(true)
	local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords, radius, itemset, 3, Citizen.ResultAsInteger())

	local objects = {}

	if size > 0 then
		for i = 0, size - 1 do
			table.insert(objects, GetIndexedItemInItemset(i, itemset))
		end
	end

	if IsItemsetValid(itemset) then
		DestroyItemset(itemset)
	end

	return objects
end

function IsPlayerDriverOfVehicle(vehicle)
    -- if Config.DebugEast then print('IsPlayerDriverOfVehicle', vehicle, Citizen.InvokeNative(0x2963B5C1637E8A27, vehicle)) end
    return (Citizen.InvokeNative(0x2963B5C1637E8A27, vehicle) == PlayerPedId())
end

--------

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then

        if easternTrainClass then
            DeleteEntity(NetToEnt(easternTrainClass:getNetId()))
            if easternTrainClass:getConductorNetId() then
                DeleteEntity(NetToEnt(easternTrainClass:getConductorNetId()))
            end
        end

        if easternTrainNpcTicket then
            DeleteEntity(easternTrainNpcTicket)
        end

        easternTrainClass = nil
    end

end)
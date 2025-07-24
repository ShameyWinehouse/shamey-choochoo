VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

function LoadModelHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
end

function SpawnNpc(modelHashKey, x, y, z, heading)
    LoadModelHashKey(modelHashKey)

    if Config.Debug then print('SpawnNpc', modelHashKey, x, y, z, heading) end

    local npc = CreatePed(modelHashKey, x, y, (z-1.0), heading, false, true, true, true)
    repeat Wait(1) until DoesEntityExist(npc)
    PlaceEntityOnGroundProperly(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    RainbowCore.UtilitySetPedUnattackable(npc)

    SetTimeout(3000, function()
        FreezeEntityPosition(npc, true)
    end)

    return npc
end

function MakePedInvincible(ped, setAsGroupMemberOfPlayer)
    if setAsGroupMemberOfPlayer then
        SetPedAsGroupMember(ped, GetPedGroupIndex(PlayerPedId()))
    end
    SetBlockingOfNonTemporaryEvents(ped,true)

    RainbowCore.UtilitySetPedUnattackable(npc)
end

function GetNearbyVehicles(ped)
    local DataStruct = DataView.ArrayBuffer(256 * 10) 

    local size = Citizen.InvokeNative(0xCFF869CBFA210D82, ped, DataStruct:Buffer()) -- GET_PED_NEARBY_VEHICLES

    local vehicles = {}
    for i = 1, 10, 1 do
        vehicles[i] = DataStruct:GetInt64(8 * i)
    end

    if Config.Debug then print(size, vehicles) end

    return vehicles
end
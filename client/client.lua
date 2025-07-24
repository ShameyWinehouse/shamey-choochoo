VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


playerCoords = nil

local blips = {}


-------- THREADS

-- Let the server know the player joined
Citizen.CreateThread(function()
    CreateBlips()
end)

-- Performance - delay getting ped coords
CreateThread(function()
    while true do
        Wait(100)
        playerCoords = GetEntityCoords(PlayerPedId())
    end
end)


-- -- Debug command
-- if Config.Debug then
--     RegisterCommand("train", function(source, args, raw)
--         if args[1] ~= "delete" then
--             print("trying to create train")
--             local n = tonumber(args[1])
--             if not n then
--                 n = GetHashKey(args[1])
--             end
--             if n then
--                 local direction = 0
--                 if args[2] then
--                     direction = tonumber(args[2])
--                     if direction == nil then
--                         direction = 0
--                     end
--                 end
--                 SpawnEasternTrain(n)
--             else
--                 print("wrong train hash or name")
--             end
--         else
--             print("trying to delete train "..tostring(easternTrain))
--             if easternTrain and easternTrain > 0 then
--                 local train_driver_id  = Citizen.InvokeNative(0x2963B5C1637E8A27, easternTrain)  -- GET_DRIVER_OF_VEHICLE
--                 if train_driver_id and train_driver_id ~= 0 and train_driver_id ~= PlayerPedId() then 
--                     SetEntityAsMissionEntity(train_driver_id,1,1)
--                     DeletePed(train_driver_id)
--                 end
--                 Citizen.InvokeNative(0x0D3630FB07E8B570, Citizen.PointerValueIntInitialized(easternTrain))  -- DELETE_MISSION_TRAIN
--                 Citizen.InvokeNative(0xA3120A1385F17FF7) -- DELETE_ALL_TRAINS   
--                 easternTrain = 0
--             end
--         end
--     end)
-- end


-------- EVENTS



-------- FUNCTIONS

function getNearestTrainStop(subjectVector3)
    local nearestStop = "Valentine"
    local nearestStopDistance = 999999.9
    for k,v in pairs(Config.Stops) do
        local distanceFromStop = #(v.coords - subjectVector3)
        if distanceFromStop <= nearestStopDistance then
            nearestStop = k
            nearestStopDistance = distanceFromStop
        end
    end
    return nearestStop
end

function CreateBlips()
    for k,v in pairs(Config.EasternLine.Blips.Coords) do
        local blip = VORPutils.Blips:SetBlip(Config.EasternLine.Blips.Label, Config.EasternLine.Blips.HashName, 0.2, v.x, v.y, v.z, nil)
        table.insert(blips, blip)
    end
end


--------

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then

        -- Delete the blips
        for k, blip in pairs(blips) do
            blip:Remove()
        end
        
        blips = {}
    end

end)


-------- NATIVES
function NetworkDoesEntityExistWithNetworkId(netId)
    return Citizen.InvokeNative(0x18A47D074708FD68, netId)
  end
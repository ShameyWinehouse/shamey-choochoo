VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


function GetPlayersCount()
    -- if Config.Debug then print("GetPlayersCount()") end
    local players = GetPlayers()
    -- if Config.Debug then print("GetPlayersCount()", players, #players) end
    return #players
end
NUIEvents = {}

NUIEvents.UpdateHUD = function(trainClass, speed)

    local fuel = trainClass:getFuelAmount()

    print(fuel)
	
	SendNUIMessage({
        fuel = fuel,
        speed = speed,
    })
end

NUIEvents.ShowHUD = function(show)
    SendNUIMessage({
        showhud = show
    })
end
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

-- onDuty = false


RegisterServerEvent("rainbow_choochoo:BuyTicket")
AddEventHandler("rainbow_choochoo:BuyTicket", function()
    local _source = source

    if Config.Debug then print("rainbow_choochoo:BuyTicket", _source) end

    local Character = VORPcore.getUser(_source).getUsedCharacter
    local money = Character.money

    local canCarryQuantity = VorpInv.canCarryItems(_source, 1) --can carry inv space
    local canCarryItem = VorpInv.canCarryItem(_source, Config.TicketItemName, 1) --cancarry item

    if not canCarryQuantity then
        VORPcore.NotifyRightTip(_source, "You don't have enough space in your inventory.", 4000)
        return
    end

    if not canCarryItem then
        VORPcore.NotifyRightTip(_source, "You have too many of this item.", 4000)
        return
    end

    if money < Config.TicketPrice then
        VORPcore.NotifyRightTip(_source, "You don't have enough money.", 4000)
        return
    end

    VorpInv.addItem(_source, Config.TicketItemName, 1)
    Character.removeCurrency(0, Config.TicketPrice)

    VORPcore.NotifyRightTip(_source, "You bought 1 " .. Config.TicketLabel .. " for $" .. string.format("%.2f", Config.TicketPrice), 4000)
end)

RegisterServerEvent("rainbow_choochoo:GiveTicket")
AddEventHandler("rainbow_choochoo:GiveTicket", function()
    local _source = source

    if Config.Debug then print("rainbow_choochoo:GiveTicket", _source) end

    local count = VorpInv.getItemCount(_source, Config.TicketItemName)

    if count <= 0 then
        VORPcore.NotifyRightTip(_source, "You don't have a train ticket.", 4000)
        return
    end

    VorpInv.subItem(_source, Config.TicketItemName, 1)
    VORPcore.NotifyRightTip(_source, "You gave the ticket-taker 1 train ticket.", 4000)
end)

-------- STAFF

-- RegisterNetEvent("rainbow_choochoo:Staff:SetDuty")
-- AddEventHandler("rainbow_choochoo:Staff:SetDuty", function(isOnDuty)
--     local _source = source
--     onDuty = isOnDuty
-- end)

RegisterNetEvent("rainbow_choochoo:Staff:GetPaycheck")
AddEventHandler("rainbow_choochoo:Staff:GetPaycheck",function()
	local _source = source
	local User = VORPcore.getUser(_source)
	local Character = User.getUsedCharacter

    for k, v in pairs (Config.Jobs) do
		for i, j in pairs (v.jobGrade) do
			if exports["rainbow-core"]:AbsolutelyHasJobAndGradeServer(_source, v.job, j.grade) then
				Character.addCurrency(0, j.paycheck)
				if Config.ShameyDebug then print("paycheck sent: ", _source) end
				TriggerClientEvent('vorp:Tip', _source, string.upper(v.job).." : Received your paycheck "..j.paycheck.."$", 10000)
			end
		end
	end
end)

RegisterNetEvent("rainbow_choochoo:Staff:DepositTickets")
AddEventHandler("rainbow_choochoo:Staff:DepositTickets",function()
	local _source = source

    if Config.Debug then print("rainbow_choochoo:Staff:DepositTickets", _source) end

    local hasAmount = VorpInv.getItemCount(_source, Config.TicketItemName)

    if hasAmount > 0 then
        VorpInv.subItem(_source, Config.TicketItemName, hasAmount)
        VORPcore.NotifyRightTip(_source, "All train tickets have been emptied from your inventory.", 4000)
    else
        VORPcore.NotifyRightTip(_source, "You do not have any train tickets.", 4000)
    end
end)
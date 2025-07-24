---@class Train
Train = {}

local fuelMaximum = 80

Train.name = nil
Train.netId = 0
Train.conductorNetId = 0
Train.ownerNetId = 0
Train.isAutomated = true
Train.fuelAmount = 0

function Train:getName()
	return self.name
end

function Train:setName(name)
	self.name = name
end

function Train:getNetId()
	return self.netId
end

function Train:setNetId(netId)
	self.netId = netId
end

function Train:getConductorNetId()
	return self.conductorNetId
end

function Train:setConductorNetId(conductorNetId)
	self.conductorNetId = conductorNetId
end

function Train:getOwnerNetId()
	return self.ownerNetId
end

function Train:setOwnerNetId(ownerNetId)
	self.ownerNetId = ownerNetId
end

function Train:getIsAutomated()
	return self.isAutomated
end

function Train:setIsAutomated(isAutomated)
	self.isAutomated = isAutomated
end

function Train:getFuelAmount()
	return self.fuelAmount
end

function Train:setFuelAmount(fuelAmount)
	self.fuelAmount = fuelAmount
end

function Train:addFuel(fuelAmount)
	if self.fuelAmount ~= nil then
		self.fuelAmount = self.fuelAmount + fuelAmount
	else
		self.fuelAmount = tonumber(fuelAmount)
	end

    if self.fuelAmount > fuelMaximum then
        self.fuelAmount = fuelMaximum
    end

	MySQL.update('UPDATE trains SET fuel = @fuel WHERE name=@name',
		{ ['fuel'] = self.fuelAmount, ['name'] = self.name })
end

function Train:subFuel(fuelAmount)
	if self.fuelAmount ~= nil then
		self.fuelAmount = self.fuelAmount - fuelAmount

		if self.fuelAmount <= 0 then
			self.fuelAmount = 0
		end
        
		MySQL.update('UPDATE trains SET fuel = @fuel WHERE name=@name',
			{ ['fuel'] = self.fuelAmount, ['name'] = self.name })
	end
end


---@return Train
function Train:New(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end
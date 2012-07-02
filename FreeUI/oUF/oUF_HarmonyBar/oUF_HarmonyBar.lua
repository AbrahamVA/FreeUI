if select(2, UnitClass('player')) ~= "MONK" then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF_HarmonyBar was unable to locate oUF install')

local SPELL_POWER_LIGHT_FORCE = SPELL_POWER_LIGHT_FORCE

local Colors = { 
	[1] = {.69, .31, .31, 1},
	[2] = {.65, .42, .31, 1},
	[3] = {.65, .63, .35, 1},
	[4] = {.46, .63, .35, 1},
	[5] = {.33, .63, .33, 1},
}

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'LIGHT_FORCE')) then return end
	
	local hb = self.HarmonyBar
	
	if(hb.PreUpdate) then
		hb:PreUpdate(unit)
	end
	
	local light = UnitPower("player", SPELL_POWER_LIGHT_FORCE)
	local numPoints = UnitPowerMax("player", SPELL_POWER_LIGHT_FORCE)

	if hb.numPoints ~= numPoints then
		if numPoints == 4 then
			local spacing = select(4, hb[4]:GetPoint())
			hb[5]:Hide()
			for i = 1, 5 do
				hb[i]:SetWidth(hb[i].W + (hb[i].W/4))
			end
		else
			hb[5]:Show()
			for i = 1, 5 do
				hb[i]:SetWidth(hb[i].W)
			end
		end
		
		hb.numPoints = numPoints
	end

	for i = 1, numPoints do
		if i <= light then
			hb[i]:SetAlpha(1)
		else
			hb[i]:SetAlpha(.2)
		end
	end
	
	if(hb.PostUpdate) then
		return hb:PostUpdate(light)
	end
end

local Path = function(self, ...)
	return (self.HarmonyBar.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'LIGHT_FORCE')
end

local function Enable(self, unit)
	local hb = self.HarmonyBar
	if hb and unit == "player" then
		hb.__owner = self
		hb.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("UNIT_POWER", Update)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		
		for i = 1, 5 do
			local Point = hb[i]
			if not Point:GetStatusBarTexture() then
				Point:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end
			
			Point:SetStatusBarColor(unpack(Colors[i]))
			Point:SetFrameLevel(hb:GetFrameLevel() + 1)
			Point:GetStatusBarTexture():SetHorizTile(false)
			Point.W = Point:GetWidth()
		end
		
		hb.numPoints = 5
		
		return true
	end
end

local function Disable(self)
	if self.HarmonyBar then
		self:UnregisterEvent("UNIT_POWER", Update)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
	end
end

oUF:AddElement('HarmonyBar', Update, Enable, Disable)
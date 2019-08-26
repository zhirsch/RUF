local RUF = RUF or LibStub('AceAddon-3.0'):GetAddon('RUF')
local LSM = LibStub('LibSharedMedia-3.0')
local _, ns = ...
local oUF = ns.oUF

local _,uClass = UnitClass('player')

local classPowerData = {
	DRUID = {
		classPowerID = 4,
		classPowerType = 'COMBO_POINTS',
	},
	MAGE = {
		classPowerID = 16,
		requireSpec = 1,
		classPowerType = 'ARCANE_CHARGES',
	},
	MONK = {
		classPowerID = 12,
		requireSpec = 3,
		classPowerType = 'CHI',
		unitPowerMaxAmount = 6,
	},
	PALADIN = {
		classPowerID = 9,
		requireSpec = 3,
		classPowerType = 'HOLY_POWER',
		unitPowerMaxAmount = 5,
	},
	ROGUE = {
		classPowerID = 4,
		classPowerType = 'COMBO_POINTS',
	},
	WARLOCK = {
		classPowerID = 7,
		classPowerType = 'SOUL_SHARDS',
	},
}

function RUF.SetClassBar(self, unit)
	-- TODO set Class Bar as alternate Power bar for Feral, Guardian, and Restoraion Druids.
	if not classPowerData[uClass] then return end
	local classPowerBar = {}
	local classPowerBorder = {}
	local classPowerBackground = {}
	local unitPowerMaxAmount = classPowerData[uClass].unitPowerMaxAmount or UnitPowerMax(unit,classPowerData[uClass].classPowerID)

	local name = self:GetName() .. '.ClassPower'
	self.ClassPower = {}

	local Holder = CreateFrame('Frame',name..'.Holder',self)
	Holder.barHeight = RUF.db.profile.unit[unit].Frame.Bars.Class.Height

	if RUF.db.profile.unit[unit].Frame.Bars.Class.Position.Anchor == 'TOP' then
		Holder:SetPoint('TOP',0,0)
		Holder:SetPoint('LEFT',0,0)
		Holder:SetPoint('RIGHT',0,0)
		Holder:SetHeight(RUF.db.profile.unit[unit].Frame.Bars.Class.Height)
		Holder.anchorTo = 'TOP'
	else
		Holder:ClearAllPoints()
		Holder:SetPoint('BOTTOM',0,0)
		Holder:SetPoint('LEFT',0,0)
		Holder:SetPoint('RIGHT',0,0)
		Holder:SetHeight(RUF.db.profile.unit[unit].Frame.Bars.Class.Height)
		Holder.anchorTo = 'BOTTOM'
	end

	local texture = LSM:Fetch('statusbar', RUF.db.profile.Appearance.Bars.Class.Texture)
	local r,g,b = unpack(RUF.db.profile.Appearance.Colors.PowerColors[classPowerData[uClass].classPowerID])
	local bgMult = RUF.db.profile.Appearance.Bars.Class.Background.Multiplier
	local colorAdd = RUF.db.profile.Appearance.Bars.Class.Color.Multiplier

	for i = 1,unitPowerMaxAmount do
		local Bar = CreateFrame('StatusBar',name..i,Holder)
		local Border = CreateFrame('Frame',name..i..'.Border',Bar)
		local Background = Bar:CreateTexture(name..i..'.Background','BACKGROUND')
		local size = (RUF.db.profile.unit[unit].Frame.Size.Width + (unitPowerMaxAmount-1)) / unitPowerMaxAmount
		local counter = i
		if unitPowerMaxAmount == 4 then
			counter = i +1
		end

		-- Set Bar Parent Size
		Bar:SetWidth(size)
		Bar:SetHeight(RUF.db.profile.unit[unit].Frame.Bars.Class.Height)
		if i == 1 then
			Bar:SetPoint('TOPLEFT',Holder,'TOPLEFT',0,0)
		else
			Bar:SetPoint('TOPLEFT',classPowerBar[i-1],'TOPRIGHT',-1,0)
		end
		Bar:SetFrameLevel(5)

		-- Set Status Bar
		Bar:SetFillStyle(RUF.db.profile.unit[unit].Frame.Bars.Class.Fill)
		Bar:SetFrameLevel(6)
		Bar:SetStatusBarTexture(texture)
		local ir = (r*((((counter+colorAdd)*6.6667)/100)))
		local ig = (g*((((counter+colorAdd)*6.6667)/100)))
		local ib = (b*((((counter+colorAdd)*6.6667)/100)))
		Bar:SetStatusBarColor(ir,ig,ib)

		-- Set Border
		Border:SetAllPoints(Bar)
		Border:SetFrameLevel(7)
		Border:SetBackdrop({edgeFile = LSM:Fetch('border', RUF.db.profile.Appearance.Bars.Class.Border.Style.edgeFile), edgeSize = RUF.db.profile.Appearance.Bars.Class.Border.Style.edgeSize})
		local borderr,borderg,borderb = unpack(RUF.db.profile.Appearance.Bars.Class.Border.Color)
		Border:SetBackdropBorderColor(borderr,borderg,borderb, RUF.db.profile.Appearance.Bars.Class.Border.Alpha)

		-- Set Background
		Background:SetAllPoints(Bar)
		Background:SetTexture(LSM:Fetch('background', 'Solid'))
		Background:SetVertexColor(r*bgMult,g*bgMult,b*bgMult,RUF.db.profile.Appearance.Bars.Class.Background.Alpha)

		classPowerBar[i] = Bar
		classPowerBorder[i] = Border
		classPowerBackground[i] = Background
		self.ClassPower[i] = Bar
		self.ClassPower[i].Border = Border
		self.ClassPower[i].Background = Background

	end

	self.ClassPower.Override = RUF.ClassUpdate
	self.ClassPower.UpdateColor = RUF.ClassUpdateColor
	self.ClassPower.Holder = Holder
	self.ClassPower.Holder.__owner = self

	self.ClassPower.UpdateOptions = RUF.ClassUpdateOptions


	--self.Background.ClassPower:SetAllPoints(self.ClassPower.Holder)

	-- Force an update to make sure we are showing the correct number of bars for classes with talents that add additional points.
	RUF.ClassUpdate(self, "PLAYER_TALENT_UPDATE", unit, classPowerData[uClass].classPowerType)
end

function RUF.ClassUpdateColor(element, powerType)
	local r,g,b = unpack(RUF.db.profile.Appearance.Colors.PowerColors[classPowerData[uClass].classPowerID])
	local bgMult = RUF.db.profile.Appearance.Bars.Class.Background.Multiplier
	local colorAdd = RUF.db.profile.Appearance.Bars.Class.Color.Multiplier
	for i = 1, #element do
		local counter = i
		if #element == 4 then
			counter = i +1
		end
		local Bar = element[i]
		local Background = element[i].Background
		local ir = (r*((((counter+colorAdd)*6.6667)/100)))
		local ig = (g*((((counter+colorAdd)*6.6667)/100)))
		local ib = (b*((((counter+colorAdd)*6.6667)/100)))
		Bar:SetStatusBarColor(ir,ig,ib)
		Background:SetVertexColor(r*bgMult,g*bgMult,b*bgMult,RUF.db.profile.Appearance.Bars.Class.Background.Alpha)
	end
end

function RUF.ClassUpdate(self, event, unit, powerType)

	-- Override function of oUF's ClassPower Update function.
	if not unit then return end
	if not UnitIsUnit(unit,'player') and (powerType == classPowerData[uClass].classPowerType or (unit == 'vehicle' and powerType == 'COMBO_POINTS')) then return end

	local element = self.ClassPower

	local cur, max, oldMax
	if event ~= 'ClassPowerDisable' then
		local powerID = unit == 'vehicle' and SPELL_POWER_COMBO_POINTS or classPowerData[uClass].classPowerID
		cur = UnitPower(unit, powerID, true)
		max = UnitPowerMax(unit, powerID)

		if(classPowerData[uClass].classPowerType == 'SOUL_SHARDS' and GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION) then
			cur = cur - cur % 1
		end

		local numActive = cur + 0.9
		local size = (RUF.db.profile.unit[self.frame].Frame.Size.Width + (max-1)) / max
		if event == 'UNIT_MAXPOWER' or event == 'PLAYER_TALENT_UPDATE' or event == 'ClassPowerEnable' or event == 'ForceUpdate' then
			for i = 1, #element do
				if i > max then
					if element[i]:IsVisible() then
						element[i]:Hide()
						element[i]:SetValue(0)
						for j = 1,#element do
							element[j]:SetWidth(size)
						end
					end
				else
					if not element[i]:IsVisible() then
						element[i]:Show()
						for j = 1,#element do
							element[j]:SetWidth(size)
						end
					end
				end
			end
		end


		if RUF.db.global.TestMode == true then
			cur = math.random(0,max)
		end
		for i = 1, #element do
			if cur >= i then
				element[i]:SetValue(cur)
			else
				element[i]:SetValue(0)
			end
		end

		oldMax = element.__max
		if(max ~= oldMax) then
			element.__max = max
		end
	end

	--[[if element[1]:IsVisible() then
		self.Background.ClassPower:Hide()
	else
		self.Background.ClassPower:Show()
	end]]--

	if event == 'ClassPowerDisable' then
		self.ClassPower.Holder:Hide()
		--self.Background.ClassPower:Show()
	end
	if event == 'ClassPowerEnable' then
		self.ClassPower.Holder:Show()
		--self.Background.ClassPower:Hide()
	end
end

function RUF.ClassUpdateOptions(self)
	-- TODO: Update Position

	if not classPowerData[uClass] then return end
	local unit = self.__owner.frame
	local unitPowerMaxAmount = classPowerData[uClass].unitPowerMaxAmount or UnitPowerMax(unit,classPowerData[uClass].classPowerID)
	local texture = LSM:Fetch('statusbar', RUF.db.profile.Appearance.Bars.Class.Texture)
	local r,g,b = unpack(RUF.db.profile.Appearance.Colors.PowerColors[classPowerData[uClass].classPowerID])
	local bgMult = RUF.db.profile.Appearance.Bars.Class.Background.Multiplier
	local colorAdd = RUF.db.profile.Appearance.Bars.Class.Color.Multiplier

	local holder = self.__owner.ClassPower.Holder
	holder:SetHeight(RUF.db.profile.unit[unit].Frame.Bars.Class.Height)
	holder.barHeight = RUF.db.profile.unit[unit].Frame.Bars.Class.Height

	for i = 1,unitPowerMaxAmount do
		local Bar = self[i]
		local Background = self[i].Background
		local Border = self[i].Border
		local size = (RUF.db.profile.unit[unit].Frame.Size.Width + (unitPowerMaxAmount-1)) / unitPowerMaxAmount
		local counter = i
		if unitPowerMaxAmount == 4 then
			counter = i +1
		end

		-- Set Bar Parent Size
		Bar:SetWidth(size)
		Bar:SetHeight(RUF.db.profile.unit[unit].Frame.Bars.Class.Height)
		Bar:SetFrameLevel(5)

		-- Set Status Bar
		Bar:SetFillStyle(RUF.db.profile.unit[unit].Frame.Bars.Class.Fill)
		Bar:SetFrameLevel(6)
		Bar:SetStatusBarTexture(texture)
		local ir = (r*((((counter+colorAdd)*6.6667)/100)))
		local ig = (g*((((counter+colorAdd)*6.6667)/100)))
		local ib = (b*((((counter+colorAdd)*6.6667)/100)))
		Bar:SetStatusBarColor(ir,ig,ib)

		-- Set Border
		Border:SetAllPoints(Bar)
		Border:SetFrameLevel(7)
		Border:SetBackdrop({edgeFile = LSM:Fetch('border', RUF.db.profile.Appearance.Bars.Class.Border.Style.edgeFile), edgeSize = RUF.db.profile.Appearance.Bars.Class.Border.Style.edgeSize})
		local borderr,borderg,borderb = unpack(RUF.db.profile.Appearance.Bars.Class.Border.Color)
		Border:SetBackdropBorderColor(borderr,borderg,borderb, RUF.db.profile.Appearance.Bars.Class.Border.Alpha)

		-- Set Background
		Background:SetAllPoints(Bar)
		Background:SetTexture(LSM:Fetch('background', 'Solid'))
		Background:SetVertexColor(r*bgMult,g*bgMult,b*bgMult,RUF.db.profile.Appearance.Bars.Class.Background.Alpha)



	end

	RUF:SetBarLocation(self.__owner,unit)
	self:ForceUpdate()

end
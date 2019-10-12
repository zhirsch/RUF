local RUF = RUF or LibStub('AceAddon-3.0'):GetAddon('RUF')
local LSM = LibStub('LibSharedMedia-3.0')
local _, ns = ...
local oUF = ns.oUF

function RUF.HealPredictionUpdateColor(element, unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	local cur = UnitHealth(unit)
	if element.myBar then
		local r,g,b = RUF:GetBarColor(element, unit, 'HealPrediction', 'Player', cur)
		local a = RUF.db.profile.Appearance.Bars.HealPrediction.Player.Color.Alpha
		element.myBar:SetStatusBarColor(r,g,b,a)
	end
	if element.otherBar then
		local r,g,b = RUF:GetBarColor(element, unit, 'HealPrediction', 'Others', cur)
		local a = RUF.db.profile.Appearance.Bars.HealPrediction.Others.Color.Alpha
		element.otherBar:SetStatusBarColor(r,g,b,a)
	end
end

function RUF.SetHealPrediction(self, unit)
	local PlayerHeals,OtherHeals
	local Health = self.Health

	PlayerHeals = CreateFrame('StatusBar', nil, Health)
	OtherHeals = CreateFrame('StatusBar', nil, Health)
	local anchorFrom, anchorTo
	if Health.FillStyle == 'REVERSE' then -- Right
		anchorFrom = 'RIGHT'
		anchorTo = 'LEFT'
	--elseif Health.FillStyle == 'CENTER' then
		-- TODO: Create a bar on either side of the health bar and split value in two to make it grow outwards.
	else -- Left
		anchorFrom = 'LEFT'
		anchorTo = 'RIGHT'
	end

	local profileReference = RUF.db.profile.Appearance.Bars.HealPrediction
	local texture = LSM:Fetch("statusbar", profileReference.Player.Texture)
	PlayerHeals:SetPoint('TOP')
	PlayerHeals:SetPoint('BOTTOM')
	PlayerHeals:SetPoint(anchorFrom, self.Health:GetStatusBarTexture(), anchorTo)
	PlayerHeals:SetStatusBarTexture(texture)
	PlayerHeals:SetStatusBarColor(0,1,0,1)
	PlayerHeals:SetFillStyle(RUF.db.profile.unit[self.frame].Frame.Bars.Health.Fill)
	PlayerHeals:SetWidth(self:GetWidth())
	PlayerHeals:Hide()
	PlayerHeals.FillStyle = RUF.db.profile.unit[unit].Frame.Bars.Health.Fill
	PlayerHeals.Enabled = profileReference.Player.Enabled

	texture = LSM:Fetch("statusbar", profileReference.Others.Texture)
	OtherHeals:SetPoint('TOP')
	OtherHeals:SetPoint('BOTTOM')
	OtherHeals:SetPoint(anchorFrom, PlayerHeals:GetStatusBarTexture(), anchorTo)
	OtherHeals:SetStatusBarTexture(texture)
	OtherHeals:SetStatusBarColor(0,1,1,1)
	OtherHeals:SetFillStyle(RUF.db.profile.unit[self.frame].Frame.Bars.Health.Fill)
	OtherHeals:SetWidth(self:GetWidth())
	OtherHeals:Hide()
	OtherHeals.FillStyle = RUF.db.profile.unit[unit].Frame.Bars.Health.Fill
	OtherHeals.Enabled = profileReference.Others.Enabled

	-- Register with oUF
	self.HealPrediction = {
		myBar = PlayerHeals,
		otherBar = OtherHeals,
		maxOverflow = 1 + profileReference.Overflow or 0,
		frequentUpdates = true, -- TODO Option
	}
	self.HealPrediction.UpdateOptions = RUF.HealPredictionUpdateOptions
end

function RUF.HealPredictionUpdateOptions(self)
	local unit = self.__owner.frame
	local profileReference = RUF.db.profile.Appearance.Bars.HealPrediction
	self.frequentUpdates = true -- TODO Option
	self.maxOverflow = 1 + profileReference.Overflow or 0

	local PlayerHeals = self.myBar
	local OtherHeals = self.otherBar


	local anchorFrom, anchorTo, anchorTexture
	if self.__owner.Health.FillStyle == 'REVERSE' then -- Right
		anchorFrom = 'RIGHT'
		anchorTo = 'LEFT'
	--elseif Health.FillStyle == 'CENTER' then
		-- TODO: Create a bar on either side of the health bar and split value in two to make it grow outwards.
	else -- Left
		anchorFrom = 'LEFT'
		anchorTo = 'RIGHT'
	end

	local texture = LSM:Fetch("statusbar", profileReference.Player.Texture)
	PlayerHeals:SetPoint('TOP')
	PlayerHeals:SetPoint('BOTTOM')
	PlayerHeals:SetPoint(anchorFrom, self.__owner.Health:GetStatusBarTexture(), anchorTo)
	PlayerHeals:SetStatusBarTexture(texture)
	PlayerHeals:SetFillStyle(RUF.db.profile.unit[unit].Frame.Bars.Health.Fill)
	PlayerHeals:SetWidth(self.__owner:GetWidth())
	PlayerHeals.FillStyle = RUF.db.profile.unit[unit].Frame.Bars.Health.Fill
	PlayerHeals.Enabled = profileReference.Player.Enabled

	if PlayerHeals.Enabled then
		anchorTexture = PlayerHeals:GetStatusBarTexture()
	else
		anchorTexture = self.__owner.Health:GetStatusBarTexture()
	end
	texture = LSM:Fetch("statusbar", profileReference.Others.Texture)
	OtherHeals:SetPoint('TOP')
	OtherHeals:SetPoint('BOTTOM')
	OtherHeals:SetPoint(anchorFrom, anchorTexture, anchorTo)
	OtherHeals:SetStatusBarTexture(texture)
	OtherHeals:SetFillStyle(RUF.db.profile.unit[unit].Frame.Bars.Health.Fill)
	OtherHeals:SetWidth(self.__owner:GetWidth())
	OtherHeals.FillStyle = RUF.db.profile.unit[unit].Frame.Bars.Health.Fill
	OtherHeals.Enabled = profileReference.Others.Enabled

	-- TODO Add Smoothing support
	-- This should already work, just need to update initial hook so it gets set at login too.
	--[[if PlayerHeals.Smooth == true then
		self.__owner:SmoothBar(PlayerHeals)
	else
		self.__owner:UnSmoothBar(PlayerHeals)
	end]]--

	self:ForceUpdate()
end
local RUF = RUF or LibStub("AceAddon-3.0"):GetAddon("RUF")
local L = LibStub("AceLocale-3.0"):GetLocale("RUF")
local LSM = LibStub("LibSharedMedia-3.0")
local _, ns = ...
local oUF = ns.oUF
local _, PlayerClass = UnitClass('player')
local UnitSettingsDone


local function SetClassColors()
	local function customClassColors()
		if(CUSTOM_CLASS_COLORS) and RUF.db.profile.Appearance.Colors.UseClassColors then
			local function updateColors()
				for classToken, color in next, CUSTOM_CLASS_COLORS do
					RUF.db.profile.Appearance.Colors.ClassColors[classToken] = {(color.r), (color.g), (color.b)}
				end
				for _, obj in next, oUF.objects do
					obj:UpdateAllElements('CUSTOM_CLASS_COLORS')
				end
			end
			updateColors()
			CUSTOM_CLASS_COLORS:RegisterCallback(updateColors)
			return true
		end
	end
	if(not customClassColors()) then
		local eventHandler = CreateFrame('Frame')
		eventHandler:RegisterEvent('ADDON_LOADED')
		eventHandler:SetScript('OnEvent', function(self)
			if(customClassColors()) then
				self:UnregisterEvent('ADDON_LOADED')
				self:SetScript('OnEvent', nil)
			end
		end)
	end
end

-- TODO Check if following elements should be enabled and disable them after creation if necessary.
-- self:DisableElement("Power")

local function SetupFrames(self, unit)
	unit = unit:match('^(.-)%d+') or unit
	self.frame = unit
	local profileReference = RUF.db.profile.unit[unit]

	-- Set Colors
	if RUF.Client == 1 then
		SetClassColors()
	end

	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	-- Frame Size
	self:SetHeight(profileReference.Frame.Size.Height)
	self:SetWidth(profileReference.Frame.Size.Width)
	self:SetClampedToScreen(true)

	-- Frame Border
	RUF.SetFrameBorder(self,unit)

	-- Frame Background
	RUF.SetFrameBackground(self, unit)


	-- Setup Bars
	RUF.SetHealthBar(self, unit)
	self.Health.Override = RUF.HealthUpdate
	self.Health.UpdateColor = RUF.HealthUpdateColor
	-- self.Health.PostUpdate = RUF.HealthPostUpdate
	-- Set PostUpdate only if needed. See Health.lua

	-- Mana / Energy / Rage / Focus / Runic Power
	RUF.SetPowerBar(self, unit)
	self.Power.Override = RUF.PowerUpdate
	--self.Power.PreUpdate = RUF.PowerPreUpdate
	--self:RegisterEvent("UNIT_TARGET", RUF.PowerPreUpdate)

	if RUF.Client == 1 then
		-- Prevents trying to load these elements for Classic since they don't exist in Classic.

		-- Absorb Bars
		RUF.SetAbsorbBar(self, unit)
		self.Absorb.Override = RUF.AbsorbUpdate

		if unit == 'player' then
			self:SetAttribute('toggleForVehicle', false) -- TODO Implement option for this
			RUF.SetClassBar(self, unit) -- Normal Class Power bar
			RUF.SetFakeClassBar(self, unit) -- Fake Clone Bar for Insanity/Maelstrom/Lunar Power
			RUF.SetRunes(self, unit)
			RUF.SetStagger(self, unit)
		end
		if unit == 'pet' then
			self:SetAttribute('toggleForVehicle', false)
		end

	end

	-- Class (or Spec) specific resources
	-- Holy Power, Chi, Arcane Charges, Astral Power, Combo Points, Soul Shards, Maelstrom, Insanity etc.
	-- FUNCTIONNAME(self, unit)

	--RUF:SetBarLocation(self,unit)
	--RUF:UpdateBarLocation(self,unit)


	-- Castbars
	-- TODO Styling and Positioning from profile.
	--RUF.SetCastBar(self, unit)

	RUF.SetTextParent(self,unit)
	local texts = {}
	for k,v in pairs(profileReference.Frame.Text) do
		if v ~= "" then
			table.insert(texts,k)
		end
	end
	for i = 1,#texts do
		RUF.CreateTextArea(self,unit,texts[i])
		if profileReference.Frame.Text[texts[i]].Enabled == false then
			self.Text[texts[i]].String:UpdateTag()
			self:Untag(self.Text[texts[i]].String)
			self.Text[texts[i]].String:Hide()
		end
	end
	for i = 1,#texts do
		RUF.SetTextPoints(self,unit,texts[i])
	end

	-- Setup Auras
	RUF.SetBuffs(self,unit)
	RUF.SetDebuffs(self,unit)

	-- Indicators
	RUF.SetIndicators(self, unit)

end

function RUF:OnEnable()
	if RUF.db.char.Nickname ~= "" then
		if RUF:GetNickname(UnitName('player'),false,true) ~= RUF.db.char.Nickname then
			if RUF:NickValidator(RUF.db.char.Nickname) == true and RUF.db.char.Nickname ~= UnitName('player') then
				RUF:SetNickname(RUF.db.char.Nickname)
			end
		end
	end
	oUF:RegisterStyle('RUF_', SetupFrames)
	oUF:Factory(function(self)
		self:SetActiveStyle('RUF_')

		-- Spawn single unit frames
		local frames = {}
		local groupFrames = {}
		if RUF.Client == 1 then
			frames = {
				'Player',
				'Pet',
				'PetTarget',
				'Focus',
				'FocusTarget',
				'Target',
				'TargetTarget',
			}
			groupFrames = {
				'Boss',
				--'BossTarget',
				'Arena',
				--'ArenaTarget',
			}
		else
			frames = {
				'Player',
				'Pet',
				'PetTarget',
				'Target',
				'TargetTarget',
			}
			-- No Arena or Boss units in vanilla.
		end
		for i = 1,#frames do
			local profile = string.lower(frames[i])
			self:Spawn(profile):SetPoint(
				RUF.db.profile.unit[profile].Frame.Position.AnchorFrom,
				RUF.db.profile.unit[profile].Frame.Position.AnchorFrame,
				RUF.db.profile.unit[profile].Frame.Position.AnchorTo,
				RUF.db.profile.unit[profile].Frame.Position.x,
				RUF.db.profile.unit[profile].Frame.Position.y)

			if RUF.db.profile.unit[profile].Enabled == false then
				_G['oUF_RUF_' .. frames[i]]:Disable()
			end
		end

		local AnchorFrom
		if RUF.db.profile.unit["party"].Frame.Position.growth == "BOTTOM" then
			AnchorFrom = "TOP"
		elseif RUF.db.profile.unit["party"].Frame.Position.growth == "TOP" then
			AnchorFrom = "BOTTOM"
		end

		-- Spawn party
		local party = oUF:SpawnHeader(
			'oUF_RUF_Party', nil, 'party',
			'showSolo', false,
			'showParty', true,
			'showRaid', false,
			'showPlayer', false,
			'yOffset', RUF.db.profile.unit["party"].Frame.Position.offsety,
			'Point', AnchorFrom
		):SetPoint(
			RUF.db.profile.unit["party"].Frame.Position.AnchorFrom,
			RUF.db.profile.unit["party"].Frame.Position.AnchorFrame,
			RUF.db.profile.unit["party"].Frame.Position.AnchorTo,
			RUF.db.profile.unit["party"].Frame.Position.x,
			RUF.db.profile.unit["party"].Frame.Position.y)

		-- Spawn single frames for Boss and Arena units
		for i = 1, #groupFrames do
			local frameName = 'oUF_RUF_' .. groupFrames[i]
			local profile = string.lower(groupFrames[i])
			local AnchorFrom
			if RUF.db.profile.unit[profile].Frame.Position.growth == "BOTTOM" then
				AnchorFrom = "TOP"
			elseif RUF.db.profile.unit[profile].Frame.Position.growth == "TOP" then
				AnchorFrom = "BOTTOM"
			end
			for u = 1,5 do
				local frame = self:Spawn(profile..u)
				if(u == 1) then
					frame:SetPoint(
						RUF.db.profile.unit[profile].Frame.Position.AnchorFrom,
						RUF.db.profile.unit[profile].Frame.Position.AnchorFrame,
						RUF.db.profile.unit[profile].Frame.Position.AnchorTo,
						RUF.db.profile.unit[profile].Frame.Position.x,
						RUF.db.profile.unit[profile].Frame.Position.y)
				else
					frame:SetPoint(
						AnchorFrom,
						_G[frameName .. u -1],
						RUF.db.profile.unit[profile].Frame.Position.growth,
						RUF.db.profile.unit[profile].Frame.Position.offsetx,
						RUF.db.profile.unit[profile].Frame.Position.offsety)
				end
				if RUF.db.profile.unit[profile].Enabled == false then
					_G['oUF_RUF_' .. groupFrames[i]..u]:Disable()
				end
			end
		end
	end)


	-- Spawn full list of party frames immediately
	-- rather than on-demand, so it's easier to manage test-mode display
	local PartyNum = GetNumSubgroupMembers()
	oUF_RUF_Party.Enabled = RUF.db.profile.unit["party"].Enabled
	oUF_RUF_Party:SetAttribute('startingIndex', -3 + PartyNum)
	oUF_RUF_Party:Show()
	oUF_RUF_Party:SetAttribute('startingIndex', 1)
	oUF_RUF_Party:SetClampedToScreen(true)
	RegisterAttributeDriver(oUF_RUF_Party,'state-visibility',oUF_RUF_Party.visibility)
	if RUF.db.profile.unit['party'].Enabled == false then
		oUF_RUF_PartyUnitButton1:Disable()
		oUF_RUF_PartyUnitButton2:Disable()
		oUF_RUF_PartyUnitButton3:Disable()
		oUF_RUF_PartyUnitButton4:Disable()
	end

	-- Create Party Holder for dragging.
	local MoveBG = CreateFrame("Frame",oUF_RUF_Party:GetName()..".MoveBG",oUF_RUF_Party)
	MoveBG:SetAllPoints(oUF_RUF_Party)
	local Background = MoveBG:CreateTexture(oUF_RUF_Party:GetName()..".MoveBG.BG","BACKGROUND")
	Background:SetTexture(LSM:Fetch("background", "Solid"))
	Background:SetAllPoints(MoveBG)
	Background:SetVertexColor(0,0,0,0)
	MoveBG:SetFrameStrata("HIGH")
	MoveBG:Hide()


	if PlayerClass == 'DEATHKNIGHT' then
		-- I don't know why, but this only seems to work here.
		if RUF.db.profile.unit['player'].Frame.Bars.Class.Enabled == false then
			oUF_RUF_Player:DisableElement('Runes')
		end
	end
end
local RUF = RUF or LibStub("AceAddon-3.0"):GetAddon("RUF")
local L = LibStub("AceLocale-3.0"):GetLocale("RUF")
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

function RUF:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("RUFDB", RUF.Layout.cfg, true) -- Setup Saved Variables
	RUF.Client = 1
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		-- Running classic client, set global variable so we run classic code alterations.
		RUF.Client = 2
	end

	if RUF.Client == 1 then
		local LibDualSpec = LibStub('LibDualSpec-1.0')
		LibDualSpec:EnhanceDatabase(self.db, "RUF")
	end

	-- Register /RUF command
	self:RegisterChatCommand("RUF", "ChatCommand")

	-- Profile Management
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	-- Register Media
	LSM:Register("font", "RUF", [[Interface\Addons\RUF\Media\TGL.ttf]],LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register("statusbar", "RUF 1", [[Interface\Addons\RUF\Media\Raeli 1.tga]])
	LSM:Register("statusbar", "RUF 2", [[Interface\Addons\RUF\Media\Raeli 2.tga]])
	LSM:Register("statusbar", "RUF 3", [[Interface\Addons\RUF\Media\Raeli 3.tga]])
	LSM:Register("statusbar", "RUF 4", [[Interface\Addons\RUF\Media\Raeli 4.tga]])
	LSM:Register("statusbar", "RUF 5", [[Interface\Addons\RUF\Media\Raeli 5.tga]])
	LSM:Register("statusbar", "RUF 6", [[Interface\Addons\RUF\Media\Raeli 6.tga]])
	LSM:Register("statusbar", "Armory",[[Interface\Addons\RUF\Media\Extra\Armory.tga]])
	LSM:Register("statusbar", "Cabaret 2", [[Interface\Addons\RUF\Media\Extra\Cabaret 2.tga]])
	LSM:Register("border","RUF Pixel", [[Interface\ChatFrame\ChatFrameBackground]])
	LSM:Register("border","RUF Glow", [[Interface\Addons\RUF\Media\InternalGlow.tga]])
	LSM:Register("border","RUF Glow Small", [[Interface\Addons\RUF\Media\InternalGlowSmall.tga]])
	LSM:Register("font","Overwatch Oblique",[[Interface\Addons\RUF\Media\Extra\BigNoodleTooOblique.ttf]])
	LSM:Register("font","Overwatch",[[Interface\Addons\RUF\Media\Extra\BigNoodleToo.ttf]])
	LSM:Register("font","Futura",[[Interface\Addons\RUF\Media\Extra\Futura.ttf]])
	LSM:Register("font","Semplicita Light",[[Interface\Addons\RUF\Media\Extra\semplicita.light.otf]])
	LSM:Register("font","Semplicita Light Italic",[[Interface\Addons\RUF\Media\Extra\semplicita.light-italic.otf]])
	LSM:Register("font","Semplicita Medium",[[Interface\Addons\RUF\Media\Extra\semplicita.medium.otf]])
	LSM:Register("font","Semplicita Medium Italic",[[Interface\Addons\RUF\Media\Extra\semplicita.medium-italic.otf]])

	RUF.db.global.TestMode = false
	RUF.db.global.frameLock = true

	--project-revision
	RUF.db.global.Version = string.match(GetAddOnMetadata("RUF","Version"),"%d+")

	if not RUFDB.profiles then
		RUFDB.profiles = {}
		RUFDB.profiles["Alidie's Layout"] = RUF.Layout.Alidie
		RUFDB.profiles["Raeli's Layout"] = RUF.Layout.Raeli
	else
		if not RUFDB.profiles["Alidie's Layout"] then
			RUFDB.profiles["Alidie's Layout"] = RUF.Layout.Alidie
		end
		if not RUFDB.profiles["Raeli's Layout"] then
			RUFDB.profiles["Raeli's Layout"] = RUF.Layout.Raeli
		end
	end
end

function RUF:ChatCommand(input)
	if not InCombatLockdown() then
		self:EnableModule("Options")
		if ACD.OpenFrames["RUF"] then
			ACD:Close("RUF")
		else
			ACD:Open("RUF")
		end
	else
		RUF:Print_Self(L["Cannot configure while in combat."])
	end
end

function RUF:RefreshConfig()
	RUF.db.profile = self.db.profile
	RUF:UpdateAllUnitSettings()
end
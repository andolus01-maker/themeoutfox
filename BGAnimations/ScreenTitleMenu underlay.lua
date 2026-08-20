-- =====================================================================
-- Title screen
-- =====================================================================
-- Modern mode adds an accent halo behind the logo, a softer breathing
-- animation and glass info chips for the song count and engine build.
-- All original behaviour (mod reset, Discord presence, memory card
-- prompts) is untouched.
-- =====================================================================

local Modern = ModernUI and ModernUI.IsModern()
local function Dur(seconds)
    if ModernUI then return ModernUI.T(seconds) end
    return seconds
end

local t = Def.ActorFrame {
    OnCommand=function(self)
        -- Reset machine profile mods
        ResetLuaMods(PLAYER_1)
        ResetLuaMods(PLAYER_2)

        GAMESTATE:UpdateDiscordGameMode(GAMESTATE:GetCurrentGame():GetName())
        GAMESTATE:UpdateDiscordScreenInfo("Title Menu", "", 1)
    end,

    Def.ActorFrame {
        OnCommand=function(self)
            self:xy(SCREEN_CENTER_X, SCREENMAN:GetTopScreen():GetName() == "ScreenLogo" and SCREEN_CENTER_Y or SCREEN_CENTER_Y - 20)
            :queuecommand("ZoomY")
        end,

        OffCommand=function(self)
            self:stoptweening()
            :easeoutexpo(Dur(0.5))
            :zoom(1.5):diffusealpha(0)
        end,

        ZoomYCommand=function(self)
            -- Softer, slower breathing than the original 0.96 snap
            self:accelerate(Dur(3.4288))
            :zoom(Modern and 0.98 or 0.96)
            :decelerate(Dur(3.4288))
            :zoom(1)
            :queuecommand("ZoomY")
        end,

        -- Accent halo behind the logo
        Modern and ModernUI.SoftGlow {
            x = 0, y = 0, zoom = 3.2, alpha = 0.22,
            pulse = 1.05, period = 5, color = ModernUI.Accent(1),
        } or Def.Actor {},

        Modern and ModernUI.SoftGlow {
            x = 0, y = 40, zoom = 2.2, alpha = 0.18,
            pulse = 1.07, period = 7, offset = 1.2, color = ModernUI.Accent(2),
        } or Def.Actor {},

        LoadActor(THEME:GetPathG("", "Logo/Parts"))..{
            InitCommand=function(self)
                self:zoom(0.8)
            end
        },

        Def.Sprite {
            Texture=THEME:GetPathG("", "Logo/Logo"),
            OnCommand=function(self)
                self:diffusealpha(0)
                :zoom(0.8)
                :queuecommand("Pulse")
            end,
            PulseCommand=function(self)
                self:sleep(Dur(3.4288))
                :diffusealpha(0.5)
                :zoom(0.8)
                :decelerate(Dur(1.7144))
                :zoom(1)
                :diffusealpha(0)
                :sleep(Dur(1.7144))
                :queuecommand("Pulse")
            end,
        },

        Def.Sprite {
            Texture=THEME:GetPathG("", "Logo/BlurLogo"),
            OnCommand=function(self)
                self:zoom(0.83)
                :diffusealpha(0)
                :queuecommand("Flash")
            end,
            FlashCommand=function(self)
                self:accelerate(Dur(3.4288))
                :diffusealpha(Modern and 0.65 or 0.8)
                :decelerate(Dur(3.4288))
                :diffusealpha(0)
                :queuecommand("Flash")
            end,
            OffCommand=function(self)
                self:stoptweening()
                :diffusealpha(1)
                :easeoutexpo(Dur(1))
                :zoom(2):diffusealpha(0)
            end,
        }
    },

    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, 20)
        end,

        OffCommand=function(self)
            self:stoptweening():easeoutexpo(Dur(1)):xy(SCREEN_CENTER_X, -80)
        end,

        -- Glass chip behind the library / build info
        Modern and ModernUI.GlassCard {
            x = 0, y = 20, w = 420, h = 56,
            valign = 0.5, alpha = 0.45, accentBar = false,
        } or Def.Actor {},

        Def.BitmapText {
            Font="Montserrat normal 20px",
            InitCommand=function(self)
                if Modern then self:diffuse(ModernUI.Tokens.Text) end
                local InstalledSongs, Groups, InstalledCourses = 0
                if SONGMAN:GetRandomSong() then
                    InstalledSongs, Groups, InstalledCourses =
                        SONGMAN:GetNumSongs() + SONGMAN:GetNumAdditionalSongs() + SONGMAN:GetNumUnlockedSongs(),
                        SONGMAN:GetNumSongGroups(),
                        SONGMAN:GetNumCourses() + SONGMAN:GetNumAdditionalCourses()
                else
                    return
                end

                self:settextf(THEME:GetString("ScreenTitleMenu", "%i Songs (%i Groups), %i Courses"), InstalledSongs, Groups, InstalledCourses)
            end
        },

        Def.BitmapText {
            Font="Montserrat normal 20px",
            Text=string.format("OutFox %s - %s", ProductVersion(), VersionDate()),
            AltText="OutFox",
            InitCommand=function(self)
                self:y(20)
                if Modern then self:diffuse(ModernUI.Tokens.TextDim):zoom(0.9) end
            end
        }
    }
}

if not IsHome() and GAMESTATE:EnoughCreditsToJoin() then
    t[#t+1] = Def.ActorFrame {
        OnCommand=function(self)
            -- Hide "Press Center Step" icons if we're on ScreenLogo
            self:visible(SCREENMAN:GetTopScreen():GetName() ~= "ScreenLogo" and true or false)
        end,

        LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {
            InitCommand=function(self) self:xy(SCREEN_CENTER_X - SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.75):queuecommand("Refresh") end,
            OffCommand=function(self) self:stoptweening():easeoutexpo(Dur(0.25)):zoom(2):diffusealpha(0) end,
            StorageDevicesChangedMessageCommand=function(self)self:queuecommand("Refresh")end,
            RefreshCommand=function(self)
			CardState = MEMCARDMAN:GetCardState(PLAYER_1)
			if CardState == "MemoryCardState_none" then
				self:GetChild("Press"):Load(THEME:GetPathG("", "PressCenterStep/Press"))
			elseif CardState == "MemoryCardState_ready" then
				self:GetChild("Press"):Load(THEME:GetPathG("", "PressCenterStep/USB"))
			elseif CardState == "MemoryCardState_error" then
				self:GetChild("Press"):Load(THEME:GetPathG("", "PressCenterStep/Error"))
			end
		end
        },

        LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {
            InitCommand=function(self) self:xy(SCREEN_CENTER_X + SCREEN_WIDTH * 0.3, SCREEN_HEIGHT * 0.75):queuecommand("Refresh") end,
            OffCommand=function(self) self:stoptweening():easeoutexpo(Dur(0.25)):zoom(2):diffusealpha(0) end,
            StorageDevicesChangedMessageCommand=function(self)self:queuecommand("Refresh")end,
            RefreshCommand=function(self)
			CardState = MEMCARDMAN:GetCardState(PLAYER_2)
			if CardState == "MemoryCardState_none" then
				self:GetChild("Press"):Load(THEME:GetPathG("", "PressCenterStep/Press"))
			elseif CardState == "MemoryCardState_ready" then
				self:GetChild("Press"):Load(THEME:GetPathG("", "PressCenterStep/USB"))
			elseif CardState == "MemoryCardState_error" then
				self:GetChild("Press"):Load(THEME:GetPathG("", "PressCenterStep/Error"))
			end
		end
        }
    }
end

return t

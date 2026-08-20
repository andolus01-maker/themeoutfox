-- =====================================================================
-- Top / bottom HUD chrome
-- =====================================================================
-- Modern mode replaces the flat Infinity plates with layered glass:
--   * frosted gradient bar + accent hairline
--   * original panel art kept underneath at low opacity so the theme
--     still reads as Infinity, just cleaner
--   * light typography (white on dark) instead of black on light
--   * elevated avatar card with accent ring and level chip
-- All original functionality (screen name, stage count, lives, avatars,
-- profile level) is preserved, and classic mode restores the old look.
-- =====================================================================

local Modern    = ModernUI and ModernUI.IsModern()
local Glass     = ModernUI and ModernUI.UseGlass()
local Accent    = Modern and ModernUI.Accent(1) or color("#39E6FF")
local Accent2   = Modern and ModernUI.Accent(2) or color("#3D7BFF")
local TextTone  = Modern and ModernUI.Tokens.Text or Color.Black
local PanelArt  = Modern and 0.42 or 1

local function Dur(seconds)
    if ModernUI then return ModernUI.T(seconds) end
    return seconds
end

local t = Def.ActorFrame {
    Def.ActorFrame {
        Name="TopChrome",
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -128)
        end,
        OnCommand=function(self)
            self:easeoutexpo(Dur(0.5)):xy(SCREEN_CENTER_X, 0)
        end,
        OffCommand=function(self)
            self:easeoutexpo(Dur(0.5)):xy(SCREEN_CENTER_X, -128)
        end,

        -- Frosted glass slab behind the original plate
        Glass and ModernUI.ChromeBar {
            x = 0, y = 0, w = SCREEN_WIDTH, h = 92,
            valign = 0, alpha = 0.62, accentThickness = 2,
        } or Def.Actor {},

        -- Top panel (original art, dimmed so the glass shows through)
        Def.Sprite {
            Texture=THEME:GetPathG("", "UI/PanelTop"),
            InitCommand=function(self)
                self:scaletofit(0, 0, 1280, 128):xy(0, 0):valign(0)
                    :diffusealpha(PanelArt)
            end,
        },

        -- Accent hairline along the bottom edge of the bar
        Modern and Def.Quad {
            InitCommand=function(self)
                self:zoomto(SCREEN_WIDTH, 2):valign(1):y(92)
                    :diffuse(Accent):diffuserightedge(Accent2)
                    :blend("BlendMode_Add"):diffusealpha(0.7)
            end
        } or Def.Actor {},

        -- Screen name
        Def.BitmapText {
            Name="ScreenName",
            Font=Modern and "Montserrat extrabold 40px" or "Montserrat normal 40px",
            Text=ToUpper(Screen.String("HeaderText")),
            InitCommand=function(self)
                self:xy(-WideScale(200, 200), 40):halign(1):zoom(0.6)
                    :diffuse(TextTone):shadowlength(Modern and 0 or 1)

                if Modern then
                    self:skewx(-0.06)
                        :shadowlength(2):shadowcolor(color("0,0,0,0.55"))
                end

                if not IsUsingWideScreen() then
                    local IsSelectMusic = self:GetText() == "SELECT MUSIC"
                    if IsSelectMusic then self:x(-WideScale(170, 170)) end

                    local WidthLimit = (IsSelectMusic and 181 or 160) / self:GetZoom()
                    self:maxwidth(WidthLimit):wrapwidthpixels(WidthLimit):vertspacing(-16)
                end
            end,
        },

        -- Accent underline under the screen name, modern only
        Modern and Def.Quad {
            InitCommand=function(self)
                self:xy(-WideScale(200, 200), 56):halign(1):valign(0)
                    :zoomto(64, 3)
                    :diffuse(Accent):diffuseleftedge(Accent2)
                    :blend("BlendMode_Add")
            end
        } or Def.Actor {},

        -- Stage count
        Def.BitmapText {
            Font=Modern and "Montserrat semibold 40px" or "Montserrat normal 40px",
            InitCommand=function(self)
                self:visible(Screen.String("HeaderText") == "Select Music" and true or false)
                self:settext("STAGE "..string.format("%02d", GAMESTATE:GetCurrentStageIndex() + 1))
                self:xy(-WideScale(200, 200), Modern and 72 or 60):halign(1):zoom(0.5)
                    :diffuse(Modern and ModernUI.Tokens.TextDim or Color.Black)
            end,
        },

        -- Amount of lives left
        Def.ActorFrame {
            InitCommand=function(self)
                self:xy(WideScale(200, 225), 40)
            end,

            Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Button"),
                InitCommand=function(self)
                    self:zoom(0.65)
                    if Modern then self:diffusealpha(0.75) end
                end,
            },

            Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Heart"),
                InitCommand=function(self)
                    self:x(-21):zoom(0.3)
                    if Modern and ModernUI.MotionScale() > 0 then
                        self:pulse():effectmagnitude(1, 1.06, 1)
                            :effectperiod(ModernUI.T(2.2))
                    end
                end,
            },

            Def.BitmapText {
                Font="Montserrat semibold 40px",
                InitCommand=function(self)
                    self:x(-6):zoom(0.6):halign(0)
                    if Modern then self:diffuse(TextTone):shadowlength(1) end

                    local Hearts = GAMESTATE:GetNumStagesLeft(PLAYER_1) + GAMESTATE:GetNumStagesLeft(PLAYER_2)
                    self:settext("x " .. (GAMESTATE:IsEventMode() and "∞" or Hearts))
                end
            },
        }
    },

    -- Bottom glass slab
    Glass and Def.ActorFrame {
        InitCommand=function(self) self:y(128) end,
        OnCommand=function(self) self:easeoutexpo(Dur(0.5)):y(0) end,
        OffCommand=function(self) self:easeoutexpo(Dur(0.5)):y(128) end,

        ModernUI.ChromeBar {
            x = SCREEN_CENTER_X, y = SCREEN_BOTTOM, w = SCREEN_WIDTH, h = 96,
            valign = 1, alpha = 0.66, accentBar = false,
        },

        Def.Quad {
            InitCommand=function(self)
                self:xy(SCREEN_CENTER_X, SCREEN_BOTTOM - 96):valign(0)
                    :zoomto(SCREEN_WIDTH, 2)
                    :diffuse(Accent2):diffuserightedge(Accent)
                    :blend("BlendMode_Add"):diffusealpha(0.6)
            end
        },
    } or Def.Actor {},

    -- Bottom panel
    Def.Sprite {
        Texture=THEME:GetPathG("", "UI/PanelBottom"),
        InitCommand=function(self)
            self:scaletofit(0, 0, 1280, 128)
            :xy(SCREEN_CENTER_X, SCREEN_BOTTOM + 128):valign(1)
            :diffusealpha(PanelArt)
        end,
        OnCommand=function(self)
            self:easeoutexpo(Dur(0.5))
            :xy(SCREEN_CENTER_X, SCREEN_BOTTOM)
        end,
        OffCommand=function(self)
            self:easeoutexpo(Dur(0.5))
            :xy(SCREEN_CENTER_X, SCREEN_BOTTOM + 128)
        end,
    },
}

-- Avatar display and info on bottom panel
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if PROFILEMAN:GetProfile(pn) and (PROFILEMAN:IsPersistentProfile(pn) or PROFILEMAN:ProfileWasLoadedFromMemoryCard(pn)) then
        local Side = (pn == PLAYER_2) and 1 or -1

        t[#t+1] = Def.ActorFrame {
            Def.ActorFrame {
                InitCommand=function(self) self:y(128) end,
                OnCommand=function(self) self:easeoutexpo(Dur(0.5)):y(0) end,
                OffCommand=function(self) self:easeoutexpo(Dur(0.5)):y(128) end,

                -- Accent ring behind the avatar, modern only
                Modern and Def.Quad {
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 172, SCREEN_BOTTOM - 39)
                            :zoomto(138, 74)
                            :diffuse(Accent):diffusebottomedge(Accent2)
                            :blend("BlendMode_Add"):diffusealpha(0.28)
                    end
                } or Def.Actor {},

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/AvatarSlotMask"),
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 172, SCREEN_BOTTOM - 39)
                        :rotationy(pn == PLAYER_2 and 180 or 0):MaskSource()
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 232, SCREEN_BOTTOM - 32)
                        :halign(pn == PLAYER_2 and 0 or 1):valign(1):MaskDest()
                        if Modern then self:diffusealpha(0.8) end
                    end
                },

                Def.BitmapText {
                    Font="Montserrat semibold 20px",
                    Text=PROFILEMAN:GetProfile(pn):GetDisplayName(),
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 292, SCREEN_BOTTOM - 48):zoom(0.9)
                        :maxwidth(112 / self:GetZoom()):skewx(-0.2):shadowlength(1)
                        if Modern then self:diffuse(ModernUI.Tokens.Text) end

                        if PROFILEMAN:GetProfile(pn):GetDisplayName() == "" then
                            self:settext(THEME:GetString("ProfileStats", "No Profile"))
                        end
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 212, SCREEN_BOTTOM - 10)
                        :halign(pn == PLAYER_2 and 0 or 1):valign(1):MaskDest()
                        if Modern then self:diffusealpha(0.8) end
                    end
                },

                Def.BitmapText {
                    Font="Montserrat semibold 20px",
                    -- This ingenious level system was made up at 4am
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 281, SCREEN_BOTTOM - 26):zoom(0.9)
                        :maxwidth(96 / self:GetZoom()):skewx(-0.2):shadowlength(1)
                        if Modern then self:diffuse(Accent) end
                        lvl = math.floor(math.sqrt(PROFILEMAN:GetProfile(pn):GetTotalDancePoints() / 500)) + 1
                        -- You can check if a number is "nan" by comparing it to itself
                        -- because "nan" is not equal to anything, not even itself
                        if (lvl < 0) or (lvl ~= lvl) then lvl = 0 end
                        self:settext(THEME:GetString("ProfileStats", "Level") .. " " .. lvl)
                    end
                },

                Def.Sprite {
                    Texture=LoadModule("Options.GetProfileData.lua")(pn)["Image"],
                    InitCommand=function(self)
                        self:scaletocover(0, 0, 128, 64)
                        :xy(SCREEN_CENTER_X + Side * 172, SCREEN_BOTTOM - 39)
                        :MaskDest():ztestmode("ZTestMode_WriteOnFail"):diffusealpha(0.5)
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/AvatarSlotOverlay"),
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + Side * 172, SCREEN_BOTTOM - 39)
                        :rotationy(pn == PLAYER_2 and 180 or 0)
                    end
                },

                Def.Sprite {
                    Texture=LoadModule("Options.GetProfileData.lua")(pn)["Image"],
                    InitCommand=function(self)
                        self:scaletocover(0, 0, 64, 64)
                        :xy(SCREEN_CENTER_X + Side * 172, SCREEN_BOTTOM - 39)
                        :MaskDest():ztestmode("ZTestMode_WriteOnFail")
                    end
                }
            }
        }
    end
end

return t

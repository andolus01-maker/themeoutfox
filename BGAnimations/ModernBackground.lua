-- =====================================================================
-- Modern aurora background
-- =====================================================================
-- Fully procedural, no new art assets required:
--   1. deep vertical gradient base (tinted per screen/mode)
--   2. drifting additive glow blobs (the "aurora")
--   3. the original perspective grid for depth
--   4. animated film grain
--   5. corner vignette so UI chrome always stays readable
--
-- Cheaper than the pre-rendered video background and it reacts to the
-- current screen, which the original theme could not do.
-- =====================================================================

local Motion = ModernUI.MotionScale()
local Blobs = ModernUI.Config.GlowBlobs or 5

local function IsTitleLike()
    local screen = SCREENMAN:GetTopScreen()
    if not screen then return true end
    local name = screen:GetName()
    return name == "ScreenTitleMenu" or name == "ScreenLogo" or name == "ScreenTitleJoin"
end

-- Mode aware tint, mirrors the logic of the original background but with
-- a modern, less saturated palette.
local function BaseTint()
    if IsTitleLike() then return color("#150F34") end

    local basic = getenv("IsBasicMode")
    if basic then
        local noSongs = #SONGMAN:GetPreferredSortSongs() == SONGMAN:GetNumSongs()
        return noSongs and color("#2A0F16") or color("#0C1E30")
    end
    return color("#0D0A22")
end

local t = Def.ActorFrame {}

-- 1. Gradient base -----------------------------------------------------
t[#t + 1] = Def.Quad {
    Name = "AuroraBase",
    InitCommand = function(self)
        self:Center():zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
            :diffuse(ModernUI.Tokens.Base)
            :queuecommand("Refresh")
    end,
    ScreenChangedMessageCommand = function(self) self:queuecommand("Refresh") end,
    RefreshCommand = function(self)
        self:stoptweening():linear(ModernUI.T(0.9))
            :diffuse(BaseTint())
            :diffusebottomedge(color("0.02,0.02,0.06,1"))
    end
}

-- 2. Aurora blobs ------------------------------------------------------
for i = 1, Blobs do
    local bright = (i % 2 == 1)
    local baseZoom = 1.6 + (i * 0.35)

    t[#t + 1] = Def.Sprite {
        Name = "AuroraBlob" .. i,
        Texture = THEME:GetPathG("", "Background/circle"),
        InitCommand = function(self)
            self:xy(
                    SCREEN_CENTER_X + ((i % 2 == 0) and -1 or 1) * (60 + i * 70),
                    SCREEN_CENTER_Y + ((i % 3 == 0) and 140 or -110)
                )
                :zoom(baseZoom)
                :blend("BlendMode_Add")
                :diffuse(bright and ModernUI.Accent(1) or ModernUI.Accent(2))
                :diffusealpha(bright and 0.16 or 0.22)

            if Motion > 0 then
                self:bob()
                    :effectmagnitude(70 + i * 22, 46 + i * 12, 0)
                    :effectperiod(ModernUI.T(9 + i * 2.5))
                    :effectoffset(i * 0.7)
                    :effectclock("timer")
            end
        end,
        ScreenChangedMessageCommand = function(self)
            self:stoptweening():linear(ModernUI.T(0.9))
                :diffuse(bright and ModernUI.Accent(1) or ModernUI.Accent(2))
                :diffusealpha(IsTitleLike() and (bright and 0.22 or 0.28) or (bright and 0.14 or 0.18))
        end
    }
end

-- Slow breathing core glow behind the centre of the screen
t[#t + 1] = ModernUI.SoftGlow {
    x = SCREEN_CENTER_X, y = SCREEN_CENTER_Y,
    zoom = 4, alpha = 0.1, pulse = 1.08, period = 7,
    color = ModernUI.Accent(2),
}

-- 3. Grid depth --------------------------------------------------------
t[#t + 1] = LoadActor(THEME:GetPathG("", "Grid")) .. {
    InitCommand = function(self) self:diffusealpha(0.55) end
}

-- 4. Film grain --------------------------------------------------------
if ModernUI.Config.Grain then
    t[#t + 1] = Def.Sprite {
        Name = "Grain",
        Texture = THEME:GetPathG("", "Noise"),
        InitCommand = function(self)
            self:Center():scaletocover(0, 0, SCREEN_RIGHT, SCREEN_BOTTOM)
                :blend("BlendMode_Add"):diffusealpha(0.045)
            if Motion > 0 then
                self:texcoordvelocity(0.02, 0.035)
            end
        end
    }
end

if ModernUI.Config.Scanlines then
    t[#t + 1] = Def.Sprite {
        Name = "Scanlines",
        Texture = THEME:GetPathG("", "Scanline"),
        InitCommand = function(self)
            self:Center():zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
                :customtexturerect(0, 0, 1, SCREEN_HEIGHT / 4)
                :diffusealpha(0.08)
        end
    }
end

-- 5. Vignette ----------------------------------------------------------
if ModernUI.Config.Vignette then
    -- Top and bottom shades keep the glass chrome legible over any tint
    t[#t + 1] = Def.Quad {
        InitCommand = function(self)
            self:xy(SCREEN_CENTER_X, SCREEN_TOP):valign(0)
                :zoomto(SCREEN_WIDTH, 200)
                :diffuse(color("0,0,0,0.55"))
                :diffusebottomedge(color("0,0,0,0"))
        end
    }

    t[#t + 1] = Def.Quad {
        InitCommand = function(self)
            self:xy(SCREEN_CENTER_X, SCREEN_BOTTOM):valign(1)
                :zoomto(SCREEN_WIDTH, 220)
                :diffuse(color("0,0,0,0.6"))
                :diffusetopedge(color("0,0,0,0"))
        end
    }

    t[#t + 1] = Def.Quad {
        InitCommand = function(self)
            self:xy(SCREEN_LEFT, SCREEN_CENTER_Y):halign(0)
                :zoomto(200, SCREEN_HEIGHT)
                :diffuse(color("0,0,0,0.4"))
                :diffuserightedge(color("0,0,0,0"))
        end
    }

    t[#t + 1] = Def.Quad {
        InitCommand = function(self)
            self:xy(SCREEN_RIGHT, SCREEN_CENTER_Y):halign(1)
                :zoomto(200, SCREEN_HEIGHT)
                :diffuse(color("0,0,0,0.4"))
                :diffuseleftedge(color("0,0,0,0"))
        end
    }
end

-- Keep the anniversary surprise working
t[#t + 1] = LoadActor(THEME:GetPathG("", "Background/confetti")) .. {
    Condition = IsAnniversary()
}

return t

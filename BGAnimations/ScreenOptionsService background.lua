-- Modern UI: the service/options backdrop gets the aurora treatment so it
-- matches the rest of the theme instead of sitting on a bare grid.
-- The grid is dimmed and accent-tinted, and the scanline overlay now
-- respects ModernUI.Config.Scanlines.
local Modern = ModernUI and ModernUI.IsModern()
local Scanlines = (not Modern) or ModernUI.Config.Scanlines
local FadeIn = Modern and ModernUI.T(1) or 1

local t = Def.ActorFrame {}

if Modern then
    -- Deep base so the glass panels above have something to sit on
    t[#t+1] = Def.Quad {
        InitCommand=function(self)
            self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):Center()
            :diffuse(ModernUI.Tokens.Base)
            :diffusetopedge(ModernUI.Tokens.BaseAlt)
        end
    }

    t[#t+1] = ModernUI.SoftGlow {
        x = SCREEN_CENTER_X - 260,
        y = SCREEN_CENTER_Y - 140,
        zoom = 5.5,
        alpha = 0.20,
        pulse = true,
        period = 9,
    }

    t[#t+1] = ModernUI.SoftGlow {
        x = SCREEN_CENTER_X + 300,
        y = SCREEN_CENTER_Y + 180,
        zoom = 4.5,
        alpha = 0.16,
        color = ModernUI.Accent(2),
        pulse = true,
        period = 11,
        offset = 3,
    }
end

t[#t+1] = LoadActor(THEME:GetPathG("", "Grid"))..{
    InitCommand=function(self)
        self:diffusealpha(0)
        :linear(FadeIn)
        :diffusealpha(Modern and 0.22 or 0.5)
        if Modern then self:diffuse(ModernUI.Accent(1)):diffusealpha(0.22) end
    end
}

if Scanlines then
    t[#t+1] = Def.Sprite {
        Name="Scanlines",
        Texture=THEME:GetPathG("", "Scanline"),
        InitCommand=function(self)
            self:customtexturerect(0,0,SCREEN_WIDTH*4/16,SCREEN_HEIGHT*4/16)
            :zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):Center()
            :diffusealpha(0.25)
        end
    }
end

if Modern and ModernUI.Config.Vignette then
    t[#t+1] = Def.Quad {
        InitCommand=function(self)
            self:zoomto(SCREEN_WIDTH, 140):Center():y(SCREEN_TOP + 70)
            :diffuse(ModernUI.Tokens.Base):diffusebottomedge(color("0,0,0,0"))
            :diffusealpha(0.55)
        end
    }
    t[#t+1] = Def.Quad {
        InitCommand=function(self)
            self:zoomto(SCREEN_WIDTH, 140):Center():y(SCREEN_BOTTOM - 70)
            :diffuse(ModernUI.Tokens.Base):diffusetopedge(color("0,0,0,0"))
            :diffusealpha(0.55)
        end
    }
end

return t

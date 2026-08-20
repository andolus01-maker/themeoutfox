-- Static gradient backdrop used by lighter screens.
-- Modern mode layers an accent haze and a soft vignette over the original
-- gradient so it matches the aurora background instead of looking flat.
local t = Def.ActorFrame {}

t[#t + 1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Gradient background"),
    InitCommand = function(self)
        self:Center():scaletocover(0, 0, SCREEN_RIGHT, SCREEN_BOTTOM)
        if ModernUI and ModernUI.IsModern() then
            self:diffusealpha(0.85)
        end
    end
}

if ModernUI and ModernUI.IsModern() then
    t[#t + 1] = Def.Quad {
        InitCommand = function(self)
            self:Center():zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
                :diffuse(color("0.03,0.03,0.09,0.55"))
                :diffusetopedge(color("0.06,0.05,0.18,0.35"))
        end
    }

    t[#t + 1] = ModernUI.SoftGlow {
        x = SCREEN_CENTER_X, y = SCREEN_CENTER_Y - 60,
        zoom = 3.4, alpha = 0.14, pulse = 1.06, period = 6,
        color = ModernUI.Accent(1),
    }

    t[#t + 1] = ModernUI.SoftGlow {
        x = SCREEN_CENTER_X + 260, y = SCREEN_CENTER_Y + 120,
        zoom = 2.6, alpha = 0.12, pulse = 1.05, period = 8, offset = 1.4,
        color = ModernUI.Accent(2),
    }
end

return t

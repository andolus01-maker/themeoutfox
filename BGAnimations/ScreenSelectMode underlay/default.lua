-- =====================================================================
-- Mode select screen
-- =====================================================================
-- This file used to be three lines - the HUD panels and the corner arrows
-- - with nothing of the modern layer at all, which is why the screen
-- still looked like the original theme while the rest had moved on.
--
-- SCOPE, deliberately narrow: the mode choices are drawn by the engine
-- from the fallback theme's metrics, not from here. So this underlay only
-- dresses the screen (chrome bar, headline, glow, hairline). Reaching
-- into the choice list from an underlay would fight the engine's own
-- navigation and input handling for no visual gain.
--
-- Draw order matters: the modern chrome is inserted *ahead* of the
-- existing actors, so the HUD panels and corner arrows keep drawing on
-- top of it instead of being buried by it.
--
-- Classic style returns the original three lines untouched.
-- =====================================================================

local Modern = ModernUI and ModernUI.IsModern()

local t = Def.ActorFrame {
    LoadActor("../HudPanels"),

    LoadActor("../CornerArrows")
}

if not Modern then
    return t
end

-- This screen belongs to the fallback theme, so it has no guaranteed
-- entry in our own language files. Ask for a string, but fall back to a
-- literal rather than risking a nil on a screen the player must pass
-- through to start a game.
local Headline = "SELECT MODE"
local ok, text = pcall(function()
    return THEME:GetString("ScreenSelectMode", "Header")
end)
if ok and text and text ~= "" and not text:match("^~~") then
    Headline = ToUpper(text)
end

local function Dur(seconds)
    return ModernUI.T(seconds)
end

local chrome = {
    -- Wide, very faint accent wash so the empty middle of the screen is
    -- not just flat background behind the choice list.
    ModernUI.SoftGlow {
        x = SCREEN_CENTER_X, y = SCREEN_CENTER_Y,
        zoom = 4.2, alpha = 0.13,
        pulse = 1.04, period = 8,
        color = ModernUI.Accent(2),
    },

    ModernUI.ChromeBar {
        y = 0,
        h = 76,
        alpha = 0.55,
        accentThickness = 2,
    },

    Def.BitmapText {
        Font = "Montserrat semibold 40px",
        Text = Headline,
        InitCommand = function(self)
            self:xy(SCREEN_CENTER_X, 36)
                :zoom(0.72)
                :maxwidth((SCREEN_WIDTH - 120) / 0.72)
                :skewx(-ModernUI.Skew())
                :diffuse(ModernUI.Tokens.Text)
                :diffusebottomedge(ModernUI.Accent(1))
                :shadowlength(1)
                :diffusealpha(0)
        end,
        OnCommand = function(self)
            ModernUI.EaseIn(self, 0.4):diffusealpha(1)
        end,
        OffCommand = function(self)
            self:stoptweening()
            ModernUI.EaseOut(self, 0.25):diffusealpha(0)
        end,
    },

    ModernUI.Hairline {
        x = SCREEN_CENTER_X,
        y = 86,
        w = SCREEN_WIDTH * 0.72,
        skew = -ModernUI.Skew(),
        alpha = 0.16,
    },
}

-- Insert in reverse so the chrome ends up in the order written above,
-- all of it behind the actors that were already here.
for i = #chrome, 1, -1 do
    table.insert(t, 1, chrome[i])
end

return t

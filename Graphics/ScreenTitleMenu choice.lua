-- =====================================================================
-- Title menu choice card
-- =====================================================================
-- ScreenSelectMaster draws its scroller by loading one copy of this
-- actor per entry in the ChoiceNames metric. When the theme does not
-- provide this file the engine falls back to _fallback's version, which
-- is the black pill button. Owning the file here replaces the pill
-- outright: there is nothing to hide, because the pill actor is never
-- constructed.
--
-- Whether the engine asks for "scroll" or "choice" varies between
-- builds, so this is a byte-identical twin of
-- "ScreenTitleMenu scroll.lua". Only one path is ever queried; the other
-- file is simply never read, which costs nothing.
--
-- Placement, scale, fade and the slide-to-centre motion all come from
-- ScrollerTransform in metrics.ini. This file is only responsible for
-- what a single card looks like, which keeps the two concerns apart.
-- =====================================================================

local Modern = ModernUI and ModernUI.IsModern()

local CardW, CardH = 182, 58

local Choices = {}
for name in string.gmatch(THEME:GetMetric("ScreenTitleMenu", "ChoiceNames") or "", "[^,%s]+") do
    Choices[#Choices + 1] = name
end

-- The engine loads one copy of this file per choice, in ChoiceNames
-- order, so a rolling counter is enough to tell each copy which entry it
-- is without depending on message parameters that vary between builds.
-- Wrapping keeps it correct when the screen or the whole theme reloads.
if not ModernTitleChoiceCursor or ModernTitleChoiceCursor >= #Choices then
    ModernTitleChoiceCursor = 0
end
ModernTitleChoiceCursor = ModernTitleChoiceCursor + 1

local ChoiceName = Choices[ModernTitleChoiceCursor] or ""

-- Guarded: a missing string key must not be allowed to take down the
-- title screen, which is the one screen the player cannot skip past.
local Label = ChoiceName
if ChoiceName ~= "" and THEME.GetString then
    local ok, translated = pcall(function()
        return THEME:GetString("ScreenTitleMenu", ChoiceName)
    end)
    if ok and translated and translated ~= "" then Label = translated end
end
Label = ToUpper(Label)

local t = Def.ActorFrame {}

if Modern then
    t[#t + 1] = ModernUI.GlassCard {
        x = 0, y = 0, w = CardW, h = CardH,
        halign = 0.5, valign = 0.5,
        alpha = 0.5, accentBar = true, accentThickness = 3,
    }

    t[#t + 1] = ModernUI.Hairline {
        w = CardW - 26, y = CardH * 0.5 - 9, alpha = 0.18,
    }
else
    t[#t + 1] = Def.Quad {
        InitCommand = function(self)
            self:zoomto(CardW, CardH):diffuse(color("0,0,0,0.85"))
        end,
    }
end

t[#t + 1] = Def.BitmapText {
    Font = "Montserrat semibold 40px",
    Text = Label,
    InitCommand = function(self)
        self:zoom(0.62):maxwidth((CardW - 34) / 0.62)
        if Modern then
            self:skewx(-ModernUI.Skew())
                :diffuse(ModernUI.Tokens.Text)
                :diffusebottomedge(ModernUI.Accent(1))
                :shadowlength(1)
        else
            self:diffuse(Color.White)
        end
    end,
}

return t

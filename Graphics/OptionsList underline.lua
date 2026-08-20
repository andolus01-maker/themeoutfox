-- Modern UI: the flat grey underline becomes a frosted accent rule.
-- The body quad is dimmed towards the surface token so it reads as glass,
-- while the top and bottom hairlines pick up the accent ramp.
-- Style = "classic" restores the original grey shift exactly.
local Modern = ModernUI and ModernUI.IsModern()
local Animate = not Modern or ModernUI.MotionScale() > 0

local BodyW = Modern and 164 or 150

local Body1 = Modern and ModernUI.Tokens.SurfaceHi or color("#606060")
local Body2 = Modern and ModernUI.Tokens.Surface or color("#303030")
local Line1 = Modern and ModernUI.Accent(1) or color("#808080")
local Line2 = Modern and ModernUI.Accent(2) or color("#505050")

local function Shift(self, c1, c2)
    if Animate then
        self:diffuseshift():effectcolor1(c1):effectcolor2(c2):effectperiod(0.75)
    else
        self:diffuse(c1)
    end
end

return Def.ActorFrame {

    Def.Quad {
        InitCommand=function(self)
            self:draworder(200)
            :zoomto(BodyW, 24)
            :fadeleft(0.75)
            :faderight(0.75)
            :blend(Blend.Add)
            :MaskDest()
            Shift(self, Body1, Body2)
        end
    },

    Def.Quad {
        Name="BottomLine",
        InitCommand=function(self)
            self:draworder(200)
            :zoomto(BodyW, Modern and 1 or 2)
            :valign(0)
            :fadeleft(0.75)
            :faderight(0.75)
            :y(10)
            :blend(Blend.Add)
            :MaskDest()
            Shift(self, Line1, Line2)
        end
    },

    Def.Quad {
        Name="TopLine",
        InitCommand=function(self)
            self:draworder(200)
            :zoomto(BodyW, Modern and 1 or 2)
            :valign(1)
            :fadeleft(0.75)
            :faderight(0.75)
            :y(-10)
            :blend(Blend.Add)
            :MaskDest()
            Shift(self, Line1, Line2)
        end
    }

}

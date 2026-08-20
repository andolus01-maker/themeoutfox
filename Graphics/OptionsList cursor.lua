-- Modern UI: the cursor now shifts between the two accent ramp colours
-- instead of the hard-coded purple, and glows a little wider so the
-- selection reads clearly on the aurora background.
-- Style = "classic" restores the original purple/black shift exactly.
local Modern = ModernUI and ModernUI.IsModern()
local Animate = not Modern or ModernUI.MotionScale() > 0

local C1 = Modern and ModernUI.Accent(1) or color("#9334BD")
local C2 = Modern and ModernUI.Accent(2) or color("#000000")
local CursorW = Modern and 164 or 150

return Def.ActorFrame{
    Def.Quad {
        InitCommand=function(self)
            self:zoomto(CursorW, 20)
            :fadeleft(0.25)
            :faderight(0.25)
            :blend(Blend.Add)
            :MaskDest()

            if Animate then
                self:diffuseshift()
                :effectcolor2(C2)
                :effectcolor1(C1)
                :effectperiod(0.75)
                :effectoffset(0.325)
            else
                -- Motion = "off": hold a static accent instead of shifting
                self:diffuse(C1)
            end
        end
    },

    Def.Sprite {
        Texture=THEME:GetPathG("", "MusicWheel/Selector"),
        InitCommand=function(self)
            self:zoom(0.5)
            :MaskDest()

            if Modern then self:diffuse(C1) end

            if Animate then
                self:pulse()
                :effectmagnitude(0.95,1,1)
                :effectperiod(0.75)
            end
        end
    }
}

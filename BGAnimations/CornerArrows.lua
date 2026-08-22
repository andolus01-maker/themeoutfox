-- Corner navigation arrows.
-- Modern mode keeps the exact same behaviour but with motion-token driven
-- easing and a longer, softer additive glow trail on input.
local function Dur(seconds)
    if ModernUI then return ModernUI.T(seconds) end
    return seconds
end

local Modern = ModernUI and ModernUI.IsModern()
local GlowTone = Modern and ModernUI.Accent(1) or nil

local function Glow(self)
    self:stoptweening():diffusealpha(1):zoom(0.5)
        :linear(Dur(Modern and 0.32 or 0.25))
        :diffusealpha(0):zoom(Modern and 0.68 or 0.6)
end

return Def.ActorFrame {
    -- Up Left
    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/ShiftUL"),
        OnCommand=function(self) self:zoom(0.5):xy(-72, -72):easeoutexpo(Dur(1)):xy(72, 72) end,
        OffCommand=function(self) self:stoptweening():easeoutexpo(Dur(1)):xy(-72, -72) end
    },

    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/GlowShiftUL"),
        InitCommand=function(self)
            self:xy(72, 72):zoom(0.5):blend('add'):diffusealpha(0)
            if GlowTone then self:diffuse(GlowTone) end
        end,
        SongUnchosenMessageCommand=function(self) self:playcommand("Glow") end,
        StartSelectingGroupMessageCommand=function(self) self:playcommand("Glow") end,
        GlowCommand=function(self) Glow(self) end
    },

    -- Up Right
    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/ShiftUR"),
        OnCommand=function(self) self:zoom(0.5):xy(SCREEN_RIGHT + 72, -72):easeoutexpo(Dur(1)):xy(SCREEN_RIGHT - 72, 72) end,
        OffCommand=function(self) self:stoptweening():easeoutexpo(Dur(1)):xy(SCREEN_RIGHT + 72, -72) end
    },

    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/GlowShiftUR"),
        InitCommand=function(self)
            self:xy(SCREEN_RIGHT - 72, -72):zoom(0.5):blend('add'):diffusealpha(0)
            if GlowTone then self:diffuse(GlowTone) end
        end,
        SongUnchosenMessageCommand=function(self) self:playcommand("Glow") end,
        StartSelectingGroupMessageCommand=function(self) self:playcommand("Glow") end,
        GlowCommand=function(self) Glow(self) end
    },

    -- Down Left
    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/ShiftDL"),
        OnCommand=function(self) self:zoom(0.5):xy(-72, SCREEN_BOTTOM + 72):easeoutexpo(Dur(1)):xy(72, SCREEN_BOTTOM - 72) end,
        OffCommand=function(self) self:stoptweening():easeoutexpo(Dur(1)):xy(-72, SCREEN_BOTTOM + 72) end
    },

    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/GlowShiftDL"),
        InitCommand=function(self)
            self:xy(72, SCREEN_BOTTOM - 72):zoom(0.5):blend('add'):diffusealpha(0)
            if GlowTone then self:diffuse(GlowTone) end
        end,
        PreviousSongMessageCommand=function(self) Glow(self) end,
        ScrollMessageCommand=function(self, params)
            if params.Direction == -1 then Glow(self) end
        end
    },

    -- Down Right
    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/ShiftDR"),
        OnCommand=function(self) self:zoom(0.5):xy(SCREEN_RIGHT + 72, SCREEN_BOTTOM + 72):easeoutexpo(Dur(1)):xy(SCREEN_RIGHT - 72, SCREEN_BOTTOM - 72) end,
        OffCommand=function(self) self:stoptweening():easeoutexpo(Dur(1)):xy(SCREEN_RIGHT + 72, SCREEN_BOTTOM + 72) end
    },

    Def.Sprite {
        Texture=THEME:GetPathG("", "CornerArrows/GlowShiftDR"),
        InitCommand=function(self)
            self:xy(SCREEN_RIGHT - 72, SCREEN_BOTTOM - 72):zoom(0.5):blend('add'):diffusealpha(0)
            if GlowTone then self:diffuse(GlowTone) end
        end,
        NextSongMessageCommand=function(self) Glow(self) end,
        ScrollMessageCommand=function(self, params)
            if params.Direction == 1 then Glow(self) end
        end
    }
}

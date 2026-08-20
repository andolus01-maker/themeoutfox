local FrameW = 620
local FrameH = 76

-- Modern UI: the original plate is a light panel with black text, which
-- clashes with the dark aurora background. In modern mode we lay a glass
-- card underneath, dim the plate art, and switch the type to light.
local Modern = ModernUI and ModernUI.IsModern()
local Glass  = ModernUI and ModernUI.UseGlass()
local TextTone = Modern and ModernUI.Tokens.Text or Color.Black

return Def.ActorFrame {
    InitCommand=function(self)
        local Song = GAMESTATE:GetCurrentSong()
        if Song then
            local TitleText = Song:GetDisplayFullTitle()
            if TitleText == "" then TitleText = "Unknown" end

            local AuthorText = Song:GetDisplayArtist()
            if AuthorText == "" then AuthorText = "Unknown" end

            local BPMRaw = Song:GetDisplayBpms()
            local BPMLow = math.ceil(BPMRaw[1])
            local BPMHigh = math.ceil(BPMRaw[2])
            local BPMDisplay = (BPMLow == BPMHigh and BPMHigh or BPMLow .. "-" .. BPMHigh)
            local StepList = Song:GetAllSteps()
            local FirstStep = StepList[1]
            local Duration = FirstStep:GetChartLength()

            if Song:IsDisplayBpmRandom() or BPMDisplay == 0 then BPMDisplay = "???" end

            self:GetChild("Title"):settext(TitleText)
            self:GetChild("Artist"):settext(AuthorText)
            self:GetChild("Length"):settext(SecondsToMMSS(Duration))
            self:GetChild("BPM"):settext(BPMDisplay .. " BPM")
        else
            self:GetChild("Title"):settext("")
            self:GetChild("Artist"):settext("")
            self:GetChild("Length"):settext("")
            self:GetChild("BPM"):settext("")
        end
    end,

    -- Frosted card sized to the original plate
    Glass and ModernUI.GlassCard {
        x = 0, y = 0, w = FrameW, h = FrameH,
        valign = 0.5, alpha = 0.6, accentThickness = 3,
    } or Def.Actor {},

    Def.Sprite {
        Texture=THEME:GetPathG("", "Evaluation/EvalSongInfo"),
        InitCommand=function(self)
            if Modern then self:diffusealpha(0.32) end
        end
    },

    Def.BitmapText {
        Font="Montserrat semibold 40px",
        Name="Title",
        InitCommand=function(self)
            self:zoom(0.8):valign(0)
            :maxwidth(FrameW * 0.89 / self:GetZoom())
            :diffuse(TextTone)
            :y(-30)
            if Modern then self:shadowlength(2):shadowcolor(color("0,0,0,0.55")) end
        end
    },

    Def.BitmapText {
        Font="Montserrat normal 20px",
        Name="Artist",
        InitCommand=function(self)
            self:zoom(1):valign(1)
            :maxwidth(FrameW * 0.5 / self:GetZoom())
            :diffuse(Modern and ModernUI.Tokens.TextDim or Color.Black)
            :y(16)
        end
    },

    Def.BitmapText {
        Font="Montserrat normal 20px",
        Name="Length",
        InitCommand=function(self)
            self:zoom(1):halign(1):valign(1)
            :maxwidth(FrameW * 0.2 / self:GetZoom())
            :diffuse(Modern and ModernUI.Accent(1) or Color.Black)
            :xy(FrameW / 2 - 36, 16)
        end
    },

    Def.BitmapText {
        Font="Montserrat normal 20px",
        Name="BPM",
        InitCommand=function(self)
            self:zoom(1):halign(0):valign(1)
            :maxwidth(FrameW * 0.175 / self:GetZoom())
            :diffuse(Modern and ModernUI.Accent(1) or Color.Black)
            :xy(-FrameW / 2 + 36, 16)
        end
    }
}

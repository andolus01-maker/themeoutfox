-- Modern UI: the build stamp sits in a glass chip in the corner instead of
-- floating raw over the grid, and the theme name picks up the accent.
local Modern = ModernUI and ModernUI.IsModern()

local BuildText = ToUpper(string.format("OutFox %s - %s", ProductVersion(), VersionDate()))

local t = Def.ActorFrame {
    OnCommand=function(self)
        SCREENMAN:set_input_redirected(PLAYER_1, false)
        SCREENMAN:set_input_redirected(PLAYER_2, false)
    end
}

if Modern and ModernUI.UseGlass() then
    t[#t+1] = ModernUI.GlassCard {
        x = SCREEN_LEFT + 12,
        y = SCREEN_BOTTOM - 12,
        w = 300,
        h = 62,
        halign = 0,
        valign = 1,
        alpha = 0.42,
        accentBar = true,
        accentThickness = 2,
    }
end

t[#t+1] = Def.BitmapText {
    Font="VCR OSD Mono 20px",
    InitCommand=function(self)
        self:xy(SCREEN_LEFT + 20, SCREEN_BOTTOM - 20)
        :halign(0):valign(1)
        :settext("INFINITESIMAL\n"..BuildText)

        if Modern then
            self:diffuse(ModernUI.Tokens.TextDim)
            -- Highlight just the theme name on the first line
            self:AddAttribute(0, { Length = 14, Diffuse = ModernUI.Accent(1) })
        end
    end
}

return t

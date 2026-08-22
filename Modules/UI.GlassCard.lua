-- Thin wrapper around ModernUI.GlassCard so screens can build frosted
-- surfaces with LoadModule, matching the style of the other UI modules.
--
-- Usage:
--   LoadModule("UI.GlassCard.lua"){ x = 100, y = 80, w = 420, h = 160 }
return function(params)
    params = params or {}

    if not (ModernUI and ModernUI.UseGlass()) then
        -- Classic style: plain translucent slab, same footprint
        return Def.Quad {
            InitCommand = function(self)
                self:xy(params.x or 0, params.y or 0)
                    :zoomto(params.w or 320, params.h or 120)
                    :halign(params.halign or 0.5):valign(params.valign or 0.5)
                    :diffuse(color("0,0,0,0.75"))
            end
        }
    end

    return ModernUI.GlassCard(params)
end

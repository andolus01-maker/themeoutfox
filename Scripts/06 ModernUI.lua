-- =====================================================================
-- Infinitesimal :: Modern UI (v2)
-- =====================================================================
-- A small design system that sits on top of the original Infinity look:
--
--   * colour tokens      (base / surface / text / accent ramps)
--   * motion tokens      (single place to slow down or disable motion)
--   * elevation helpers  (glass cards, hairlines, soft glows)
--
-- Nothing else in the theme has to be touched to retune the look, every
-- switch lives in ModernUI.Config below.
--
-- Style:
--   "aurora"  - new procedural animated background (default, recommended)
--   "video"   - keep the pre-rendered _Background.mp4 background
--   "classic" - fall back to the original Infinity chrome and background
--
-- Accent:  cyan | violet | magenta | lime | amber | ice
-- Motion:  full | reduced | off        (reduced/off help low-end hardware)
-- =====================================================================

ModernUI = {}

ModernUI.Config = {
    Style      = "aurora",
    Accent     = "cyan",
    Motion     = "full",
    Glass      = true,
    Grain      = true,
    Vignette   = true,
    Scanlines  = false,
    GlowBlobs  = 5,
}

-- ---------------------------------------------------------------------
-- Tokens
-- ---------------------------------------------------------------------

local AccentRamps = {
    cyan    = { "#39E6FF", "#3D7BFF" },
    violet  = { "#A177FF", "#5A2BE0" },
    magenta = { "#FF5FD2", "#7A28FF" },
    lime    = { "#8BFF5A", "#12C9A0" },
    amber   = { "#FFC24A", "#FF5F6D" },
    ice     = { "#DCEBFF", "#6E8CFF" },
}

ModernUI.Tokens = {
    Base      = color("#07070F"),
    BaseAlt   = color("#120E2E"),
    Surface   = color("#1A1640"),
    SurfaceHi = color("#2A2470"),
    Text      = color("#F4F6FF"),
    TextDim   = color("#9AA1CC"),
    Good      = color("#3BE6A8"),
    Warn      = color("#FFC24A"),
    Bad       = color("#FF5470"),
    Hairline  = color("1,1,1,0.16"),
}

-- Accent ramp, 1 = bright end, 2 = deep end
function ModernUI.Accent(index)
    local ramp = AccentRamps[ModernUI.Config.Accent] or AccentRamps.cyan
    return color(ramp[index or 1])
end

function ModernUI.IsModern()
    return ModernUI.Config.Style ~= "classic"
end

function ModernUI.UseAurora()
    return ModernUI.Config.Style == "aurora"
end

function ModernUI.UseGlass()
    return ModernUI.IsModern() and ModernUI.Config.Glass
end

-- ---------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------

function ModernUI.MotionScale()
    local m = ModernUI.Config.Motion
    if m == "off" then return 0 end
    if m == "reduced" then return 0.55 end
    return 1
end

-- Scale a duration with the current motion setting.
function ModernUI.T(seconds)
    local scale = ModernUI.MotionScale()
    if scale == 0 then return 0.001 end
    return seconds * scale
end

-- Signature easing of the modern layer: snappy in, soft landing.
function ModernUI.EaseIn(actor, seconds)
    local duration = ModernUI.T(seconds or 0.5)
    if duration <= 0.01 then return actor:linear(0.001) end
    return actor:easeoutexpo(duration)
end

function ModernUI.EaseOut(actor, seconds)
    local duration = ModernUI.T(seconds or 0.35)
    if duration <= 0.01 then return actor:linear(0.001) end
    return actor:easeinexpo(duration)
end

-- ---------------------------------------------------------------------
-- Elevation helpers
-- ---------------------------------------------------------------------

-- A 1px bright line used to separate surfaces, the cheapest way to make
-- flat panels read as layered glass.
function ModernUI.Hairline(params)
    params = params or {}
    local width = params.w or 200
    local thickness = params.thickness or 1
    local shade = params.color or ModernUI.Tokens.Hairline
    local alpha = params.alpha or 1

    return Def.Quad {
        InitCommand = function(self)
            self:xy(params.x or 0, params.y or 0)
                :zoomto(width, thickness)
                :halign(params.halign or 0.5):valign(params.valign or 0.5)
                :diffuse(shade):diffusealpha(alpha)
        end
    }
end

-- Additive radial glow built from the texture the theme already ships.
function ModernUI.SoftGlow(params)
    params = params or {}
    local shade = params.color or ModernUI.Accent(1)

    return Def.Sprite {
        Texture = THEME:GetPathG("", "Background/circle"),
        InitCommand = function(self)
            self:xy(params.x or 0, params.y or 0)
                :zoom(params.zoom or 1)
                :blend("BlendMode_Add")
                :diffuse(shade)
                :diffusealpha(params.alpha or 0.2)

            if params.pulse and ModernUI.MotionScale() > 0 then
                self:pulse():effectmagnitude(1, params.pulse or 1.06, 1)
                    :effectperiod(ModernUI.T(params.period or 4))
                    :effectoffset(params.offset or 0)
            end
        end
    }
end

-- Frosted panel: shadow -> gradient body -> top highlight -> accent bar.
-- Corners stay square on purpose, OutFox quads cannot be rounded without
-- shipping extra textures, so the modern look leans on gradients instead.
function ModernUI.GlassCard(params)
    params = params or {}
    local width  = params.w or 320
    local height = params.h or 120
    local halign = params.halign or 0.5
    local valign = params.valign or 0.5
    local alpha  = params.alpha or 0.55
    local accent = params.accent or ModernUI.Accent(1)
    local accentBar = params.accentBar ~= false

    local card = Def.ActorFrame {
        InitCommand = function(self)
            self:xy(params.x or 0, params.y or 0)
        end
    }

    -- Ambient shadow
    card[#card + 1] = Def.Quad {
        InitCommand = function(self)
            self:zoomto(width + 12, height + 12)
                :halign(halign):valign(valign)
                :diffuse(color("#000008")):diffusealpha(0.32 * alpha)
        end
    }

    -- Frosted body, brighter on top so it reads as lit from above
    card[#card + 1] = Def.Quad {
        InitCommand = function(self)
            self:zoomto(width, height)
                :halign(halign):valign(valign)
                :diffuse(ModernUI.Tokens.Surface)
                :diffusetopedge(color(string.format("0.16,0.14,0.36,%.3f", alpha)))
                :diffusebottomedge(color(string.format("0.04,0.04,0.11,%.3f", math.min(alpha + 0.2, 1))))
        end
    }

    -- Top highlight hairline
    card[#card + 1] = ModernUI.Hairline {
        w = width, thickness = 1,
        x = (0.5 - halign) * width,
        y = -valign * height,
        alpha = 0.9,
    }

    -- Accent bar, the single strongest "this is new" signal
    if accentBar then
        card[#card + 1] = Def.Quad {
            InitCommand = function(self)
                self:zoomto(width, params.accentThickness or 3)
                    :halign(halign):valign(0)
                    :x((0.5 - halign) * width)
                    :y(-valign * height)
                    :diffuse(accent)
                    :diffuserightedge(ModernUI.Accent(2))
                    :blend("BlendMode_Add")
                    :diffusealpha(0.85)
            end
        }
    end

    return card
end

-- Convenience wrapper so BGAnimations can build a full-width chrome bar.
function ModernUI.ChromeBar(params)
    params = params or {}
    return ModernUI.GlassCard {
        x = params.x or SCREEN_CENTER_X,
        y = params.y or 0,
        w = params.w or SCREEN_WIDTH,
        h = params.h or 84,
        halign = 0.5,
        valign = params.valign or 0,
        alpha = params.alpha or 0.6,
        accentBar = params.accentBar ~= false,
        accentThickness = params.accentThickness or 2,
    }
end

Trace("[Infinitesimal] Modern UI v2 loaded (style: " .. tostring(ModernUI.Config.Style)
    .. ", accent: " .. tostring(ModernUI.Config.Accent)
    .. ", motion: " .. tostring(ModernUI.Config.Motion) .. ")")

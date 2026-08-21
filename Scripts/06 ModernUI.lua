-- =====================================================================
-- Glassmorphism :: Modern UI (v2)
-- =====================================================================
-- A small design system that sits on top of the original Infinity look:
--
--   * colour tokens      (palette / accent ramps)
--   * motion tokens      (single place to slow down or disable motion)
--   * elevation helpers  (glass cards, hairlines, soft glows)
--   * geometry tokens    (the Phoenix-style diagonal shear)
--
-- Nothing else in the theme has to be touched to retune the look, every
-- switch lives in ModernUI.Config below.
--
-- Style:
--   "aurora"  - new procedural animated background (default, recommended)
--   "video"   - keep the pre-rendered _Background.mp4 background
--   "classic" - fall back to the original Infinity chrome and background
--
-- Palette: phoenix | infinity
-- Accent:  phoenix2 | phoenix | cyan | violet | magenta | lime | amber | ice
-- Motion:  full | reduced | off        (reduced/off help low-end hardware)
-- =====================================================================

ModernUI = {}

ModernUI.Config = {
    Style      = "aurora",
    Palette    = "phoenix",
    Accent     = "phoenix2",
    Motion     = "full",
    Glass      = true,
    Grain      = true,
    Vignette   = true,
    Scanlines  = false,
    GlowBlobs  = 5,
    -- Horizontal shear applied to chrome, the strongest "Phoenix" cue.
    -- 0 = the original upright panels, 0.06 is a subtle lean.
    Skew       = 0.06,
}

-- ---------------------------------------------------------------------
-- Tokens
-- ---------------------------------------------------------------------

local AccentRamps = {
    -- Phoenix 2 (2026) is built around an electric green identity.
    phoenix2 = { "#8CFF1F", "#12C98A" },
    -- The original Phoenix generation (2023) leaned on near-white cyan.
    phoenix  = { "#E9FBFF", "#2BA8FF" },
    cyan     = { "#39E6FF", "#3D7BFF" },
    violet   = { "#A177FF", "#5A2BE0" },
    magenta  = { "#FF5FD2", "#7A28FF" },
    lime     = { "#8BFF5A", "#12C9A0" },
    amber    = { "#FFC24A", "#FF5F6D" },
    ice      = { "#DCEBFF", "#6E8CFF" },
}

local Palettes = {
    -- The violet-leaning original modern palette.
    infinity = {
        Base      = "#07070F",
        BaseAlt   = "#120E2E",
        Surface   = "#1A1640",
        SurfaceHi = "#2A2470",
        Text      = "#F4F6FF",
        TextDim   = "#9AA1CC",
        Hairline  = "1,1,1,0.16",
    },
    -- Phoenix: almost black navy, cooler surfaces, pure white type. Shared by
    -- both Phoenix generations; only the accent hue changes between them.
    phoenix = {
        Base      = "#05070E",
        BaseAlt   = "#0A1224",
        Surface   = "#101B33",
        SurfaceHi = "#1B2E52",
        Text      = "#FFFFFF",
        TextDim   = "#93A6C4",
        Hairline  = "1,1,1,0.20",
    },
}

-- Status colours are shared by every palette.
ModernUI.Tokens = {
    Good = color("#3BE6A8"),
    Warn = color("#FFC24A"),
    Bad  = color("#FF5470"),
}

-- Swap palettes at runtime. The token table is mutated in place on purpose:
-- other files may already be holding a reference to ModernUI.Tokens, and
-- replacing the table would leave them pointing at the old colours.
function ModernUI.ApplyPalette(name)
    local palette = Palettes[name or ModernUI.Config.Palette] or Palettes.phoenix
    for key, value in pairs(palette) do
        ModernUI.Tokens[key] = color(value)
    end
    return ModernUI.Tokens
end

ModernUI.ApplyPalette()

-- Alpha carried by a colour token, used so helpers can keep the alpha that
-- is baked into the token instead of silently replacing it with 1.
local function ColorAlpha(shade)
    if type(shade) == "table" and type(shade[4]) == "number" then
        return shade[4]
    end
    return 1
end

-- Accent ramp, 1 = bright end, 2 = deep end
function ModernUI.Accent(index)
    local ramp = AccentRamps[ModernUI.Config.Accent] or AccentRamps.phoenix2
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
-- Geometry
-- ---------------------------------------------------------------------

-- Shared horizontal shear. Classic mode always stays upright.
function ModernUI.Skew()
    if not ModernUI.IsModern() then return 0 end
    return tonumber(ModernUI.Config.Skew) or 0
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
-- Chart level and grade tiers (Phoenix style)
-- ---------------------------------------------------------------------

-- Upper bound of each tier -> colour. Tune the numbers here, nothing else.
local LevelTiers = {
    { 4,  "#3BE6A8" },
    { 9,  "#39B6FF" },
    { 14, "#FFD44A" },
    { 18, "#FF9A3C" },
    { 21, "#FF5470" },
    { 24, "#C86BFF" },
}

function ModernUI.LevelColor(level)
    level = tonumber(level) or 0
    for _, tier in ipairs(LevelTiers) do
        if level <= tier[1] then return color(tier[2]) end
    end
    -- Anything above the last tier is the "extreme" bracket.
    return color("#7A28FF")
end

-- Minimum percentage -> grade name, highest first.
-- These are approximations of the official Phoenix cutoffs; adjust freely.
local GradeTiers = {
    { 99.5, "SSS+" }, { 99,   "SSS" },
    { 98.5, "SS+"  }, { 98,   "SS"  },
    { 97.5, "S+"   }, { 97,   "S"   },
    { 96,   "AAA+" }, { 95,   "AAA" },
    { 92.5, "AA+"  }, { 90,   "AA"  },
    { 87.5, "A+"   }, { 85,   "A"   },
    { 80,   "B"    }, { 70,   "C"   },
    { 60,   "D"    },
}

-- Accepts either a 0-1 ratio (what the engine usually hands out) or a
-- already-scaled 0-100 percentage.
function ModernUI.GradeTier(percent)
    percent = tonumber(percent) or 0
    if percent > 0 and percent <= 1 then percent = percent * 100 end

    for _, tier in ipairs(GradeTiers) do
        if percent >= tier[1] then return tier[2] end
    end
    return "F"
end

function ModernUI.GradeColor(grade)
    grade = tostring(grade or "F")
    local head = grade:sub(1, 1)

    if head == "S" then return ModernUI.Accent(1) end
    if head == "A" then return ModernUI.Tokens.Good end
    if grade == "F" then return ModernUI.Tokens.Bad end
    return ModernUI.Tokens.Warn
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
    local skew = params.skew or 0
    -- diffusealpha() replaces the alpha carried by the colour token, so the
    -- token's own alpha is the default here. Callers that want a brighter
    -- line (the glass card highlight, for example) still pass params.alpha.
    local alpha = params.alpha or ColorAlpha(shade)

    return Def.Quad {
        InitCommand = function(self)
            self:xy(params.x or 0, params.y or 0)
                :zoomto(width, thickness)
                :halign(params.halign or 0.5):valign(params.valign or 0.5)
                :skewx(skew)
                :diffuse(shade):diffusealpha(alpha)
        end
    }
end

-- Additive radial glow built from the texture the theme already ships.
function ModernUI.SoftGlow(params)
    params = params or {}
    local shade = params.color or ModernUI.Accent(1)
    local baseZoom = params.zoom or 1

    return Def.Sprite {
        Texture = THEME:GetPathG("", "Background/circle"),
        InitCommand = function(self)
            self:xy(params.x or 0, params.y or 0)
                :zoom(baseZoom)
                :blend("BlendMode_Add")
                :diffuse(shade)
                :diffusealpha(params.alpha or 0.2)

            if params.pulse and ModernUI.MotionScale() > 0 then
                -- pulse() drives zoom directly, so the magnitude has to be
                -- expressed in absolute zoom. Feeding it a bare 1 -> 1.06
                -- would throw away baseZoom and snap the glow down to 1x.
                -- params.pulse may be `true` (default ratio) or a number
                -- describing how far the glow should breathe.
                local ratio = tonumber(params.pulse) or 1.06
                self:pulse()
                    :effectmagnitude(baseZoom, baseZoom * ratio, 1)
                    :effectperiod(ModernUI.T(params.period or 4))
                    :effectoffset(params.offset or 0)
            end
        end
    }
end

-- Frosted panel: shadow -> gradient body -> top highlight -> accent bar.
-- Corners stay square on purpose, OutFox quads cannot be rounded without
-- shipping extra textures, so the modern look leans on gradients, hairlines
-- and the shared diagonal shear instead.
function ModernUI.GlassCard(params)
    params = params or {}
    local width  = params.w or 320
    local height = params.h or 120
    local halign = params.halign or 0.5
    local valign = params.valign or 0.5
    local alpha  = params.alpha or 0.55
    local accent = params.accent or ModernUI.Accent(1)
    local accentBar = params.accentBar ~= false
    local skew = params.skew or ModernUI.Skew()

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
                :skewx(skew)
                :diffuse(color("#000008")):diffusealpha(0.32 * alpha)
        end
    }

    -- Frosted body, brighter on top so it reads as lit from above
    card[#card + 1] = Def.Quad {
        InitCommand = function(self)
            self:zoomto(width, height)
                :halign(halign):valign(valign)
                :skewx(skew)
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
        skew = skew,
    }

    -- Accent bar, the single strongest "this is new" signal
    if accentBar then
        card[#card + 1] = Def.Quad {
            InitCommand = function(self)
                self:zoomto(width, params.accentThickness or 3)
                    :halign(halign):valign(0)
                    :x((0.5 - halign) * width)
                    :y(-valign * height)
                    :skewx(skew)
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
    local height = params.h or 84
    local skew = params.skew or ModernUI.Skew()
    -- A sheared quad pulls its top and bottom edges sideways, which would
    -- expose a wedge of background at the screen edges. Grow the bar by the
    -- offset the shear introduces so it always bleeds off-screen.
    local bleed = math.abs(skew) * height * 2 + 8

    return ModernUI.GlassCard {
        x = params.x or SCREEN_CENTER_X,
        y = params.y or 0,
        w = params.w or (SCREEN_WIDTH + bleed),
        h = height,
        halign = 0.5,
        valign = params.valign or 0,
        alpha = params.alpha or 0.6,
        accentBar = params.accentBar ~= false,
        accentThickness = params.accentThickness or 2,
        skew = skew,
    }
end

Trace("[Glassmorphism] Modern UI v2 loaded (style: " .. tostring(ModernUI.Config.Style)
    .. ", palette: " .. tostring(ModernUI.Config.Palette)
    .. ", accent: " .. tostring(ModernUI.Config.Accent)
    .. ", motion: " .. tostring(ModernUI.Config.Motion) .. ")")

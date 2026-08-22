-- =====================================================================
-- Glassmorphism :: procedural shapes
-- =====================================================================
-- Rounded panels, soft shadows, sheen and rings drawn with geometry
-- instead of textures.
--
-- WHY THIS EXISTS
-- Graphics/Glass/*.png is generated art (Other/gen_glass_assets.py) and a
-- fresh checkout does not have it. Without that art every panel fell back
-- to hard square corners with no shadow, no sheen and no ring, which is
-- most of the glass look gone. Everything here is pure Lua, so it ships
-- with the theme and always works, on any checkout, with no build step.
--
-- Textures still win when they are present: a pre-blurred shadow sprite is
-- softer than anything geometry can do this cheaply. This is the floor,
-- not a replacement.
--
-- IMPLEMENTATION NOTES
--   * One ActorMultiVertex per shape, drawn as a triangle list. A triangle
--     list rather than a fan or strip because a single list can hold the
--     body and its antialiasing skirt in one actor and one draw call.
--   * Corners are real arcs, so the radius is exact at any size. The
--     nine-slice stretched a square texture and distorted the corner
--     whenever the panel was far from square.
--   * Edges are antialiased by a feather skirt: every outline vertex is
--     repeated a little further out along its own normal with alpha 0.
--     Because the outline is generated from the corner arcs, that normal
--     is exact, not approximated from the centre of the panel.
--   * Vertical gradients are baked into vertex colours, which is why the
--     body needs no diffusetopedge/diffusebottomedge.
--
-- Colours are plain {r, g, b, a} tables, so anything color() returns and
-- any ModernUI token can be passed straight in.
--
-- Shapes are centred on the actor's own origin unless halign/valign are
-- given, matching ModernUI.GlassCard.
-- =====================================================================

local Shapes = {}

-- Arc spans in degrees, clockwise in screen coordinates (y grows
-- downward), starting at the top-left corner. Walking these four in order
-- traces the whole panel outline exactly once.
local CornerArcs = {
    { 180, 270 },
    { 270, 360 },
    {   0,  90 },
    {  90, 180 },
}

-- Segments per corner. Small radii do not need many; large ones do. The
-- ceiling keeps the vertex count sane on screens full of cards.
local function ArcSegments(radius)
    return math.max(3, math.min(12, math.floor(radius / 2.5) + 3))
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

-- Colour of the vertical gradient at a given y.
local function ShadeAt(topShade, bottomShade, y, top, height)
    local t = 0
    if height > 0 then
        t = math.max(0, math.min(1, (y - top) / height))
    end
    return {
        Lerp(topShade[1] or 0, bottomShade[1] or 0, t),
        Lerp(topShade[2] or 0, bottomShade[2] or 0, t),
        Lerp(topShade[3] or 0, bottomShade[3] or 0, t),
        Lerp(topShade[4] or 1, bottomShade[4] or 1, t),
    }
end

-- Outline of a rounded rectangle as { x, y, nx, ny } per vertex, where
-- nx/ny is the outward unit normal used for feathering.
--
-- `segments` can be forced so that two outlines of different radius still
-- produce the same vertex count, which the ring stitching depends on.
local function Outline(left, top, right, bottom, radius, segments)
    segments = segments or ArcSegments(radius)

    local centres = {
        { left  + radius, top    + radius },
        { right - radius, top    + radius },
        { right - radius, bottom - radius },
        { left  + radius, bottom - radius },
    }

    local points = {}
    for corner = 1, 4 do
        local from, to = CornerArcs[corner][1], CornerArcs[corner][2]
        local cx, cy = centres[corner][1], centres[corner][2]
        for step = 0, segments do
            local radians = math.rad(from + (to - from) * (step / segments))
            local nx, ny = math.cos(radians), math.sin(radians)
            points[#points + 1] = { cx + nx * radius, cy + ny * radius, nx, ny }
        end
    end
    return points
end

local function Vertex(x, y, shade)
    return { { x, y, 0 }, { shade[1], shade[2], shade[3], shade[4] or 1 } }
end

-- Resolve w/h/halign/valign into bounds around the actor's origin.
local function Bounds(params)
    local width  = params.w or 320
    local height = params.h or 120
    local halign = params.halign or 0.5
    local valign = params.valign or 0.5
    local left, top = -halign * width, -valign * height
    return left, top, left + width, top + height, width, height
 end

local function MultiVertex(vertices, params)
    return Def.ActorMultiVertex {
        InitCommand = function(self)
            self:xy(params.x or 0, params.y or 0)
            -- Vertices first, then the draw state: Num = -1 means "all of
            -- them", so the count has to be known by the time it is read.
            self:SetVertices(vertices)
            self:SetDrawState({ Mode = "DrawMode_Triangles", First = 1, Num = -1 })
            if params.blend then self:blend(params.blend) end
        end
    }
end

-- ---------------------------------------------------------------------
-- Rounded rectangle
-- ---------------------------------------------------------------------
-- params.topColor / bottomColor - vertical gradient ends (or .color for a
--                                 flat fill)
-- params.radius                  - corner radius in pixels
-- params.feather                 - antialiasing width; raise it for a glow
function Shapes.RoundedRect(params)
    params = params or {}
    local left, top, right, bottom, width, height = Bounds(params)

    -- Never let the radius eat more than half the smaller side, and never
    -- let it reach exactly 0: the arcs would collapse onto each other.
    local radius = math.max(0.5, math.min(params.radius or 14,
        math.floor(math.min(width, height) * 0.5)))
    local feather = params.feather or 1

    local topShade = params.topColor or params.color or { 1, 1, 1, 1 }
    local bottomShade = params.bottomColor or topShade

    local points = Outline(left, top, right, bottom, radius)
    local count = #points
    local centreX, centreY = (left + right) * 0.5, (top + bottom) * 0.5
    local centreShade = ShadeAt(topShade, bottomShade, centreY, top, height)

    local vertices = {}
    local function push(x, y, shade)
        vertices[#vertices + 1] = Vertex(x, y, shade)
    end

    -- Body: a fan from the centre, written out as individual triangles.
    for i = 1, count do
        local a = points[i]
        local b = points[(i % count) + 1]
        push(centreX, centreY, centreShade)
        push(a[1], a[2], ShadeAt(topShade, bottomShade, a[2], top, height))
        push(b[1], b[2], ShadeAt(topShade, bottomShade, b[2], top, height))
    end

    -- Feather: a transparent skirt hugging the outline, which is what makes
    -- the curve read as smooth instead of stepped.
    if feather > 0 then
        for i = 1, count do
            local a = points[i]
            local b = points[(i % count) + 1]
            local aShade = ShadeAt(topShade, bottomShade, a[2], top, height)
            local bShade = ShadeAt(topShade, bottomShade, b[2], top, height)
            local aClear = { aShade[1], aShade[2], aShade[3], 0 }
            local bClear = { bShade[1], bShade[2], bShade[3], 0 }
            local ax, ay = a[1] + a[3] * feather, a[2] + a[4] * feather
            local bx, by = b[1] + b[3] * feather, b[2] + b[4] * feather

            push(a[1], a[2], aShade)
            push(b[1], b[2], bShade)
            push(bx, by, bClear)

            push(a[1], a[2], aShade)
            push(bx, by, bClear)
            push(ax, ay, aClear)
        end
    end

    return MultiVertex(vertices, params)
end

-- ---------------------------------------------------------------------
-- Soft ambient shadow
-- ---------------------------------------------------------------------
-- A rounded rectangle whose feather is deliberately enormous, which is a
-- cheap approximation of a blur. Not as soft as the pre-blurred sprite,
-- but far better than the hard quad it replaces.
function Shapes.SoftShadow(params)
    params = params or {}
    local spread = params.spread or 18
    local shade = params.color or { 0, 0, 0.03 }
    local alpha = params.alpha or 0.35

    return Shapes.RoundedRect {
        x = params.x, y = params.y,
        w = (params.w or 320) + spread * 0.5,
        h = (params.h or 120) + spread * 0.5,
        halign = params.halign, valign = params.valign,
        radius = (params.radius or 14) + spread * 0.25,
        feather = spread,
        color = { shade[1], shade[2], shade[3], alpha },
    }
end

-- ---------------------------------------------------------------------
-- Specular glint
-- ---------------------------------------------------------------------
-- Honest naming caveat: the texture draws a full diagonal streak, this
-- draws a corner glint that fades out toward the opposite corner. Same
-- purpose, simpler geometry, and it reads correctly on a glass panel.
function Shapes.Sheen(params)
    params = params or {}
    local left, top, right, bottom = Bounds(params)
    local alpha = params.alpha or 0.10
    local shade = params.color or { 1, 1, 1 }

    local function tone(a)
        return { shade[1], shade[2], shade[3], a }
    end

    local topLeft     = tone(alpha)
    local topRight    = tone(alpha * 0.25)
    local bottomLeft  = tone(alpha * 0.30)
    local bottomRight = tone(0)

    local vertices = {
        Vertex(left,  top,    topLeft),
        Vertex(right, top,    topRight),
        Vertex(right, bottom, bottomRight),

        Vertex(left,  top,    topLeft),
        Vertex(right, bottom, bottomRight),
        Vertex(left,  bottom, bottomLeft),
    }

    params.blend = params.blend or "BlendMode_Add"
    return MultiVertex(vertices, params)
end

-- ---------------------------------------------------------------------
-- Rounded outline ring
-- ---------------------------------------------------------------------
-- Unlike Ring.png this is built from the requested width and height, so a
-- wide frame keeps its corner radius instead of smearing it.
function Shapes.Ring(params)
    params = params or {}
    local left, top, right, bottom, width, height = Bounds(params)
    local thickness = params.thickness or 2
    local feather = params.feather or 1
    local shade = params.color or { 1, 1, 1, 1 }

    local radius = math.max(0.5, math.min(params.radius or 14,
        math.floor(math.min(width, height) * 0.5)))
    local innerRadius = math.max(0.5, radius - thickness)

    -- Both outlines are forced to the same segment count so vertex i on the
    -- outer edge always pairs with vertex i on the inner edge.
    local segments = ArcSegments(radius)
    local outer = Outline(left, top, right, bottom, radius, segments)
    local inner = Outline(left + thickness, top + thickness,
        right - thickness, bottom - thickness, innerRadius, segments)

    local count = #outer
    local clear = { shade[1], shade[2], shade[3], 0 }

    local vertices = {}
    local function push(x, y, s)
        vertices[#vertices + 1] = Vertex(x, y, s)
    end

    for i = 1, count do
        local nextIndex = (i % count) + 1
        local o1, o2 = outer[i], outer[nextIndex]
        local i1, i2 = inner[i], inner[nextIndex]

        -- The band itself.
        push(o1[1], o1[2], shade)
        push(o2[1], o2[2], shade)
        push(i2[1], i2[2], shade)

        push(o1[1], o1[2], shade)
        push(i2[1], i2[2], shade)
        push(i1[1], i1[2], shade)

        if feather > 0 then
            -- Outer skirt, pushed along the outward normal.
            local ox1, oy1 = o1[1] + o1[3] * feather, o1[2] + o1[4] * feather
            local ox2, oy2 = o2[1] + o2[3] * feather, o2[2] + o2[4] * feather

            push(o1[1], o1[2], shade)
            push(o2[1], o2[2], shade)
            push(ox2, oy2, clear)

            push(o1[1], o1[2], shade)
            push(ox2, oy2, clear)
            push(ox1, oy1, clear)

            -- Inner skirt, pushed the other way so the hole is smooth too.
            local ix1, iy1 = i1[1] - i1[3] * feather, i1[2] - i1[4] * feather
            local ix2, iy2 = i2[1] - i2[3] * feather, i2[2] - i2[4] * feather

            push(i1[1], i1[2], shade)
            push(i2[1], i2[2], shade)
            push(ix2, iy2, clear)

            push(i1[1], i1[2], shade)
            push(ix2, iy2, clear)
            push(ix1, iy1, clear)
        end
    end

    return MultiVertex(vertices, params)
end

return Shapes

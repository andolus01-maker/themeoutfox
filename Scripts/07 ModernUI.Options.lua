-- Modern UI — persisted option rows
--
-- Lets the whole modern look be changed from an options screen instead of
-- editing Scripts/06 ModernUI.lua by hand. Values are stored in
-- Save/OutFoxPrefs.ini next to the theme's existing preferences, so they
-- survive updates to the theme files themselves.
--
-- This file loads AFTER 06 ModernUI.lua (alphabetical load order), so it can
-- safely overwrite ModernUI.Config with whatever the player saved.

if not ModernUI then return end

local PrefsFile = "Save/OutFoxPrefs.ini"

local function Load(key)
    return LoadModule("Config.Load.lua")(key, PrefsFile)
end

local function Save(key, value)
    LoadModule("Config.Save.lua")(key, value, PrefsFile)
end

-- Choice tables. The first entry of each is the shipped default.
ModernUI.Choices = {
    Style   = { "aurora", "video", "classic" },
    Palette = { "phoenix", "infinity" },
    Accent  = { "phoenix2", "phoenix", "cyan", "violet", "magenta", "lime", "amber", "ice" },
    Motion  = { "full", "reduced", "off" },
}

-- Discrete stops for the numeric settings. These are the values the option
-- rows offer; the config itself still accepts anything in range if edited by
-- hand, and the rows snap to the nearest stop when displaying it.
local SkewValues   = { 0, 0.03, 0.06, 0.10, 0.15, 0.20, 0.25 }
local RadiusValues = { 0, 8, 14, 20, 28 }
local BlobValues   = { 0, 1, 2, 3, 4, 5, 6, 7, 8 }

local function IsValid(list, value)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

-- Apply saved preferences over the compiled-in defaults.
-- Anything missing or corrupt falls back to the value in 06 ModernUI.lua.
for _, key in ipairs({ "Style", "Palette", "Accent", "Motion" }) do
    local saved = Load("Modern" .. key)
    if saved and IsValid(ModernUI.Choices[key], saved) then
        ModernUI.Config[key] = saved
    end
end

-- Booleans are stored as the strings "true"/"false" by Config.Save.lua.
-- Sheen and Pumbility used to be missing from this list, which meant a value
-- written into the prefs file by hand was read back and then ignored.
for _, key in ipairs({ "Glass", "Grain", "Vignette", "Scanlines", "Sheen", "Pumbility" }) do
    local saved = Load("Modern" .. key)
    if saved ~= nil and saved ~= "" then
        ModernUI.Config[key] = (saved == "true" or saved == true or saved == 1)
    end
end

local savedBlobs = tonumber(Load("ModernGlowBlobs"))
if savedBlobs then
    ModernUI.Config.GlowBlobs = math.max(0, math.min(8, math.floor(savedBlobs)))
end

-- Shear is clamped hard: past ~0.25 the chrome starts to look broken rather
-- than stylised.
local savedSkew = tonumber(Load("ModernSkew"))
if savedSkew then
    ModernUI.Config.Skew = math.max(-0.25, math.min(0.25, savedSkew))
end

-- Corner radius was likewise never being loaded. Clamped to the largest size
-- the corner art can serve without visibly stretching.
local savedRadius = tonumber(Load("ModernRadius"))
if savedRadius then
    ModernUI.Config.Radius = math.max(0, math.min(32, math.floor(savedRadius)))
end

-- The palette may have changed above, so rebuild the colour tokens before any
-- screen gets a chance to read them.
ModernUI.ApplyPalette()

-- ---------------------------------------------------------------------------
-- Option row builders
-- ---------------------------------------------------------------------------
-- Every setting in ModernUI.Config now has a row here, and metrics.ini lists
-- them all under [ScreenInfOptionsUI]. Adding a further row means adding its
-- title and explanation to Languages/en.ini as well; the other language files
-- fall back to English for any key they are missing.
--
-- Note: the choice labels below are still hard-coded English. Only the row
-- titles and explanations go through the language files.
-- See MODERN-UI.md.

ModernUI.OptionRow = {}

-- Builds a single-choice, one-for-all-players row backed by OutFoxPrefs.ini
local function BuildRow(name, choices, prettyNames)
    local key = name:gsub("^Modern", "")

    return {
        Name = name,
        LayoutType = "ShowAllInRow",
        SelectType = "SelectOne",
        OneChoiceForAllPlayers = true,
        ExportOnChange = true,
        Choices = prettyNames or choices,

        LoadSelections = function(self, list, pn)
            local current = ModernUI.Config[key] or choices[1]
            local index = 1
            for i, v in ipairs(choices) do
                if v == current then index = i break end
            end
            list[index] = true
        end,

        SaveSelections = function(self, list, pn)
            for i, v in ipairs(choices) do
                if list[i] then
                    ModernUI.Config[key] = v
                    Save(name, v)

                    -- Colour tokens are derived from the palette, so they have
                    -- to be rebuilt here or the change waits for a reload.
                    if key == "Palette" then ModernUI.ApplyPalette() end
                    break
                end
            end
            -- A theme reload picks up background/chrome changes everywhere.
            -- Colours applied per-screen update as soon as you leave options.
        end,
    }
end

-- On/off row for the boolean settings.
local function BuildToggleRow(name)
    local key = name:gsub("^Modern", "")

    return {
        Name = name,
        LayoutType = "ShowAllInRow",
        SelectType = "SelectOne",
        OneChoiceForAllPlayers = true,
        ExportOnChange = true,
        Choices = { "Off", "On" },

        LoadSelections = function(self, list, pn)
            list[ModernUI.Config[key] and 2 or 1] = true
        end,

        SaveSelections = function(self, list, pn)
            ModernUI.Config[key] = list[2] and true or false
            Save(name, tostring(ModernUI.Config[key]))
        end,
    }
end

-- Numeric row over a fixed set of stops. The current value is matched by
-- nearest neighbour rather than exact equality, so a value someone typed into
-- the prefs file by hand still shows up on the closest stop instead of
-- silently snapping back to the first one.
local function BuildValueRow(name, values, labels)
    local key = name:gsub("^Modern", "")

    return {
        Name = name,
        LayoutType = "ShowAllInRow",
        SelectType = "SelectOne",
        OneChoiceForAllPlayers = true,
        ExportOnChange = true,
        Choices = labels,

        LoadSelections = function(self, list, pn)
            local current = tonumber(ModernUI.Config[key]) or values[1]
            local index, closest = 1, nil
            for i, v in ipairs(values) do
                local distance = math.abs(v - current)
                if closest == nil or distance < closest then
                    index, closest = i, distance
                end
            end
            list[index] = true
        end,

        SaveSelections = function(self, list, pn)
            for i, v in ipairs(values) do
                if list[i] then
                    ModernUI.Config[key] = v
                    Save(name, tostring(v))
                    break
                end
            end
        end,
    }
end

function ModernUI.OptionRow.Style()
    return BuildRow("ModernStyle", ModernUI.Choices.Style, { "Aurora", "Video", "Classic" })
end

function ModernUI.OptionRow.Palette()
    return BuildRow("ModernPalette", ModernUI.Choices.Palette, { "Phoenix", "Infinity" })
end

function ModernUI.OptionRow.Accent()
    return BuildRow("ModernAccent", ModernUI.Choices.Accent,
        { "Phoenix 2", "Phoenix", "Cyan", "Violet", "Magenta", "Lime", "Amber", "Ice" })
end

function ModernUI.OptionRow.Motion()
    return BuildRow("ModernMotion", ModernUI.Choices.Motion, { "Full", "Reduced", "Off" })
end

function ModernUI.OptionRow.Glass()
    return BuildToggleRow("ModernGlass")
end

function ModernUI.OptionRow.Sheen()
    return BuildToggleRow("ModernSheen")
end

function ModernUI.OptionRow.Grain()
    return BuildToggleRow("ModernGrain")
end

function ModernUI.OptionRow.Vignette()
    return BuildToggleRow("ModernVignette")
end

function ModernUI.OptionRow.Scanlines()
    return BuildToggleRow("ModernScanlines")
end

function ModernUI.OptionRow.Pumbility()
    return BuildToggleRow("ModernPumbility")
end

function ModernUI.OptionRow.Skew()
    return BuildValueRow("ModernSkew", SkewValues,
        { "Off", "Subtle", "Light", "Medium", "Strong", "Extreme", "Max" })
end

function ModernUI.OptionRow.Radius()
    return BuildValueRow("ModernRadius", RadiusValues,
        { "Square", "Small", "Default", "Large", "Round" })
end

function ModernUI.OptionRow.GlowBlobs()
    return BuildValueRow("ModernGlowBlobs", BlobValues,
        { "Off", "1", "2", "3", "4", "5", "6", "7", "8" })
end

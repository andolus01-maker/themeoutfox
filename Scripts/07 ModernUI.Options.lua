-- Modern UI — persisted option rows
--
-- Lets Style / Accent / Motion be changed from an options screen instead of
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
-- These four have no option row yet, so they are file-only settings for now.
for _, key in ipairs({ "Glass", "Grain", "Vignette", "Scanlines" }) do
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

-- The palette may have changed above, so rebuild the colour tokens before any
-- screen gets a chance to read them.
ModernUI.ApplyPalette()

-- ---------------------------------------------------------------------------
-- Option row builders
-- ---------------------------------------------------------------------------
-- These rows are already wired up: metrics.ini declares LineModernStyle,
-- LineModernAccent, LineModernMotion and LineModernGlass under
-- [ScreenInfOptionsUI], and every Languages/*.ini carries the matching
-- [OptionTitles] / [OptionExplanations] strings. Do not add those keys again.
--
-- Palette, Skew, Grain, Vignette, Scanlines and GlowBlobs are read above but
-- have no row yet; adding one also means adding strings to all five language
-- files.
--
-- Note: the choice labels below are still hard-coded English. Only the row
-- titles and explanations go through the language files.
-- See MODERN-UI.md.

ModernUI.OptionRow = {}

-- Builds a single-choice, one-for-all-players row backed by OutFoxPrefs.ini
local function BuildRow(name, choices, prettyNames)
    return {
        Name = name,
        LayoutType = "ShowAllInRow",
        SelectType = "SelectOne",
        OneChoiceForAllPlayers = true,
        ExportOnChange = true,
        Choices = prettyNames or choices,

        LoadSelections = function(self, list, pn)
            local current = ModernUI.Config[name:gsub("^Modern", "")] or choices[1]
            local index = 1
            for i, v in ipairs(choices) do
                if v == current then index = i break end
            end
            list[index] = true
        end,

        SaveSelections = function(self, list, pn)
            for i, v in ipairs(choices) do
                if list[i] then
                    local key = name:gsub("^Modern", "")
                    ModernUI.Config[key] = v
                    Save(name, v)
                    break
                end
            end
            -- A theme reload picks up background/chrome changes everywhere.
            -- Colours applied per-screen update as soon as you leave options.
        end,
    }
end

function ModernUI.OptionRow.Style()
    return BuildRow("ModernStyle", ModernUI.Choices.Style, { "Aurora", "Video", "Classic" })
end

function ModernUI.OptionRow.Accent()
    return BuildRow("ModernAccent", ModernUI.Choices.Accent,
        { "Phoenix 2", "Phoenix", "Cyan", "Violet", "Magenta", "Lime", "Amber", "Ice" })
end

function ModernUI.OptionRow.Motion()
    return BuildRow("ModernMotion", ModernUI.Choices.Motion, { "Full", "Reduced", "Off" })
end

function ModernUI.OptionRow.Glass()
    return {
        Name = "ModernGlass",
        LayoutType = "ShowAllInRow",
        SelectType = "SelectOne",
        OneChoiceForAllPlayers = true,
        ExportOnChange = true,
        Choices = { "Off", "On" },
        LoadSelections = function(self, list, pn)
            list[ModernUI.Config.Glass and 2 or 1] = true
        end,
        SaveSelections = function(self, list, pn)
            ModernUI.Config.Glass = list[2] and true or false
            Save("ModernGlass", tostring(ModernUI.Config.Glass))
        end,
    }
end

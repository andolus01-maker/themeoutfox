-- =====================================================================
-- Pumbility-style player rating
-- =====================================================================
-- Phoenix 2 renews "Pumbility", a single number summarising a player from
-- their best charts. Andamiro does not publish the formula, so this is an
-- explicit approximation, not a reproduction. Every constant that shapes it
-- lives in this block:
--
--   chart rating = chart level  x  grade weight  x  PointScale
--   pumbility    = sum of the best TopCount chart ratings / TopCount
--
-- Dividing by TopCount rather than by the number of charts actually played is
-- deliberate: like the real system, a player has to build up a body of scored
-- charts before the number stops being small. The UI dims the figure while
-- fewer than TopCount charts have been scored so this does not read as a bug.
--
-- Usage:
--   local data = LoadModule("UI.Pumbility.lua")(pn)
--   data.rating  -- rounded integer
--   data.charts  -- how many scored charts went into it
--   data == false -- could not be computed (no profile, or engine API missing)
-- =====================================================================

local TopCount = 50
local PointScale = 40

-- Minimum percentage -> how much of a chart's level the player banks.
-- Mirrors the grade cutoffs in PIU/Score.Grading.lua; keep them in step.
local GradeWeights = {
    { 99.5, 1.00 }, { 99,   0.98 },
    { 98.5, 0.96 }, { 98,   0.94 },
    { 97.5, 0.92 }, { 97,   0.90 },
    { 96,   0.86 }, { 95,   0.82 },
    { 92.5, 0.76 }, { 90,   0.70 },
    { 82.5, 0.60 }, { 75,   0.50 },
    { 65,   0.35 }, { 55,   0.20 },
    { 45,   0.10 },
}

-- Computed lazily and kept for the rest of the session. `false` is stored for
-- "tried and failed", which is why lookups test against nil and not falsiness:
-- otherwise a failed profile would be recomputed on every screen.
local Cache = {}

local function WeightFor(percent)
    for _, tier in ipairs(GradeWeights) do
        if percent >= tier[1] then return tier[2] end
    end
    return 0
end

local function Compute(pn)
    if not PROFILEMAN:IsPersistentProfile(pn) then return false end

    local profile = PROFILEMAN:GetProfile(pn)
    if not profile then return false end

    local songs = SONGMAN:GetAllSongs()
    if type(songs) ~= "table" then return false end

    local ratings = {}

    for _, song in ipairs(songs) do
        local charts = SongUtil.GetPlayableSteps(song)

        if charts then
            for _, chart in ipairs(charts) do
                local meter = chart:GetMeter()

                -- 99 is the co-op sentinel, not a difficulty, so it cannot be
                -- rated. Skipping it also keeps co-op charts from dominating.
                if meter and meter > 0 and meter ~= 99 then
                    local list = profile:GetHighScoreList(song, chart)
                    local scores = list and list:GetHighScores()

                    if scores and scores[1] then
                        local weight = WeightFor(scores[1]:GetPercentDP() * 100)
                        if weight > 0 then
                            ratings[#ratings + 1] = meter * weight * PointScale
                        end
                    end
                end
            end
        end
    end

    if #ratings == 0 then return { rating = 0, charts = 0 } end

    table.sort(ratings, function(a, b) return a > b end)

    local counted = math.min(#ratings, TopCount)
    local total = 0
    for i = 1, counted do total = total + ratings[i] end

    return {
        rating = math.floor(total / TopCount + 0.5),
        charts = counted,
    }
end

return function(pn, refresh)
    if not refresh and Cache[pn] ~= nil then return Cache[pn] end

    -- Walking the whole library touches a lot of engine objects. A failure here
    -- must never take down the screen that asked for a decorative number, so
    -- the result is a hidden chip rather than an error.
    local ok, result = pcall(Compute, pn)
    if not ok then
        Trace("[Glassmorphism] Pumbility could not be computed: " .. tostring(result))
    end

    Cache[pn] = ok and result or false
    return Cache[pn]
end

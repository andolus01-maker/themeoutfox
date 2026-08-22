local Scoring = LoadModule("Config.Load.lua")("ScoringSystem", "Save/OutFoxPrefs.ini") or "Old"
local ClassicGrades = LoadModule("Config.Load.lua")("ClassicGrades", "Save/OutFoxPrefs.ini") and Scoring == "Old"
local SongIsChosen = false

-- Modern UI: accent glow behind the score plate plus grade-tinted personal and
-- machine best figures. The grade sprite itself is left alone -- it is official
-- PIU art from Graphics/LetterGrades and the theme should keep using it. What
-- the modern layer adds is colour on the *numbers*, driven by the very same
-- grade code the sprite is loaded from, so the two can never disagree.
local Modern = ModernUI and ModernUI.IsModern()
local function Dur(seconds)
    if ModernUI then return ModernUI.T(seconds) end
    return seconds
end

-- Tint a score readout by grade, or reset it to the accent when there is no
-- score to grade.
local function TintByGrade(text, grade)
    if not Modern then return end
    text:diffuse(Color.White)
    text:diffusetopedge(grade and ModernUI.GradeColor(grade) or ModernUI.Accent(1))
end

local t = Def.ActorFrame {}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    -- Player 2's panel is slightly adjusted, so we need to correct
    -- the positioning of actors so that they fit in properly
    local CorrectionX = pn == PLAYER_2 and -15 or 0
    
    t[#t+1] = Def.ActorFrame {
        Def.ActorFrame {
            CurrentChartChangedMessageCommand=function(self, params) if SongIsChosen and params.Player == pn then self:playcommand("Refresh") end end,
            
            SongChosenMessageCommand=function(self)
                SongIsChosen = true
                self:stoptweening():easeoutexpo(Dur(0.5))
                :x(358 * (pn == PLAYER_2 and 1 or -1))
                self:playcommand("Refresh")
            end,
            SongUnchosenMessageCommand=function(self)
                SongIsChosen = false
                self:stoptweening():easeoutexpo(Dur(0.5)):x(0)
            end,

            RefreshCommand=function(self)
                Song = GAMESTATE:GetCurrentSong()
                Chart = GAMESTATE:GetCurrentSteps(pn)

                -- Personal best score
                if PROFILEMAN:IsPersistentProfile(pn) then
                    ProfileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(Song, Chart):GetHighScores()

                    if ProfileScores[1] ~= nil then
                        local ProfileScore = ProfileScores[1]:GetScore()
                        local ProfileDP = round(ProfileScores[1]:GetPercentDP() * 100, 2) .. "%"
                        local ProfileGrade = LoadModule("PIU/Score.Grading.lua")(ProfileScores[1])

                        self:GetChild("PersonalGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
                            ProfileGrade)):visible(true)
                        self:GetChild("PersonalScore"):settext(ProfileDP .. "\n" .. ProfileScore)
                        TintByGrade(self:GetChild("PersonalScore"), ProfileGrade)
                    else
                        self:GetChild("PersonalGrade"):visible(false)
                        self:GetChild("PersonalScore"):settext("")
                        TintByGrade(self:GetChild("PersonalScore"), nil)
                    end
                else
                    self:GetChild("PersonalGrade"):visible(false)
                    self:GetChild("PersonalScore"):settext("")
                    TintByGrade(self:GetChild("PersonalScore"), nil)
                end

                -- Machine best score
                local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
                if MachineHighScores[1] ~= nil then
                    local MachineScore = MachineHighScores[1]:GetScore()
                    local MachineDP = round(MachineHighScores[1]:GetPercentDP() * 100, 2) .. "%"
                    local MachineName = MachineHighScores[1]:GetName()
                    local MachineGrade = LoadModule("PIU/Score.Grading.lua")(MachineHighScores[1])

                    self:GetChild("MachineGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
                            MachineGrade)):visible(true)
                    self:GetChild("MachineScore"):settext(MachineName .. "\n" .. MachineDP .. "\n" .. MachineScore)
                    TintByGrade(self:GetChild("MachineScore"), MachineGrade)
                else
                    self:GetChild("MachineGrade"):visible(false)
                    self:GetChild("MachineScore"):settext("")
                    TintByGrade(self:GetChild("MachineScore"), nil)
                end
            end,

            -- Soft accent bloom behind the plate
            Modern and ModernUI.SoftGlow {
                x = 0, y = 10, zoom = 1.9, alpha = 0.16,
                pulse = 1.04, period = 6,
            } or Def.Actor {},

            Def.Sprite {
                -- Texture=THEME:GetPathG("", "UI/ScoreDisplay"),
                InitCommand=function(self)
                    self:Load(THEME:GetPathG("", "UI/ScoreDisplay" .. ToEnumShortString(pn)))
                    :xy(0, 0):zoom(0.75)
                end,
            },
            
            Def.Sprite {
                Name="PersonalGrade",
                InitCommand=function(self)
                    self:xy(-40 + CorrectionX, -35):zoom(0.2)
                end,
            },

            Def.BitmapText {
                Name="PersonalScore",
                Font="Common normal",
                InitCommand=function(self)
                    self:xy(90 + CorrectionX, -35):zoom(1):halign(1)
                    :diffuse(Color.White):vertspacing(-6):shadowlength(1)
                    if Modern then self:diffusetopedge(ModernUI.Accent(1)) end
                end,
            },
            
            Def.Sprite {
                Name="MachineGrade",
                InitCommand=function(self)
                    self:xy(-40 + CorrectionX, 60):zoom(0.2)
                end,
            },

            Def.BitmapText {
                Name="MachineScore",
                Font="Common normal",
                InitCommand=function(self)
                    self:xy(90 + CorrectionX, 60):zoom(1):halign(1)
                    :diffuse(Color.White):vertspacing(-6):shadowlength(1)
                    if Modern then self:diffusetopedge(ModernUI.Accent(1)) end
                end,
            },
        }
    }
end

return t

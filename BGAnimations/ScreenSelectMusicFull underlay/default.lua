setenv("IsBasicMode", false)

-- Modern UI: nothing in this file is addressed by index, so adding actors here
-- is safe. (ChartDisplay.lua is the opposite -- see the note in that file.)
local Modern = ModernUI and ModernUI.IsModern()

local t = Def.ActorFrame {
	-- Add timer functionality
	InitCommand=function(self)
		self:sleep(0.5):queuecommand("CheckTimer")
	end,
	CheckTimerCommand=function(self)
		if SCREENMAN:GetTopScreen():GetChild("Timer"):GetSeconds() <= 0 then
			self:queuecommand("TimerExpired")
		else
			self:sleep(0.5):queuecommand("CheckTimer")
		end
	end,
	TimerExpiredCommand=function(self)
		-- Set these or else we crash.
        GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
        GAMESTATE:SetCurrentStyle(GAMESTATE:GetNumSidesJoined() > 1 and "versus" or string.lower(ShortType(GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber()))))
        SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

-- The column thing
t[#t+1] = Def.Quad {
    InitCommand=function(self)
        self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):valign(0.5)
        :zoomx(255)
        :diffuse(0,0,0,0.75)
        :zoomy(0)
        :decelerate(0.5)
        :zoomy(SCREEN_HEIGHT)
    end,
    OffCommand=function(self)
        self:stoptweening():decelerate(0.5):zoomy(0)
    end
}

t[#t+1] = LoadActor("MusicWheel") .. { Name="MusicWheel" }

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    t[#t+1] = Def.ActorFrame {
        Def.Actor {
            -- If no AV is defined, do it before it causes any issues
            OnCommand=function(self)
                local AV = LoadModule("Config.Load.lua")("AutoVelocity", CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
                if not AV then
                    LoadModule("Config.Save.lua")("AutoVelocity", tostring(200), CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
                end
                LoadModule("Player.SetSpeed.lua")(pn)
            end,

            -- Make sure the speed is set relative to the selected song when going to gameplay
            OffCommand=function(self)
                LoadModule("Player.SetSpeed.lua")(pn)
            end
        },

        LoadActor("../ModIcons", pn) .. {
            InitCommand=function(self)
                self:xy(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2, 160)
                :easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT - 40 or 40)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2)
            end
        },

        -- Pumbility-style rating chip.
        --
        -- The value is filled in *after* the screen has animated in: computing
        -- it walks every song's high score list for this profile, which is not
        -- instant on a large library, and doing that during the transition
        -- would visibly stall it. The chip simply starts empty.
        (Modern and ModernUI.Config.Pumbility) and Def.ActorFrame {
            InitCommand=function(self)
                self:xy(pn == PLAYER_2 and SCREEN_RIGHT + 200 or -200, 74)
                :easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT - 104 or 104)
                :queuecommand("Defer")
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1)
                :x(pn == PLAYER_2 and SCREEN_RIGHT + 200 or -200)
            end,

            DeferCommand=function(self)
                self:sleep(0.6):queuecommand("Compute")
            end,

            ComputeCommand=function(self)
                local badge = self:GetChild("PumbilityBadge")
                local value = badge and badge:GetChild("Value")
                if not value then return end

                local data = LoadModule("UI.Pumbility.lua")(pn)

                if data and data.rating and data.charts and data.charts > 0 then
                    value:settext(tostring(data.rating))

                    -- Below a full set of scored charts the figure is
                    -- structurally low, so dim it rather than presenting a
                    -- small number as if it were final.
                    if data.charts < 50 then
                        value:diffuse(ModernUI.Tokens.TextDim)
                    end
                else
                    -- No profile, no scores, or the walk failed. Hide the chip
                    -- instead of showing a placeholder: the value font is
                    -- digits only and would render nothing useful anyway.
                    self:visible(false)
                end
            end,

            ModernUI.GradeBadge {
                name = "PumbilityBadge",
                w = 172, h = 64,
                label = "PUMBILITY",
                font = "Montserrat numbers 40px",
                zoom = 0.7,
            },
        } or Def.Actor {},

        Def.ActorFrame {
            InitCommand=function(self)
                self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y)
                :easeoutexpo(1):y(SCREEN_CENTER_Y - 11)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1)
                :y(-SCREEN_CENTER_Y - 100)
            end,

            StepsChosenMessageCommand=function(self, params)
                if params.Player == pn then
                    self:stoptweening():easeoutexpo(0.5)
                    :x(SCREEN_CENTER_X + (pn == PLAYER_2 and 380 or -380))
                end
            end,
            CurrentChartChangedMessageCommand=function(self, params)
                if params.Player == pn then
                    self:stoptweening():easeoutexpo(0.5):x(SCREEN_CENTER_X)
                end
            end,
            StepsUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):x(SCREEN_CENTER_X)
            end,
            SongUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):x(SCREEN_CENTER_X)
            end,

            Def.Quad {
                InitCommand=function(self)
                    self:zoomto(128, 32):diffuse(Color.White)

                    if pn == PLAYER_2 then
                        self:diffuserightedge(Color.Invisible)
                    else
                        self:diffuseleftedge(Color.Invisible)
                    end
                end
            },

            Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Ready" .. ToEnumShortString(pn)),
                InitCommand=function(self) self:y(1) end
            }
        }
  }
end

t[#t+1] = Def.ActorFrame {
    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y):zoom(0.5)
            :easeoutexpo(1):y(SCREEN_CENTER_Y)
        end,
        OffCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(-SCREEN_CENTER_Y)
        end,
        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y + 95):zoom(1)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.25):y(SCREEN_CENTER_Y):zoom(0.5)
        end,

        Def.Sprite {
            Texture=THEME:GetPathG("", "DifficultyDisplay/InfoPanel"),
            InitCommand=function(self) self:y(85):zoom(0.75) end
        },

        LoadActor("ChartInfo")
    }
}

t[#t+1] = Def.ActorFrame {
    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y)
            :easeoutexpo(1):y(SCREEN_CENTER_Y)
        end,
        OffCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(-SCREEN_CENTER_Y)
        end,

        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y-40):zoom(0.9)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y):zoom(1)
        end,

        LoadActor("ScoreDisplay") .. {
            InitCommand=function(self) self:y(-100) end
        },
        
        LoadActor("PadIcons") .. {
            InitCommand=function(self) self:y(24) end
        },

        LoadActor("SongPreview") .. {
            InitCommand=function(self) self:y(-100) end
        },
        
        Def.ActorFrame {
            InitCommand=function(self) self:y(85) end,

            SongChosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):y(94):zoom(1.25)
            end,
            SongUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):y(85):zoom(1)
            end,            

            Def.Sprite {
                Texture=THEME:GetPathG("", "DifficultyDisplay/Bar"),
                InitCommand=function(self) self:zoom(1.2) end
            },

            LoadActor("BigPreviewBall")..{
              Condition = (LoadModule("Config.Load.lua")("ShowBigBall", "Save/OutFoxPrefs.ini") and GetScreenAspectRatio() >= 1.5)
            },

            LoadActor("ChartDisplay", 12)
        }
    }
}

return t

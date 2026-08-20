-- Background router.
--   aurora  -> new procedural Modern UI background
--   video   -> original pre-rendered _Background.mp4
--   classic -> original Graphics/Background actor
if ModernUI and ModernUI.UseAurora() then
    return LoadActor(THEME:GetPathB("", "ModernBackground"))
end

if IsVideoBackground or (ModernUI and ModernUI.Config.Style == "video") then
    local t = Def.ActorFrame {
        Def.Sprite {
            Texture=THEME:GetPathG("", "_Background.mp4"),
            InitCommand=function(self)
                self:scaletocover(0, 0, SCREEN_RIGHT, SCREEN_BOTTOM):Center()
            end
        },

        -- Stop looking at the code this is supposed to be a surprise >:(
        LoadActor(THEME:GetPathG("", "Background/confetti"))..{
            Condition=IsAnniversary()
        }
    }
    return t
else
    return LoadActor(THEME:GetPathG("", "Background"))
end

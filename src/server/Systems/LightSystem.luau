--!native
--!optimize 2

--[ SERVICES ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--[ TYPES ]--
type LightOptions = "Chamber" | "Control" | "Backup"

type LightDetails = {
	Color: string,
	State: string,
	Folder: Folder,
	MaxDelay: number,
}

--[ OUR MAIN MODULE FOR THE LIGHT SYSTEM ]--
local LightSystem = {}

--[ GAME FOLDERS ]--
local GameFolder = game.Workspace.Game

--[ COLOR CONSTANTS ]--
local COLOR_BLACK = Color3.new(0, 0, 0)
local COLOR_WHITE = Color3.new(1, 1, 1)

--[ SOUND CONSTANTS ]--
local TOGGLE_ON_SOUND = ReplicatedStorage.SharedAssets.Audio.Light.ToggleOn
local TOGGLE_OFF_SOUND = ReplicatedStorage.SharedAssets.Audio.Light.ToggleOff
local FLICKER_SOUND = ReplicatedStorage.SharedAssets.Audio.Light.Flicker

--[ OTHER INSTANCES ]--
local RandomInst = Random.new()

--[ INFORMATION FOR EACH LIGHT TOGGLE THING IDK WHAT TO CALL IT ]--
--[ ALSO, PREFERABLY DO NOT CHANGE "STATE" AND "COLOR" FOR ANY OF THEM ]--
local ToggleDetails: { [LightOptions]: LightDetails } = {
	Chamber = {
		State = "ChamberLightState",
		Color = "ChamberLightColor",
		Folder = GameFolder.ChamberLights,
		MaxDelay = 2,
	},

	Control = {
		State = "ControlLightState",
		Color = "ControlLightColor",
		Folder = GameFolder.ControlRoomLights,
		MaxDelay = 1,
	},

	Backup = {
		State = "BackupLightState",
		Color = "BackupLightColor",
		Folder = GameFolder.BackupLights,
		MaxDelay = 1,
	},
}

--[ LOCAL FUNCTIONS ]--
local function ToggleLightEffects(part: BasePart, color: Color3, sound: Sound, state: boolean)
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	-- TODO: CAMERA SHAKE!

	part.Color = color

	for index, light in ipairs(part:GetDescendants()) do
		if light:IsA("Light") then
			light.Enabled = state
		elseif light:IsA("ParticleEmitter") then
			light.Enabled = true
		end
	end
end

--[ FUNCTIONS ]--
function LightSystem.ToggeLights(state: boolean, light_type: LightOptions)
	if ToggleDetails[light_type] == nil then
		warn("That's not a valid light type!")
		return
	end

	local LightType = ToggleDetails[light_type]

	if state == GameFolder:GetAttribute(LightType.State) then
		return
	end

	GameFolder:SetAttribute(LightType.State, state)

	-- DECLARING VARIABLES EARLY
	local Color: Color3
	local Sound: Sound

	if state == true then
		Color = GameFolder:GetAttribute(LightType.Color)
		Sound = TOGGLE_ON_SOUND:Clone()
	else
		Color = COLOR_BLACK
		Sound = TOGGLE_OFF_SOUND:Clone()
	end

	for index, lightpart in ipairs(LightType.Folder:GetChildren()) do
		task.delay(RandomInst:NextNumber(0, LightType.MaxDelay), ToggleLightEffects, lightpart, Color, Sound, state)
	end
end

function LightSystem.CreateGlow(brightness: number, color: Color3, lifetime: number)
	local ColorCorrection = Instance.new("ColorCorrectionEffect")

	ColorCorrection.Brightness = brightness
	ColorCorrection.TintColor = color

	local GlowTweenInfo = TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local GlowTween = TweenService:Create(ColorCorrection, GlowTweenInfo, { Brightness = 0, TintColor = COLOR_WHITE })

    GlowTween:Play()

    GlowTween.Completed:Connect(function()
        ColorCorrection:Destroy()
    end)
end

return LightSystem

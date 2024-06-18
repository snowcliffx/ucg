--!strict
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
	MaxToggleDelay: number,
    MaxFlickerDelay: number,
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

--[ INFORMATION FOR EACH LIGHT TOGGLE ]--
--[ PREFERABLY DO NOT CHANGE "STATE" AND "COLOR" FOR ANY OF THEM ]--
local ToggleDetails: { [LightOptions]: LightDetails } = {
	Chamber = {
		State = "ChamberLightState",
		Color = "ChamberLightColor",
		Folder = GameFolder.ChamberLights,
		MaxToggleDelay = 2,
        MaxFlickerDelay = 0.5
	},

	Control = {
		State = "ControlLightState",
		Color = "ControlLightColor",
		Folder = GameFolder.ControlRoomLights,
		MaxToggleDelay = 1, -- TOGGLE
        MaxFlickerDelay = 0.5
	},

	Backup = {
		State = "BackupLightState",
		Color = "BackupLightColor",
		Folder = GameFolder.BackupLights,
		MaxToggleDelay = 1, -- TOGGLE
        MaxFlickerDelay = 0.5
	},
}

--[ LOCAL FUNCTIONS ]--
local function ToggleLightEffects(lightpart: BasePart, color: Color3, sound: Sound, state: boolean)
	sound.Parent = lightpart

    sound.Ended:Connect(function()
		sound:Destroy()
	end)

	sound:Play()

	-- TODO: CAMERA SHAKE!

	lightpart.Color = color

	for index, light in ipairs(lightpart:GetDescendants()) do
		if light:IsA("Light") then
			light.Enabled = state
		elseif light:IsA("ParticleEmitter") then
			light.Enabled = state
		end
	end
end

local function FlickerLightEffects(lightpart: BasePart, max_delay, after_color)
    ToggleLightEffects(lightpart, COLOR_BLACK, FLICKER_SOUND:Clone(), false)
    task.wait(RandomInst:NextNumber(0, max_delay))
    ToggleLightEffects(lightpart, after_color, FLICKER_SOUND:Clone(), true)
end

--[ FUNCTIONS ]--
function LightSystem.ToggeLights(light_type: LightOptions, state: boolean)
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
        if lightpart:IsA("BasePart") then
            task.delay(RandomInst:NextNumber(0, LightType.MaxToggleDelay), ToggleLightEffects, lightpart, Color, Sound, state)
        end
	end
end

function LightSystem.FlickerLights(light_type: LightOptions)
	if ToggleDetails[light_type] == nil then
		warn("That's not a valid light type!")
		return
	end

	local LightType = ToggleDetails[light_type]

    local MaxFlickerDelay = LightType.MaxFlickerDelay
    local AfterFlickerColor = GameFolder:GetAttribute(LightType.Color)

	for count = 1, 3 do
		for index, lightpart in ipairs(LightType.Folder:GetChildren()) do
            if lightpart:IsA("BasePart") then
                task.delay(RandomInst:NextNumber(0, MaxFlickerDelay), FlickerLightEffects, lightpart, MaxFlickerDelay, AfterFlickerColor)
            end
		end
	end
end

function LightSystem.CreateGlow(brightness: number, color: Color3, lifetime: number)
	local ColorCorrection = Instance.new("ColorCorrectionEffect")

	ColorCorrection.Brightness = brightness
	ColorCorrection.TintColor = color

    ColorCorrection.Parent = game.Lighting

	local GlowTweenInfo = TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local GlowTween = TweenService:Create(ColorCorrection, GlowTweenInfo, { Brightness = 0, TintColor = COLOR_WHITE })

    GlowTween.Completed:Connect(function()
		ColorCorrection:Destroy()
	end)

	GlowTween:Play()
end

return LightSystem

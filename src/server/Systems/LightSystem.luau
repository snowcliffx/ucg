--!strict
--!native
--!optimize 2

--[[
	DISCLAIMER:
	I WAS ABLE TO USE STRICT TYPECHECKING IN THIS ONE UNLIKE LASERSYSTEM.
	THE LOCATIONS OF ATTRIBUTES ARE SUBJECT TO CHANGE, AND SO IS THE "TOGGLEDETAILS" TABLE.
]]

--[ SERVICES ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--[ TYPES ]--
type LightOptions = "Chamber" | "Control" | "Backup"

type LightDetails = {
	Folder: Folder,
	MaxToggleDelay: number,
	MaxFlickerDelay: number,
}

--[ OUR MAIN MODULE FOR THE LIGHT SYSTEM ]--
local LightSystem = {}

--[ GAME FOLDER ]--
local GameFolder = game.Workspace.Game

--[ COLOR CONSTANTS ]--
local BLACK_COLOR = Color3.new(0, 0, 0)
local WHITE_COLOR = Color3.new(1, 1, 1)

--[ SOUNDS ]--
local ToggleOnSound = ReplicatedStorage.SharedAssets.Audio.Light.ToggleOn
local ToggleOffSound = ReplicatedStorage.SharedAssets.Audio.Light.ToggleOff
local FlickerSound = ReplicatedStorage.SharedAssets.Audio.Light.Flicker

--[ OTHER INSTANCES ]--
local RandomInst = Random.new()

--[ INFORMATION FOR EACH LIGHT TOGGLE ]--
local ToggleDetails: { [LightOptions]: LightDetails } = {
	Chamber = {
		Folder = GameFolder.ChamberLights,
		MaxToggleDelay = 2,
		MaxFlickerDelay = 0.5,
	},

	Control = {
		Folder = GameFolder.ControlRoomLights,
		MaxToggleDelay = 1, -- TOGGLE
		MaxFlickerDelay = 0.5,
	},

	Backup = {
		Folder = GameFolder.BackupLights,
		MaxToggleDelay = 1, -- TOGGLE
		MaxFlickerDelay = 0.5,
	},
}

--[ LOCAL FUNCTIONS ]--
local function ToggleLightEffects(lightpart: BasePart, color: Color3, sound: Sound, state: boolean)
	sound.Parent = lightpart

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	sound:Play()

	--// TODO Camera Shake

	lightpart.Color = color

	for index, light in ipairs(lightpart:GetDescendants()) do
		if light:IsA("Light") then
			light.Enabled = state
		elseif light:IsA("ParticleEmitter") then
			light.Enabled = state
		end
	end
end

local function FlickerLightEffects(lightpart: BasePart, max_delay, color1, color2, curr_state)
	ToggleLightEffects(lightpart, color1, FlickerSound:Clone(), not curr_state)
	task.wait(RandomInst:NextNumber(0, max_delay))
	ToggleLightEffects(lightpart, color2, FlickerSound:Clone(), curr_state)
end

--[ FUNCTIONS ]--
function LightSystem.ToggleLights(light_type: LightOptions, state: boolean)
	if ToggleDetails[light_type] == nil then
		warn("That's not a valid light type!")
		return
	end

	local LightType = ToggleDetails[light_type]
	local LightFolder = LightType.Folder

	if state == LightFolder:GetAttribute("LightState") then
		return
	end

	LightFolder:SetAttribute("LightState", state)

	-- DECLARING VARIABLES EARLY
	local Color: Color3
	local Sound: Sound

	if state == true then
		Color = LightFolder:GetAttribute("LightColor")
		Sound = ToggleOnSound:Clone()
	else
		Color = BLACK_COLOR
		Sound = ToggleOffSound:Clone()
	end

	for index, lightpart in ipairs(LightType.Folder:GetChildren()) do
		if lightpart:IsA("BasePart") then
			task.delay(RandomInst:NextNumber(0, LightType.MaxToggleDelay), ToggleLightEffects, lightpart, Color, Sound, state)
		end
	end
end

function LightSystem.FlickerLights(light_type: LightOptions, curr_state: boolean)
	if ToggleDetails[light_type] == nil then
		warn("That's not a valid light type!")
		return
	end

	local LightType = ToggleDetails[light_type]
	local LightFolder = LightType.Folder

	local MaxFlickerDelay = LightType.MaxFlickerDelay
	local NormalColor = LightFolder:GetAttribute("LightColor")

	local Color1: Color3
	local Color2: Color3

	if curr_state == true then
		Color1 = BLACK_COLOR
		Color2 = NormalColor
	else
		Color1 = NormalColor
		Color2 = BLACK_COLOR
	end

	for count = 1, 3 do
		for index, lightpart in ipairs(LightType.Folder:GetChildren()) do
			if lightpart:IsA("BasePart") then
				task.delay(RandomInst:NextNumber(0, MaxFlickerDelay), FlickerLightEffects, lightpart, MaxFlickerDelay, Color1, Color2, curr_state)
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
	local GlowTween = TweenService:Create(ColorCorrection, GlowTweenInfo, { Brightness = 0, TintColor = WHITE_COLOR })

	GlowTween.Completed:Connect(function()
		ColorCorrection:Destroy()
	end)

	GlowTween:Play()
end

return LightSystem

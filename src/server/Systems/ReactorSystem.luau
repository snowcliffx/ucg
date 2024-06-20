--!strict
--!native
--!optimize 2

--[ SERVICES ]--
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

--[ MODULES ]--
local LaserSystem = require(ServerScriptService.Systems.LaserSystem)
local LightSystem = require(ServerScriptService.Systems.LightSystem)
local ShieldSystem = require(ServerScriptService.Systems.ShieldSystem)

--[ OUR MAIN MODULE FOR THE REACTOR SYSTEM]
local ReactorSystem = {}

--[ GAME FOLDERS ]--
local GameFolder = game.Workspace.Game
local LaserStorage = GameFolder.Lasers
local ReactorStorage = GameFolder.Reactor

--[ COLOR CONSTANTS ]--
local GLOW_COLOR = Color3.fromRGB(185, 65, 255)

--[ TWEEN CONSTANTS ]--
local RETRACT_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local EXTEND_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
local SHOCKWAVE_TWEEN = TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local SHOCKWAVE_PROPERTIES = { Size = Vector3.new(400, 400, 400), Transparency = 1 }

--[ FUNCTIONS ]--
function ReactorSystem.ShockWave(flicker: boolean)
	ReactorStorage.Shockwave:Play()
	task.wait(1)
	-- TOOD: CAMERA SHAKE

	ReactorStorage.Main.Shockwave.Main:Emit(250)
	ReactorStorage.Main.Shockwave.Particles:Emit(250)

	local NewWave = ServerStorage.ServerAssets.Parts.ShockWave:Clone()
	NewWave.Parent = game.Workspace

	TweenService:Create(NewWave, SHOCKWAVE_TWEEN, SHOCKWAVE_PROPERTIES):Play()

	if flicker == true then
		LightSystem.FlickerLights("Chamber", GameFolder:GetAttribute("ChamberLightState"))
		LightSystem.FlickerLights("Control", GameFolder:GetAttribute("ControlLightState"))
	end
end

function ReactorSystem.Initialize()
	--//TODO ANNOUNCE

	GameFolder:SetAttribute("ReactorStatus", "STARTUP INITIATE")

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.PrimeLaser(laser)
	end

	task.wait(5)

	GameFolder.Reactor.ChamberParticles.Idle.Enabled = true

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.ToggleVents(laser, true)
		task.delay(3, function()
			laser.Mechanics.LaserTopBeam.LaserFireStartup:Play()
		end)
	end

	GameFolder:SetAttribute("ReactorStatus", "PRIMING REACTOR CONTAINMENT")
	ShieldSystem.InitializeShield()

	task.wait(10)

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.ToggleVents(laser, false)
	end

	task.wait(2)

	GameFolder:SetAttribute("ReactorStatus", "INITIATING LASERS")

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.ToggleBottomCharge(laser, true)
	end

	LightSystem.ToggleLights("Chamber", false)
	LightSystem.ToggleLights("Control", false)

	task.wait(4)

	--//TODO CAMERA SHAKE

	GameFolder:SetAttribute("ReactorPower", 5)
	GameFolder:SetAttribute("ReactorStatus", "CREATING NUCLEAR REACTION")

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.ToggleBottomCharge(laser, false)
	end

	LightSystem.CreateGlow(0.5, GLOW_COLOR, 2)

	ReactorStorage.Main.StartupShockwave:Play()
	ReactorStorage.ChamberParticles.Core1.Enabled = true
	ReactorStorage.Main.Idle1:Play()
	ReactorStorage.Main.PointLight.Enabled = true

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.ToggleLaser(laser, true)
	end

	for index, particle in ipairs(ReactorStorage.Main.Charge:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end

	task.wait(1)

	ReactorSystem.ShockWave(true)

	GameFolder:SetAttribute("ReactorPower", 10)

	LightSystem.CreateGlow(1, GLOW_COLOR, 2)

	for index, particle in ipairs(ReactorStorage.Main.Charge:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = false
		end
	end

	ReactorStorage.Main.Ignite.Electricity:Emit(10)
	ReactorStorage.Main.Ignite.Ignite1:Emit(100)
	ReactorStorage.Main.Ignite.Ignite2:Emit(10)
	ReactorStorage.Main.Ignite.Ignite3.Enabled = true

	for index, particle in ipairs(ReactorStorage.Main.Idle:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.RetractLaser(laser, 10, RETRACT_TWEEN)
	end

	task.wait(1)

	for index, laser in ipairs(LaserStorage:GetChildren()) do
		LaserSystem.ExtendLaser(laser, 12, EXTEND_TWEEN)
	end

	task.wait(5)

	--//TODO CAMERA SHAKE

	GameFolder:SetAttribute("ReactorPower", 1)
	GameFolder:SetAttribute("CoolantPower", 1)
	GameFolder:SetAttribute("ReactorStatus", "RE-CONTAINING REACTOR")

	ReactorStorage.Main.Ignite.Ignite3.Enabled = false

	task.wait(5)

	GameFolder:SetAttribute("ReactorStatus", "STARTUP SUCCESS")

	--//TODO ANNOUNCE

	GameFolder:SetAttribute("ControlsEnabled", true)
	LightSystem.ToggleLights("Chamber", true)
	LightSystem.ToggleLights("Control", true)

	task.wait(5)

	GameFolder:SetAttribute("Online", true)
	GameFolder:SetAttribute("ReactorStatus", "ONLINE")
end

return ReactorSystem

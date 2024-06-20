--[ SERVICES ]--
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

--[ MODULES ]--
local LightSystem = require(ServerScriptService.Systems.LightSystem)
local ShieldSystem = require(ServerScriptService.Systems.ShieldSystem)
local ReactorSystem = require(ServerScriptService.Systems.ReactorSystem)

--[ GAME FOLDER ]--
local GameFolder = game.Workspace.Game

--[ MAIN STARTUP BUTTON ]--
local StartupButton = GameFolder.Controls.StartupButton
local GlassHinge = StartupButton.Glass.Hinge

--[ PRIME BUTTON ]--
local PrimeButton = StartupButton.PrimeButton
local PrimeLight = PrimeButton.Parent.PrimeLight
local PrimeClickDetector = PrimeButton.ClickDetector

--[ INITIALIZE BUTTON ]--
local InitializeButton = GameFolder.Controls.StartupButton.InitializeButton
local InitializeClickDetector = InitializeButton.ClickDetector

--[ STATUS-SCREEN ]--
local StatusScreen = GameFolder.Controls.StatusScreen

--[ TWEEN CONSTANTS ]--
local GLASS_HINGE_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local BUTTON_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true)

--[ VECTOR CONSTANTS ]--
local BUTTON_PUSH = Vector3.new(0, 0.015, 0)

--[ MAIN EVENT ]--
PrimeClickDetector.MouseClick:Connect(function(player: Player)
	if PrimeButton:GetAttribute("Enabled") == false or GameFolder:GetAttribute("ControlsEnabled") == false then
		return
	end

	print(player.Name .. " has primed the reactor!")
	PrimeButton:SetAttribute("Enabled", false)
	PrimeClickDetector.MaxActivationDistance = 0

	PrimeButton.Click:Play()
	TweenService:Create(PrimeButton, BUTTON_TWEEN, { Position = PrimeButton.Position - BUTTON_PUSH }):Play()

	PrimeLight.Color = Color3.fromRGB(255, 205, 45)
	PrimeLight.PointLight.Color = Color3.fromRGB(255, 185, 35)

	StatusScreen.NoSignal.Status2.Box2.BootBar.Frame:TweenSize(UDim2.fromScale(1, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 3)

	--// TODO ANNOUNCE

	task.wait(5)
	StatusScreen.NoSignal.Enabled = false
	task.wait(1)
	StatusScreen.MainScreen.Enabled = true

	ShieldSystem.ToggleBlastShield(true)

	--// TODO INFORMATION STUFF

	task.wait(3)
	LightSystem.ToggleLights("Chamber", true)
	task.wait(5)

	PrimeLight.Color = Color3.fromRGB(165, 255, 165)
	PrimeLight.PointLight.Color = Color3.fromRGB(0, 255, 0)

	TweenService:Create(GlassHinge, GLASS_HINGE_TWEEN, { CFrame = GlassHinge.CFrame * CFrame.Angles(0, math.rad(110), 0) }):Play()

	InitializeButton:SetAttribute("Enabled", true)
	InitializeClickDetector.MaxActivationDistance = 32
end)

InitializeClickDetector.MouseClick:Connect(function(player: Player)
	if InitializeButton:GetAttribute("Enabled") == false or GameFolder:GetAttribute("ControlsEnabled") == false then
		return
	end

	print(player.Name .. " has initialized the reactor!")
	InitializeButton:SetAttribute("Enabled", false)
	InitializeClickDetector.MaxActivationDistance = 0

	InitializeButton.Click:Play()
	TweenService:Create(InitializeButton, BUTTON_TWEEN, { Position = InitializeButton.Position - BUTTON_PUSH}):Play()

	--// TODO ANNOUNCE

	--// TODO INFORMATION STUFF

	TweenService:Create(GlassHinge, GLASS_HINGE_TWEEN, { CFrame = GlassHinge.CFrame * CFrame.Angles(0, math.rad(-110), 0)})
	ReactorSystem.Initialize()
end)

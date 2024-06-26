--[ SERVICES ]--
local TweenService = game:GetService("TweenService")

--[ GAME FOLDER ]--
local GameFolder = game.Workspace.Game

--[ SCREENS ]--
local StatusScreen = GameFolder.Controls.StatusScreen
local MainScreen = StatusScreen.MainScreen

--[ PROPERTIES ]--
local CoolingProperties = MainScreen.MainFrame.CoolingProperties
local PowerProperties = MainScreen.MainFrame.PowerProperties
local ReactorProperties = MainScreen.MainFrame.ReactorProperties
local ShieldProperties = MainScreen.MainFrame.ShieldProperties

--[ TWEEN CONSTANTS ]--
local QUAD_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

--[ VARIABLES ]--
local LowIntegrity = false
local HighPower = false

--[ TWEENS FOR EACH INTEGRITY/POWER STATE ]--
local IntegrityTweens = {
	LowIntegrity = {
		TweenService:Create(ShieldProperties.Integrity.IntegrityBar, QUAD_TWEEN, { BackgroundColor3 = Color3.fromRGB(83, 0, 0) }),
		TweenService:Create(ShieldProperties.Integrity.IntegrityBar.FillBar, QUAD_TWEEN, { BackgroundColor3 = Color3.fromRGB(255, 0, 0) }),
		TweenService:Create(ShieldProperties.Integrity.Title, QUAD_TWEEN, { TextColor3 = Color3.fromRGB(198, 0, 0) }),
		TweenService:Create(ShieldProperties.Integrity.IntegrityBar.UIStroke, QUAD_TWEEN, { Color = Color3.fromRGB(177, 0, 0) }),
	},

	HighIntegrity = {
		TweenService:Create(ShieldProperties.Integrity.IntegrityBar, QUAD_TWEEN, { BackgroundColor3 = Color3.fromRGB(61, 61, 61) }),
		TweenService:Create(ShieldProperties.Integrity.IntegrityBar.FillBar, QUAD_TWEEN, { BackgroundColor3 = Color3.fromRGB(0, 127, 0) }),
		TweenService:Create(ShieldProperties.Integrity.Title, QUAD_TWEEN, { TextColor3 = Color3.fromRGB(195, 195, 195) }),
		TweenService:Create(ShieldProperties.Integrity.IntegrityBar.UIStroke, QUAD_TWEEN, { Color = Color3.fromRGB(112, 112, 112) }),
	},
}

local PowerTweens = {
	HighPower = {
		TweenService:Create(PowerProperties.Power.PowerBar, QUAD_TWEEN, { BackgroundColor3 = Color3.fromRGB(83, 0, 0) }),
		TweenService:Create(PowerProperties.Power.PowerBar.PowerValue, QUAD_TWEEN, { TextColor3 = Color3.fromRGB(198, 0, 0) }),
		TweenService:Create(PowerProperties.Power.PowerBar.UIStroke, QUAD_TWEEN, { Color = Color3.fromRGB(177, 0, 0) }),
	},

	LowPower = {
		TweenService:Create(PowerProperties.Power.PowerBar, QUAD_TWEEN, { BackgroundColor3 = Color3.fromRGB(61, 61, 61) }),
		TweenService:Create(PowerProperties.Power.PowerBar.PowerValue, QUAD_TWEEN, { TextColor3 = Color3.fromRGB(195, 195, 195) }),
		TweenService:Create(PowerProperties.Power.PowerBar.UIStroke, QUAD_TWEEN, { Color = Color3.fromRGB(112, 112, 112) }),
	},
}

--[ UPDATING VALUES ]--
GameFolder:GetAttributeChangedSignal("CoreTemperature"):Connect(function()
	local value: number = GameFolder:GetAttribute("CoreTemperature")
	print(value)

	ReactorProperties.Temperature.TemperatureBar.TemperatureValue.Text = value .. "°C"
end)

GameFolder:GetAttributeChangedSignal("ReactorStatus"):Connect(function()
	local value: string = GameFolder:GetAttribute("ReactorStatus")

	ReactorProperties.Status.StatusBar.Information.Text = value
end)

GameFolder:GetAttributeChangedSignal("ShieldIntegrity"):Connect(function()
	local value: number = GameFolder:GetAttribute("ShieldIntegrity")

	ShieldProperties.Integrity.Title.Text = "Shield Integrity: " .. math.round(value) .. "%"
	ShieldProperties.Integrity.IntegrityBar.FillBar:TweenSize(UDim2.fromScale(value / 100, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5)

	if value <= 35 and LowIntegrity == false then
		LowIntegrity = true

		for index, tween in IntegrityTweens.LowIntegrity do
			tween:Play()
		end
	elseif value > 35 and LowIntegrity == true then
		LowIntegrity = false

		for index, tween in IntegrityTweens.HighIntegrity do
			tween:Play()
		end
	end
end)

GameFolder:GetAttributeChangedSignal("ShieldTemperature"):Connect(function()
	local value: number = GameFolder:GetAttribute("ShieldTemperature")

	ShieldProperties.Temperature.TemperatureBar.TemperatureValue.Text = value .. "°C"
end)

GameFolder:GetAttributeChangedSignal("ReactorPower"):Connect(function()
	local value: number = GameFolder:GetAttribute("ReactorPower")

	PowerProperties.Power.PowerBar.PowerValue.Text = value

	if value >= 5 and HighPower == false then
		HighPower = true

		for index, tween in PowerTweens.HighPower do
			tween:Play()
		end
	elseif value < 5 and HighPower == true then
		HighPower = false

		for index, tween in PowerTweens.LowPower do
			tween:Play()
		end
	end
end)

GameFolder:GetAttributeChangedSignal("CoolantPower"):Connect(function()
	local value: number = GameFolder:GetAttribute("CoolantPower")

	CoolingProperties.Coolant.CoolantBar.CoolantValue.Text = value
end)

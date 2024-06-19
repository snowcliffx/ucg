local TweenService = game:GetService("TweenService")

local GameFolder = game.Workspace.Game

local StatusScreen = GameFolder.Controls.StatusScreen
local MainScreen = StatusScreen.MainScreen

local CoolingProperties = MainScreen.MainFrame.CoolingProperties
local PowerProperties = MainScreen.MainFrame.PowerProperties
local ReactorProperties = MainScreen.MainFrame.ReactorProperties
local ShieldProperties = MainScreen.MainFrame.ShieldProperties

local QUAD_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local LowIntegrity = false
local HighIntegrity = false

GameFolder:GetAttributeChangedSignal("CoreTemperature"):Connect(function(value: number)
    ReactorProperties.Temperature.tempBar.TextLabel.Text = value .. "°C"
end)

GameFolder:GetAttributeChangedSignal("ReactorStatus"):Connect(function(value: string)
    ReactorProperties.Status.tempBar.TextLabel.Text = value
end)

GameFolder:GetAttributeChangedSignal("ShieldIntegrity"):Connect(function(value: number)
    ShieldProperties.Integrity.TextLabel.Text = "Shield Integrity: "..math.round(value) .. "%"
    ShieldProperties.Integrity.IntegBar.Frame:TweenSize(UDim2.fromScale(value/100, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5)

    if value <= 35 and LowIntegrity == false then
        LowIntegrity = true

        TweenService:Create(ShieldProperties.Integrity.IntegBar, QUAD_TWEEN, {BackgroundColor3 = Color3.fromRGB(83, 0, 0)}):Play()
	    TweenService:Create(ShieldProperties.Integrity.IntegBar.Frame, QUAD_TWEEN, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
	    TweenService:Create(ShieldProperties.Integrity.IntegBar.UIStroke, QUAD_TWEEN, {Color = Color3.fromRGB(177, 0, 0)}):Play()
	    TweenService:Create(ShieldProperties.Integrity.TextLabel, QUAD_TWEEN, {TextColor3 = Color3.fromRGB(198, 0, 0)}):Play()
    elseif value > 35 and LowIntegrity == true then
        
    end
end)

GameFolder:GetAttributeChangedSignal("ShieldTemperature"):Connect(function(value: number)
    ShieldProperties.Integrity.TextLabel.Text = value .. "°C"
end)

GameFolder:GetAttributeChangedSignal("ReactorPower"):Connect(function(value: number)
    PowerProperties.Status.tempBar.TextLabel.Text = value
end)

GameFolder:GetAttributeChangedSignal("CoolantPower"):Connect(function(value: number)
    CoolingProperties.Status.tempBar.TextLabel.Text = value
end)

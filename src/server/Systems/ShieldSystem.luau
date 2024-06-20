--!strict
--!native
--!optimize 2

--[ SERVICES ]--
local TweenService = game:GetService("TweenService")

--[ OUR MAIN MODULE FOR THE SHIELD SYSTEM ]--
local ShieldSystem = {}

--[ GAME FOLDERS ]--
local GameFolder = game.Workspace.Game
local BlastShield = GameFolder.Controls.BlastShield
local ReactorStorage = GameFolder.Reactor

--[ TWEEN CONSTANTS ]--
local _LINEAR_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Linear)
local BLAST_SHIELD_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local DEFAULT_SHIELD_TWEEN = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, nil, false, 3)

--[ VECTOR CONSTANTS ]--
local POSITION_DELTA = Vector3.new(0, 15, 0)

--[ VARIABLES ]--
local ToggleDebounce = false

function ShieldSystem.InitializeShield()
	task.spawn(function()
		for count = 1, 10 do
			task.wait(1)
			GameFolder:SetAttribute("ShieldIntegrity", GameFolder:GetAttribute("ShieldIntegrity") + 10)
		end
	end)

	TweenService:Create(ReactorStorage.Shield, DEFAULT_SHIELD_TWEEN, { Transparency = -1 }):Play()
end

function ShieldSystem.ToggleBlastShield(state: boolean)
	if state == GameFolder:GetAttribute("ShieldState") or GameFolder:GetAttribute("ShieldDestroyed") == true or ToggleDebounce == true then
		return
	end

	ToggleDebounce = true
	GameFolder:SetAttribute("ShieldState", state)

	local PosSign = state and POSITION_DELTA or -POSITION_DELTA

	local ShieldTween = TweenService:Create(BlastShield, BLAST_SHIELD_TWEEN, { Position = BlastShield.Position + PosSign })

	ShieldTween.Completed:Connect(function()
		ToggleDebounce = false
	end)

	ShieldTween:Play()

	for index, part in ipairs(BlastShield:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, BLAST_SHIELD_TWEEN, { Position = part.Position + PosSign }):Play()
		end
	end
end

function ShieldSystem.DestroyBlastShield()
	if GameFolder:GetAttribute("ShieldDestroyed") == true then
		return
	end

	GameFolder:SetAttribute("ShieldDestroyed", true)

	ReactorStorage.Main.Beam.Main.Enabled = true
	ReactorStorage.Main.Beam.Main2.Enabled = true
	ReactorStorage.Main.Beam.Particles2.Enabled = true
end

return ShieldSystem

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

--[ TWEEN CONSTANTS ]--
local SHIELD_TWEEN_INFO = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

--[ VECTOR CONSTANTS ]--
local POSITION_DELTA = Vector3.new(0, 15, 0)

--[ VARIABLES ]--
local ToggleDebounce = false

function ShieldSystem.ToggleBlastShield(state: boolean)
	if state == GameFolder:GetAttribute("ShieldState") or ToggleDebounce == true then
		return
	end

	ToggleDebounce = true
	GameFolder:SetAttribute("ShieldState", state)

	local PosSign = state and POSITION_DELTA or -POSITION_DELTA

	local ShieldTween = TweenService:Create(BlastShield, SHIELD_TWEEN_INFO, { Position = BlastShield.Position + PosSign })

	ShieldTween.Completed:Connect(function()
		ToggleDebounce = false
	end)

	ShieldTween:Play()

	for index, part in ipairs(BlastShield:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, SHIELD_TWEEN_INFO, { Position = part.Position + PosSign }):Play()
		end
	end
end

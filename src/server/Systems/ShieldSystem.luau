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
local NormalShield = ReactorStorage.Shield

--[ TWEEN CONSTANTS ]--
local LINEAR_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Linear)
local BEAM_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local BLAST_SHIELD_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local NORMAL_SHIELD_TWEEN = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 3)

--[ VECTOR CONSTANTS ]--
local POSITION_DELTA = Vector3.new(0, 15, 0)

--[ BRIGHTNESS CONSTANTS ]--
local ZERO_BRIGHTNESS = { Brightness = 0 }

--[ VARIABLES ]--
local ToggleDebounce = false

--[ FUNCTIONS ]--
function ShieldSystem.InitializeShield()
	task.spawn(function()
		for count = 1, 10 do
			task.wait(1)
			GameFolder:SetAttribute("ShieldIntegrity", GameFolder:GetAttribute("ShieldIntegrity") + 10)
		end
	end)

	TweenService:Create(NormalShield, NORMAL_SHIELD_TWEEN, { Transparency = -1 }):Play()
end

function ShieldSystem.ToggleBlastShield(state: boolean)
	if state == GameFolder:GetAttribute("BlastShieldState") or GameFolder:GetAttribute("BlastShieldDestroyed") == true or ToggleDebounce == true then
		return
	end

	ToggleDebounce = true
	GameFolder:SetAttribute("BlastShieldState", state)

	local PosSign = state and POSITION_DELTA or -POSITION_DELTA

	local ShieldTween = TweenService:Create(BlastShield, BLAST_SHIELD_TWEEN, { Position = BlastShield.Position + PosSign })

	ShieldTween.Completed:Connect(function()
		ToggleDebounce = false
	end)

	ShieldTween:Play()

	for index, part in ipairs(BlastShield.Parts:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, BLAST_SHIELD_TWEEN, { Position = part.Position + PosSign }):Play()
		end
	end
end

function ShieldSystem.DestroyBlastShield()
	if GameFolder:GetAttribute("BlastShieldDestroyed") == true then
		return
	end

	GameFolder:SetAttribute("BlastShieldDestroyed", true)

	ReactorStorage.Main.Beam.Main.Enabled = true
	ReactorStorage.Main.Beam.Main2.Enabled = true
	ReactorStorage.Main.Beam.Particles2.Enabled = true

	local BeamTween = TweenService:Create(ReactorStorage.Main.Beam, BEAM_TWEEN, { WorldPosition = BlastShield.Position})
	BeamTween:Play()

	BeamTween.Completed:Wait()

	TweenService:Create(ReactorStorage.Main.Beam1, LINEAR_TWEEN, ZERO_BRIGHTNESS):Play()
	TweenService:Create(ReactorStorage.Main.Beam2, LINEAR_TWEEN, ZERO_BRIGHTNESS):Play()
	TweenService:Create(ReactorStorage.Main.Beam3, LINEAR_TWEEN, ZERO_BRIGHTNESS):Play()

	ReactorStorage.Main.Beam.Main.Enabled = false
	ReactorStorage.Main.Beam.Main2.Enabled = false
	ReactorStorage.Main.Beam.Particles2.Enabled = false

	ReactorStorage.Main.Beam.Explode:Emit(100)
	ReactorStorage.Main.Beam.Flare:Emit(5)
	ReactorStorage.Main.Beam.Smoke:Emit(25)

	BlastShield.Anchored = false
	BlastShield.CanCollide = false

	BlastShield.Explosion:Play()
	BlastShield.FireS:Play()

	BlastShield.Material = Enum.Material.CorrodedMetal

	for index, particle in ipairs(BlastShield.Particles:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end

	for index, part in ipairs(BlastShield.Parts:GetChildren()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.CorrodedMetal
		end
	end

	task.delay(3, function()
		BlastShield:Destroy()
	end)
end

return ShieldSystem

--!nocheck

--[ SERVICES ]--
local TweenService = game:GetService("TweenService")

--[ OUR MAIN MODULE FOR THE LASER SYSTEM ]--
local LaserSystem = {}

--[ CONSTANT TWEENS ]--

-- REGULAR
local LINEAR_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Linear)
local TOGGLE_RETRACT_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
-- PRIME
local PRIME_EXTEND_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
local PRIME_COLOR_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Linear)
-- DESTROY
local DESTROY_RETRACT_TWEEN = TweenInfo.new(4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local DESTROY_COLOR_TWEEN = TweenInfo.new(2, Enum.EasingStyle.Linear)

--[ CONSTANT BRIGHTNESS ]--
local MIN_BRIGHTNESS = { Brightness = 0 }
local MED_BRIGHTNESS = { Brightness = 5 }
local MAX_BRIGHTNESS = { Brightness = 10 }

--[ CONSTANT COLORS ]--
local PRIME_COLOR = Color3.fromRGB(225, 225, 225)
local DESTROY_COLOR = Color3.fromRGB(225, 65, 0)

--[ FUNCTIONS ]--
function LaserSystem.RetractLaser(laser: Model, amount: number, tweeninfo: TweenInfo)
	TweenService:Create(
		laser.Mechanics.LaserAnchor,
		tweeninfo,
		{ CFrame = laser.Mechanics.LaserAnchor.CFrame * CFrame.new(Vector3.new(0, -amount, 0)) }
	):Play()
end

function LaserSystem.ExtendLaser(laser: Model, amount: number, tweeninfo: TweenInfo)
	TweenService:Create(
		laser.Mechanics.LaserAnchor,
		tweeninfo,
		{ CFrame = laser.Mechanics.LaserAnchor.CFrame * CFrame.new(Vector3.new(0, amount, 0)) }
	):Play()
end

function LaserSystem.ToggleLaser(laser: Model, state: boolean)
	-- IF THE STATE IS ALREADY THE SAME, DO NOTHING
	if laser:GetAttribute("State") == state then
		return
	end

	-- SET STATE
	laser:SetAttribute("State", state)

	-- SOME IMPORTANT PARTS
	local Mechanics = laser.Mechanics

	-- DECLARING VARIABLES EARLY
	local MainBrightness
	local PointBrightness

	-- INITIALIZATION CODE BASED ON STATE
	if state == true then
		if laser:GetAttribute("Primed") == false or laser:GetAttribute("Destroyed") == true then
			return
		end

		MainBrightness = MAX_BRIGHTNESS
		PointBrightness = MED_BRIGHTNESS

		LaserSystem.RetractLaser(laser, 2, TOGGLE_RETRACT_TWEEN)
	else
		MainBrightness = MIN_BRIGHTNESS
		PointBrightness = MIN_BRIGHTNESS
	end

	-- PLAY CHAMBER BEAM TWEENS [CHAMBER]
	TweenService:Create(Mechanics.ChamberInnerBeam.Beam0, LINEAR_TWEEN, MainBrightness):Play()
	TweenService:Create(Mechanics.ChamberInnerBeam.Beam1, LINEAR_TWEEN, MainBrightness):Play()
	TweenService:Create(Mechanics.Chamber.PointLight, LINEAR_TWEEN, PointBrightness):Play()

	-- TOGGLE PARTICLE EMITTERS [CHAMBER]
	Mechanics.ChamberInnerBeam.BottomParticles.ParticleEmitter.Enabled = state
	Mechanics.ChamberInnerBeam.TopParticles.ParticleEmitter.Enabled = state
	Mechanics.Chamber.ParticleEmitter.Enabled = state

	-- PLAY LASER ACTIVATION AND IGNITE BOTTOM PARTICLES BASED ON STATE [MAIN]
	if state == true then
		Mechanics.LaserTopBeam.Active:Play()
		Mechanics.LaserTopBeam.BottomParticlesIgnite.Ignite1:Emit(100)
		Mechanics.LaserTopBeam.BottomParticlesIgnite.Ignite2:Emit(10)
	else
		Mechanics.LaserTopBeam.Active:Stop()
	end

	-- PLAY MAIN TOP BEAM TWEENS [MAIN]
	TweenService:Create(Mechanics.LaserTopBeam.Beam0, LINEAR_TWEEN, MainBrightness)
	TweenService:Create(Mechanics.LaserTopBeam.Beam1, LINEAR_TWEEN, MainBrightness)

	-- TOGGLE PARTICLE EMITTERS [MAIN]
	Mechanics.LaserTopBeam.BottomParticles.Particles1.Enabled = state
	Mechanics.LaserTopBeam.BottomParticles.Particles2.Enabled = state
	Mechanics.LaserTopBeam.BottomParticles.Particles3.Enabled = state
end

function LaserSystem.ChangeColor(laser: Model, color: Color3, tweeninfo: TweenInfo)
	-- TWEEN COLOR FOR EVERY NEON PART
	for index, part in ipairs(laser.Mechanics.Neons) do
		TweenService:Create(part, tweeninfo, { Color = color }):Play()
	end
end

function LaserSystem.PrimeLaser(laser: Model)
	-- IF LASER IS PRIMED OR DESTROYED, DO NOTHING
	if laser:GetAttribute("Primed") == true or laser:GetAttribute("Destroyed") == true then
		return
	end

	-- SET PRIMED VALUE
	laser:SetAttribute("Primed", true)

	-- PLAY LASER EXTENSION AUDIO
	laser.Mechanics.LaserAnchor.LaserExtensions:Play()

	-- COLOR AND PARTICLE TWEENS
	LaserSystem.ExtendLaser(laser, 15, PRIME_EXTEND_TWEEN)
	LaserSystem.ChangeColor(laser, PRIME_COLOR, PRIME_COLOR_TWEEN)
end

function LaserSystem.DestroyLaser(laser: Model)
	-- IF THE LASER IS ALREADY DESTROYED, DO NOTHING
	if laser:GetAttribute("Destroyed") == true then
		return
	end

	-- SET DESTROYED VALUE
	laser:SetAttribute("Destroyed", true)

	-- DISABLE LASER
	LaserSystem.ToggleLaser(laser, false)

	-- VISUALS
	laser.Mechanics.LaserTopBeam.Explosion.Explode:Emit(100)
	laser.Mechanics.LaserTopBeam.Explosion.Flare:Emit(5)
	laser.Mechanics.LaserTopBeam.ExplosionSound:Play()
	laser.Mechanics.LaserTopBeam.Smoke.Fire.Enabled = true

	LaserSystem.RetractLaser(laser, 15, DESTROY_RETRACT_TWEEN)
	LaserSystem.ChangeColor(laser, DESTROY_COLOR, DESTROY_COLOR_TWEEN)
end

return LaserSystem

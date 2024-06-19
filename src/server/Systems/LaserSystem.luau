--!nocheck
--!native
--!optimize 2

--[[
	DISCLAIMER:
	I WOULD NORMALLY USE STRICT TYPECHECKING, BUT THE FUNCTIONS REQUIRED ARE AGAINST THE NATURE OF STRICT TYPECHECKING.
	NATIVE AND OPTIMIZE FLAGS ARE TO SQUEEZE OUT EVERY DROP FROM NATIVE LUAU CODE. LET ME KNOW IF THIS COULD HAVE ADVERSE EFFECTS!
]]

--[ SERVICES ]--
local TweenService = game:GetService("TweenService")

--[ OUR MAIN MODULE FOR THE LASER SYSTEM ]--
local LaserSystem = {}

--[ TWEEN CONSTANTS ]--
local LINEAR_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Linear)
local TOGGLE_RETRACT_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local PRIME_EXTEND_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
local PRIME_COLOR_TWEEN = TweenInfo.new(5, Enum.EasingStyle.Linear)

local DESTROY_RETRACT_TWEEN = TweenInfo.new(4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local DESTROY_COLOR_TWEEN = TweenInfo.new(2, Enum.EasingStyle.Linear)

local FLASH_TWEEN = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 1, true, 1)

--[ BRIGHTNESS CONSTANTS ]--
local MIN_BRIGHTNESS = { Brightness = 0 }
local MED_BRIGHTNESS = { Brightness = 5 }
local MAX_BRIGHTNESS = { Brightness = 10 }

--[ COLOR CONSTANTS ]--
local WHITE_COLOR = Color3.new(1, 1, 1)
local _BLACK_COLOR = Color3.new(0, 0, 0) -- not used currently
local PRIME_COLOR = Color3.fromRGB(225, 225, 225)
local FLASH_COLOR = Color3.fromRGB(255, 155, 0)
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

	-- FOLDER FOR MOST PARTS BELOW
	local Mechanics = laser.Mechanics
	print(MainBrightness)
	print(PointBrightness)

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
	TweenService:Create(Mechanics.LaserTopBeam.Beam0, LINEAR_TWEEN, MainBrightness):Play()
	TweenService:Create(Mechanics.LaserTopBeam.Beam1, LINEAR_TWEEN, MainBrightness):Play()

	-- TOGGLE PARTICLE EMITTERS [MAIN]
	Mechanics.LaserTopBeam.BottomParticles.Particles1.Enabled = state
	Mechanics.LaserTopBeam.BottomParticles.Particles2.Enabled = state
	Mechanics.LaserTopBeam.BottomParticles.Particles3.Enabled = state
end

function LaserSystem.FlashLaser(laser: Model, state: boolean)
	if laser:GetAttribute("Flashing") == state then
		return
	end

	laser:SetAttribute("Flashing", state)

	if state == true then
		for index, part in ipairs(laser.Mechanics.Neons:GetChildren()) do
			local OldColor = part.Color

			local PriorTween = TweenService:Create(part, LINEAR_TWEEN, { Color = WHITE_COLOR })
			local FlashTween = TweenService:Create(part, FLASH_TWEEN, { Color = FLASH_COLOR })

			FlashTween.Completed:Connect(function()
				if laser:GetAttribute("Flashing") == true then
					FlashTween:Play()
				else
					FlashTween:Cancel()
					FlashTween:Destroy()

					TweenService:Create(part, LINEAR_TWEEN, { Color = OldColor }):Play()
				end
			end)

			PriorTween.Completed:Connect(function()
				PriorTween:Cancel()
				PriorTween:Destroy()

				FlashTween:Play()
			end)

			PriorTween:Play()
		end
	end
end

function LaserSystem.ToggleVents(laser: Model, state: boolean)
	for index, vent in ipairs(laser.Mechanics.Vents:GetChildren()) do
		vent.ParticleEmitter.Enabled = state
	end

	laser.Mechanics.LaserTopBeam.ShieldParticles.Particles1.Enabled = state
	LaserSystem.FlashLaser(laser, state)
end

function LaserSystem.ToggleBottomCharge(laser: Model, state: boolean)
	for index, particle in pairs(laser.Mechanics.LaserTopBeam.BottomParticlesCharge:GetChildren()) do
		particle.Enabled = state
	end
end

function LaserSystem.ChangeColor(laser: Model, color: Color3, tweeninfo: TweenInfo)
	-- TWEEN COLOR FOR EVERY NEON PART
	for index, part in ipairs(laser.Mechanics.Neons:GetChildren()) do
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
	laser.Mechanics.LaserAnchor.LaserExtension:Play()

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

	-- TWEENS
	LaserSystem.RetractLaser(laser, 15, DESTROY_RETRACT_TWEEN)
	LaserSystem.ChangeColor(laser, DESTROY_COLOR, DESTROY_COLOR_TWEEN)
end

return LaserSystem

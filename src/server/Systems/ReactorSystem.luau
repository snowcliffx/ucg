--!strict
--!native
--!optimize 2

--[ SERVICES ]--
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

--[ MODULES ]--
local LaserSystem = require(ServerScriptService.Systems.LaserSystem)
local LightSystem = require(ServerScriptService.Systems.LightSystem)

--[ OUR MAIN MODULE FOR THE REACTOR SYSTEM]
local ReactorSystem = {}

--[ GAME FOLDERS ]--
local GameFolder = game.Workspace.Game
local LaserStorage = GameFolder.Lasers

--[ TWEEN CONSTANTS ]--

--[ OTHER ]--
local Lasers = LaserStorage:GetChildren()

--[ FUNCTIONS ]--
function ReactorSystem.Initialize()
	-- TODO: ANNOUNCE
	for index, laser in ipairs(Lasers) do
		LaserSystem.PrimeLaser(laser)
	end

	task.wait(5)

	GameFolder.Reactor.ChamberParticles.Idle.Enabled = true

	for index, laser in ipairs(Lasers) do
	end
end

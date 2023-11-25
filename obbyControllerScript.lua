--important variables and functions used in the code

--services for determining if a player joins
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	--variables used to track game data
	local lastCheckpoint = nil
	--offset variable used for teleportation, makes sure player isnt in a block
	local offset = Vector3.new(0,2,0)
	--variable assigned to victoryPlatform
	local victoryPlatform = game.Workspace.victoryPlatform
	-- checks if part touching assigned part is a humanoid
	local function isHuman(part)
		local hum = part.Parent:FindFirstChild("HumanoidRootPart")
		return hum
	end
	-- calls module PlayerStatManager
	local PlayerStatManager = require(game.ServerScriptService.PlayerStatManager)
	--global debounce
	canUseVictory = true
	canUseFirstRandomize = true
	canUseCheckpoint = true
--



--code for randomizing the obby

--gives a random obstacle from the set of 8
function giveRandomObstacle()
	local selectedObstacle = math.random(1,8)
	if selectedObstacle == 1 then
	return game.Workspace.Stages.stage1
	elseif selectedObstacle == 2 then
		return game.Workspace.Stages.stage2
	elseif selectedObstacle == 3 then
		return game.Workspace.Stages.stage3
	elseif selectedObstacle == 4 then
		return game.Workspace.Stages.stage4
	elseif selectedObstacle == 5 then
		return game.Workspace.Stages.stage5
	elseif selectedObstacle == 6 then
		return game.Workspace.Stages.stage6
	elseif selectedObstacle == 7 then
		return game.Workspace.Stages.stage7
	elseif selectedObstacle == 8 then
		return game.Workspace.Stages.stage8
	end
end


--uses giveRandomObstacle to randomly swap obstacles
function randomizeObstacles() -- randomizes obstacles
		for i = 1, 8, 1 do
			local chosenObstacle1 = giveRandomObstacle()
			local chosenObstacle2 = giveRandomObstacle()
			local tempPositionZ = Vector3.new(0,0,0)
			tempPositionZ = chosenObstacle1.CFrame
			chosenObstacle1.CFrame = chosenObstacle2.CFrame
			chosenObstacle2.CFrame = tempPositionZ
		end
		print("randomizeObstacles cooldown actiavted")
		task.wait(5)
		print("randomizeObstacles cooldown ended")
end


--



--code for teleporting player to last checkpoint if they touch a killbrick

	local function teleportToCheckpoint(part) --teleports player back to last checkpoint
		local hum = isHuman(part)
		if hum then
			hum.CFrame = lastCheckpoint.CFrame + offset

			print(hum,"has teleported to a checkpoint")
		end
	end
--

--code for if player gets to victoryPlatform
local function victoryPlatformTouched(part)
	local hum = isHuman(part)
	local playerName = part.Parent.Name

	if hum and canUseVictory then
		--gives +1 Wins in leaderstats value "Wins"
		local player = game.Players:FindFirstChild(playerName)
		PlayerStatManager:ChangeStat(player, "Wins", 1)
		print(playerName, " made it to the end first!")

		canUseVictory = false
		--teleports everyone back to spawn
		for key, player in pairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			humanoidRootPart.CFrame = CFrame.new(0,5,0)
		end
		--randomizes obby
		randomizeObstacles()
		
		canUseVictory = true

	end
end
--



--events

	victoryPlatform.Touched:Connect(victoryPlatformTouched)

	--sets player's lastCheckpoint to the last one they touched
	for key, object in pairs(game.Workspace.Checkpoints:GetChildren()) do
		--sets last checkpoint
		if object.Name == "checkPoint" then
			object.Touched:Connect(function(part)
				local hum = isHuman(part)
				if hum and canUseCheckpoint then
					lastCheckpoint = object
					print(hum, "has touched a checkpoint")
					canUseCheckpoint = false
					task.wait(2.5)
					canUseCheckpoint = true
				end
			end)
		end
	end

	--set's player's position to lastCheckpoint if they touched a "killBrick"
	for key,object in pairs(game.Workspace.killBricks:GetChildren()) do
		if object.Name == "killBrick" then
			object.Touched:Connect(teleportToCheckpoint)
		end

	end

	--randomizes obstacles when a player joins (uses services at the top) if it's the first time
	game.Players.PlayerAdded:Connect(function()
		if canUseFirstRandomize then
			canUseFirstRandomize = false
			for i = 1, 8, 1 do
				local chosenObstacle1 = giveRandomObstacle()
				local chosenObstacle2 = giveRandomObstacle()
				local tempPositionZ = Vector3.new(0,0,0)
				--swap positions
				tempPositionZ = chosenObstacle1.CFrame
				chosenObstacle1.CFrame = chosenObstacle2.CFrame
				chosenObstacle2.CFrame = tempPositionZ
			end
			print("player joined, randomizing obstacles")
		end
	end)


--

--code for adding leaderboard stats to each player that joins
	local function AddBoardToPlayer(player)
		-- create variable board with a new model instance, set parent as the Player object
		local board = Instance.new("Model", player)
		-- set name of board variable to "leaderstats," because the area where its name is isn't filled out
		board.Name = "leaderstats"
		-- add a new IntValue variable "wins" to the board, give it the name "Wins" with a string, and set the value to 0
		local wins = Instance.new("IntValue",board)
		wins.Name = "Wins"
		wins.Value = 0
	end
--


--events
	-- connect function to game.Players.PlayerAdded event
	game.Players.PlayerAdded:Connect(AddBoardToPlayer)
--
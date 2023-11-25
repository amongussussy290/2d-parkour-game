-- reference to the script itself, allows us to call functions and reference variables from external programs
-- what we return at the end of this script
local PlayerStatManager = {}

--variable for holding the DataStoreService
local DataStoreService = game.GetService("DataStoreService")

--variable that will hold specific store of a player's file
--if we need to get or set data, we will use this variable
local playerData = DataStoreService:GetDataStore("Player Data")

--to be used when we run our autosave function
--controls how many seconds we will wait between saves before saving agian
local AUTOSAVE_INTERVAL = 60

--control how many times to retry a save if the save fails initially
local DATASTORE_RETRIES = 3
local sessionData = {} 

local function updateboard(player)
	for key, object in pairs (sessionData[player])do
		player.leaderstats[key].Value = object
	end
end




--starts off with name of module
--when you create a ModuleScript and call it from another script, you can assign it to a varaible
--Example: local variable == require(game.ServerScriptService.PlayerStatManager)
--now, if i ever want to use ChangeStat, i can use variable:ChangeStat and pass in the arguments of specified player and data attached to them
--this would change tje sessionData table value for that player in ModuleScript
--works kind of like a function that can be called
function PlayerStatManager:ChangeStat(player, statName, changeValue)
	sessionData[player][statName] = sessionData[player][statName]+changeValue
	updateboard(player)
end


--[[function dataStoreRetry
pass in argument dataStoreFunction, which passes in what the function does but not its name
this kind of function pass is an anonymous function
in the repeat loop, increase tries by one, set variable success to the result of pcall
a pcall is a protected call that evaluates a function's results. If a function crashes or errors out, the entire script usually stops.
With a pcall, the same function can be ran and analyzed for it's results, and handle it without the script stopping 
The pcall can return two things: the result (true or false) and the message string (if the call is good or what went wrong)
At the end of the loop, even with a good or bad call, after three tries, the results are sent back to the developer
If there was an error, return an error message. Also return variables success (can hold false) and data
dataStoreRetry is created first because it is used in other functions after
]]

local function dataStoreRetry(dataStoreFunction)
	local tries = 0 local success = true local data = nil
	repeat
		tries = tries + 1
		success = pcall(function() data = dataStoreFunction()
		end)
		if not success then wait(1)
			print("retrying autosave...")
		end
	until tries == DATASTORE_RETRIES or success
	if not success then
		error("Couldn't access DataStore! Data might not save!")
	end
	return success, data
end

--Function to retrieve player's data from the DataStore
--[[
This function gets the player data from DataStore by calling the dataStoreRetry function and passing in an anonymous function. Then, pass in a Player
object and using its UserId to call GetAsync.
]]
local function getPlayerData(player)
	return dataStoreRetry(function()
		return playerData:GetAsync(player.UserId)
	end)
end

--Function to save player's data into the DataStore
--[[
savePlayerData is the same as the getPlayerData function but with one change: Instead of GetAsync, it uses SetAsync. SetAsync makes us pass in the value
we want to save.
In this case, we are saving a session entry for a player and will therefore not just be saving a single key with a single value. Instead, a single key is saved
(the player.UserId) and a table of indexed data.
The SetAsync is loading the data no matter what the data is used for. This function won't be ran directly.
]]
local function savePlayerData(player)
	if sessionData[player] then
		return dataStoreRetry(function()
			return playerData:SetAsync(player.UserId,sessionData[player])
		end)
	end
end

--Function to save player's data to the DataStore.
--[[
Takes the argument of player, which is passed into our function from the PlayerAdded event that will be programmed later. 
Then, use the getPlayerData function (returns a true/false for if it ran correctly and the information requested). Then, the information is stored into two
variables success and data.
Then, the function checks if success is true. If not, set the data to false to prevent it from being used.
If getPlayerData worked, check to see if the data is good. If there is no data for the player, create the sessionData entry with the player as the key,
then set its value to a table of indexed values. 
]]
local function setupPlayerData(player)
	local success, data = getPlayerData(player)
	if not success then
		--Could not access DataStore, set session data for player to false
		sessionData[player] = false else
		if not data then
			--DataStores are working, but no data for this player
			sessionData[player] = {Dots = 0, Experience = 0}
			savePlayerData(player)
		else
			--DataStores are working and we got data for this player
			sessionData[player] = data
		end
	end
	updateboard(player)
end
--[[Because this is the first tine that this player has been seen, the savePlayerData function is immediately ran to ensure that player's fule will be in the
DataStore the next time the user joins. If the data was found, then simply add it to the sessionData table.
]]

--The problem with this method is that if you added something new to your playerData, the else function doesn't see if the new value is there if someone who
--joined before the adding of soemthing new to playerData loads their game.
--Check the data to make sure that player has the same number of keys and values that eveyone else gets when when they first join.




--Function to run int he background to periodically save player's data
--[[New function autosave. A while loop will perform a wait function for the time we have given it. If the AUTOSAVE_INTERVAl is 0, the autosave will be
disabled. Then, a for/ in loop with the sessionData table will use the savePlayerData function for every player.
]]
local function autosave()
	while wait(AUTOSAVE_INTERVAL) do
		for player, data in pairs(sessionData) do
			savePlayerData(player)
		end
	end
end

--Bind setupPlayerData to PlayerAdded to call it when player joins.
game.Players.PlayerAdded:connect(setupPlayerData)
	
--Call savePlayerData on PlayerRemoving to save player data when they leave
--Also delete the player from the table sessionData (the player isnt in the game anymore)
game.Players.PlayerRemoving:connect(function(player) --anonymous function
	savePlayerData(player) sessionData[player] = nil
end)

--start running autosave function in background
spawn(autosave)
--spawn creates a thread for a function to run on, as it is not good to make the rest of the code wait for the autosave to finish

--Return the PlayerStatManager table so external scripts can use it
return PlayerStatManager
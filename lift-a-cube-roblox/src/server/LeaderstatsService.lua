--!strict
-- ServerScriptService/LeaderstatsService.lua
-- Sets up standard Roblox leaderstats for player scoreboards.

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.DataManager)

local LeaderstatsService = {}

function LeaderstatsService.setupPlayer(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    local strength = leaderstats:FindFirstChild("Strength") :: NumberValue?
    if not strength then
        strength = Instance.new("NumberValue")
        strength.Name = "Strength"
        strength.Value = DataManager.getStrength(player)
        strength.Parent = leaderstats
    end

    local wins = leaderstats:FindFirstChild("Wins") :: NumberValue?
    if not wins then
        wins = Instance.new("NumberValue")
        wins.Name = "Wins"
        wins.Value = DataManager.getWins(player)
        wins.Parent = leaderstats
    end

    -- Initial push to client
    DataManager.syncToClient(player)
end

function LeaderstatsService.init()
    Players.PlayerAdded:Connect(function(player)
        -- Give time for DataManager to populate profile
        task.wait(0.2)
        LeaderstatsService.setupPlayer(player)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        LeaderstatsService.setupPlayer(player)
    end
end

return LeaderstatsService

--!strict
-- ServerScriptService/TrainingService.lua
-- Handles push-up training, cooldown checks, multiplier calculations, and auto-train.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Remotes)
local ArmsConfig = require(ReplicatedStorage.Config.ArmsConfig)
local MaterialsConfig = require(ReplicatedStorage.Config.MaterialsConfig)
local DataManager = require(ServerScriptService.DataManager)

local TrainingService = {}

-- Track last push-up timestamp per player for server-side cooldown enforcement
local lastTrainTime: { [Player]: number } = {}
local autoTrainActive: { [Player]: boolean } = {}

local function getPlayerCooldown(player: Player): number
    local equippedArmId = DataManager.getEquippedArm(player)
    local armData = ArmsConfig.Arms[equippedArmId]
    if armData then
        return armData.SpeedCooldown
    end
    return 1.0
end

local function getPlayerMultiplier(player: Player): number
    local equippedMatId = DataManager.getEquippedMaterial(player)
    local matData = MaterialsConfig.Materials[equippedMatId]
    if matData then
        return matData.Multiplier
    end
    return 1.0
end

function TrainingService.processTrain(player: Player): boolean
    local now = os.clock()
    local cooldown = getPlayerCooldown(player)
    local lastTime = lastTrainTime[player] or 0

    -- Add a small 0.05s buffer for network ping
    if (now - lastTime) < (cooldown - 0.05) then
        return false
    end

    lastTrainTime[player] = now

    local baseGain = 1
    local multiplier = getPlayerMultiplier(player)
    local totalGain = math.floor(baseGain * multiplier)

    DataManager.addStrength(player, totalGain)

    -- Send visual feedback to player client
    local feedbackRemote = Remotes.getEvent(Remotes.Names.TrainingFeedback)
    feedbackRemote:FireClient(player, totalGain)

    return true
end

function TrainingService.init()
    local trainRequest = Remotes.getEvent(Remotes.Names.TrainRequest)
    local autoTrainToggle = Remotes.getEvent(Remotes.Names.ToggleAutoTrain)

    trainRequest.OnServerEvent:Connect(function(player)
        TrainingService.processTrain(player)
    end)

    autoTrainToggle.OnServerEvent:Connect(function(player, state: boolean?)
        if state == nil then
            autoTrainActive[player] = not autoTrainActive[player]
        else
            autoTrainActive[player] = state
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        lastTrainTime[player] = nil
        autoTrainActive[player] = nil
    end)

    -- Auto-train background loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            for player, isActive in pairs(autoTrainActive) do
                if isActive and player.Parent then
                    TrainingService.processTrain(player)
                end
            end
        end
    end)
end

return TrainingService

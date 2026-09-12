--!strict
-- ServerScriptService/ShopService.lua
-- Manages purchasing arm upgrades using Wins and equipping owned arms.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Remotes)
local ArmsConfig = require(ReplicatedStorage.Config.ArmsConfig)
local DataManager = require(ServerScriptService.DataManager)

local ShopService = {}

function ShopService.buyArm(player: Player, armId: string): (boolean, string)
    local armData = ArmsConfig.Arms[armId]
    if not armData then
        return false, "Invalid arm ID"
    end

    local profile = DataManager.getData(player)
    if not profile then
        return false, "Data not loaded"
    end

    -- If already owned, just equip it
    if profile.OwnedArms[armId] then
        DataManager.setEquippedArm(player, armId)
        return true, "Equipped " .. armData.Name
    end

    -- Check price
    if profile.Wins < armData.Cost then
        return false, "Not enough Wins!"
    end

    -- Deduct and equip
    local success = DataManager.deductWins(player, armData.Cost)
    if success then
        DataManager.setEquippedArm(player, armId)
        return true, "Purchased and equipped " .. armData.Name .. "!"
    else
        return false, "Transaction failed"
    end
end

function ShopService.init()
    local buyRemote = Remotes.getFunction(Remotes.Names.BuyArmRequest)
    buyRemote.OnServerInvoke = function(player, armId: string)
        return ShopService.buyArm(player, armId)
    end
end

return ShopService

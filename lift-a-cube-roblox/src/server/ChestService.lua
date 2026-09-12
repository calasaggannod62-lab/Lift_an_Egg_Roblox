--!strict
-- ServerScriptService/ChestService.lua
-- Manages weighted RNG chest rolls, arm material multipliers, and arm visual effects.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Remotes)
local MaterialsConfig = require(ReplicatedStorage.Config.MaterialsConfig)
local DataManager = require(ServerScriptService.DataManager)

local ChestService = {}

-- Applies material color, texture, and particles to character's arms (supports R6 and R15)
function ChestService.applyArmVisuals(character: Model, materialId: string)
    local matData = MaterialsConfig.Materials[materialId]
    if not matData then return end

    local armPartNames = {
        -- R6
        "Right Arm", "Left Arm",
        -- R15
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
    }

    for _, partName in ipairs(armPartNames) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Material = matData.ArmMaterial
            part.Color = matData.ArmColor

            -- Clean up previous particle emitters
            local oldEmitter = part:FindFirstChild("ArmAura")
            if oldEmitter then oldEmitter:Destroy() end

            -- Add aura if material has particles
            if matData.HasParticle and matData.ParticleColor then
                local emitter = Instance.new("ParticleEmitter")
                emitter.Name = "ArmAura"
                emitter.Color = ColorSequence.new(matData.ParticleColor)
                emitter.Size = NumberSequence.new(0.3, 0)
                emitter.Rate = 12
                emitter.Lifetime = NumberRange.new(0.5, 0.9)
                emitter.Speed = NumberRange.new(1, 2)
                emitter.SpreadAngle = Vector2.new(45, 45)
                emitter.Parent = part
            end
        end
    end
end

-- Pick a random material based on loot table weights
local function pickWeightedMaterial(lootTable: { MaterialsConfig.ChestLootItem }): string
    local totalWeight = 0
    for _, item in ipairs(lootTable) do
        totalWeight += item.Weight
    end

    local roll = math.random() * totalWeight
    local current = 0
    for _, item in ipairs(lootTable) do
        current += item.Weight
        if roll <= current then
            return item.MaterialId
        end
    end

    return lootTable[1].MaterialId
end

function ChestService.openChest(player: Player, chestId: string): (boolean, any)
    local chestData = MaterialsConfig.Chests[chestId]
    if not chestData then
        return false, "Invalid chest ID"
    end

    local profile = DataManager.getData(player)
    if not profile then
        return false, "Profile not loaded"
    end

    if profile.Wins < chestData.Cost then
        return false, "Not enough Wins to open this chest!"
    end

    local success = DataManager.deductWins(player, chestData.Cost)
    if not success then
        return false, "Transaction failed"
    end

    local rolledMaterialId = pickWeightedMaterial(chestData.LootTable)
    local matInfo = MaterialsConfig.Materials[rolledMaterialId]

    -- Check if it's a new or higher multiplier material
    local currentMat = MaterialsConfig.Materials[profile.EquippedMaterial]
    if not currentMat or matInfo.Multiplier > currentMat.Multiplier then
        DataManager.setEquippedMaterial(player, rolledMaterialId)
    else
        profile.OwnedMaterials[rolledMaterialId] = true
        DataManager.syncToClient(player)
    end

    -- Update arm visuals on player character
    if player.Character then
        ChestService.applyArmVisuals(player.Character, rolledMaterialId)
    end

    return true, {
        MaterialId = rolledMaterialId,
        Name = matInfo.Name,
        Multiplier = matInfo.Multiplier,
        Rarity = matInfo.Rarity,
        RarityColor = { matInfo.RarityColor.R, matInfo.RarityColor.G, matInfo.RarityColor.B },
    }
end

function ChestService.init()
    local openRemote = Remotes.getFunction(Remotes.Names.OpenChestRequest)
    openRemote.OnServerInvoke = function(player, chestId: string)
        return ChestService.openChest(player, chestId)
    end

    -- Reapply arm visuals upon respawn
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5) -- wait for limbs to load
            local currentMatId = DataManager.getEquippedMaterial(player)
            ChestService.applyArmVisuals(character, currentMatId)
        end)
    end)
end

return ChestService

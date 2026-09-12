--!strict
-- ServerScriptService/EggService.lua
-- Manages 3D procedural egg generation, themed nests, lifting mechanics, and incubator deliveries.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Remotes)
local EggsConfig = require(ReplicatedStorage.Config.EggsConfig)
local ZonesConfig = require(ReplicatedStorage.Config.ZonesConfig)
local DataManager = require(ServerScriptService.DataManager)

local EggService = {}

type CarryState = {
    EggId: string,
    CarriedModel: Part,
    Weld: WeldConstraint,
}

local activeCarries: { [Player]: CarryState } = {}

-- Ensure Workspace folders exist
local function getEggsFolder(): Folder
    local folder = Workspace:FindFirstChild("Eggs") :: Folder
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Eggs"
        folder.Parent = Workspace
    end
    return folder
end

-- Helper to create 3D egg part with SpecialMesh
local function createEggPart(eggData: EggsConfig.EggData, isCarried: boolean): Part
    local part = Instance.new("Part")
    part.Name = if isCarried then "CarriedEgg" else "InteractEgg"

    local displaySize = eggData.Scale
    if isCarried then
        -- Scale down carried egg slightly so it sits neatly in player's hands
        displaySize = Vector3.new(
            math.clamp(eggData.Scale.X * 0.6, 1.4, 3.5),
            math.clamp(eggData.Scale.Y * 0.6, 1.8, 4.5),
            math.clamp(eggData.Scale.Z * 0.6, 1.4, 3.5)
        )
    end

    part.Size = displaySize
    part.Material = eggData.ShellMaterial
    part.Color = eggData.ShellColor
    part.CanCollide = not isCarried
    part.Massless = isCarried

    -- SpecialMesh shaped as an egg (vertically elongated sphere)
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1, 1.25, 1)
    mesh.Parent = part

    -- Add glow/light if configured
    if eggData.HasGlow and eggData.GlowColor then
        local light = Instance.new("PointLight")
        light.Color = eggData.GlowColor
        light.Brightness = 2.5
        light.Range = 10
        light.Parent = part

        local highlight = Instance.new("Highlight")
        highlight.FillColor = eggData.GlowColor
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = eggData.GlowColor
        highlight.OutlineTransparency = 0.2
        highlight.Parent = part
    end

    return part
end

-- Spawn an egg station inside a themed Nest
function EggService.spawnEggStation(eggId: string, cframe: CFrame)
    local eggData = EggsConfig.Eggs[eggId]
    if not eggData then return end

    local folder = getEggsFolder()

    local stationModel = Instance.new("Model")
    stationModel.Name = eggId
    stationModel.Parent = folder

    -- Themed Nest Pedestal (Wood/Twig/Stone bowl)
    local nest = Instance.new("Part")
    nest.Name = "Nest"
    nest.Size = Vector3.new(eggData.Scale.X + 2, 0.8, eggData.Scale.Z + 2)
    nest.CFrame = cframe
    nest.Anchored = true
    nest.Material = if eggData.Area == 1 then Enum.Material.Wood
        elseif eggData.Area == 2 then Enum.Material.Slate
        elseif eggData.Area == 3 then Enum.Material.Basalt
        else Enum.Material.Neon
    nest.Color = if eggData.Area == 1 then Color3.fromRGB(115, 75, 40)
        elseif eggData.Area == 2 then Color3.fromRGB(90, 95, 85)
        elseif eggData.Area == 3 then Color3.fromRGB(40, 25, 30)
        else Color3.fromRGB(50, 15, 90)
    nest.Parent = stationModel

    -- 3D Egg Part
    local eggPart = createEggPart(eggData, false)
    eggPart.CFrame = cframe + Vector3.new(0, (eggData.Scale.Y * 0.6) + 0.4, 0)
    eggPart.Anchored = true
    eggPart.Parent = stationModel

    -- Info Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "InfoGui"
    billboard.Size = UDim2.new(0, 200, 0, 55)
    billboard.StudsOffset = Vector3.new(0, (eggData.Scale.Y * 0.7) + 1.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = eggPart

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.Text = "🥚 " .. eggData.Name
    nameLabel.Parent = billboard

    local reqLabel = Instance.new("TextLabel")
    reqLabel.Size = UDim2.new(1, 0, 0.5, 0)
    reqLabel.Position = UDim2.new(0, 0, 0.5, 0)
    reqLabel.BackgroundTransparency = 1
    reqLabel.TextColor3 = Color3.fromRGB(255, 220, 60)
    reqLabel.TextStrokeTransparency = 0.2
    reqLabel.TextScaled = true
    reqLabel.Font = Enum.Font.FredokaOne
    reqLabel.Text = "Req: " .. tostring(eggData.RequiredStrength) .. " Strength"
    reqLabel.Parent = billboard

    -- Proximity Prompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LiftPrompt"
    prompt.ActionText = "Lift Egg"
    prompt.ObjectText = eggData.Name .. " (+" .. tostring(eggData.WinReward) .. " Wins)"
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = eggPart

    prompt.Triggered:Connect(function(player)
        EggService.attemptLift(player, eggId)
    end)
end

function EggService.attemptLift(player: Player, eggId: string): boolean
    local character = player.Character
    if not character then return false end

    local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return false end

    if activeCarries[player] then
        return false
    end

    local eggData = EggsConfig.Eggs[eggId]
    if not eggData then return false end

    local playerStrength = DataManager.getStrength(player)
    if playerStrength < eggData.RequiredStrength then
        return false
    end

    -- Create carried 3D egg welded overhead
    local carriedEgg = createEggPart(eggData, true)
    carriedEgg.CFrame = hrp.CFrame + Vector3.new(0, 3.8, 0)
    carriedEgg.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = carriedEgg
    weld.Parent = carriedEgg

    activeCarries[player] = {
        EggId = eggId,
        CarriedModel = carriedEgg,
        Weld = weld,
    }

    return true
end

function EggService.completeCarry(player: Player): boolean
    local carry = activeCarries[player]
    if not carry then return false end

    local eggData = EggsConfig.Eggs[carry.EggId]
    if eggData then
        DataManager.addWins(player, eggData.WinReward)
    end

    if carry.CarriedModel then
        carry.CarriedModel:Destroy()
    end

    activeCarries[player] = nil
    return true
end

function EggService.dropCarry(player: Player)
    local carry = activeCarries[player]
    if carry then
        if carry.CarriedModel then
            carry.CarriedModel:Destroy()
        end
        activeCarries[player] = nil
    end
end

-- Connect incubator pads in both Workspace.Incubators and Workspace.Map
local function setupIncubators()
    local function connectPad(pad: BasePart)
        pad.Touched:Connect(function(hit)
            local character = hit.Parent
            if character then
                local player = Players:GetPlayerFromCharacter(character)
                if player and activeCarries[player] then
                    EggService.completeCarry(player)
                end
            end
        end)
    end

    -- Hook legacy folder if exists
    local incubatorFolder = Workspace:FindFirstChild("Incubators")
    if incubatorFolder then
        for _, pad in ipairs(incubatorFolder:GetChildren()) do
            if pad:IsA("BasePart") then connectPad(pad) end
        end
    end

    -- Hook 3D Incubators built by MapService in Workspace.Map
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, desc in ipairs(mapFolder:GetDescendants()) do
            if desc:IsA("BasePart") and string.find(desc.Name, "Incubator") and string.find(desc.Name, "Pad") then
                connectPad(desc)
            end
        end
    end
end

function EggService.init()
    local liftFunc = Remotes.getFunction(Remotes.Names.LiftEggRequest)
    local dropEvent = Remotes.getEvent(Remotes.Names.DropEggRequest)
    local finishEvent = Remotes.getEvent(Remotes.Names.FinishEggCarry)

    liftFunc.OnServerInvoke = function(player, eggId: string)
        return EggService.attemptLift(player, eggId)
    end

    dropEvent.OnServerEvent:Connect(function(player)
        EggService.dropCarry(player)
    end)

    finishEvent.OnServerEvent:Connect(function(player)
        EggService.completeCarry(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        EggService.dropCarry(player)
    end)

    setupIncubators()

    -- Spawn eggs automatically by area along each themed island's lane
    local eggsFolder = getEggsFolder()
    if #eggsFolder:GetChildren() == 0 then
        -- Area 1: Farm Meadow
        EggService.spawnEggStation("Egg_1_1", CFrame.new(-12, 0.5, 5))
        EggService.spawnEggStation("Egg_1_2", CFrame.new(12, 0.5, 5))
        EggService.spawnEggStation("Egg_1_3", CFrame.new(-12, 0.5, 25))
        EggService.spawnEggStation("Egg_1_4", CFrame.new(12, 0.5, 25))

        -- Area 2: Prehistoric Jungle
        EggService.spawnEggStation("Egg_2_1", CFrame.new(-12, 0.5, 85))
        EggService.spawnEggStation("Egg_2_2", CFrame.new(12, 0.5, 100))
        EggService.spawnEggStation("Egg_2_3", CFrame.new(-12, 0.5, 115))

        -- Area 3: Volcanic Dragon Lair
        EggService.spawnEggStation("Egg_3_1", CFrame.new(-12, 0.5, 175))
        EggService.spawnEggStation("Egg_3_2", CFrame.new(12, 0.5, 190))
        EggService.spawnEggStation("Egg_3_3", CFrame.new(-12, 0.5, 205))

        -- Area 4: Cosmic Core
        EggService.spawnEggStation("Egg_4_1", CFrame.new(-12, 0.5, 265))
        EggService.spawnEggStation("Egg_4_2", CFrame.new(12, 0.5, 280))
        EggService.spawnEggStation("Egg_4_3", CFrame.new(-12, 0.5, 295))
    end
end

return EggService

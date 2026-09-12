--!strict
-- ServerScriptService/ZoneService.lua
-- Controls zone gates and barrier access based on player Wins thresholds.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ZonesConfig = require(ReplicatedStorage.Config.ZonesConfig)
local DataManager = require(ServerScriptService.DataManager)

local ZoneService = {}

local function setupGates()
    local zonesFolder = (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Zones")) or Workspace:FindFirstChild("Zones")
    if not zonesFolder then
        zonesFolder = Instance.new("Folder")
        zonesFolder.Name = "Zones"
        zonesFolder.Parent = Workspace
    end

    for zoneId, zoneInfo in pairs(ZonesConfig) do
        if zoneInfo.RequiredWins > 0 then
            -- Find the gate barrier part (either as child or descendant of a Gate model)
            local gate: BasePart? = nil
            local found = zonesFolder:FindFirstChild(zoneInfo.GateBarrierName, true)
            if found and found:IsA("BasePart") then
                gate = found
            end

            if not gate then
                -- Spawn a default barrier wall if MapService didn't build one
                gate = Instance.new("Part")
                gate.Name = zoneInfo.GateBarrierName
                gate.Size = Vector3.new(20, 15, 2)
                gate.Position = Vector3.new(30 * (zoneId - 1), 7.5, -40)
                gate.Anchored = true
                gate.Material = Enum.Material.ForceField
                gate.Color = Color3.fromRGB(255, 60, 60)
                gate.Transparency = 0.3
                gate.Parent = zonesFolder

                -- Billboard label displaying requirement
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 200, 0, 60)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = gate

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0.5, 0)
                title.BackgroundTransparency = 1
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextStrokeTransparency = 0.2
                title.TextScaled = true
                title.Font = Enum.Font.FredokaOne
                title.Text = zoneInfo.Name
                title.Parent = billboard

                local req = Instance.new("TextLabel")
                req.Size = UDim2.new(1, 0, 0.5, 0)
                req.Position = UDim2.new(0, 0, 0.5, 0)
                req.BackgroundTransparency = 1
                req.TextColor3 = Color3.fromRGB(255, 220, 0)
                req.TextStrokeTransparency = 0.2
                req.TextScaled = true
                req.Font = Enum.Font.FredokaOne
                req.Text = "Requires " .. tostring(zoneInfo.RequiredWins) .. " Wins"
                req.Parent = billboard
            end

            -- Pass-through check on touch
            gate.Touched:Connect(function(hit)
                local character = hit.Parent
                if character then
                    local player = Players:GetPlayerFromCharacter(character)
                    if player then
                        local wins = DataManager.getWins(player)
                        if wins >= zoneInfo.RequiredWins then
                            -- Temporarily allow pass-through
                            local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
                            if hrp and (hrp.Position - gate.Position).Magnitude < 15 then
                                -- Teleport slightly past the gate to prevent getting stuck
                                local forward = gate.CFrame.LookVector
                                hrp.CFrame = hrp.CFrame + (forward * 3)
                            end
                        end
                    end
                end
            end)
        end
    end
end

function ZoneService.init()
    setupGates()
end

return ZoneService

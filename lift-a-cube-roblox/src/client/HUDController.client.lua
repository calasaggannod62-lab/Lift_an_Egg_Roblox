--!strict
-- StarterPlayerScripts/HUDController.client.lua
-- Creates and manages the modern game HUD (Stats, Auto-Train toggle, Shop & Chest buttons).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local remotesModule = ReplicatedStorage:WaitForChild("Remotes", 15)
if not remotesModule:IsA("ModuleScript") then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child.Name == "Remotes" and child:IsA("ModuleScript") then
            remotesModule = child
            break
        end
    end
end
local Remotes = require(remotesModule :: ModuleScript)

local ConfigFolder = ReplicatedStorage:WaitForChild("Config", 15)
local ArmsConfig = require(ConfigFolder:WaitForChild("ArmsConfig", 15) :: ModuleScript)
local MaterialsConfig = require(ConfigFolder:WaitForChild("MaterialsConfig", 15) :: ModuleScript)
local NumberFormat = require(script.Parent:WaitForChild("NumberFormat", 15) :: ModuleScript)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local autoTrainRemote = Remotes.getEvent(Remotes.Names.ToggleAutoTrain)
local dataUpdatedRemote = Remotes.getEvent(Remotes.Names.DataUpdated)

local isAutoTraining = false

-- Create Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LiftAnEgg_HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Top Stats Container
local statsContainer = Instance.new("Frame")
statsContainer.Name = "StatsContainer"
statsContainer.Size = UDim2.new(0, 360, 0, 75)
statsContainer.Position = UDim2.new(0.5, -180, 0, 15)
statsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
statsContainer.BackgroundTransparency = 0.25
statsContainer.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsContainer

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = Color3.fromRGB(80, 85, 100)
statsStroke.Thickness = 2
statsStroke.Parent = statsContainer

-- Strength Label
local strengthFrame = Instance.new("Frame")
strengthFrame.Size = UDim2.new(0.5, -10, 0.5, -5)
strengthFrame.Position = UDim2.new(0, 8, 0, 6)
strengthFrame.BackgroundTransparency = 1
strengthFrame.Parent = statsContainer

local strengthLabel = Instance.new("TextLabel")
strengthLabel.Size = UDim2.new(1, 0, 1, 0)
strengthLabel.BackgroundTransparency = 1
strengthLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
strengthLabel.Font = Enum.Font.FredokaOne
strengthLabel.TextScaled = true
strengthLabel.Text = "💪 0"
strengthLabel.TextXAlignment = Enum.TextXAlignment.Left
strengthLabel.Parent = strengthFrame

-- Wins Label
local winsFrame = Instance.new("Frame")
winsFrame.Size = UDim2.new(0.5, -10, 0.5, -5)
winsFrame.Position = UDim2.new(0.5, 2, 0, 6)
winsFrame.BackgroundTransparency = 1
winsFrame.Parent = statsContainer

local winsLabel = Instance.new("TextLabel")
winsLabel.Size = UDim2.new(1, 0, 1, 0)
winsLabel.BackgroundTransparency = 1
winsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
winsLabel.Font = Enum.Font.FredokaOne
winsLabel.TextScaled = true
winsLabel.Text = "🏆 0"
winsLabel.TextXAlignment = Enum.TextXAlignment.Left
winsLabel.Parent = winsFrame

-- Sub-Stats Badges (Speed & Multiplier)
local subStatsFrame = Instance.new("Frame")
subStatsFrame.Size = UDim2.new(1, -16, 0.4, 0)
subStatsFrame.Position = UDim2.new(0, 8, 0.55, 0)
subStatsFrame.BackgroundTransparency = 1
subStatsFrame.Parent = statsContainer

local armSpeedLabel = Instance.new("TextLabel")
armSpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
armSpeedLabel.BackgroundTransparency = 1
armSpeedLabel.TextColor3 = Color3.fromRGB(160, 200, 255)
armSpeedLabel.Font = Enum.Font.FredokaOne
armSpeedLabel.TextScaled = true
armSpeedLabel.Text = "⚡ Speed: 1.0s"
armSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
armSpeedLabel.Parent = subStatsFrame

local multiplierLabel = Instance.new("TextLabel")
multiplierLabel.Size = UDim2.new(0.5, 0, 1, 0)
multiplierLabel.Position = UDim2.new(0.5, 0, 0, 0)
multiplierLabel.BackgroundTransparency = 1
multiplierLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
multiplierLabel.Font = Enum.Font.FredokaOne
multiplierLabel.TextScaled = true
multiplierLabel.Text = "🥚 Shell: 1x"
multiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
multiplierLabel.Parent = subStatsFrame

-- Right Sidebar Buttons (Auto-Train, Shop, Incubators)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 0, 220)
sidebar.Position = UDim2.new(1, -155, 0.5, -110)
sidebar.BackgroundTransparency = 1
sidebar.Parent = screenGui

local function createButton(name: string, text: string, color: Color3, yPos: number): TextButton
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.FredokaOne
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = btn

    return btn
end

local autoTrainBtn = createButton("AutoTrainBtn", "AUTO: OFF", Color3.fromRGB(60, 60, 65), 0)
local shopBtn = createButton("ShopBtn", "🛒 ARMS SHOP", Color3.fromRGB(40, 120, 220), 65)
local chestBtn = createButton("ChestBtn", "🥚 INCUBATORS", Color3.fromRGB(210, 140, 20), 130)

-- Auto-train click handler
autoTrainBtn.MouseButton1Click:Connect(function()
    isAutoTraining = not isAutoTraining
    autoTrainRemote:FireServer(isAutoTraining)

    if isAutoTraining then
        autoTrainBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 70)
        autoTrainBtn.Text = "AUTO: ON ⚡"
    else
        autoTrainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        autoTrainBtn.Text = "AUTO: OFF"
    end
end)

-- Button toggles for Shop and Chests
shopBtn.MouseButton1Click:Connect(function()
    local shopGui = playerGui:FindFirstChild("LiftAnEgg_Shop")
    if shopGui then
        local frame = shopGui:FindFirstChild("ShopFrame") :: Frame?
        if frame then
            frame.Visible = not frame.Visible
        end
    end
end)

chestBtn.MouseButton1Click:Connect(function()
    local chestGui = playerGui:FindFirstChild("LiftAnEgg_Chests")
    if chestGui then
        local frame = chestGui:FindFirstChild("ChestFrame") :: Frame?
        if frame then
            frame.Visible = not frame.Visible
        end
    end
end)

-- Handle Data Updated from server
dataUpdatedRemote.OnClientEvent:Connect(function(profile: any)
    if profile.Strength ~= nil then
        strengthLabel.Text = "💪 " .. NumberFormat.format(profile.Strength)
    end
    if profile.Wins ~= nil then
        winsLabel.Text = "🏆 " .. NumberFormat.format(profile.Wins)
    end

    if profile.EquippedArm then
        local armData = ArmsConfig.Arms[profile.EquippedArm]
        if armData then
            armSpeedLabel.Text = string.format("⚡ Speed: %.2fs", armData.SpeedCooldown)
        end
    end

    if profile.EquippedMaterial then
        local matData = MaterialsConfig.Materials[profile.EquippedMaterial]
        if matData then
            multiplierLabel.Text = "✨ Multi: " .. NumberFormat.format(matData.Multiplier) .. "x"
            multiplierLabel.TextColor3 = matData.RarityColor
        end
    end
end)

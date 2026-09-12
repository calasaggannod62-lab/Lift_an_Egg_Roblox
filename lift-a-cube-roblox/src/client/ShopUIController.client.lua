--!strict
-- StarterPlayerScripts/ShopUIController.client.lua
-- Manages the Arm Upgrade Shop interface, displaying tiers, stats, costs, and buy buttons.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local NumberFormat = require(script.Parent:WaitForChild("NumberFormat", 15) :: ModuleScript)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local buyRemote = Remotes.getFunction(Remotes.Names.BuyArmRequest)
local dataUpdatedRemote = Remotes.getEvent(Remotes.Names.DataUpdated)

local currentProfile: any = nil

-- ScreenGui for Shop
local shopGui = Instance.new("ScreenGui")
shopGui.Name = "LiftAnEgg_Shop"
shopGui.ResetOnSpawn = false
shopGui.Parent = playerGui

-- Main Shop Frame
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 480, 0, 420)
shopFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
shopFrame.Visible = false
shopFrame.Parent = shopGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = shopFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(65, 120, 240)
stroke.Thickness = 2.5
stroke.Parent = shopFrame

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -60, 0, 50)
header.Position = UDim2.new(0, 20, 0, 10)
header.BackgroundTransparency = 1
header.Text = "🦾 ARMS UPGRADE SHOP"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.FredokaOne
header.TextScaled = true
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = shopFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -48, 0, 15)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.FredokaOne
closeBtn.TextScaled = true
closeBtn.Parent = shopFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

-- Scrolling list for arms
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 1, -80)
scroll.Position = UDim2.new(0, 15, 0, 65)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, #ArmsConfig.Order * 70)
scroll.Parent = shopFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scroll

local armCards: { [string]: { Button: TextButton, ArmData: ArmsConfig.ArmData } } = {}

-- Refresh button states based on player data
local function refreshButtons()
    if not currentProfile then return end

    for armId, card in pairs(armCards) do
        local armData = card.ArmData
        local isOwned = currentProfile.OwnedArms and currentProfile.OwnedArms[armId]
        local isEquipped = currentProfile.EquippedArm == armId

        if isEquipped then
            card.Button.Text = "EQUIPPED"
            card.Button.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        elseif isOwned then
            card.Button.Text = "EQUIP"
            card.Button.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        else
            card.Button.Text = "BUY: " .. NumberFormat.format(armData.Cost) .. " 🏆"
            if currentProfile.Wins >= armData.Cost then
                card.Button.BackgroundColor3 = Color3.fromRGB(220, 160, 30)
            else
                card.Button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            end
        end
    end
end

-- Create an arm item card in the shop
local function createArmCard(armId: string, orderIndex: number)
    local armData = ArmsConfig.Arms[armId]
    if not armData then return end

    local card = Instance.new("Frame")
    card.Name = armId
    card.Size = UDim2.new(1, -10, 0, 62)
    card.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    card.LayoutOrder = orderIndex
    card.Parent = scroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.55, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = armData.Name
    nameLabel.Parent = card

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.55, 0, 0.4, 0)
    speedLabel.Position = UDim2.new(0, 12, 0.5, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    speedLabel.Font = Enum.Font.FredokaOne
    speedLabel.TextScaled = true
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Text = string.format("Cooldown: %.2fs", armData.SpeedCooldown)
    speedLabel.Parent = card

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0.38, 0, 0.7, 0)
    actionBtn.Position = UDim2.new(0.6, 0, 0.15, 0)
    actionBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 30)
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.Font = Enum.Font.FredokaOne
    actionBtn.TextScaled = true
    actionBtn.Text = "BUY"
    actionBtn.Parent = card

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = actionBtn

    actionBtn.MouseButton1Click:Connect(function()
        local success, msg = buyRemote:InvokeServer(armId)
        if success then
            refreshButtons()
        end
    end)

    armCards[armId] = {
        Button = actionBtn,
        ArmData = armData,
    }
end

-- Initialize shop list
for i, armId in ipairs(ArmsConfig.Order) do
    createArmCard(armId, i)
end

dataUpdatedRemote.OnClientEvent:Connect(function(profile)
    currentProfile = profile
    refreshButtons()
end)

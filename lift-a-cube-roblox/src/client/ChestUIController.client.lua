--!strict
-- StarterPlayerScripts/ChestUIController.client.lua
-- Manages Chest rolling GUI, unboxing reveal animations, and rarity highlights.

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
local MaterialsConfig = require(ConfigFolder:WaitForChild("MaterialsConfig", 15) :: ModuleScript)
local NumberFormat = require(script.Parent:WaitForChild("NumberFormat", 15) :: ModuleScript)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local openChestRemote = Remotes.getFunction(Remotes.Names.OpenChestRequest)

-- ScreenGui for Chests
local chestGui = Instance.new("ScreenGui")
chestGui.Name = "LiftAnEgg_Chests"
chestGui.ResetOnSpawn = false
chestGui.Parent = playerGui

-- Main Chest Frame
local chestFrame = Instance.new("Frame")
chestFrame.Name = "ChestFrame"
chestFrame.Size = UDim2.new(0, 520, 0, 360)
chestFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
chestFrame.BackgroundColor3 = Color3.fromRGB(24, 22, 30)
chestFrame.Visible = false
chestFrame.Parent = chestGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = chestFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 180, 40)
stroke.Thickness = 2.5
stroke.Parent = chestFrame

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -60, 0, 50)
header.Position = UDim2.new(0, 20, 0, 10)
header.BackgroundTransparency = 1
header.Text = "🥚 INCUBATOR SHELL CHESTS"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.FredokaOne
header.TextScaled = true
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = chestFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -48, 0, 15)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.FredokaOne
closeBtn.TextScaled = true
closeBtn.Parent = chestFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    chestFrame.Visible = false
end)

-- Container for chest cards
local chestCardsContainer = Instance.new("Frame")
chestCardsContainer.Size = UDim2.new(1, -30, 0, 260)
chestCardsContainer.Position = UDim2.new(0, 15, 0, 70)
chestCardsContainer.BackgroundTransparency = 1
chestCardsContainer.Parent = chestFrame

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0, 155, 0, 240)
layout.CellPadding = UDim2.new(0, 12, 0, 10)
layout.Parent = chestCardsContainer

-- Unboxing Reveal Modal
local revealModal = Instance.new("Frame")
revealModal.Name = "RevealModal"
revealModal.Size = UDim2.new(0, 380, 0, 260)
revealModal.Position = UDim2.new(0.5, -190, 0.5, -130)
revealModal.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
revealModal.Visible = false
revealModal.ZIndex = 10
revealModal.Parent = chestGui

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 16)
modalCorner.Parent = revealModal

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(255, 255, 255)
modalStroke.Thickness = 3
modalStroke.Parent = revealModal

local resultRarity = Instance.new("TextLabel")
resultRarity.Size = UDim2.new(1, 0, 0, 35)
resultRarity.Position = UDim2.new(0, 0, 0, 20)
resultRarity.BackgroundTransparency = 1
resultRarity.Font = Enum.Font.FredokaOne
resultRarity.TextScaled = true
resultRarity.Text = "LEGENDARY!"
resultRarity.ZIndex = 11
resultRarity.Parent = revealModal

local resultName = Instance.new("TextLabel")
resultName.Size = UDim2.new(1, 0, 0, 50)
resultName.Position = UDim2.new(0, 0, 0, 65)
resultName.BackgroundTransparency = 1
resultName.TextColor3 = Color3.fromRGB(255, 255, 255)
resultName.Font = Enum.Font.FredokaOne
resultName.TextScaled = true
resultName.Text = "Diamond Arm"
resultName.ZIndex = 11
resultName.Parent = revealModal

local resultMulti = Instance.new("TextLabel")
resultMulti.Size = UDim2.new(1, 0, 0, 35)
resultMulti.Position = UDim2.new(0, 0, 0, 125)
resultMulti.BackgroundTransparency = 1
resultMulti.TextColor3 = Color3.fromRGB(255, 220, 50)
resultMulti.Font = Enum.Font.FredokaOne
resultMulti.TextScaled = true
resultMulti.Text = "+200x Strength Multiplier"
resultMulti.ZIndex = 11
resultMulti.Parent = revealModal

local okBtn = Instance.new("TextButton")
okBtn.Size = UDim2.new(0.6, 0, 0, 45)
okBtn.Position = UDim2.new(0.2, 0, 0, 190)
okBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
okBtn.Text = "AWESOME!"
okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
okBtn.Font = Enum.Font.FredokaOne
okBtn.TextScaled = true
okBtn.ZIndex = 11
okBtn.Parent = revealModal

local okCorner = Instance.new("UICorner")
okCorner.CornerRadius = UDim.new(0, 8)
okCorner.Parent = okBtn

okBtn.MouseButton1Click:Connect(function()
    revealModal.Visible = false
end)

local function playRevealAnimation(data: any)
    local rarityColor = Color3.new(data.RarityColor[1], data.RarityColor[2], data.RarityColor[3])
    modalStroke.Color = rarityColor
    resultRarity.Text = string.upper(data.Rarity) .. "!"
    resultRarity.TextColor3 = rarityColor
    resultName.Text = data.Name .. " Arm"
    resultMulti.Text = "+" .. NumberFormat.format(data.Multiplier) .. "x Strength Multiplier"

    revealModal.Visible = true
    revealModal.Size = UDim2.new(0, 50, 0, 50)
    revealModal.Position = UDim2.new(0.5, -25, 0.5, -25)

    local popTween = TweenService:Create(
        revealModal,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, 380, 0, 260), Position = UDim2.new(0.5, -190, 0.5, -130) }
    )
    popTween:Play()
end

local function createChestCard(chestId: string, chestData: MaterialsConfig.ChestData)
    local card = Instance.new("Frame")
    card.Name = chestId
    card.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
    card.Parent = chestCardsContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(70, 65, 90)
    cardStroke.Thickness = 1.5
    cardStroke.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 35)
    nameLabel.Position = UDim2.new(0, 5, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextScaled = true
    nameLabel.Text = chestData.Name
    nameLabel.Parent = card

    -- Icon placeholder / chest emoji
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0, 65)
    iconLabel.Position = UDim2.new(0, 0, 0, 48)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.FredokaOne
    iconLabel.TextScaled = true
    iconLabel.Text = "📦"
    iconLabel.Parent = card

    -- Open button
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0.9, 0, 0, 42)
    openBtn.Position = UDim2.new(0.05, 0, 1, -52)
    openBtn.BackgroundColor3 = Color3.fromRGB(220, 140, 20)
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.Font = Enum.Font.FredokaOne
    openBtn.TextScaled = true
    openBtn.Text = "OPEN: " .. NumberFormat.format(chestData.Cost) .. " 🏆"
    openBtn.Parent = card

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = openBtn

    openBtn.MouseButton1Click:Connect(function()
        local success, result = openChestRemote:InvokeServer(chestId)
        if success then
            playRevealAnimation(result)
        end
    end)
end

for chestId, chestData in pairs(MaterialsConfig.Chests) do
    createChestCard(chestId, chestData)
end

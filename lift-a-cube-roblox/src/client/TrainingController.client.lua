--!strict
-- StarterPlayerScripts/TrainingController.client.lua
-- Manages client-side push-up inputs, auto-train, and visual feedback effects.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
local NumberFormat = require(script.Parent:WaitForChild("NumberFormat", 15) :: ModuleScript)

local player = Players.LocalPlayer
local trainRequest = Remotes.getEvent(Remotes.Names.TrainRequest)
local feedbackEvent = Remotes.getEvent(Remotes.Names.TrainingFeedback)

-- Display floating "+X Strength" popup text
local function showFloatingGain(amount: number)
    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head") :: BasePart?
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 2, math.random(-10, 10) / 10)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 60, 60)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.FredokaOne
    label.Text = "+" .. NumberFormat.format(amount) .. " Strength!"
    label.Parent = billboard

    -- Float upwards and fade out
    local tween = TweenService:Create(
        billboard,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { StudsOffset = billboard.StudsOffset + Vector3.new(0, 3, 0) }
    )
    local fadeTween = TweenService:Create(
        label,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { TextTransparency = 1, TextStrokeTransparency = 1 }
    )

    tween:Play()
    fadeTween:Play()
    tween.Completed:Connect(function()
        billboard:Destroy()
    end)
end

-- Procedural push-up motion if no external animation is loaded
local function playPushUpMotion()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end

    -- Dip down and back up smoothly
    local originalCFrame = rootPart.CFrame
    local dipCFrame = originalCFrame * CFrame.new(0, -1.8, 0) * CFrame.Angles(math.rad(-80), 0, 0)

    local dipTween = TweenService:Create(
        rootPart,
        TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { CFrame = dipCFrame }
    )
    local riseTween = TweenService:Create(
        rootPart,
        TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
        { CFrame = originalCFrame }
    )

    dipTween:Play()
    dipTween.Completed:Connect(function()
        riseTween:Play()
    end)
end

-- Listen for server feedback
feedbackEvent.OnClientEvent:Connect(function(gainAmount: number)
    showFloatingGain(gainAmount)
    playPushUpMotion()
end)

-- Click/Tap to train
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        trainRequest:FireServer()
    end
end)

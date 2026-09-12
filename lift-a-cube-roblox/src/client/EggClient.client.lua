--!strict
-- StarterPlayerScripts/EggClient.client.lua
-- Handles client-side egg carrying poses, drop hotkeys (Q / Backspace), and delivery effects.

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

local player = Players.LocalPlayer
local dropRemote = Remotes.getEvent(Remotes.Names.DropEggRequest)

-- Press 'Q' or 'Backspace' to drop carried egg
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.Backspace then
        dropRemote:FireServer()
    end
end)

-- Monitor when a carried egg is welded to player's character
local function setupCarryVisuals(character: Model)
    character.ChildAdded:Connect(function(child)
        if child.Name == "CarriedEgg" and child:IsA("BasePart") then
            -- Create carry pose: hold arms upwards to cradle the egg
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
                local rightShoulder = character:FindFirstChild("RightUpperArm") and character.RightUpperArm:FindFirstChild("RightShoulder") :: Motor6D?
                local leftShoulder = character:FindFirstChild("LeftUpperArm") and character.LeftUpperArm:FindFirstChild("LeftShoulder") :: Motor6D?

                if rightShoulder and leftShoulder then
                    local targetAngle = CFrame.Angles(math.rad(140), 0, math.rad(20))
                    TweenService:Create(rightShoulder, TweenInfo.new(0.25), { Transform = targetAngle }):Play()
                    TweenService:Create(leftShoulder, TweenInfo.new(0.25), { Transform = targetAngle }):Play()
                end
            end
        end
    end)
end

if player.Character then
    setupCarryVisuals(player.Character)
end

player.CharacterAdded:Connect(setupCarryVisuals)

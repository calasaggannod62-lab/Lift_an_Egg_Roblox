--!strict
-- ReplicatedStorage/Remotes.lua
-- Centralized networking helper between Client and Server.
-- Self-heals conflicting folders and manages RemoteEvents/RemoteFunctions.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isServer = RunService:IsServer()

-- Self-healing: if an old Folder named "Remotes" exists, clean it up to prevent require collisions
if isServer then
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child.Name == "Remotes" and child:IsA("Folder") then
            child:Destroy()
        end
    end
end

-- NetworkRemotes folder stores the actual RemoteEvent / RemoteFunction instances
local RemotesFolder: Folder
if isServer then
    RemotesFolder = ReplicatedStorage:FindFirstChild("NetworkRemotes") :: Folder
    if not RemotesFolder then
        RemotesFolder = Instance.new("Folder")
        RemotesFolder.Name = "NetworkRemotes"
        RemotesFolder.Parent = ReplicatedStorage
    end
else
    RemotesFolder = ReplicatedStorage:WaitForChild("NetworkRemotes", 15) :: Folder
end

local Remotes = {}

function Remotes.getEvent(name: string): RemoteEvent
    if isServer then
        local remote = RemotesFolder:FindFirstChild(name)
        if not remote then
            remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = RemotesFolder
        end
        return remote :: RemoteEvent
    else
        return RemotesFolder:WaitForChild(name, 15) :: RemoteEvent
    end
end

function Remotes.getFunction(name: string): RemoteFunction
    if isServer then
        local remote = RemotesFolder:FindFirstChild(name)
        if not remote then
            remote = Instance.new("RemoteFunction")
            remote.Name = name
            remote.Parent = RemotesFolder
        end
        return remote :: RemoteFunction
    else
        return RemotesFolder:WaitForChild(name, 15) :: RemoteFunction
    end
end

Remotes.Names = {
    TrainRequest = "TrainRequest",
    ToggleAutoTrain = "ToggleAutoTrain",
    TrainingFeedback = "TrainingFeedback",
    LiftEggRequest = "LiftEggRequest",
    FinishEggCarry = "FinishEggCarry",
    DropEggRequest = "DropEggRequest",
    BuyArmRequest = "BuyArmRequest",
    OpenChestRequest = "OpenChestRequest",
    DataUpdated = "DataUpdated",
}

return Remotes

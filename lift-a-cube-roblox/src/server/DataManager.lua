--!strict
-- ServerScriptService/DataManager.lua
-- Robust DataStoreService wrapper with session caching, autosaving, and BindToClose protection.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

local DATA_VERSION = "v1.0.0"
local DATA_STORE_NAME = "LiftACube_PlayerData_" .. DATA_VERSION
local AUTOSAVE_INTERVAL = 120 -- seconds

local PlayerDataStore
local success, err = pcall(function()
    PlayerDataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)
end)
if not success then
    warn("[DataManager] DataStoreService unavailable or API requests disabled in Studio:", err)
end

export type PlayerProfile = {
    Strength: number,
    Wins: number,
    EquippedArm: string,
    EquippedMaterial: string,
    OwnedArms: { [string]: boolean },
    OwnedMaterials: { [string]: boolean },
    UnlockedZones: { [number]: boolean },
}

local DEFAULT_PROFILE: PlayerProfile = {
    Strength = 0,
    Wins = 0,
    EquippedArm = "Default Arm",
    EquippedMaterial = "Calcite",
    OwnedArms = { ["Default Arm"] = true },
    OwnedMaterials = { ["Calcite"] = true },
    UnlockedZones = { [1] = true },
}

local sessionData: { [Player]: PlayerProfile } = {}

local DataManager = {}

local function deepCopy<T>(original: T): T
    if type(original) ~= "table" then
        return original
    end
    local copy = {}
    for k, v in pairs(original :: any) do
        copy[k] = deepCopy(v)
    end
    return copy :: any
end

-- Reconcile loaded data with defaults in case new fields were added
local function reconcile(loaded: any, default: any): any
    if type(default) ~= "table" then
        return if loaded ~= nil then loaded else default
    end
    if type(loaded) ~= "table" then
        return deepCopy(default)
    end
    for k, v in pairs(default) do
        loaded[k] = reconcile(loaded[k], v)
    end
    return loaded
end

function DataManager.loadData(player: Player): PlayerProfile
    local key = "Player_" .. player.UserId
    local loadedData = nil
    
    if PlayerDataStore then
        local successLoad, result = pcall(function()
            return PlayerDataStore:GetAsync(key)
        end)
        if successLoad and result then
            loadedData = result
        elseif not successLoad then
            warn("[DataManager] Failed to load data for", player.Name, result)
        end
    end

    local profile: PlayerProfile = reconcile(loadedData, DEFAULT_PROFILE)
    sessionData[player] = profile
    return profile
end

function DataManager.saveData(player: Player)
    local profile = sessionData[player]
    if not profile or not PlayerDataStore then return end

    local key = "Player_" .. player.UserId
    local successSave, result = pcall(function()
        PlayerDataStore:SetAsync(key, profile)
    end)

    if not successSave then
        warn("[DataManager] Failed to save data for", player.Name, result)
    end
end

function DataManager.getData(player: Player): PlayerProfile?
    return sessionData[player]
end

function DataManager.getStrength(player: Player): number
    local profile = sessionData[player]
    return if profile then profile.Strength else 0
end

function DataManager.addStrength(player: Player, amount: number)
    local profile = sessionData[player]
    if profile then
        profile.Strength = math.max(0, profile.Strength + amount)
        DataManager.syncLeaderstats(player)
    end
end

function DataManager.getWins(player: Player): number
    local profile = sessionData[player]
    return if profile then profile.Wins else 0
end

function DataManager.addWins(player: Player, amount: number)
    local profile = sessionData[player]
    if profile then
        profile.Wins = math.max(0, profile.Wins + amount)
        DataManager.syncLeaderstats(player)
    end
end

function DataManager.deductWins(player: Player, amount: number): boolean
    local profile = sessionData[player]
    if profile and profile.Wins >= amount then
        profile.Wins -= amount
        DataManager.syncLeaderstats(player)
        return true
    end
    return false
end

function DataManager.getEquippedArm(player: Player): string
    local profile = sessionData[player]
    return if profile then profile.EquippedArm else "Default Arm"
end

function DataManager.setEquippedArm(player: Player, armId: string)
    local profile = sessionData[player]
    if profile then
        profile.EquippedArm = armId
        profile.OwnedArms[armId] = true
        DataManager.syncToClient(player)
    end
end

function DataManager.getEquippedMaterial(player: Player): string
    local profile = sessionData[player]
    return if profile then profile.EquippedMaterial else "Plastic"
end

function DataManager.setEquippedMaterial(player: Player, materialId: string)
    local profile = sessionData[player]
    if profile then
        profile.EquippedMaterial = materialId
        profile.OwnedMaterials[materialId] = true
        DataManager.syncToClient(player)
    end
end

function DataManager.syncLeaderstats(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    local profile = sessionData[player]
    if leaderstats and profile then
        local strengthVal = leaderstats:FindFirstChild("Strength") :: NumberValue?
        if strengthVal then
            strengthVal.Value = profile.Strength
        end
        local winsVal = leaderstats:FindFirstChild("Wins") :: NumberValue?
        if winsVal then
            winsVal.Value = profile.Wins
        end
    end
    DataManager.syncToClient(player)
end

function DataManager.syncToClient(player: Player)
    local profile = sessionData[player]
    if profile then
        local remote = Remotes.getEvent(Remotes.Names.DataUpdated)
        remote:FireClient(player, profile)
    end
end

-- Setup player join/leave & autosave
function DataManager.init()
    Players.PlayerAdded:Connect(function(player)
        DataManager.loadData(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        DataManager.saveData(player)
        sessionData[player] = nil
    end)

    -- Periodic Autosave
    task.spawn(function()
        while true do
            task.wait(AUTOSAVE_INTERVAL)
            for _, player in ipairs(Players:GetPlayers()) do
                DataManager.saveData(player)
            end
        end
    end)

    -- BindToClose to save all players before server closes
    game:BindToClose(function()
        for _, player in ipairs(Players:GetPlayers()) do
            DataManager.saveData(player)
        end
    end)
end

return DataManager

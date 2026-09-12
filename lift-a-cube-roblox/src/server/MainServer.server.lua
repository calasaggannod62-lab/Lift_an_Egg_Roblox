--!strict
-- ServerScriptService/MainServer.server.lua
-- Master server bootstrapper that initializes all server services in sequence.

local ServerScriptService = game:GetService("ServerScriptService")

print("--- [Lift an Egg] Starting Game Services ---")

local MapService = require(ServerScriptService.MapService)
local DataManager = require(ServerScriptService.DataManager)
local LeaderstatsService = require(ServerScriptService.LeaderstatsService)
local TrainingService = require(ServerScriptService.TrainingService)
local EggService = require(ServerScriptService.EggService)
local ShopService = require(ServerScriptService.ShopService)
local ChestService = require(ServerScriptService.ChestService)
local ZoneService = require(ServerScriptService.ZoneService)

-- Build 3D world, islands, and gates first
MapService.init()
print("[Lift an Egg] MapService Initialized (World Generated)")

DataManager.init()
print("[Lift an Egg] DataManager Initialized")

LeaderstatsService.init()
print("[Lift an Egg] LeaderstatsService Initialized")

TrainingService.init()
print("[Lift an Egg] TrainingService Initialized")

EggService.init()
print("[Lift an Egg] EggService Initialized")

ShopService.init()
print("[Lift an Egg] ShopService Initialized")

ChestService.init()
print("[Lift an Egg] ChestService Initialized")

ZoneService.init()
print("[Lift an Egg] ZoneService Initialized")

print("--- [Lift an Egg] All Game Services Online! ---")

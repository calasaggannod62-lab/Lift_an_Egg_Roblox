--!strict
-- ReplicatedStorage/Config/MaterialsConfig.lua
-- Eggshell Infused Arm Materials: rolled from Incubator Chests.
-- Grants Strength Multipliers & alters character arm appearance.

export type MaterialData = {
    Id: string,
    Name: string,
    Multiplier: number,
    Rarity: string,
    RarityColor: Color3,
    ArmMaterial: Enum.Material,
    ArmColor: Color3,
    HasParticle: boolean,
    ParticleColor: Color3?,
}

local Materials: { [string]: MaterialData } = {
    ["Calcite"] = {
        Id = "Calcite",
        Name = "Calcite Shell",
        Multiplier = 1,
        Rarity = "Common",
        RarityColor = Color3.fromRGB(200, 200, 200),
        ArmMaterial = Enum.Material.SmoothPlastic,
        ArmColor = Color3.fromRGB(245, 240, 235),
        HasParticle = false,
    },
    ["Woodland"] = {
        Id = "Woodland",
        Name = "Woodland Shell",
        Multiplier = 2,
        Rarity = "Common",
        RarityColor = Color3.fromRGB(160, 120, 80),
        ArmMaterial = Enum.Material.Wood,
        ArmColor = Color3.fromRGB(145, 95, 45),
        HasParticle = false,
    },
    ["Fossil"] = {
        Id = "Fossil",
        Name = "Fossil Shell",
        Multiplier = 5,
        Rarity = "Uncommon",
        RarityColor = Color3.fromRGB(110, 190, 75),
        ArmMaterial = Enum.Material.Slate,
        ArmColor = Color3.fromRGB(105, 115, 100),
        HasParticle = false,
    },
    ["Iron"] = {
        Id = "Iron",
        Name = "Iron Shell",
        Multiplier = 15,
        Rarity = "Rare",
        RarityColor = Color3.fromRGB(75, 150, 255),
        ArmMaterial = Enum.Material.Metal,
        ArmColor = Color3.fromRGB(180, 190, 205),
        HasParticle = false,
    },
    ["Golden"] = {
        Id = "Golden",
        Name = "Golden Shell",
        Multiplier = 50,
        Rarity = "Epic",
        RarityColor = Color3.fromRGB(255, 215, 0),
        ArmMaterial = Enum.Material.Metal,
        ArmColor = Color3.fromRGB(255, 205, 25),
        HasParticle = true,
        ParticleColor = Color3.fromRGB(255, 220, 50),
    },
    ["Diamond"] = {
        Id = "Diamond",
        Name = "Diamond Shell",
        Multiplier = 200,
        Rarity = "Legendary",
        RarityColor = Color3.fromRGB(255, 110, 20),
        ArmMaterial = Enum.Material.Glass,
        ArmColor = Color3.fromRGB(80, 230, 255),
        HasParticle = true,
        ParticleColor = Color3.fromRGB(100, 240, 255),
    },
    ["DragonFlame"] = {
        Id = "DragonFlame",
        Name = "Dragon Flame Shell",
        Multiplier = 1000,
        Rarity = "Mythic",
        RarityColor = Color3.fromRGB(255, 50, 50),
        ArmMaterial = Enum.Material.Neon,
        ArmColor = Color3.fromRGB(255, 70, 10),
        HasParticle = true,
        ParticleColor = Color3.fromRGB(255, 90, 0),
    },
    ["Void"] = {
        Id = "Void",
        Name = "Void Astral Shell",
        Multiplier = 5000,
        Rarity = "Godly",
        RarityColor = Color3.fromRGB(180, 40, 255),
        ArmMaterial = Enum.Material.Neon,
        ArmColor = Color3.fromRGB(45, 0, 75),
        HasParticle = true,
        ParticleColor = Color3.fromRGB(190, 50, 255),
    },
    ["Rainbow"] = {
        Id = "Rainbow",
        Name = "Rainbow Phoenix Shell",
        Multiplier = 25000,
        Rarity = "Secret",
        RarityColor = Color3.fromRGB(255, 255, 255),
        ArmMaterial = Enum.Material.Neon,
        ArmColor = Color3.fromRGB(255, 255, 255),
        HasParticle = true,
        ParticleColor = Color3.fromRGB(255, 255, 255),
    },
}

export type ChestLootItem = {
    MaterialId: string,
    Weight: number,
}

export type ChestData = {
    Id: string,
    Name: string,
    Cost: number,
    LootTable: { ChestLootItem },
}

local Chests: { [string]: ChestData } = {
    ["StarterIncubator"] = {
        Id = "StarterIncubator",
        Name = "Farm Incubator",
        Cost = 5,
        LootTable = {
            { MaterialId = "Calcite", Weight = 500 },  -- 50%
            { MaterialId = "Woodland", Weight = 300 }, -- 30%
            { MaterialId = "Fossil", Weight = 140 },   -- 14%
            { MaterialId = "Iron", Weight = 55 },      -- 5.5%
            { MaterialId = "Golden", Weight = 5 },     -- 0.5%
        },
    },
    ["JurassicNest"] = {
        Id = "JurassicNest",
        Name = "Jurassic Nest",
        Cost = 50,
        LootTable = {
            { MaterialId = "Iron", Weight = 500 },
            { MaterialId = "Golden", Weight = 350 },
            { MaterialId = "Diamond", Weight = 130 },
            { MaterialId = "DragonFlame", Weight = 20 },
        },
    },
    ["CosmicIncubator"] = {
        Id = "CosmicIncubator",
        Name = "Cosmic Incubator",
        Cost = 500,
        LootTable = {
            { MaterialId = "Golden", Weight = 400 },
            { MaterialId = "Diamond", Weight = 350 },
            { MaterialId = "DragonFlame", Weight = 180 },
            { MaterialId = "Void", Weight = 65 },
            { MaterialId = "Rainbow", Weight = 5 },    -- 0.5% Secret!
        },
    },
}

return {
    Materials = Materials,
    Chests = Chests,
}

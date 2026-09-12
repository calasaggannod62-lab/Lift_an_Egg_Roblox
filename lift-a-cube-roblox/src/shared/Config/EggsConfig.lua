--!strict
-- ReplicatedStorage/Config/EggsConfig.lua
-- Comprehensive configuration for all themed eggs across the 4 areas.

export type EggData = {
    Id: string,
    Name: string,
    Area: number,
    AreaName: string,
    RequiredStrength: number,
    WinReward: number,
    Scale: Vector3, -- Base dimensions (X, Y, Z)
    ShellColor: Color3,
    ShellMaterial: Enum.Material,
    HasGlow: boolean,
    GlowColor: Color3?,
    Description: string,
}

local EggsConfig: { [string]: EggData } = {
    -- ==============================
    -- AREA 1: FARM MEADOW (Starter)
    -- ==============================
    ["Egg_1_1"] = {
        Id = "Egg_1_1",
        Name = "White Chicken Egg",
        Area = 1,
        AreaName = "Farm Meadow",
        RequiredStrength = 0,
        WinReward = 1,
        Scale = Vector3.new(2, 2.7, 2),
        ShellColor = Color3.fromRGB(245, 240, 230),
        ShellMaterial = Enum.Material.SmoothPlastic,
        HasGlow = false,
        Description = "A fragile little farm egg. Great for warming up!",
    },
    ["Egg_1_2"] = {
        Id = "Egg_1_2",
        Name = "Spotted Quail Egg",
        Area = 1,
        AreaName = "Farm Meadow",
        RequiredStrength = 25,
        WinReward = 3,
        Scale = Vector3.new(2.3, 3.1, 2.3),
        ShellColor = Color3.fromRGB(195, 175, 140),
        ShellMaterial = Enum.Material.Slate,
        HasGlow = false,
        Description = "Dense speckled egg from the grasslands.",
    },
    ["Egg_1_3"] = {
        Id = "Egg_1_3",
        Name = "Golden Goose Egg",
        Area = 1,
        AreaName = "Farm Meadow",
        RequiredStrength = 120,
        WinReward = 12,
        Scale = Vector3.new(2.8, 3.8, 2.8),
        ShellColor = Color3.fromRGB(255, 215, 40),
        ShellMaterial = Enum.Material.Metal,
        HasGlow = true,
        GlowColor = Color3.fromRGB(255, 230, 80),
        Description = "Solid gold! Exceptionally heavy and lucrative.",
    },
    ["Egg_1_4"] = {
        Id = "Egg_1_4",
        Name = "Giant Ostrich Egg",
        Area = 1,
        AreaName = "Farm Meadow",
        RequiredStrength = 500,
        WinReward = 40,
        Scale = Vector3.new(3.4, 4.6, 3.4),
        ShellColor = Color3.fromRGB(230, 220, 200),
        ShellMaterial = Enum.Material.SmoothPlastic,
        HasGlow = false,
        Description = "Massive thick-shelled egg that tests true farm strength.",
    },

    -- =====================================
    -- AREA 2: PREHISTORIC JUNGLE (25 Wins)
    -- =====================================
    ["Egg_2_1"] = {
        Id = "Egg_2_1",
        Name = "Velociraptor Egg",
        Area = 2,
        AreaName = "Prehistoric Jungle",
        RequiredStrength = 2000,
        WinReward = 150,
        Scale = Vector3.new(3.8, 5.1, 3.8),
        ShellColor = Color3.fromRGB(75, 130, 65),
        ShellMaterial = Enum.Material.Slate,
        HasGlow = false,
        Description = "Fossilized raptor egg with hardened primal moss.",
    },
    ["Egg_2_2"] = {
        Id = "Egg_2_2",
        Name = "Armored Triceratops Egg",
        Area = 2,
        AreaName = "Prehistoric Jungle",
        RequiredStrength = 8500,
        WinReward = 550,
        Scale = Vector3.new(4.4, 5.9, 4.4),
        ShellColor = Color3.fromRGB(140, 100, 70),
        ShellMaterial = Enum.Material.Rock,
        HasGlow = false,
        Description = "Plated like stone armor, weighing hundreds of pounds.",
    },
    ["Egg_2_3"] = {
        Id = "Egg_2_3",
        Name = "Titan T-Rex Egg",
        Area = 2,
        AreaName = "Prehistoric Jungle",
        RequiredStrength = 35000,
        WinReward = 2000,
        Scale = Vector3.new(5.0, 6.75, 5.0),
        ShellColor = Color3.fromRGB(160, 50, 40),
        ShellMaterial = Enum.Material.Granite,
        HasGlow = true,
        GlowColor = Color3.fromRGB(220, 70, 50),
        Description = "Apex predator egg vibrating with primal ferocity!",
    },

    -- =====================================
    -- AREA 3: VOLCANIC DRAGON LAIR (500 Wins)
    -- =====================================
    ["Egg_3_1"] = {
        Id = "Egg_3_1",
        Name = "Magma Drake Egg",
        Area = 3,
        AreaName = "Volcanic Dragon Lair",
        RequiredStrength = 150000,
        WinReward = 7500,
        Scale = Vector3.new(5.5, 7.4, 5.5),
        ShellColor = Color3.fromRGB(255, 80, 0),
        ShellMaterial = Enum.Material.Neon,
        HasGlow = true,
        GlowColor = Color3.fromRGB(255, 110, 0),
        Description = "Blistering egg fresh from molten lava pools.",
    },
    ["Egg_3_2"] = {
        Id = "Egg_3_2",
        Name = "Obsidian Wyrm Egg",
        Area = 3,
        AreaName = "Volcanic Dragon Lair",
        RequiredStrength = 600000,
        WinReward = 28000,
        Scale = Vector3.new(6.0, 8.1, 6.0),
        ShellColor = Color3.fromRGB(25, 20, 30),
        ShellMaterial = Enum.Material.Glass,
        HasGlow = true,
        GlowColor = Color3.fromRGB(180, 40, 220),
        Description = "Crystallized volcanic glass forged in subterranean pressure.",
    },
    ["Egg_3_3"] = {
        Id = "Egg_3_3",
        Name = "Elder Fire Dragon Egg",
        Area = 3,
        AreaName = "Volcanic Dragon Lair",
        RequiredStrength = 2500000,
        WinReward = 110000,
        Scale = Vector3.new(6.8, 9.2, 6.8),
        ShellColor = Color3.fromRGB(255, 30, 30),
        ShellMaterial = Enum.Material.Neon,
        HasGlow = true,
        GlowColor = Color3.fromRGB(255, 200, 0),
        Description = "Radiates intense inferno heat! Only true masters can budge it.",
    },

    -- ===================================
    -- AREA 4: COSMIC CORE (10,000 Wins)
    -- ===================================
    ["Egg_4_1"] = {
        Id = "Egg_4_1",
        Name = "Nebula Phoenix Egg",
        Area = 4,
        AreaName = "Cosmic Core",
        RequiredStrength = 12000000,
        WinReward = 500000,
        Scale = Vector3.new(7.2, 9.7, 7.2),
        ShellColor = Color3.fromRGB(0, 180, 255),
        ShellMaterial = Enum.Material.Neon,
        HasGlow = true,
        GlowColor = Color3.fromRGB(0, 230, 255),
        Description = "Glowing stellar dust compressed into an ethereal shell.",
    },
    ["Egg_4_2"] = {
        Id = "Egg_4_2",
        Name = "Void Leviathan Egg",
        Area = 4,
        AreaName = "Cosmic Core",
        RequiredStrength = 60000000,
        WinReward = 2200000,
        Scale = Vector3.new(7.8, 10.5, 7.8),
        ShellColor = Color3.fromRGB(80, 0, 140),
        ShellMaterial = Enum.Material.Neon,
        HasGlow = true,
        GlowColor = Color3.fromRGB(160, 40, 255),
        Description = "Contains the gravitational mass of a collapsed singularity.",
    },
    ["Egg_4_3"] = {
        Id = "Egg_4_3",
        Name = "Primordial Celestial Egg",
        Area = 4,
        AreaName = "Cosmic Core",
        RequiredStrength = 300000000,
        WinReward = 10000000,
        Scale = Vector3.new(8.5, 11.5, 8.5),
        ShellColor = Color3.fromRGB(255, 255, 255),
        ShellMaterial = Enum.Material.Neon,
        HasGlow = true,
        GlowColor = Color3.fromRGB(255, 220, 120),
        Description = "The origin of all mythical creatures in the cosmos!",
    },
}

-- Ordered lists per area for clean spawning
local EggsByArea: { [number]: { string } } = {
    [1] = { "Egg_1_1", "Egg_1_2", "Egg_1_3", "Egg_1_4" },
    [2] = { "Egg_2_1", "Egg_2_2", "Egg_2_3" },
    [3] = { "Egg_3_1", "Egg_3_2", "Egg_3_3" },
    [4] = { "Egg_4_1", "Egg_4_2", "Egg_4_3" },
}

local AllEggIds: { string } = {
    "Egg_1_1", "Egg_1_2", "Egg_1_3", "Egg_1_4",
    "Egg_2_1", "Egg_2_2", "Egg_2_3",
    "Egg_3_1", "Egg_3_2", "Egg_3_3",
    "Egg_4_1", "Egg_4_2", "Egg_4_3",
}

return {
    Eggs = EggsConfig,
    ByArea = EggsByArea,
    List = AllEggIds,
}

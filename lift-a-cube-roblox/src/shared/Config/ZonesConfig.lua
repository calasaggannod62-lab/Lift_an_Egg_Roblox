--!strict
-- ReplicatedStorage/Config/ZonesConfig.lua
-- Zones with gate requirements (Wins needed to unlock/enter each themed egg area).

export type ZoneData = {
    Id: number,
    Name: string,
    RequiredWins: number,
    GateBarrierName: string,
    ThemeColor: Color3,
    Description: string,
}

local ZonesConfig: { [number]: ZoneData } = {
    [1] = {
        Id = 1,
        Name = "Farm Meadow",
        RequiredWins = 0,
        GateBarrierName = "Zone1Gate",
        ThemeColor = Color3.fromRGB(120, 200, 80),
        Description = "Beginner pastoral area with farm and poultry eggs.",
    },
    [2] = {
        Id = 2,
        Name = "Prehistoric Jungle",
        RequiredWins = 25,
        GateBarrierName = "Zone2Gate",
        ThemeColor = Color3.fromRGB(70, 150, 60),
        Description = "Dense Jurassic wildlands holding dinosaur fossil eggs.",
    },
    [3] = {
        Id = 3,
        Name = "Volcanic Dragon Lair",
        RequiredWins = 500,
        GateBarrierName = "Zone3Gate",
        ThemeColor = Color3.fromRGB(240, 70, 30),
        Description = "Fiery cavern filled with molten dragon eggs.",
    },
    [4] = {
        Id = 4,
        Name = "Cosmic Core",
        RequiredWins = 10000,
        GateBarrierName = "Zone4Gate",
        ThemeColor = Color3.fromRGB(140, 50, 255),
        Description = "Astral dimension housing celestial stellar eggs.",
    },
}

return ZonesConfig

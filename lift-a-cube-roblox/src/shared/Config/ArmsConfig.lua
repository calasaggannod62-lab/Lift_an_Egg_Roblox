--!strict
-- ReplicatedStorage/Config/ArmsConfig.lua
-- Configuration for arm upgrades: affects push-up cooldown speed.

export type ArmData = {
    Id: string,
    Name: string,
    SpeedCooldown: number, -- Seconds per push-up (lower = faster)
    Cost: number,          -- Wins cost
    Tier: number,
    Description: string,
}

local ArmsConfig: { [string]: ArmData } = {
    ["Default Arm"] = {
        Id = "Default Arm",
        Name = "Default Arm",
        SpeedCooldown = 1.0,
        Cost = 0,
        Tier = 1,
        Description = "Standard arms. 1 push-up per second.",
    },
    ["Bronze Arm"] = {
        Id = "Bronze Arm",
        Name = "Bronze Arm",
        SpeedCooldown = 0.85,
        Cost = 50,
        Tier = 2,
        Description = "A bit firmer. Push-ups are 15% faster.",
    },
    ["Iron Arm"] = {
        Id = "Iron Arm",
        Name = "Iron Arm",
        SpeedCooldown = 0.70,
        Cost = 250,
        Tier = 3,
        Description = "Tough metallic arms. 30% faster push-ups.",
    },
    ["Golden Arm"] = {
        Id = "Golden Arm",
        Name = "Golden Arm",
        SpeedCooldown = 0.55,
        Cost = 1000,
        Tier = 4,
        Description = "Gleaming golden arms. 45% faster push-ups.",
    },
    ["Diamond Arm"] = {
        Id = "Diamond Arm",
        Name = "Diamond Arm",
        SpeedCooldown = 0.40,
        Cost = 5000,
        Tier = 5,
        Description = "Ultra-dense crystal arms. 60% faster push-ups.",
    },
    ["Cyber Arm"] = {
        Id = "Cyber Arm",
        Name = "Cyber Arm",
        SpeedCooldown = 0.25,
        Cost = 25000,
        Tier = 6,
        Description = "Piston-powered robotic arms. 75% faster push-ups.",
    },
    ["Cosmic Arm"] = {
        Id = "Cosmic Arm",
        Name = "Cosmic Arm",
        SpeedCooldown = 0.12,
        Cost = 100000,
        Tier = 7,
        Description = "Infused with stellar energy. Insanely rapid push-ups!",
    },
}

-- Order list for shop display
local ArmOrder: { string } = {
    "Default Arm",
    "Bronze Arm",
    "Iron Arm",
    "Golden Arm",
    "Diamond Arm",
    "Cyber Arm",
    "Cosmic Arm",
}

return {
    Arms = ArmsConfig,
    Order = ArmOrder,
}

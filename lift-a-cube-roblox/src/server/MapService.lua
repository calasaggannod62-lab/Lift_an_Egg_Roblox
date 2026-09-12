--!strict
-- ServerScriptService/MapService.lua
-- Generates a vibrant 3D themed simulator world with 4 areas, scenery props, archway portals, and 3D incubators.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local MapService = {}

-- Utility to create anchored parts cleanly
local function makePart(
    name: string,
    size: Vector3,
    cframe: CFrame,
    material: Enum.Material,
    color: Color3,
    canCollide: boolean,
    parent: Instance
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Material = material
    part.Color = color
    part.CanCollide = canCollide
    part.Anchored = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

-- Setup vibrant cartoony lighting
function MapService.setupLighting()
    Lighting.ClockTime = 14.5 -- Afternoon sunlight
    Lighting.Brightness = 2.5
    Lighting.OutdoorAmbient = Color3.fromRGB(120, 130, 150)
    Lighting.GlobalShadows = true

    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Density = 0.25
        atmosphere.Offset = 0.1
        atmosphere.Color = Color3.fromRGB(200, 220, 255)
        atmosphere.Decay = Color3.fromRGB(220, 180, 140)
        atmosphere.Parent = Lighting
    end

    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.5
        bloom.Size = 24
        bloom.Threshold = 1.2
        bloom.Parent = Lighting
    end
end

-- Builds a low-poly tree
local function spawnTree(cframe: CFrame, parent: Instance, foliageColor: Color3)
    local trunk = makePart("Trunk", Vector3.new(2, 8, 2), cframe + Vector3.new(0, 4, 0), Enum.Material.Wood, Color3.fromRGB(110, 70, 35), true, parent)
    local foliage1 = makePart("Foliage", Vector3.new(9, 6, 9), cframe + Vector3.new(0, 9, 0), Enum.Material.Grass, foliageColor, false, parent)
    local foliage2 = makePart("FoliageTop", Vector3.new(6, 5, 6), cframe + Vector3.new(0, 13, 0), Enum.Material.Grass, foliageColor, false, parent)
    
    local m1 = Instance.new("SpecialMesh")
    m1.MeshType = Enum.MeshType.Sphere
    m1.Parent = foliage1

    local m2 = Instance.new("SpecialMesh")
    m2.MeshType = Enum.MeshType.Sphere
    m2.Parent = foliage2
end

-- Builds a wooden fence section
local function spawnFence(cframe: CFrame, parent: Instance)
    local postL = makePart("PostL", Vector3.new(0.8, 3.5, 0.8), cframe + Vector3.new(-3, 1.75, 0), Enum.Material.Wood, Color3.fromRGB(130, 85, 45), true, parent)
    local postR = makePart("PostR", Vector3.new(0.8, 3.5, 0.8), cframe + Vector3.new(3, 1.75, 0), Enum.Material.Wood, Color3.fromRGB(130, 85, 45), true, parent)
    local rail1 = makePart("Rail1", Vector3.new(6.5, 0.5, 0.4), cframe + Vector3.new(0, 2.5, 0), Enum.Material.Wood, Color3.fromRGB(150, 95, 50), true, parent)
    local rail2 = makePart("Rail2", Vector3.new(6.5, 0.5, 0.4), cframe + Vector3.new(0, 1.2, 0), Enum.Material.Wood, Color3.fromRGB(150, 95, 50), true, parent)
end

-- Builds a floating glowing crystal spire
local function spawnCrystal(cframe: CFrame, parent: Instance, color: Color3)
    local crystal = makePart("Crystal", Vector3.new(2.5, 8, 2.5), cframe + Vector3.new(0, 4, 0), Enum.Material.Glass, color, false, parent)
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Wedge
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = crystal

    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 3
    light.Range = 14
    light.Parent = crystal
end

-- Builds monumental zone archway gate with glowing barrier forcefield
function MapService.buildGate(
    gateName: string,
    areaName: string,
    requiredWins: number,
    cframe: CFrame,
    frameColor: Color3,
    frameMaterial: Enum.Material,
    barrierColor: Color3,
    parent: Instance
): Part
    local gateModel = Instance.new("Model")
    gateModel.Name = gateName
    gateModel.Parent = parent

    -- Left and Right pillars
    local pillarL = makePart("PillarL", Vector3.new(3, 16, 3), cframe + Vector3.new(-12, 8, 0), frameMaterial, frameColor, true, gateModel)
    local pillarR = makePart("PillarR", Vector3.new(3, 16, 3), cframe + Vector3.new(12, 8, 0), frameMaterial, frameColor, true, gateModel)

    -- Top Arch lintel
    local arch = makePart("Arch", Vector3.new(27, 3.5, 3.5), cframe + Vector3.new(0, 16.5, 0), frameMaterial, frameColor, true, gateModel)

    -- Forcefield Barrier Part
    local barrier = makePart(gateName, Vector3.new(21, 15, 1.5), cframe + Vector3.new(0, 7.5, 0), Enum.Material.ForceField, barrierColor, true, gateModel)
    barrier.Transparency = 0.35

    -- Floating Lock & Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 240, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 11, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = barrier

    local lockIcon = Instance.new("TextLabel")
    lockIcon.Size = UDim2.new(1, 0, 0.45, 0)
    lockIcon.BackgroundTransparency = 1
    lockIcon.TextScaled = true
    lockIcon.Font = Enum.Font.FredokaOne
    lockIcon.Text = "🔒 " .. areaName
    lockIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockIcon.Parent = billboard

    local reqLabel = Instance.new("TextLabel")
    reqLabel.Size = UDim2.new(1, 0, 0.45, 0)
    reqLabel.Position = UDim2.new(0, 0, 0.5, 0)
    reqLabel.BackgroundTransparency = 1
    reqLabel.TextScaled = true
    reqLabel.Font = Enum.Font.FredokaOne
    reqLabel.Text = "Requires " .. tostring(requiredWins) .. " Wins 🏆"
    reqLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
    reqLabel.Parent = billboard

    return barrier
end

-- Builds a 3D Hatch Incubator structure
function MapService.buildIncubator(
    name: string,
    areaNumber: number,
    cframe: CFrame,
    parent: Instance
): Part
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent

    -- Base Platform
    local base = makePart("Base", Vector3.new(16, 1.5, 16), cframe + Vector3.new(0, 0.75, 0), Enum.Material.Concrete, Color3.fromRGB(60, 60, 65), true, model)

    -- Outer decorative pillars
    for _, offset in ipairs({ Vector3.new(-7, 4, -7), Vector3.new(7, 4, -7), Vector3.new(-7, 4, 7), Vector3.new(7, 4, 7) }) do
        makePart("CornerPillar", Vector3.new(1.8, 8, 1.8), cframe + offset, Enum.Material.Metal, Color3.fromRGB(180, 140, 40), true, model)
    end

    -- Top Dome / Canopy
    local canopy = makePart("Canopy", Vector3.new(15, 2, 15), cframe + Vector3.new(0, 9, 0), Enum.Material.Metal, Color3.fromRGB(150, 110, 30), true, model)

    -- Glowing Center Hatch Deposit Pad
    local padColor = if areaNumber == 1 then Color3.fromRGB(80, 220, 100)
        elseif areaNumber == 2 then Color3.fromRGB(255, 180, 40)
        elseif areaNumber == 3 then Color3.fromRGB(255, 60, 20)
        else Color3.fromRGB(180, 60, 255)

    local depositPad = makePart(name .. "_Pad", Vector3.new(11, 0.6, 11), cframe + Vector3.new(0, 1.6, 0), Enum.Material.Neon, padColor, true, model)

    -- Overhead Hologram Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 260, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 9, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = depositPad

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.FredokaOne
    label.Text = "HATCH INCUBATOR\n(Deposit Eggs for Wins 🏆)"
    label.Parent = billboard

    return depositPad
end

-- Build Area 1: Farm Meadow
local function buildArea1(mapFolder: Folder)
    local area = Instance.new("Folder")
    area.Name = "Area1_FarmMeadow"
    area.Parent = mapFolder

    -- Main Island Slab (Z: -20 to 60, X: -35 to 35)
    makePart("Ground", Vector3.new(70, 4, 80), CFrame.new(0, -2, 20), Enum.Material.Grass, Color3.fromRGB(90, 180, 75), true, area)

    -- Center Dirt Path
    makePart("DirtPath", Vector3.new(14, 0.2, 78), CFrame.new(0, 0.1, 20), Enum.Material.Ground, Color3.fromRGB(150, 115, 75), true, area)

    -- Fences along left and right perimeters
    for z = -15, 55, 8 do
        spawnFence(CFrame.new(-32, 0, z), area)
        spawnFence(CFrame.new(32, 0, z), area)
    end

    -- Hay Bales
    for _, pos in ipairs({ Vector3.new(-24, 1.5, -12), Vector3.new(-22, 1.5, -9), Vector3.new(24, 1.5, -12), Vector3.new(24, 1.5, 45) }) do
        local bale = makePart("HayBale", Vector3.new(4, 3, 3), CFrame.new(pos), Enum.Material.Wood, Color3.fromRGB(230, 200, 70), true, area)
    end

    -- Trees
    spawnTree(CFrame.new(-25, 0, 15), area, Color3.fromRGB(75, 170, 60))
    spawnTree(CFrame.new(-26, 0, 38), area, Color3.fromRGB(85, 185, 65))
    spawnTree(CFrame.new(25, 0, 15), area, Color3.fromRGB(75, 170, 60))
    spawnTree(CFrame.new(26, 0, 38), area, Color3.fromRGB(90, 195, 70))

    -- Spawn Pad at Z: -15
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "PlayerSpawn"
    spawnLocation.Size = Vector3.new(12, 1, 12)
    spawnLocation.CFrame = CFrame.new(0, 0.5, -14)
    spawnLocation.Anchored = true
    spawnLocation.Material = Enum.Material.SmoothPlastic
    spawnLocation.Color = Color3.fromRGB(255, 255, 255)
    spawnLocation.Duration = 0
    spawnLocation.Parent = area

    -- Welcome Board
    local sign = makePart("WelcomeSign", Vector3.new(10, 4, 0.8), CFrame.new(0, 3, -19), Enum.Material.Wood, Color3.fromRGB(120, 75, 35), true, area)
    local signGui = Instance.new("SurfaceGui")
    signGui.Face = Enum.NormalId.Front
    signGui.Parent = sign
    local signText = Instance.new("TextLabel")
    signText.Size = UDim2.new(1, 0, 1, 0)
    signText.BackgroundTransparency = 1
    signText.TextColor3 = Color3.fromRGB(255, 255, 255)
    signText.Font = Enum.Font.FredokaOne
    signText.TextScaled = true
    signText.Text = "🥚 WELCOME TO LIFT AN EGG!\nWorkout to get Stronger & Lift heavier eggs!"
    signText.Parent = signGui

    -- Area 1 Hatch Incubator at Z: 50
    MapService.buildIncubator("Incubator_Area1", 1, CFrame.new(0, 0, 50), area)
end

-- Build Area 2: Prehistoric Jungle
local function buildArea2(mapFolder: Folder)
    local area = Instance.new("Folder")
    area.Name = "Area2_PrehistoricJungle"
    area.Parent = mapFolder

    -- Island Slab (Z: 70 to 150)
    makePart("Ground", Vector3.new(70, 4, 80), CFrame.new(0, -2, 110), Enum.Material.Mud, Color3.fromRGB(65, 80, 50), true, area)

    -- Stone slabs path
    makePart("StonePath", Vector3.new(14, 0.2, 78), CFrame.new(0, 0.1, 110), Enum.Material.Slate, Color3.fromRGB(90, 95, 85), true, area)

    -- Dinosaur Bones & Fossil Ribs
    for z = 75, 135, 20 do
        local ribL = makePart("DinoRibL", Vector3.new(1.8, 12, 1.8), CFrame.new(-18, 5, z) * CFrame.Angles(0, 0, math.rad(-25)), Enum.Material.Bone, Color3.fromRGB(235, 225, 210), true, area)
        local ribR = makePart("DinoRibR", Vector3.new(1.8, 12, 1.8), CFrame.new(18, 5, z) * CFrame.Angles(0, 0, math.rad(25)), Enum.Material.Bone, Color3.fromRGB(235, 225, 210), true, area)
    end

    -- Giant Jungle Trees
    spawnTree(CFrame.new(-26, 0, 95), area, Color3.fromRGB(45, 110, 40))
    spawnTree(CFrame.new(26, 0, 125), area, Color3.fromRGB(50, 125, 45))

    -- Mossy Boulders
    for _, pos in ipairs({ Vector3.new(-24, 3, 115), Vector3.new(24, 3, 90), Vector3.new(-22, 2.5, 140) }) do
        local rock = makePart("Boulder", Vector3.new(6, 6, 6), CFrame.new(pos), Enum.Material.Rock, Color3.fromRGB(80, 85, 75), true, area)
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Sphere
        m.Scale = Vector3.new(1.1, 0.8, 1)
        m.Parent = rock
    end

    -- Area 2 Hatch Incubator at Z: 140
    MapService.buildIncubator("Incubator_Area2", 2, CFrame.new(0, 0, 140), area)
end

-- Build Area 3: Volcanic Dragon Lair
local function buildArea3(mapFolder: Folder)
    local area = Instance.new("Folder")
    area.Name = "Area3_VolcanicLair"
    area.Parent = mapFolder

    -- Island Slab (Z: 160 to 240)
    makePart("Ground", Vector3.new(70, 4, 80), CFrame.new(0, -2, 200), Enum.Material.Basalt, Color3.fromRGB(35, 25, 30), true, area)

    -- Lava Fissure Paths along sides
    local lavaL = makePart("LavaStreamL", Vector3.new(5, 0.3, 76), CFrame.new(-22, 0.1, 200), Enum.Material.Neon, Color3.fromRGB(255, 70, 0), true, area)
    local lavaR = makePart("LavaStreamR", Vector3.new(5, 0.3, 76), CFrame.new(22, 0.1, 200), Enum.Material.Neon, Color3.fromRGB(255, 70, 0), true, area)

    -- Smoke / ember particles over lava
    for _, lava in ipairs({ lavaL, lavaR }) do
        local emitter = Instance.new("ParticleEmitter")
        emitter.Color = ColorSequence.new(Color3.fromRGB(255, 120, 0), Color3.fromRGB(150, 30, 0))
        emitter.Size = NumberSequence.new(0.5, 0)
        emitter.Rate = 10
        emitter.Lifetime = NumberRange.new(1, 2)
        emitter.Speed = NumberRange.new(2, 4)
        emitter.Parent = lava
    end

    -- Center Obsidian Walkway
    makePart("ObsidianWalkway", Vector3.new(14, 0.2, 78), CFrame.new(0, 0.1, 200), Enum.Material.CrackedLava, Color3.fromRGB(40, 30, 35), true, area)

    -- Obsidian Spikes
    for _, pos in ipairs({ Vector3.new(-28, 4, 175), Vector3.new(-28, 6, 215), Vector3.new(28, 5, 185), Vector3.new(28, 7, 225) }) do
        local spike = makePart("ObsidianSpike", Vector3.new(3, 10, 3), CFrame.new(pos) * CFrame.Angles(math.rad(10), 0, math.rad(-10)), Enum.Material.Glass, Color3.fromRGB(20, 15, 25), true, area)
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Wedge
        m.Parent = spike
    end

    -- Area 3 Hatch Incubator at Z: 230
    MapService.buildIncubator("Incubator_Area3", 3, CFrame.new(0, 0, 230), area)
end

-- Build Area 4: Cosmic Core
local function buildArea4(mapFolder: Folder)
    local area = Instance.new("Folder")
    area.Name = "Area4_CosmicCore"
    area.Parent = mapFolder

    -- Island Slab (Z: 250 to 330)
    makePart("Ground", Vector3.new(70, 4, 80), CFrame.new(0, -2, 290), Enum.Material.SmoothPlastic, Color3.fromRGB(25, 10, 45), true, area)

    -- Glowing Astral Runic Trim
    makePart("AstralLineL", Vector3.new(1, 0.2, 78), CFrame.new(-16, 0.1, 290), Enum.Material.Neon, Color3.fromRGB(180, 50, 255), false, area)
    makePart("AstralLineR", Vector3.new(1, 0.2, 78), CFrame.new(16, 0.1, 290), Enum.Material.Neon, Color3.fromRGB(180, 50, 255), false, area)

    -- Glowing Starlight Walkway
    makePart("CosmicPath", Vector3.new(14, 0.2, 78), CFrame.new(0, 0.1, 290), Enum.Material.Glass, Color3.fromRGB(70, 20, 120), true, area)

    -- Floating Asteroids & Crystals
    spawnCrystal(CFrame.new(-26, 0, 270), area, Color3.fromRGB(0, 220, 255))
    spawnCrystal(CFrame.new(-26, 0, 305), area, Color3.fromRGB(210, 50, 255))
    spawnCrystal(CFrame.new(26, 0, 280), area, Color3.fromRGB(255, 210, 40))
    spawnCrystal(CFrame.new(26, 0, 315), area, Color3.fromRGB(0, 220, 255))

    -- Floating Levitating Chunks
    for _, offset in ipairs({ Vector3.new(-20, 8, 285), Vector3.new(20, 10, 295), Vector3.new(0, 14, 320) }) do
        local chunk = makePart("Asteroid", Vector3.new(5, 3, 5), CFrame.new(offset), Enum.Material.Rock, Color3.fromRGB(45, 30, 60), false, area)
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Sphere
        m.Parent = chunk
    end

    -- Area 4 Hatch Incubator at Z: 320
    MapService.buildIncubator("Incubator_Area4", 4, CFrame.new(0, 0, 320), area)
end

-- Builds all portals and gates linking the areas
local function buildGates(mapFolder: Folder)
    local gatesFolder = Instance.new("Folder")
    gatesFolder.Name = "Zones"
    gatesFolder.Parent = mapFolder

    -- Gate 1 -> Area 2 at Z: 60 (Requires 25 Wins)
    MapService.buildGate(
        "Zone2Gate",
        "Prehistoric Jungle",
        25,
        CFrame.new(0, 0, 60),
        Color3.fromRGB(120, 85, 45),
        Enum.Material.Wood,
        Color3.fromRGB(255, 180, 40),
        gatesFolder
    )

    -- Gate 2 -> Area 3 at Z: 150 (Requires 500 Wins)
    MapService.buildGate(
        "Zone3Gate",
        "Volcanic Dragon Lair",
        500,
        CFrame.new(0, 0, 150),
        Color3.fromRGB(80, 85, 80),
        Enum.Material.Slate,
        Color3.fromRGB(255, 60, 20),
        gatesFolder
    )

    -- Gate 3 -> Area 4 at Z: 240 (Requires 10,000 Wins)
    MapService.buildGate(
        "Zone4Gate",
        "Cosmic Core",
        10000,
        CFrame.new(0, 0, 240),
        Color3.fromRGB(30, 20, 40),
        Enum.Material.Metal,
        Color3.fromRGB(180, 40, 255),
        gatesFolder
    )
end

function MapService.generateMap()
    local existing = Workspace:FindFirstChild("Map")
    if existing then
        existing:Destroy()
    end

    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "Map"
    mapFolder.Parent = Workspace

    MapService.setupLighting()
    buildArea1(mapFolder)
    buildArea2(mapFolder)
    buildArea3(mapFolder)
    buildArea4(mapFolder)
    buildGates(mapFolder)

    print("[MapService] All 4 Themed Areas & Portals generated successfully!")
end

function MapService.init()
    -- Automatically generate the complete world map if not already present
    if not Workspace:FindFirstChild("Map") then
        MapService.generateMap()
    end
end

return MapService

# 🥚 Lift an Egg - Complete Roblox Studio Game Source

A complete replication and themed overhaul of the lifting simulator genre into **"Lift an Egg"**, featuring multi-area themed eggs, 3D procedural egg meshes, nest pedestals, incubator deliveries, arms speed upgrades, eggshell enchantment chests with particle auras, and DataStore persistence.

---

## 📁 Project Architecture & Roblox Studio Hierarchy

| Local Path | Roblox Studio Destination | Type | Description |
|---|---|---|---|
| `src/shared/Config/EggsConfig.lua` | `ReplicatedStorage.Config.EggsConfig` | `ModuleScript` | 4 areas of themed eggs, stats, and 3D egg scales |
| `src/shared/Config/ZonesConfig.lua` | `ReplicatedStorage.Config.ZonesConfig` | `ModuleScript` | Zone thresholds and barrier gates |
| `src/shared/Config/ArmsConfig.lua` | `ReplicatedStorage.Config.ArmsConfig` | `ModuleScript` | Arm upgrade tiers, push-up speeds, and Win costs |
| `src/shared/Config/MaterialsConfig.lua` | `ReplicatedStorage.Config.MaterialsConfig` | `ModuleScript` | Shell enchantments, multipliers, rarities, and incubator loot |
| `src/shared/Remotes.lua` | `ReplicatedStorage.Remotes` | `ModuleScript` | Auto-network manager for events & functions |
| `src/server/DataManager.lua` | `ServerScriptService.DataManager` | `ModuleScript` | DataStoreService with session cache, autosave, and BindToClose |
| `src/server/LeaderstatsService.lua` | `ServerScriptService.LeaderstatsService` | `ModuleScript` | Scoreboard for **Strength** and **Wins** |
| `src/server/TrainingService.lua` | `ServerScriptService.TrainingService` | `ModuleScript` | Push-ups verification, cooldowns, and Auto-Train |
| `src/server/EggService.lua` | `ServerScriptService.EggService` | `ModuleScript` | 3D egg generation, nest pedestals, lifting welds, incubator rewards |
| `src/server/ShopService.lua` | `ServerScriptService.ShopService` | `ModuleScript` | Arm upgrade transactions and equipping |
| `src/server/ChestService.lua` | `ServerScriptService.ChestService` | `ModuleScript` | Weighted RNG rolls and character arm visuals (colors, materials, auras) |
| `src/server/ZoneService.lua` | `ServerScriptService.ZoneService` | `ModuleScript` | Barrier wall pass-through logic |
| `src/server/MapService.lua` | `ServerScriptService.MapService` | `ModuleScript` | Procedural 3D map generator (Islands, props, gates, incubators) |
| `src/server/MainServer.server.lua` | `ServerScriptService.MainServer` | `Script` | Master bootstrapper |
| `src/client/NumberFormat.lua` | `StarterPlayerScripts.NumberFormat` | `ModuleScript` | Abbreviates numbers (1.2K, 3.4M, 5.6B) |
| `src/client/TrainingController.client.lua` | `StarterPlayerScripts.TrainingController` | `LocalScript` | Input handling, push-up motion, floating strength popups |
| `src/client/HUDController.client.lua` | `StarterPlayerScripts.HUDController` | `LocalScript` | Dynamic top bar stats, Auto-Train button, sidebar |
| `src/client/ShopUIController.client.lua` | `StarterPlayerScripts.ShopUIController` | `LocalScript` | Full Arm Upgrade Shop modal |
| `src/client/ChestUIController.client.lua` | `StarterPlayerScripts.ChestUIController` | `LocalScript` | Egg Incubator chest unboxing modal |
| `src/client/EggClient.client.lua` | `StarterPlayerScripts.EggClient` | `LocalScript` | Overhead cradle carry pose, drop hotkeys (Q / Backspace) |

---

## 🗺️ Themed Egg Areas & Progression

Each area is themed with custom nests, materials, and progressively harder eggs:

### 🌾 Area 1: Farm Meadow (Starter Area)
* **White Chicken Egg**: 0 Strength $\to$ 1 Win
* **Spotted Quail Egg**: 25 Strength $\to$ 3 Wins
* **Golden Goose Egg**: 120 Strength $\to$ 12 Wins
* **Giant Ostrich Egg**: 500 Strength $\to$ 40 Wins

### 🌴 Area 2: Prehistoric Jungle (Requires 25 Wins)
* **Velociraptor Egg**: 2,000 Strength $\to$ 150 Wins
* **Armored Triceratops Egg**: 8,500 Strength $\to$ 550 Wins
* **Titan T-Rex Egg**: 35,000 Strength $\to$ 2,000 Wins

### 🌋 Area 3: Volcanic Dragon Lair (Requires 500 Wins)
* **Magma Drake Egg**: 150,000 Strength $\to$ 7,500 Wins
* **Obsidian Wyrm Egg**: 600,000 Strength $\to$ 28,000 Wins
* **Elder Fire Dragon Egg**: 2,500,000 Strength $\to$ 110,000 Wins

### 🌌 Area 4: Cosmic Core (Requires 10,000 Wins)
* **Nebula Phoenix Egg**: 12,000,000 Strength $\to$ 500,000 Wins
* **Void Leviathan Egg**: 60,000,000 Strength $\to$ 2,200,000 Wins
* **Primordial Celestial Egg**: 300,000,000 Strength $\to$ 10,000,000 Wins

---

## 🚀 Setup Instructions in Roblox Studio

### Method 1: Manual Copy & Paste (No tools required)

1. Open **Roblox Studio** and start a **Baseplate** template.
2. In **ReplicatedStorage**:
   - Add a Folder named `Config`.
   - Inside `Config`, create 4 `ModuleScript`s: `EggsConfig`, `ZonesConfig`, `ArmsConfig`, and `MaterialsConfig`. Paste the respective code.
   - In `ReplicatedStorage` root, create a `ModuleScript` named `Remotes` and paste `Remotes.lua`.
3. In **ServerScriptService**:
   - Create 8 `ModuleScript`s: `DataManager`, `LeaderstatsService`, `TrainingService`, `EggService`, `ShopService`, `ChestService`, `ZoneService`, and `MapService`.
   - Create 1 regular `Script` named `MainServer` and paste `MainServer.server.lua`.
4. In **StarterPlayer > StarterPlayerScripts**:
   - Create 1 `ModuleScript` named `NumberFormat`.
   - Create 5 `LocalScript`s: `TrainingController`, `HUDController`, `ShopUIController`, `ChestUIController`, and `EggClient`.
5. Press **Play (F5)**!

> [!NOTE]
> **Zero Manual Building Needed**: `EggService` automatically generates the 3D procedural egg models, thematic nests, and the **Hatch Incubator** deposit pad in your Workspace!

---

### Method 2: Rojo Sync (For VS Code users)

1. In this project folder, run:
   ```bash
   rojo build -o "LiftAnEgg.rbxl"
   ```
2. Open the resulting `LiftAnEgg.rbxl` file in Roblox Studio!

---

## 🎮 Core Game Mechanics

1. **Push-up Training**:
   - Tap/click anywhere to train Strength.
   - Click the **AUTO: OFF** button to toggle automatic training.
2. **Arm Speed Upgrades**:
   - Buy faster arms from *Default Arm* ($1.0\text{s}$ cooldown) to *Cosmic Arm* ($0.12\text{s}$ cooldown).
3. **Egg Shell Enchantment Chests**:
   - Roll incubator chests using Wins for huge Strength multipliers ($1\times$ to $25,000\times$).
   - Changes the material, color, and glowing aura particles of your character's arms.
4. **Lifting & Incubating Eggs**:
   - Approach an egg in its nest and hold **E** (or tap on mobile).
   - If strong enough, carry the egg overhead to the **Hatch Incubator** pad to earn **Wins**.
   - Press **Q** or **Backspace** to drop.
5. **Zones & Barriers**:
   - Progressive gates unlock access to Jurassic, Dragon, and Cosmic egg realms as your Wins grow.

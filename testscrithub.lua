--[[
================================================================================
    MULTI-GAME AUTO FARM SCRIPT
    Version: 1.1 (Fixed & Cleaned)
    Games: Pickaxe Simulator & Fish It
================================================================================
]]

-- ============================================
-- PICKAXE SIMULATOR
-- ============================================
if game.PlaceId == 82013336390273 then
    
    local CurrentVersion = "Pickaxe Simulator"
    
    -- Load UI Library
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
    
    local GUI = Mercury:Create{
        Name = CurrentVersion,
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    }
    
    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    
    -- Player Stats
    local playerStats = ReplicatedStorage.Stats:WaitForChild(player.Name)
    local miningSpeedBoost = playerStats:WaitForChild("MiningSpeedBoost")
    local miningPower = playerStats:WaitForChild("Power")
    
    -- State Variables
    local isMining = false
    local isAutoTraining = false
    local isEquipBestEnabled = false
    local isAutoBuyPickaxe = false
    local isAutoBuyMiner = false
    local isHatching = false
    local isSpeedMiningEnabled = false
    local isPowerEnabled = false
    local isAutoRebirthEnabled = false
    
    local selectedEgg = nil
    local selectedMiningSpeed = nil
    local selectedPower = nil
    local selectedRebirth = nil
    
    task.wait(0.5)
    
    -- Dropdown Lists
    local SpeedMiningList = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20
    }
    
    local RebirthList = {
        1, 5, 20, 50, 100, 250, 500, 1000, 2500, 5000, 
        10000, 25000, 50000, 100000, 250000, 500000, 
        1000000, 2500000, 10000000, 25000000, 100000000, 
        1000000000, 50000000000, 500000000000, 5000000000000, 
        100000000000000, 1000000000000000, 50000000000000000, 
        500000000000000000, 2500000000000000000, 50000000000000000000, 
        500000000000000000000, 5e+21, 1e+23, 1e+24, 5e+25
    }
    
    local PowerMiningList = {
        999, 9999, 99999, 999999, 9999999, 99999999
    }
    
    local EggsList = {
        "5M Egg", "Angelic Egg", "Aqua Egg", "Aura Egg",
        "Basic Egg", "Beach Egg", "Black Hole Egg", "Cave Egg",
        "Christmas Egg", "Dark Egg", "Electric Egg", "Farm Egg",
        "Forest Egg", "Galaxy Egg", "Garden Egg", "Ice Egg",
        "Lava Egg", "Music Egg", "Pixel Egg", "Rare Egg",
        "Rocket Egg", "Sakura Egg", "Sand Egg", "Snow Egg",
        "Sunny Egg", "Toy Egg", "UFO Egg", "Winter Egg"
    }
    
    -- ============================================
    -- GAME FUNCTIONS
    -- ============================================
    
    local function toggleAutoMine()
        local args = {"Toggle Setting", "AutoMine"}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remoteevent")
            :FireServer(unpack(args))
    end
    
    local function toggleAutoTrain()
        local args = {"Toggle Setting", "AutoTrain"}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remoteevent")
            :FireServer(unpack(args))
    end
    
    local function autoEquipBest()
        local args = {
            "Pet",
            {
                Action = "EquipBest",
                Sort = "Power"
            }
        }
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end
    
    local function autoSellOres()
        local args = {"Sell All Ores"}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end
    
    local function buyPickaxe()
        local args = {"Buy Pickaxe"}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end
    
    local function buyMiner()
        local args = {"Buy Miner"}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end
    
    local function hatchEgg(eggName)
        local args = {"Hatch Egg", eggName, 3}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end
    
    local function performRebirth(rebirthAmount)
        local args = {"Rebirth", rebirthAmount}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end
    
    local function setMiningSpeed(speed)
        if miningSpeedBoost then
            miningSpeedBoost.Value = speed
            print("⚡ Mining speed set to:", speed)
        end
    end
    
    local function setMiningPower(power)
        if miningPower then
            miningPower.Value = power
            print("💪 Mining power set to:", power)
        end
    end
    
    -- ============================================
    -- UI SETUP - FARM TAB
    -- ============================================
    local FarmTab = GUI:Tab{
        Name = "Auto Farm",
        Icon = "rbxassetid://8569322835"
    }
    
    FarmTab:Dropdown{
        Name = "Select Rebirth Amount",
        StartingText = "Select...",
        Description = "Choose rebirth amount",
        Items = RebirthList,
        Callback = function(item) 
            selectedRebirth = item
            print("🔄 Selected rebirth:", selectedRebirth)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Rebirth",
        StartingState = false,
        Description = "Auto rebirth with selected amount",
        Callback = function(state) 
            isAutoRebirthEnabled = state
            
            task.spawn(function()
                while isAutoRebirthEnabled do
                    if selectedRebirth then
                        performRebirth(selectedRebirth)
                        print("🔄 Rebirthing:", selectedRebirth)
                        task.wait(1)
                    else
                        warn("⚠️ No rebirth amount selected!")
                        task.wait(2)
                    end
                end
            end)
        end
    }
    
    FarmTab:Dropdown{
        Name = "Select Your Power",
        StartingText = "Select...",
        Description = "Choose mining power",
        Items = PowerMiningList,
        Callback = function(item) 
            selectedPower = item
            print("💪 Selected power:", selectedPower)
        end
    }
    
    FarmTab:Toggle{
        Name = "Set Mining Power",
        StartingState = false,
        Description = "Apply selected power",
        Callback = function(state) 
            isPowerEnabled = state
            
            if isPowerEnabled and selectedPower then
                setMiningPower(selectedPower)
            elseif isPowerEnabled then
                warn("⚠️ No power selected!")
            else
                print("❌ Power boost disabled")
            end
        end
    }
    
    FarmTab:Dropdown{
        Name = "Select Mining Speed",
        StartingText = "Select...",
        Description = "Choose speed (1-20)",
        Items = SpeedMiningList,
        Callback = function(item) 
            selectedMiningSpeed = item
            print("⚡ Selected speed:", selectedMiningSpeed)
        end
    }
    
    FarmTab:Toggle{
        Name = "Set Mining Speed",
        StartingState = false,
        Description = "Apply selected speed",
        Callback = function(state) 
            isSpeedMiningEnabled = state
            
            if isSpeedMiningEnabled and selectedMiningSpeed then
                setMiningSpeed(selectedMiningSpeed)
            elseif isSpeedMiningEnabled then
                warn("⚠️ No speed selected!")
            else
                print("❌ Speed boost disabled")
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy Pickaxe",
        StartingState = false,
        Description = "Auto upgrade pickaxe",
        Callback = function(state) 
            isAutoBuyPickaxe = state
            
            task.spawn(function()
                while isAutoBuyPickaxe do
                    buyPickaxe()
                    task.wait(30)
                end
            end)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy Miner",
        StartingState = false,
        Description = "Auto upgrade miner",
        Callback = function(state) 
            isAutoBuyMiner = state
            
            task.spawn(function()
                while isAutoBuyMiner do
                    buyMiner()
                    task.wait(30)
                end
            end)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Equip Best",
        StartingState = false,
        Description = "Auto equip strongest pets",
        Callback = function(state) 
            isEquipBestEnabled = state
            
            task.spawn(function()
                while isEquipBestEnabled do
                    autoEquipBest()
                    task.wait(20)
                end
            end)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Train",
        StartingState = false,
        Description = "Enable auto training",
        Callback = function(state) 
            isAutoTraining = state
            
            task.spawn(function()
                while isAutoTraining do
                    toggleAutoTrain()
                    task.wait(120)
                end
            end)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Mine",
        StartingState = false,
        Description = "Auto mine and sell ores",
        Callback = function(state) 
            isMining = state
            
            task.spawn(function()
                while isMining do
                    toggleAutoMine()
                    task.wait(120)
                    
                    if isMining then
                        autoSellOres()
                        task.wait(5)
                    end
                end
            end)
        end
    }
    
    -- ============================================
    -- UI SETUP - PET TAB
    -- ============================================
    local PetTab = GUI:Tab{
        Name = "Pet Tab",
        Icon = "rbxassetid://8569322835"
    }
    
    PetTab:Dropdown{
        Name = "Select Egg",
        StartingText = "Select...",
        Description = "Choose egg to hatch",
        Items = EggsList,
        Callback = function(item) 
            selectedEgg = item
            print("🥚 Selected egg:", selectedEgg)
        end
    }
    
    PetTab:Toggle{
        Name = "Auto Hatch",
        StartingState = false,
        Description = "Auto hatch selected egg (3x)",
        Callback = function(state)
            isHatching = state
            
            task.spawn(function()
                while isHatching do
                    if selectedEgg then
                        hatchEgg(selectedEgg)
                        task.wait(0.5)
                    else
                        warn("⚠️ No egg selected!")
                        task.wait(2)
                    end
                end
            end)
        end
    }
    
    print("✅ Pickaxe Simulator script loaded!")
end

-- ============================================
-- FISH IT
-- ============================================
--[[
════════════════════════════════════════════════════════════════
    FISH IT - AUTO FARM SCRIPT
    Version: 3.0 (Complete Rewrite)
    Game: Fish It (PlaceId: 121864768012064)
    Features:
        ✅ Auto Fishing (No Click Required)
        ✅ Auto Equip Best Rod/Bait (UUID Based)
        ✅ Auto Buy Rod/Bait
        ✅ Auto Sell Items
        ✅ Teleport Locations
        ✅ Anti-Stuck System
        ✅ Death Handler (Auto Respawn & Re-equip)
════════════════════════════════════════════════════════════════
]]

if game.PlaceId ~= 121864768012064 then
    warn("⚠️ Script này chỉ dành cho game Fish It!")
    return
end

print("🎣 Loading Fish It Script v3.0...")

-- ════════════════════════════════════════════════════════════════
-- 🔧 PHẦN 1: SERVICES & CORE SETUP
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Load Game Utilities
local ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
local TierUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TierUtility"))

print("✅ Core services loaded")

-- ════════════════════════════════════════════════════════════════
-- 📡 PHẦN 2: REMOTE FUNCTIONS SETUP
-- ════════════════════════════════════════════════════════════════

local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}

local function GetRemote(name, timeout)
    local currentInstance = ReplicatedStorage
    for _, childName in ipairs(RPath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

-- Định nghĩa tất cả Remotes
local Remotes = {
    -- Equip System
    EquipToolFromHotbar = GetRemote("RE/EquipToolFromHotbar"),
    EquipItem = GetRemote("RE/EquipItem"),
    EquipBait = GetRemote("RE/EquipBait"),
    UnequipItem = GetRemote("RE/UnequipItem"),
    
    -- Fishing System
    ChargeFishingRod = GetRemote("RF/ChargeFishingRod"),
    RequestFishingMinigameStarted = GetRemote("RF/RequestFishingMinigameStarted"),
    FishingCompleted = GetRemote("RE/FishingCompleted"),
    CancelFishingInputs = GetRemote("RF/CancelFishingInputs"),
    UpdateAutoFishingState = GetRemote("RF/UpdateAutoFishingState"),
    
    -- Shop System
    PurchaseFishingRod = GetRemote("RF/PurchaseFishingRod"),
    PurchaseBait = GetRemote("RF/PurchaseBait"),
    SellAllItems = GetRemote("RF/SellAllItems"),
}

print("✅ Remotes loaded:", #Remotes, "functions")

-- ════════════════════════════════════════════════════════════════
-- 🗄️ PHẦN 3: REPLION SYSTEM (INVENTORY ACCESS)
-- ════════════════════════════════════════════════════════════════

local PlayerDataReplion = nil

local function GetPlayerDataReplion()
    if PlayerDataReplion then return PlayerDataReplion end
    
    local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
    if not ReplionModule then 
        warn("❌ Không tìm thấy Replion Module")
        return nil 
    end
    
    local ReplionClient = require(ReplionModule).Client
    PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
    
    if PlayerDataReplion then
        print("✅ Replion connected")
    else
        warn("❌ Replion connection failed")
    end
    
    return PlayerDataReplion
end

-- ════════════════════════════════════════════════════════════════
-- ⚙️ PHẦN 4: CONFIGURATION & STATE
-- ════════════════════════════════════════════════════════════════

local Config = {
    -- Fishing Settings
    AutoFishingEnabled = false,
    FishingDelay = 1.5,              -- Delay giữa mỗi lần câu
    AntiStuckTimeout = 20,           -- Timeout để phát hiện bị treo
    
    -- Auto Actions
    AutoSellEnabled = false,
    SellInterval = 30,               -- Bán items mỗi 30 giây
    AutoBuyRodEnabled = false,
    AutoBuyBaitEnabled = false,
    BuyInterval = 60,                -- Mua đồ mỗi 60 giây
    
    -- Equipment Check
    EquipCheckInterval = 5,          -- Kiểm tra equip mỗi 5 giây
}

local State = {
    isEquipped = false,
    lastFishingTime = tick(),
    lastEquipCheck = tick(),
    deathConnection = nil,
    
    -- User Selections
    selectedLocation = nil,
    selectedRodID = nil,
    selectedBaitID = nil,
}

-- ════════════════════════════════════════════════════════════════
-- 💰 PHẦN 5: ROD & BAIT PRICE DATABASE
-- ════════════════════════════════════════════════════════════════

local ROD_PRICES = {
    -- Starter Rods
    [79]  = 325,        -- Luck Rod
    [76]  = 750,        -- Carbon Rod
    [85]  = 1500,       -- Grass Rod
    [77]  = 3000,       -- Demascus Rod
    [78]  = 5000,       -- Ice Rod
    
    -- Mid Tier
    [4]   = 15000,      -- Lucky Rod
    [80]  = 50000,      -- Midnight Rod
    
    -- High Tier
    [6]   = 215000,     -- Steampunk Rod
    [7]   = 437000,     -- Chrome Rod
    [255] = 715000,     -- Flourescent Rod
    [256] = 1380000,    -- Hazmat Rod
    [5]   = 1000000,    -- Astral Rod
    
    -- God Tier
    [126] = 3000000,    -- Ares Rod
    [168] = 8000000,    -- Angler Rod
    [258] = 12000000,   -- Bamboo Rod
    
    -- Quest Rods (Special)
    [169] = 99999999,   -- Ghostfin Rod
    [257] = 999999999,  -- Element Rod
}

local BAIT_PRICES = {
    [1]  = 0,           -- Starter Bait
    [2]  = 1000,        -- Luck Bait
    [3]  = 3000,        -- Midnight Bait
    [10] = 100,         -- Topwater Bait
    [17] = 83500,       -- Nature Bait
    [6]  = 290000,      -- Chroma Bait
    [4]  = 425000,      -- Royal Bait
    [8]  = 630000,      -- Dark Matter Bait
    [15] = 1148484,     -- Corrupt Bait
    [16] = 3700000,     -- Aether Bait
    [20] = 4000000,     -- Floral Bait
    [18] = 8200000,     -- Singularity Bait
}

-- ════════════════════════════════════════════════════════════════
-- 🗺️ PHẦN 6: LOCATION DATA
-- ════════════════════════════════════════════════════════════════

local LOCATIONS = {
        ["Iron Cavern"] = {Pos = Vector3.new(-8792.546, -588.000, 230.642), Look = Vector3.new(0.718, 0.000, 0.696)},
        ["Disco Event"] = {Pos = Vector3.new(-8641.672, -547.500, 160.322), Look = Vector3.new(0.984, -0.000, 0.176)},
        ["Classic Island"] = {Pos = Vector3.new(1440.843, 46.062, 2777.175), Look = Vector3.new(0.940, -0.000, 0.342)},
        ["Ancient Jungle"] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
        ["Arrow Lever"] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, -0.000, 1.000)},
        ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
        ["Crater Island"] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0.000, 0.615)},
        ["Cresent Lever"] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0.000, -0.000, -1.000)},
        ["Crystalline Passage"] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0.000, 0.994)},
        ["Ancient Ruin"] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, -0.000, -0.949)},
        ["Diamond Lever"] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0.000, 0.000, -1.000)},
        ["Enchant Room"] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Esoteric Island"] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Fisherman Island"] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Hourglass Diamond Lever"] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Kohana"] = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, -0.000, 0.458)},
        ["Lost Isle"] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, -0.000, 0.433)},
        --["Ocean (for element)"] = {Pos = Vector3.new(4675.870, 5.210, -554.690), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Sacred Temple"] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, -0.000, 0.143)},
        ["Second Enchant Altar"] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0.000, -0.955)},
        ["Sisyphus Statue"] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0.000, 0.951)},
        ["Treasure Room"] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0.000, -0.998)},
        ["Tropical Island"] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
        ["Underground Cellar"] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0.000, 0.521)},
        ["Volcano"] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
        ["Weather Machine"] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0.000, 0.999)},
    -- Thêm locations khác nếu cần
}

local LocationList = {}
for name, _ in pairs(LOCATIONS) do
    table.insert(LocationList, name)
end

-- ════════════════════════════════════════════════════════════════
-- 🎣 PHẦN 7: CORE FISHING FUNCTIONS
-- ════════════════════════════════════════════════════════════════

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Tìm & Equip Rod Mạnh Nhất                         │
-- └─────────────────────────────────────────────────────────────┘
local function EquipBestRod()
    print("🎣 [Equip] Đang tìm rod mạnh nhất...")
    
    local replion = GetPlayerDataReplion()
    if not replion then 
        warn("❌ Không thể truy cập Replion")
        return false
    end
    
    local success, inventoryData = pcall(function() 
        return replion:GetExpect("Inventory") 
    end)
    
    if not success or not inventoryData then
        warn("❌ Không đọc được Inventory")
        return false
    end
    
    -- Tìm Rod giá cao nhất
    local bestRodUUID = nil
    local bestPrice = -1
    local bestRodName = "Unknown"
    
    if inventoryData["Fishing Rods"] then
        for _, rod in ipairs(inventoryData["Fishing Rods"]) do
            -- Validate UUID
            if typeof(rod.UUID) ~= "string" or #rod.UUID < 10 then
                continue
            end
            
            local rodID = tonumber(rod.Id)
            local price = ROD_PRICES[rodID] or 0
            
            -- Special handling for quest rods
            if rodID == 169 then price = 99999999 end
            if rodID == 257 then price = 999999999 end
            
            if price > bestPrice then
                bestPrice = price
                bestRodUUID = rod.UUID
                
                -- Get rod name
                pcall(function()
                    local itemData = ItemUtility:GetItemData(rodID)
                    if itemData and itemData.Data and itemData.Data.Name then
                        bestRodName = itemData.Data.Name
                    end
                end)
            end
        end
    end
    
    -- Equip best rod
    if bestRodUUID and Remotes.EquipItem then
        local equipSuccess = pcall(function()
            Remotes.EquipItem:FireServer(bestRodUUID, "Fishing Rods")
        end)
        
        if equipSuccess then
            print("✅ Equipped:", bestRodName, "| UUID:", bestRodUUID:sub(1, 12) .. "...")
            task.wait(0.3)
            
            -- Hold in hand
            if Remotes.EquipToolFromHotbar then
                pcall(function()
                    Remotes.EquipToolFromHotbar:FireServer(1)
                end)
            end
            
            State.isEquipped = true
            return true
        else
            warn("❌ Equip rod failed")
            return false
        end
    else
        warn("⚠️ Không tìm thấy rod trong inventory")
        return false
    end
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Equip Bait Theo ID                                │
-- └─────────────────────────────────────────────────────────────┘
local function EquipBait(baitID)
    if not baitID or not Remotes.EquipBait then 
        return false
    end
    
    print("🪱 [Equip] Đang equip bait ID:", baitID)
    
    local success = pcall(function()
        Remotes.EquipBait:FireServer(baitID)
    end)
    
    if success then
        print("✅ Equipped bait ID:", baitID)
        return true
    else
        warn("❌ Equip bait failed")
        return false
    end
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Auto Fishing Loop (CORE)                          │
-- └─────────────────────────────────────────────────────────────┘
local function AutoFishingLoop()
    print("🎣 [AutoFish] Started - Version 3.0")
    
    while Config.AutoFishingEnabled do
        local success = pcall(function()
            -- ═══════════════════════════════════════════════
            -- STEP 1: Safety Checks
            -- ═══════════════════════════════════════════════
            if not LocalPlayer.Character or not HumanoidRootPart then
                warn("⚠️ Character not found, waiting for respawn...")
                repeat task.wait(0.5) until LocalPlayer.Character
                Character = LocalPlayer.Character
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
                State.isEquipped = false
                return
            end
            
            -- ═══════════════════════════════════════════════
            -- STEP 2: Anti-Stuck System
            -- ═══════════════════════════════════════════════
            if tick() - State.lastFishingTime > Config.AntiStuckTimeout then
                warn("⚠️ [Anti-Stuck] Detected stuck, resetting...")
                
                -- Method 1: Reset character
                if Humanoid then
                    Humanoid.Health = 0
                end
                
                State.lastFishingTime = tick()
                task.wait(3)
                return
            end
            
            -- ═══════════════════════════════════════════════
            -- STEP 3: Equip Check (Every 5s)
            -- ═══════════════════════════════════════════════
            if tick() - State.lastEquipCheck > Config.EquipCheckInterval then
                if not State.isEquipped then
                    print("🔄 Re-equipping rod...")
                    EquipBestRod()
                    
                    if State.selectedBaitID then
                        EquipBait(State.selectedBaitID)
                    end
                end
                State.lastEquipCheck = tick()
            end
            
            -- ═══════════════════════════════════════════════
            -- STEP 4: Fishing Sequence
            -- ═══════════════════════════════════════════════
            
            -- 4.1. Charge Rod
            if Remotes.ChargeFishingRod then
                pcall(function()
                    Remotes.ChargeFishingRod:InvokeServer(tick())
                end)
            end
            
            task.wait(0.1)
            
            -- 4.2. Start Minigame (Perfect Parameters)
            if Remotes.RequestFishingMinigameStarted then
                pcall(function()
                    Remotes.RequestFishingMinigameStarted:InvokeServer(-1.2, 0.99)
                end)
            end
            
            -- 4.3. Wait For Catch
            task.wait(Config.FishingDelay)
            
            -- 4.4. Complete Fishing
            if Remotes.FishingCompleted then
                pcall(function()
                    Remotes.FishingCompleted:FireServer()
                end)
            end
            
            State.lastFishingTime = tick()
            
            -- 4.5. Mini Delay (Stability)
            task.wait(0.1)
        end)
        
        if not success then
            warn("❌ [AutoFish] Error detected, retrying in 1s...")
            task.wait(1)
        end
    end
    
    print("🛑 [AutoFish] Stopped")
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Auto Sell Loop                                    │
-- └─────────────────────────────────────────────────────────────┘
local function AutoSellLoop()
    print("💰 [AutoSell] Started")
    
    while Config.AutoSellEnabled do
        if Remotes.SellAllItems then
            local success = pcall(function()
                Remotes.SellAllItems:InvokeServer()
            end)
            
            if success then
                print("💰 Đã bán tất cả items")
            end
        end
        
        task.wait(Config.SellInterval)
    end
    
    print("🛑 [AutoSell] Stopped")
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Auto Buy Rod Loop                                 │
-- └─────────────────────────────────────────────────────────────┘
local function AutoBuyRodLoop()
    print("🛒 [AutoBuyRod] Started")
    
    while Config.AutoBuyRodEnabled do
        if State.selectedRodID and Remotes.PurchaseFishingRod then
            local success = pcall(function()
                Remotes.PurchaseFishingRod:InvokeServer(State.selectedRodID)
            end)
            
            if success then
                print("✅ Mua rod ID:", State.selectedRodID)
                task.wait(1)
                EquipBestRod()
            end
        end
        
        task.wait(Config.BuyInterval)
    end
    
    print("🛑 [AutoBuyRod] Stopped")
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Auto Buy Bait Loop                                │
-- └─────────────────────────────────────────────────────────────┘
local function AutoBuyBaitLoop()
    print("🛒 [AutoBuyBait] Started")
    
    while Config.AutoBuyBaitEnabled do
        if State.selectedBaitID and Remotes.PurchaseBait then
            local success = pcall(function()
                Remotes.PurchaseBait:InvokeServer(State.selectedBaitID)
            end)
            
            if success then
                print("✅ Mua bait ID:", State.selectedBaitID)
                task.wait(1)
                EquipBait(State.selectedBaitID)
            end
        end
        
        task.wait(Config.BuyInterval)
    end
    
    print("🛑 [AutoBuyBait] Stopped")
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ FUNCTION: Death Handler (Respawn System)                    │
-- └─────────────────────────────────────────────────────────────┘
local function SetupDeathHandler()
    -- Disconnect old connection
    if State.deathConnection then
        State.deathConnection:Disconnect()
    end
    
    if Humanoid then
        State.deathConnection = Humanoid.Died:Connect(function()
            print("💀 [Death] Character died, waiting for respawn...")
            State.isEquipped = false
            
            -- Wait for new character
            local newCharacter = LocalPlayer.CharacterAdded:Wait()
            Character = newCharacter
            Humanoid = newCharacter:WaitForChild("Humanoid")
            HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
            
            task.wait(1)
            
            -- Teleport back to location
            if State.selectedLocation then
                HumanoidRootPart.CFrame = State.selectedLocation
                print("📍 Teleported back to saved location")
            end
            
            task.wait(0.5)
            
            -- Re-equip gear
            EquipBestRod()
            
            if State.selectedBaitID then
                EquipBait(State.selectedBaitID)
            end
            
            print("✅ [Respawn] Completed")
            
            -- Re-setup death handler
            if Config.AutoFishingEnabled then
                SetupDeathHandler()
            end
        end)
        
        print("🔗 Death handler connected")
    end
end

-- ════════════════════════════════════════════════════════════════
-- 🛒 PHẦN 8: SHOP DATA COLLECTION
-- ════════════════════════════════════════════════════════════════

print("📦 Collecting shop data...")

local RodsWithPrice = {}
local RodNamesList = {}

local BaitsWithPrice = {}
local BaitNamesList = {}

-- Collect Rods
local Items = ReplicatedStorage:FindFirstChild("Items")
if Items then
    for _, item in pairs(Items:GetChildren()) do
        if string.match(item.Name, "Rod$") then
            local success, rodData = pcall(function()
                return require(item)
            end)
            
            if success and rodData.Price then
                table.insert(RodsWithPrice, {
                    Name = item.Name,
                    Price = rodData.Price,
                    Id = rodData.Data and rodData.Data.Id or 9999,
                })
            end
        end
    end
end

-- Sort rods by ID
table.sort(RodsWithPrice, function(a, b) return a.Id < b.Id end)

-- Create display list
for _, rod in ipairs(RodsWithPrice) do
    table.insert(RodNamesList, string.format("[%d] %s", rod.Id, rod.Name))
end

print("✅ Found", #RodsWithPrice, "rods")

-- Collect Baits
local Baits = ReplicatedStorage:FindFirstChild("Baits")
if Baits then
    for _, baitItem in pairs(Baits:GetChildren()) do
        if string.match(baitItem.Name, "Bait$") then
            local success, baitData = pcall(function()
                return require(baitItem)
            end)
            
            if success and baitData.Price then
                table.insert(BaitsWithPrice, {
                    Name = baitItem.Name,
                    Price = baitData.Price,
                    Id = baitData.Data and baitData.Data.Id or 9999,
                })
            end
        end
    end
end

-- Sort baits by ID
table.sort(BaitsWithPrice, function(a, b) return a.Id < b.Id end)

-- Create display list
for _, bait in ipairs(BaitsWithPrice) do
    table.insert(BaitNamesList, string.format("[%d] %s", bait.Id, bait.Name))
end

print("✅ Found", #BaitsWithPrice, "baits")

-- ════════════════════════════════════════════════════════════════
-- 🎮 PHẦN 9: UI SETUP (MERCURY LIBRARY)
-- ════════════════════════════════════════════════════════════════

print("🎨 Loading UI...")

local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local GUI = Mercury:Create{
    Name = "Fish It - v3.0",
    Size = UDim2.fromOffset(600, 450),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}

-- ════════════════════════════════════════════════════════════════
-- 📑 TAB 1: AUTO FARM
-- ════════════════════════════════════════════════════════════════

local FarmTab = GUI:Tab{
    Name = "Auto Farm",
    Icon = "rbxassetid://8569322835"
}

-- ┌─────────────────────────────────────────────────────────────┐
-- │ SECTION: Main Fishing                                       │
-- └─────────────────────────────────────────────────────────────┘

FarmTab:Toggle{
    Name = "🎣 Auto Fishing",
    StartingState = false,
    Description = "Bật auto fishing (không cần click)",
    Callback = function(state) 
        Config.AutoFishingEnabled = state
        
        if state then
            print("═══════════════════════════════════════")
            print("🎣 AUTO FISHING STARTED")
            print("═══════════════════════════════════════")
            
            -- Enable server-side auto fishing
            if Remotes.UpdateAutoFishingState then
                Remotes.UpdateAutoFishingState:InvokeServer(true)
            end
            
            -- Setup death handler
            SetupDeathHandler()
            
            -- Equip gear
            EquipBestRod()
            
            if State.selectedBaitID then
                EquipBait(State.selectedBaitID)
            end
            
            -- Start fishing loop
            task.spawn(AutoFishingLoop)
            
        else
            print("═══════════════════════════════════════")
            print("🛑 AUTO FISHING STOPPED")
            print("═══════════════════════════════════════")
            
            -- Disable server-side auto fishing
            if Remotes.UpdateAutoFishingState then
                Remotes.UpdateAutoFishingState:InvokeServer(false)
            end
            
            -- Disconnect death handler
            if State.deathConnection then
                State.deathConnection:Disconnect()
            end
        end
    end
}

FarmTab:Slider{
    Name = "⏱️ Fishing Delay",
    Default = 1.5,
    Min = 0.5,
    Max = 5,
    Description = "Delay giữa mỗi lần câu (giây)",
    Callback = function(value)
        Config.FishingDelay = value
        print("⏱️ Fishing delay set:", value, "giây")
    end
}

FarmTab:Toggle{
    Name = "💰 Auto Sell All",
    StartingState = false,
    Description = "Tự động bán items (30s/lần)",
    Callback = function(state) 
        Config.AutoSellEnabled = state
        
        if state then
            task.spawn(AutoSellLoop)
            print("✅ Auto Sell bật (mỗi 30s)")
        else
            print("⏹️ Auto Sell tắt")
        end
    end
}

-- ┌─────────────────────────────────────────────────────────────┐
-- │ SECTION: Location                                           │
-- └─────────────────────────────────────────────────────────────┘

FarmTab:Dropdown{
    Name = "📍 Select Location",
    StartingText = "Choose location...",
    Description = "Chọn địa điểm câu cá",
    Items = LocationList,
    Callback = function(item) 
        State.selectedLocation = LOCATIONS[item]
        
        if State.selectedLocation and HumanoidRootPart then
            HumanoidRootPart.CFrame = State.selectedLocation
            print("📍 Teleported to:", item)
        end
    end
}

-- ┌─────────────────────────────────────────────────────────────┐
-- │ SECTION: Rod Management                                     │
-- └─────────────────────────────────────────────────────────────┘

FarmTab:Dropdown{
    Name = "🎣 Select Rod",
    StartingText = "Choose rod...",
    Description = "Chọn rod để mua (sorted by ID)",
    Items = RodNamesList,
    Callback = function(item) 
        local rodName = string.match(item, "%] (.+)$") or item
        
        for _, rod in ipairs(RodsWithPrice) do
            if rod.Name == rodName then
                State.selectedRodID = rod.Id
                
                print("═══════════════════════════════════════")
                print("🎣 ROD SELECTED")
                print("ID:", rod.Id)
                print("Name:", rod.Name)
                print("Price:", string.format("%s coins", rod.Price))
                print("═══════════════════════════════════════")
                break
            end
        end
    end
}

FarmTab:Toggle{
    Name = "🛒 Auto Buy Rod",
    StartingState = false,
    Description = "Tự động mua rod đã chọn (60s/lần)",
    Callback = function(state) 
        Config.AutoBuyRodEnabled = state
        
        if state then
            if not State.selectedRodID then
                warn("⚠️ Vui lòng chọn rod trước!")
                return
            end
            
            task.spawn(AutoBuyRodLoop)
            print("✅ Auto Buy Rod bật")
        else
            print("⏹️ Auto Buy Rod tắt")
        end
    end
}

FarmTab:Button{
    Name = "💰 Buy Rod Now",
    Description = "Mua rod ngay lập tức",
    Callback = function()
        if State.selectedRodID and Remotes.PurchaseFishingRod then
            print("💰 Đang mua rod ID:", State.selectedRodID)
            
            pcall(function()
                Remotes.PurchaseFishingRod:InvokeServer(State.selectedRodID)
            end)
            
            task.wait(1)
            EquipBestRod()
            
            print("✅ Đã mua và equip rod!")
        else
            warn("⚠️ Chọn rod trước!")
        end
    end
}

-- ┌─────────────────────────────────────────────────────────────┐
-- │ SECTION: Bait Management                                    │
-- └─────────────────────────────────────────────────────────────┘

FarmTab:Dropdown{
    Name = "🪱 Select Bait",
    StartingText = "Choose bait...",
    Description = "Chọn mồi để mua (sorted by ID)",
    Items = BaitNamesList,
    Callback = function(item)
        local baitName = string.match(item, "%] (.+)$") or item
        
        for _, bait in ipairs(BaitsWithPrice) do
            if bait.Name == baitName then
                State.selectedBaitID = bait.Id
                
                print("═══════════════════════════════════════")
                print("🪱 BAIT SELECTED")
                print("ID:", bait.Id)
                print("Name:", bait.Name)
                print("Price:", string.format("%s coins", bait.Price))
                print("═══════════════════════════════════════")
                break
            end
        end
    end
}

FarmTab:Toggle{
    Name = "🛒 Auto Buy Bait",
    StartingState = false,
    Description = "Tự động mua bait đã chọn (60s/lần)",
    Callback = function(state) 
        Config.AutoBuyBaitEnabled = state
        
        if state then
            if not State.selectedBaitID then
                warn("⚠️ Vui lòng chọn bait trước!")
                return
            end
            
            task.spawn(AutoBuyBaitLoop)
            print("✅ Auto Buy Bait bật")
        else
            print("⏹️ Auto Buy Bait tắt")
        end
    end
}

FarmTab:Button{
    Name = "💰 Buy Bait Now",
    Description = "Mua bait ngay lập tức",
    Callback = function()
        if State.selectedBaitID and Remotes.PurchaseBait then
            print("💰 Đang mua bait ID:", State.selectedBaitID)
            
            pcall(function()
                Remotes.PurchaseBait:InvokeServer(State.selectedBaitID)
            end)
            
            task.wait(1)
            EquipBait(State.selectedBaitID)
            
            print("✅ Đã mua và equip bait!")
        else
            warn("⚠️ Chọn bait trước!")
        end
    end
}

-- ════════════════════════════════════════════════════════════════
-- 📑 TAB 2: SETTINGS
-- ════════════════════════════════════════════════════════════════

local SettingsTab = GUI:Tab{
    Name = "Settings",
    Icon = "rbxassetid://8569322835"
}

SettingsTab:Slider{
    Name = "⏱️ Auto Sell Interval",
    Default = 30,
    Min = 10,
    Max = 120,
    Description = "Khoảng thời gian bán items (giây)",
    Callback = function(value)
        Config.SellInterval = value
        print("⏱️ Sell interval:", value, "giây")
    end
}

SettingsTab:Slider{
    Name = "🛒 Auto Buy Interval",
    Default = 60,
    Min = 30,
    Max = 300,
    Description = "Khoảng thời gian mua đồ (giây)",
    Callback = function(value)
        Config.BuyInterval = value
        print("⏱️ Buy interval:", value, "giây")
    end
}

SettingsTab:Slider{
    Name = "⏰ Anti-Stuck Timeout",
    Default = 20,
    Min = 10,
    Max = 60,
    Description = "Thời gian phát hiện bị treo (giây)",
    Callback = function(value)
        Config.AntiStuckTimeout = value
        print("⏰ Anti-stuck timeout:", value, "giây")
    end
}

SettingsTab:Button{
    Name = "🔄 Manual Equip Best Rod",
    Description = "Tự động tìm và equip rod mạnh nhất",
    Callback = function()
        print("🔄 Đang equip rod mạnh nhất...")
        EquipBestRod()
    end
}

SettingsTab:Button{
    Name = "🔄 Reset Character",
    Description = "Reset character (fix stuck)",
    Callback = function()
        print("🔄 Resetting character...")
        
        if Humanoid then
            Humanoid.Health = 0
        end
        
        print("✅ Character reset!")
    end
}

-- ════════════════════════════════════════════════════════════════
-- 📑 TAB 3: INFO
-- ════════════════════════════════════════════════════════════════

local InfoTab = GUI:Tab{
    Name = "Info",
    Icon = "rbxassetid://8569322835"
}

InfoTab:Label{
    Text = "Fish It - Auto Farm Script v3.0",
    Colorize = true
}

InfoTab:Label{
    Text = "Features:",
}

InfoTab:Label{
    Text = "✅ Auto Fishing (No Click)",
}

InfoTab:Label{
    Text = "✅ Auto Equip Best Rod/Bait",
}

InfoTab:Label{
    Text = "✅ Auto Buy Rod/Bait",
}

InfoTab:Label{
    Text = "✅ Auto Sell Items",
}

InfoTab:Label{
    Text = "✅ Anti-Stuck System",
}

InfoTab:Label{
    Text = "✅ Death Handler",
}

InfoTab:Label{
    Text = "════════════════════════════",
}

InfoTab:Label{
    Text = "How to use:",
}

InfoTab:Label{
    Text = "1. Chọn Location",
}

InfoTab:Label{
    Text = "2. Chọn Rod & Bait (optional)",
}

InfoTab:Label{
    Text = "3. Bật Auto Fishing",
}

InfoTab:Label{
    Text = "4. AFK & Enjoy!",
}

-- ════════════════════════════════════════════════════════════════
-- ✅ FINAL INITIALIZATION
-- ════════════════════════════════════════════════════════════════

print("")
print("════════════════════════════════════════════════════════════════")
print("✅ FISH IT SCRIPT V3.0 LOADED SUCCESSFULLY")
print("════════════════════════════════════════════════════════════════")
print("📊 Statistics:")
print("   • Rods available:", #RodsWithPrice)
print("   • Baits available:", #BaitsWithPrice)
print("   • Locations:", #LocationList)
print("   • Remotes loaded:", 11)
print("════════════════════════════════════════════════════════════════")
print("🎣 Ready to fish! Enjoy your AFK farming! 🎣")
print("════════════════════════════════════════════════════════════════")
print("")

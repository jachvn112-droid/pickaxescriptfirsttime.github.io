--[[
================================================================================
    MULTI-GAME AUTO FARM SCRIPT
    Version: 1.2 (Added Auto Equip Best)
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
if game.PlaceId == 121864768012064 then
    
    local CurrentVersion = "Fish It"
    
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
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local Items = ReplicatedStorage.Items
    local Baits = ReplicatedStorage:FindFirstChild("Baits")
    
    -- Player References
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    -- Load Game Utilities
    local ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
    
    -- Helper Functions
    local function getCharacter()
        return player.Character
    end
    
    local function getHumanoid()
        local char = getCharacter()
        return char and char:FindFirstChild("Humanoid")
    end
    
    local function getHumanoidRootPart()
        local char = getCharacter()
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    
    -- State Variables
    local fishing = false
    local selectedlocation = nil
    local isEquipped = false
    local autosellall = false
    local deathConnection = nil
    local selectedRod = nil
    local selectedBait = nil
    local isAutoBuyRod = false
    local isAutoBuyBait = false
    local isAutoEquipBest = false  -- ✅ NEW
    
    -- ✅ NEW: ROD PRICE DATABASE (for finding best rod)
    local ROD_PRICES = {
        [79] = 325, [76] = 750, [85] = 1500, [77] = 3000, [78] = 5000,
        [4] = 15000, [80] = 50000, [6] = 215000, [7] = 437000,
        [255] = 715000, [256] = 1380000, [5] = 1000000,
        [126] = 3000000, [168] = 8000000, [258] = 12000000,
        [169] = 99999999, [257] = 999999999
    }
    
    -- ✅ NEW: BAIT PRICE DATABASE (for finding best bait)
    local BAIT_PRICES = {
        [1] = 0, [2] = 1000, [3] = 3000, [10] = 100, [17] = 83500,
        [6] = 290000, [4] = 425000, [8] = 630000, [15] = 1148484,
        [16] = 3700000, [20] = 4000000, [18] = 8200000
    }
    
    -- Location Data
    local locationMap = {
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
        ["Sacred Temple"] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, -0.000, 0.143)},
        ["Second Enchant Altar"] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0.000, -0.955)},
        ["Sisyphus Statue"] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0.000, 0.951)},
        ["Treasure Room"] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0.000, -0.998)},
        ["Tropical Island"] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
        ["Underground Cellar"] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0.000, 0.521)},
        ["Volcano"] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
        ["Weather Machine"] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0.000, 0.999)},
    }
    
    -- Generate location list
    local farmlocationtable = {}
    for name, _ in pairs(locationMap) do
        table.insert(farmlocationtable, name)
    end
    table.sort(farmlocationtable)
    
    task.wait(0.5)
    
    -- ============================================
    -- BAIT DATA
    -- ============================================
    local baitwithprice = {}
    local baitnamelist = {}
    
    if Baits then
        for _, bait in pairs(Baits:GetChildren()) do
            if string.match(bait.Name, "Bait$") then
                local success, data = pcall(function()
                    return require(bait)      
                end)
                if success and data.Price then
                    table.insert(baitwithprice, {
                        Name = bait.Name,
                        Price = data.Price,
                        Id = data.Data and data.Data.Id or 9999,
                        BaseLuck = data.Modifiers and data.Modifiers.BaseLuck,
                        Data = data
                    })
                end
            end
        end
        
        table.sort(baitwithprice, function(a, b)
            return a.Id < b.Id
        end)
        
        for _, bait in ipairs(baitwithprice) do
            local displayName = string.format("[%d] %s", bait.Id, bait.Name)
            table.insert(baitnamelist, displayName)
        end
    end
    
    -- ============================================
    -- ROD DATA
    -- ============================================
    local rodsWithPrice = {}
    local rodNamesList = {}
    
    for _, item in pairs(Items:GetChildren()) do
        if string.match(item.Name, "Rod$") then
            local success, data = pcall(function()
                return require(item)
            end)
            
            if success and data.Price then
                table.insert(rodsWithPrice, {
                    Name = item.Name,
                    Price = data.Price,
                    Id = data.Data and data.Data.Id or 9999,
                    ClickPower = data.ClickPower or 0,
                    BaseLuck = data.RollData and data.RollData.BaseLuck or 0,
                    Data = data
                })
            end
        end
    end
    
    table.sort(rodsWithPrice, function(a, b)
        return a.Id < b.Id
    end)
    
    for _, rod in ipairs(rodsWithPrice) do
        local displayName = string.format("[%d] %s", rod.Id, rod.Name)
        table.insert(rodNamesList, displayName)
    end
    
    print("🎣 Found", #rodsWithPrice, "buyable rods (sorted by ID)")
    
    -- ============================================
    -- ✅ NEW: AUTO EQUIP BEST ROD FUNCTION
    -- ============================================
    local function EquipBestRod()
        print("🎣 [Auto Equip] Finding best rod...")
        
        -- Get Replion
        local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 5)
        if not ReplionModule then 
            warn("❌ Replion not found")
            return false
        end
        
        local ReplionClient = require(ReplionModule).Client
        local PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
        
        if not PlayerDataReplion then
            warn("❌ Cannot access player data")
            return false
        end
        
        local success, inventoryData = pcall(function() 
            return PlayerDataReplion:GetExpect("Inventory") 
        end)
        
        if not success or not inventoryData then
            warn("❌ Cannot read inventory")
            return false
        end
        
        -- Find best rod
        local bestRodUUID = nil
        local bestPrice = -1
        local bestRodName = "Unknown"
        
        if inventoryData["Fishing Rods"] then
            for _, rod in ipairs(inventoryData["Fishing Rods"]) do
                if typeof(rod.UUID) == "string" and #rod.UUID >= 10 then
                    local rodID = tonumber(rod.Id)
                    local price = ROD_PRICES[rodID] or 0
                    
                    if price > bestPrice then
                        bestPrice = price
                        bestRodUUID = rod.UUID
                        
                        pcall(function()
                            local itemData = ItemUtility:GetItemData(rodID)
                            if itemData and itemData.Data and itemData.Data.Name then
                                bestRodName = itemData.Data.Name
                            end
                        end)
                    end
                end
            end
        end
        
        -- Equip best rod
        if bestRodUUID then
            local ok = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0")
                    :WaitForChild("net")
                    :WaitForChild("RE/EquipItem")
                    :FireServer(bestRodUUID, "Fishing Rods")
            end)
            
            if ok then
                print("✅ Equipped best rod:", bestRodName)
                task.wait(0.3)
                
                -- Hold in hand
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages")
                        :WaitForChild("_Index")
                        :WaitForChild("sleitnick_net@0.2.0")
                        :WaitForChild("net")
                        :WaitForChild("RE/EquipToolFromHotbar")
                        :FireServer(1)
                end)
                
                isEquipped = true
                return true
            end
        end
        
        warn("⚠️ No rod found to equip")
        return false
    end
    
    -- ============================================
    -- ✅ NEW: AUTO EQUIP BEST BAIT FUNCTION
    -- ============================================
    local function EquipBestBait()
        print("🪱 [Auto Equip] Finding best bait...")
        
        -- Get Replion
        local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 5)
        if not ReplionModule then 
            warn("❌ Replion not found")
            return false
        end
        
        local ReplionClient = require(ReplionModule).Client
        local PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
        
        if not PlayerDataReplion then
            warn("❌ Cannot access player data")
            return false
        end
        
        local success, inventoryData = pcall(function() 
            return PlayerDataReplion:GetExpect("Inventory") 
        end)
        
        if not success or not inventoryData then
            warn("❌ Cannot read inventory")
            return false
        end
        
        -- Find best bait
        local bestBaitID = nil
        local bestPrice = -1
        local bestBaitName = "Unknown"
        
        if inventoryData["Bait"] then
            for _, bait in ipairs(inventoryData["Bait"]) do
                local baitID = tonumber(bait.Id)
                local price = BAIT_PRICES[baitID] or 0
                
                if price > bestPrice then
                    bestPrice = price
                    bestBaitID = baitID
                    bestBaitName = bait.Name or ("Bait ID " .. baitID)
                end
            end
        end
        
        -- Equip best bait
        if bestBaitID then
            local ok = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0")
                    :WaitForChild("net")
                    :WaitForChild("RE/EquipBait")
                    :FireServer(bestBaitID)
            end)
            
            if ok then
                print("✅ Equipped best bait:", bestBaitName)
                return true
            end
        end
        
        warn("⚠️ No bait found to equip")
        return false
    end
    
    -- ============================================
    -- GAME FUNCTIONS
    -- ============================================
    
    local function enableAutoFishing()
        local args = {true}
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")
            :WaitForChild("RF/UpdateAutoFishingState")
            :InvokeServer(unpack(args))
    end
    
    local function disableAutoFishing()
        local args = {false}
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")
            :WaitForChild("RF/UpdateAutoFishingState")
            :InvokeServer(unpack(args))
    end
    
    local function buyRod(rodName)
        if not rodName then
            warn("⚠️ No rod name provided!")
            return
        end
        
        local success, err = pcall(function()
            local args = {rodName}
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")
                :WaitForChild("RF/PurchaseFishingRod")
                :InvokeServer(unpack(args))
            
            print("✅ Bought:", rodName)
        end)
        
        if not success then
            warn("❌ Buy failed:", err)
        end
    end
    
    local function autoequip()
        if isEquipped then return end
        
        local success, err = pcall(function()
            local args = {1}
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")
                :WaitForChild("RE/EquipToolFromHotbar")
                :FireServer(unpack(args))
            
            isEquipped = true
            print("✅ Equipped fishing rod")
        end)
        
        if not success then
            warn("❌ Equip failed:", err)
            isEquipped = false
        end
    end
    
    local function sellAllItems()
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")
                :WaitForChild("RF/SellAllItems")
                :InvokeServer()
            
            print("💰 Sold all items!")
        end)
        
        if not success then
            warn("❌ Sell failed:", err)
        end
    end
    
    local function disconnectDeathHandler()
        if deathConnection then
            deathConnection:Disconnect()
            deathConnection = nil
            print("🔌 Disconnected death handler")
        end
    end
    
    local function setupDeathHandler()
        disconnectDeathHandler()
        
        local humanoid = getHumanoid()
        if not humanoid then 
            warn("❌ Cannot setup death handler")
            return 
        end
        
        deathConnection = humanoid.Died:Connect(function()
            print("💀 Character died, waiting for respawn...")
            isEquipped = false
            
            local newCharacter = player.CharacterAdded:Wait()
            local newHumanoid = newCharacter:WaitForChild("Humanoid")
            local newHumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
            
            task.wait(1)
            
            if selectedlocation and newHumanoidRootPart then
                newHumanoidRootPart.CFrame = selectedlocation
                print("📍 Teleported back")
            end
            
            task.wait(0.5)
            
            -- ✅ Use new auto equip function
            if isAutoEquipBest then
                EquipBestRod()
                task.wait(0.5)
                EquipBestBait()
            else
                autoequip()
            end
            
            print("✅ Respawned and re-equipped")
            
            if fishing then
                setupDeathHandler()
            end
        end)
        
        print("🔗 Death handler connected")
    end
    
    local function clickMouse()
        local humanoid = getHumanoid()
        local humanoidRootPart = getHumanoidRootPart()
        
        if not humanoid or humanoid.Health <= 0 or not humanoidRootPart then 
            return 
        end
        
        local success = pcall(function()
            local mousePos = UserInputService:GetMouseLocation()
            
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
        end)
        
        if not success then
            warn("❌ Click failed")
        end
    end
    
    local function teleportToLocation(locationData)
        local humanoidRootPart = getHumanoidRootPart()
        if humanoidRootPart and locationData then
            local pos = locationData.Pos
            local look = locationData.Look
            humanoidRootPart.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.atan2(look.X, look.Z), 0)
            print("📍 Teleported to location")
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
        Name = "Select Rod to Buy",
        StartingText = "Select a rod...",
        Description = "Sorted by ID",
        Items = rodNamesList,
        Callback = function(item) 
            local rodName = string.match(item, "%] (.+)$") or item
            selectedRod = rodName
            
            for _, rod in ipairs(rodsWithPrice) do
                if rod.Name == rodName then
                    print("═══════════════════════════════════")
                    print("🆔 ID:", rod.Id)
                    print("🎣 Rod:", rod.Name)
                    print("💰 Price:", string.format("%d", rod.Price))
                    print("💪 Click Power:", rod.ClickPower)
                    print("🍀 Luck:", rod.BaseLuck)
                    print("═══════════════════════════════════")
                    break
                end
            end
        end
    }
    
    FarmTab:Dropdown{
        Name = "Select bait to Buy",
        StartingText = "Select a Bait...",
        Description = "Sorted by ID",
        Items = baitnamelist,
        Callback = function(item) 
            local BaitName = string.match(item, "%] (.+)$") or item
            selectedBait = BaitName
            
            for _, bait in ipairs(baitwithprice) do
                if bait.Name == BaitName then
                    print("═══════════════════════════════════")
                    print("🆔 ID:", bait.Id)
                    print("🪱 Bait:", bait.Name)
                    print("💰 Price:", string.format("%d", bait.Price))
                    print("🍀 Luck:", bait.BaseLuck)
                    print("═══════════════════════════════════")
                    break
                end
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy Rod",
        StartingState = false,
        Description = "Auto buy selected rod every 60s",
        Callback = function(state) 
            isAutoBuyRod = state
            
            if isAutoBuyRod and not selectedRod then
                warn("⚠️ Please select a rod first!")
                return
            end
            
            task.spawn(function()
                while isAutoBuyRod do
                    if selectedRod then
                        buyRod(selectedRod)
                        task.wait(60)
                    else
                        warn("⚠️ No rod selected!")
                        task.wait(5)
                    end
                end
            end)
            
            if state then
                print("✅ Auto Buy Rod enabled for:", selectedRod)
            else
                print("❌ Auto Buy Rod disabled")
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy Bait",
        StartingState = false,
        Description = "Auto buy selected Baits every 60s",
        Callback = function(state) 
            isAutoBuyBait = state
            
            if isAutoBuyBait and not selectedBait then
                warn("⚠️ Please select a bait first!")
                return
            end
            
            task.spawn(function()
                while isAutoBuyBait do
                    if selectedBait then
                        -- Note: Need to implement buyBait function if needed
                        task.wait(60)
                    else
                        warn("⚠️ No bait selected!")
                        task.wait(5)
                    end
                end
            end)
            
            if state then
                print("✅ Auto Buy Bait enabled")
            else
                print("❌ Auto Buy Bait disabled")
            end
        end
    }
    
    FarmTab:Button{
        Name = "Buy Selected Rod Now",
        Description = "Buy immediately",
        Callback = function()
            if selectedRod then
                buyRod(selectedRod)
            else
                warn("⚠️ Please select a rod first!")
            end
        end
    }
    
    -- ✅ NEW: AUTO EQUIP BEST TOGGLE
    FarmTab:Toggle{
        Name = "🔄 Auto Equip Best Rod & Bait",
        StartingState = false,
        Description = "Auto equip best rod & bait every 3 minutes",
        Callback = function(state) 
            isAutoEquipBest = state
            
            if state then
                print("✅ Auto Equip Best enabled (every 3 min)")
                
                task.spawn(function()
                    while isAutoEquipBest do
                        print("🔄 [Auto Equip] Running...")
                        EquipBestRod()
                        task.wait(1)
                        EquipBestBait()
                        
                        task.wait(180)  -- 3 minutes = 180 seconds
                    end
                end)
            else
                print("❌ Auto Equip Best disabled")
            end
        end
    }
    
    FarmTab:Button{
        Name = "🔄 Equip Best Now",
        Description = "Manually equip best rod & bait",
        Callback = function()
            print("🔄 Equipping best rod and bait...")
            EquipBestRod()
            task.wait(1)
            EquipBestBait()
        end
    }
    
    FarmTab:Dropdown{
        Name = "Select Location",
        StartingText = "Select...",
        Description = "Choose fishing location",
        Items = farmlocationtable,
        Callback = function(item) 
            selectedlocation = locationMap[item]
            if selectedlocation then
                print("📍 Selected location:", item)
                teleportToLocation(selectedlocation)
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Sell All",
        StartingState = false,
        Description = "Auto sell all items every 20s",
        Callback = function(state) 
            autosellall = state
            
            task.spawn(function()
                while autosellall do
                    sellAllItems()
                    task.wait(20)
                end
            end)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Farm",
        StartingState = false,
        Description = "Enable auto fishing",
        Callback = function(state) 
            fishing = state
            
            if fishing then
                print("🎣 Auto Farm started!")
                
                enableAutoFishing()
                setupDeathHandler()
                task.wait(0.5)
                
                -- ✅ Use new auto equip if enabled
                if isAutoEquipBest then
                    EquipBestRod()
                    task.wait(0.5)
                    EquipBestBait()
                else
                    autoequip()
                end
                
                -- Auto click loop
                task.spawn(function()
                    while fishing do
                        local humanoid = getHumanoid()
                        
                        if humanoid and humanoid.Health > 0 then
                            clickMouse()
                            task.wait(0.3)
                        else
                            task.wait(1)
                        end
                    end
                    print("🛑 Click loop stopped")
                end)
                
                -- Re-equip check loop
                task.spawn(function()
                    while fishing do
                        local humanoid = getHumanoid()
                        
                        if humanoid and humanoid.Health > 0 and not isEquipped then
                            print("⚠️ Re-equipping tool...")
                            
                            if isAutoEquipBest then
                                EquipBestRod()
                            else
                                autoequip()
                            end
                        end
                        task.wait(5)
                    end
                    print("🛑 Re-equip loop stopped")
                end)
            else
                print("⏹️ Auto Farm stopped!")
                disableAutoFishing()
                disconnectDeathHandler()
                isEquipped = false
            end
        end
    }
    
    -- ============================================
    -- UI SETUP - PET TAB
    -- ============================================
    local PetTab = GUI:Tab{
        Name = "Pet Tab",
        Icon = "rbxassetid://8569322835"
    }
    
    PetTab:Button{
        Name = "Coming Soon",
        Description = "Pet features will be added soon",
        Callback = function()
            print("🐾 Pet features coming soon!")
        end
    }
    
    print("✅ Fish It script loaded!")
end

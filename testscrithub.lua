--[[
================================================================================
    MULTI-GAME AUTO FARM SCRIPT
    Version: 2.0 (Rewritten & Optimized)
    Games: Pickaxe Simulator & Fish It
    
    Features:
    - Auto Mining, Auto Training, Auto Rebirth
    - Auto Buy Pickaxe/Miner
    - Auto Equip Best Pets
    - Auto Hatch Eggs
    - Auto Fishing with Death Handler
    - Auto Buy Rod/Bait
    - Teleportation System
================================================================================
]]

--[[
================================================================================
                            PICKAXE SIMULATOR
================================================================================
]]
if game.PlaceId == 82013336390273 then

    -- ══════════════════════════════════════════════════════════════════════
    -- SERVICES
    -- ══════════════════════════════════════════════════════════════════════
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- ══════════════════════════════════════════════════════════════════════
    -- PLAYER REFERENCES
    -- ══════════════════════════════════════════════════════════════════════
    local player = Players.LocalPlayer
    local playerStats = ReplicatedStorage.Stats:WaitForChild(player.Name)
    local miningSpeedBoost = playerStats:WaitForChild("MiningSpeedBoost")
    local miningPower = playerStats:WaitForChild("Power")
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI LIBRARY
    -- ══════════════════════════════════════════════════════════════════════
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
    
    local GUI = Mercury:Create({
        Name = "Pickaxe Simulator",
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    })
    
    -- ══════════════════════════════════════════════════════════════════════
    -- STATE VARIABLES
    -- ══════════════════════════════════════════════════════════════════════
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
    
    -- ══════════════════════════════════════════════════════════════════════
    -- CONFIGURATION LISTS
    -- ══════════════════════════════════════════════════════════════════════
    local SpeedMiningList = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
    
    local RebirthList = {
        1, 5, 20, 50, 100, 250, 500, 1000, 2500, 5000,
        10000, 25000, 50000, 100000, 250000, 500000,
        1000000, 2500000, 10000000, 25000000, 100000000,
        1000000000, 50000000000, 500000000000, 5000000000000,
        100000000000000, 1000000000000000, 50000000000000000,
        500000000000000000, 2500000000000000000, 50000000000000000000,
        500000000000000000000, 5e+21, 1e+23, 1e+24, 5e+25
    }
    
    local PowerMiningList = {999, 9999, 99999, 999999, 9999999, 99999999}
    
    local EggsList = {
        "5M Egg", "Angelic Egg", "Aqua Egg", "Aura Egg",
        "Basic Egg", "Beach Egg", "Black Hole Egg", "Cave Egg",
        "Christmas Egg", "Dark Egg", "Electric Egg", "Farm Egg",
        "Forest Egg", "Galaxy Egg", "Garden Egg", "Ice Egg",
        "Lava Egg", "Music Egg", "Pixel Egg", "Rare Egg",
        "Rocket Egg", "Sakura Egg", "Sand Egg", "Snow Egg",
        "Sunny Egg", "Toy Egg", "UFO Egg", "Winter Egg"
    }
    
    -- ══════════════════════════════════════════════════════════════════════
    -- REMOTE HELPER FUNCTIONS
    -- ══════════════════════════════════════════════════════════════════════
    local function getRemoteEvent()
        return ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remoteevent")
    end
    
    local function getRemoteFunction()
        return ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
    end
    
    local function fireRemoteEvent(...)
        getRemoteEvent():FireServer(...)
    end
    
    local function invokeRemoteFunction(...)
        return getRemoteFunction():InvokeServer(...)
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- GAME ACTION FUNCTIONS
    -- ══════════════════════════════════════════════════════════════════════
    local function toggleAutoMine()
        fireRemoteEvent("Toggle Setting", "AutoMine")
    end
    
    local function toggleAutoTrain()
        fireRemoteEvent("Toggle Setting", "AutoTrain")
    end
    
    local function autoEquipBest()
        invokeRemoteFunction("Pet", {Action = "EquipBest", Sort = "Power"})
    end
    
    local function autoSellOres()
        invokeRemoteFunction("Sell All Ores")
    end
    
    local function buyPickaxe()
        invokeRemoteFunction("Buy Pickaxe")
    end
    
    local function buyMiner()
        invokeRemoteFunction("Buy Miner")
    end
    
    local function hatchEgg(eggName)
        invokeRemoteFunction("Hatch Egg", eggName, 3)
    end
    
    local function performRebirth(rebirthAmount)
        invokeRemoteFunction("Rebirth", rebirthAmount)
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
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI SETUP - FARM TAB
    -- ══════════════════════════════════════════════════════════════════════
    local FarmTab = GUI:Tab({
        Name = "Auto Farm",
        Icon = "rbxassetid://8569322835"
    })
    
    -- Rebirth Section
    FarmTab:Dropdown({
        Name = "Select Rebirth Amount",
        StartingText = "Select...",
        Description = "Choose rebirth amount",
        Items = RebirthList,
        Callback = function(item)
            selectedRebirth = item
            print("🔄 Selected rebirth:", selectedRebirth)
        end
    })
    
    FarmTab:Toggle({
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
    })
    
    -- Power Section
    FarmTab:Dropdown({
        Name = "Select Your Power",
        StartingText = "Select...",
        Description = "Choose mining power",
        Items = PowerMiningList,
        Callback = function(item)
            selectedPower = item
            print("💪 Selected power:", selectedPower)
        end
    })
    
    FarmTab:Toggle({
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
    })
    
    -- Speed Section
    FarmTab:Dropdown({
        Name = "Select Mining Speed",
        StartingText = "Select...",
        Description = "Choose speed (1-20)",
        Items = SpeedMiningList,
        Callback = function(item)
            selectedMiningSpeed = item
            print("⚡ Selected speed:", selectedMiningSpeed)
        end
    })
    
    FarmTab:Toggle({
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
    })
    
    -- Auto Buy Section
    FarmTab:Toggle({
        Name = "Auto Buy Pickaxe",
        StartingState = false,
        Description = "Auto upgrade pickaxe every 30s",
        Callback = function(state)
            isAutoBuyPickaxe = state
            
            task.spawn(function()
                while isAutoBuyPickaxe do
                    buyPickaxe()
                    task.wait(30)
                end
            end)
        end
    })
    
    FarmTab:Toggle({
        Name = "Auto Buy Miner",
        StartingState = false,
        Description = "Auto upgrade miner every 30s",
        Callback = function(state)
            isAutoBuyMiner = state
            
            task.spawn(function()
                while isAutoBuyMiner do
                    buyMiner()
                    task.wait(30)
                end
            end)
        end
    })
    
    -- Pet & Training Section
    FarmTab:Toggle({
        Name = "Auto Equip Best",
        StartingState = false,
        Description = "Auto equip strongest pets every 20s",
        Callback = function(state)
            isEquipBestEnabled = state
            
            task.spawn(function()
                while isEquipBestEnabled do
                    autoEquipBest()
                    task.wait(20)
                end
            end)
        end
    })
    
    FarmTab:Toggle({
        Name = "Auto Train",
        StartingState = false,
        Description = "Enable auto training every 2min",
        Callback = function(state)
            isAutoTraining = state
            
            task.spawn(function()
                while isAutoTraining do
                    toggleAutoTrain()
                    task.wait(120)
                end
            end)
        end
    })
    
    FarmTab:Toggle({
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
    })
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI SETUP - PET TAB
    -- ══════════════════════════════════════════════════════════════════════
    local PetTab = GUI:Tab({
        Name = "Pet Tab",
        Icon = "rbxassetid://8569322835"
    })
    
    PetTab:Dropdown({
        Name = "Select Egg",
        StartingText = "Select...",
        Description = "Choose egg to hatch",
        Items = EggsList,
        Callback = function(item)
            selectedEgg = item
            print("🥚 Selected egg:", selectedEgg)
        end
    })
    
    PetTab:Toggle({
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
    })
    
    print("✅ Pickaxe Simulator script loaded!")
end


--[[
================================================================================
                                FISH IT
================================================================================
]]
if game.PlaceId == 121864768012064 then

    -- ══════════════════════════════════════════════════════════════════════
    -- SERVICES
    -- ══════════════════════════════════════════════════════════════════════
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    
    -- ══════════════════════════════════════════════════════════════════════
    -- PLAYER REFERENCES
    -- ══════════════════════════════════════════════════════════════════════
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local Character = player.Character or player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")
    
    -- ══════════════════════════════════════════════════════════════════════
    -- GAME MODULES
    -- ══════════════════════════════════════════════════════════════════════
    local Items = ReplicatedStorage.Items
    local Baits = ReplicatedStorage:FindFirstChild("Baits")
    
    local ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
    local TierUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI LIBRARY
    -- ══════════════════════════════════════════════════════════════════════
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
    
    local GUI = Mercury:Create({
        Name = "Fish It",
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    })
    
    -- ══════════════════════════════════════════════════════════════════════
    -- STATE VARIABLES
    -- ══════════════════════════════════════════════════════════════════════
    local fishing = false
    local isEquipped = false
    local autoSellAll = false
    local isAutoBuyRod = false
    local isAutoBuyBait = false
    local autoFavorite = false
    
    local selectedLocation = nil
    local selectedRod = nil
    local selectedBait = nil
    local selectedRarities = {}
    
    local deathConnection = nil
    local autoFavoriteThread = nil
    
    -- ══════════════════════════════════════════════════════════════════════
    -- SCREEN POSITIONS (for UI automation)
    -- ══════════════════════════════════════════════════════════════════════
    local POSITIONS = {
        openInventory = {x = 292, y = 414},
        equipRod = {x = 237, y = 238},
        exitButton = {x = 715, y = 95},
    }
    
    local BAIT_POSITIONS = {
        bait1 = {x = 384, y = 410},
        bait2 = {x = 433, y = 104},
        bait3 = {x = 228, y = 232},
        bait4 = {x = 228, y = 247},
    }
    
    -- ══════════════════════════════════════════════════════════════════════
    -- LOCATION DATA
    -- ══════════════════════════════════════════════════════════════════════
    local LocationMap = {
        ["Ancient Jungle"]          = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, 0, 0.863)},
        ["Ancient Ruin"]            = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, 0, -0.949)},
        ["Arrow Lever"]             = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, 0, 1.000)},
        ["Classic Island"]          = {Pos = Vector3.new(1440.843, 46.062, 2777.175), Look = Vector3.new(0.940, 0, 0.342)},
        ["Coral Reef"]              = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0, 0.229)},
        ["Crater Island"]           = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0, 0.615)},
        ["Cresent Lever"]           = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0, 0, -1.000)},
        ["Crystalline Passage"]     = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0, 0.994)},
        ["Diamond Lever"]           = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0, 0, -1.000)},
        ["Disco Event"]             = {Pos = Vector3.new(-8641.672, -547.500, 160.322), Look = Vector3.new(0.984, 0, 0.176)},
        ["Enchant Room"]            = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(0, 0, -1.000)},
        ["Esoteric Island"]         = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(0, 0, -1.000)},
        ["Fisherman Island"]        = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(0, 0, -1.000)},
        ["Hourglass Diamond Lever"] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(0, 0, -1.000)},
        ["Iron Cavern"]             = {Pos = Vector3.new(-8792.546, -588.000, 230.642), Look = Vector3.new(0.718, 0, 0.696)},
        ["Kohana"]                  = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, 0, 0.458)},
        ["Lost Isle"]               = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, 0, 0.433)},
        ["Sacred Temple"]           = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, 0, 0.143)},
        ["Second Enchant Altar"]    = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0, -0.955)},
        ["Sisyphus Statue"]         = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0, 0.951)},
        ["Treasure Room"]           = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0, -0.998)},
        ["Tropical Island"]         = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, 0, 0.925)},
        ["Underground Cellar"]      = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0, 0.521)},
        ["Volcano"]                 = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0, 0.520)},
        ["Weather Machine"]         = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0, 0.999)},
        -- Custom locations (add your own)
        ["My Custom Spot"]          = {Pos = Vector3.new(100, 10, 200), Look = Vector3.new(1, 0, 0)},
        ["Secret Fishing Area"]     = {Pos = Vector3.new(-500, 5, 300), Look = Vector3.new(0, 0, 1)},
    }
    
    -- Build sorted location list
    local LocationList = {}
    for locationName, _ in pairs(LocationMap) do
        table.insert(LocationList, locationName)
    end
    table.sort(LocationList)
    
    -- ══════════════════════════════════════════════════════════════════════
    -- REMOTE ACCESS
    -- ══════════════════════════════════════════════════════════════════════
    local net = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
    
    local function GetRemote(name)
        return net:FindFirstChild(name)
    end
    
    -- Cache remotes
    local EquipTool = GetRemote("RE/EquipToolFromHotbar")
    local ChargeRod = GetRemote("RF/ChargeFishingRod")
    local StartMini = GetRemote("RF/RequestFishingMinigameStarted")
    local UpdateAutoFishing = GetRemote("RF/UpdateAutoFishingState")
    local PurchaseRod = GetRemote("RF/PurchaseFishingRod")
    local PurchaseBait = GetRemote("RF/PurchaseBait")
    local SellAll = GetRemote("RF/SellAllItems")
    local FavoriteItem = GetRemote("RE/FavoriteItem")
    
    -- ══════════════════════════════════════════════════════════════════════
    -- REPLION DATA ACCESS (for inventory reading)
    -- ══════════════════════════════════════════════════════════════════════
    local PlayerDataReplion = nil
    
    local function GetPlayerDataReplion()
        if PlayerDataReplion then return PlayerDataReplion end
        local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
        if not ReplionModule then 
            warn("❌ Replion module không tìm thấy!")
            return nil 
        end
        local ReplionClient = require(ReplionModule).Client
        -- Fish It dùng " " (space) thay vì "Data"
        PlayerDataReplion = ReplionClient:WaitReplion(" ", 5)
        return PlayerDataReplion
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- HELPER FUNCTIONS
    -- ══════════════════════════════════════════════════════════════════════
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
    
    local function updateCharacterReferences()
        Character = player.Character or player.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- CLICK FUNCTIONS
    -- ══════════════════════════════════════════════════════════════════════
    local function clickAt(x, y, waitTime)
        waitTime = waitTime or 0.1
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        task.wait(waitTime)
    end
    
    local function clickMouse()
        local humanoid = getHumanoid()
        local hrp = getHumanoidRootPart()
        
        if not humanoid or humanoid.Health <= 0 or not hrp then
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
    
    -- ══════════════════════════════════════════════════════════════════════
    -- TELEPORT FUNCTION
    -- ══════════════════════════════════════════════════════════════════════
    local function teleportToLocation(locationData)
        local hrp = getHumanoidRootPart()
        if hrp and locationData then
            local pos = locationData.Pos
            local look = locationData.Look
            
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.atan2(look.X, look.Z), 0)
            
            if camera then
                camera.CFrame = CFrame.new(pos + Vector3.new(0, 5, 10), pos)
            end
            
            print("📍 Teleported to location")
        end
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- DATA COLLECTION - BAITS
    -- ══════════════════════════════════════════════════════════════════════
    local baitsWithPrice = {}
    local baitNamesList = {}
    
    if Baits then
        for _, baitItem in pairs(Baits:GetChildren()) do
            if string.match(baitItem.Name, "Bait$") then
                local success, baitData = pcall(function()
                    return require(baitItem)
                end)
                
                if success and baitData.Price then
                    table.insert(baitsWithPrice, {
                        Name = baitItem.Name,
                        Price = baitData.Price,
                        Id = baitData.Data and baitData.Data.Id or 9999,
                        BaseLuck = baitData.Modifiers and baitData.Modifiers.BaseLuck or 0,
                        Data = baitData
                    })
                end
            end
        end
        
        table.sort(baitsWithPrice, function(a, b)
            return a.Id < b.Id
        end)
        
        for _, bait in ipairs(baitsWithPrice) do
            table.insert(baitNamesList, string.format("[%d] %s", bait.Id, bait.Name))
        end
        
        print("🎣 Found", #baitsWithPrice, "buyable baits (sorted by ID)")
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- DATA COLLECTION - RODS
    -- ══════════════════════════════════════════════════════════════════════
    local rodsWithPrice = {}
    local rodNamesList = {}
    
    for _, item in pairs(Items:GetChildren()) do
        if string.match(item.Name, "Rod$") then
            local success, rodData = pcall(function()
                return require(item)
            end)
            
            if success and rodData.Price then
                table.insert(rodsWithPrice, {
                    Name = item.Name,
                    Price = rodData.Price,
                    Id = rodData.Data and rodData.Data.Id or 9999,
                    ClickPower = rodData.ClickPower or 0,
                    BaseLuck = rodData.RollData and rodData.RollData.BaseLuck or 0,
                    Data = rodData
                })
            end
        end
    end
    
    table.sort(rodsWithPrice, function(a, b)
        return a.Id < b.Id
    end)
    
    for _, rod in ipairs(rodsWithPrice) do
        table.insert(rodNamesList, string.format("[%d] %s", rod.Id, rod.Name))
    end
    
    print("🎣 Found", #rodsWithPrice, "buyable rods (sorted by ID)")
    
    -- ══════════════════════════════════════════════════════════════════════
    -- GAME ACTION FUNCTIONS
    -- ══════════════════════════════════════════════════════════════════════
    local function closeInventory()
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            local inventory = playerGui:FindFirstChild("Inventory")
            if inventory then
                inventory.Enabled = false
            end
        end
    end
    
    local function enableAutoFishing()
        if UpdateAutoFishing then
            UpdateAutoFishing:InvokeServer(true)
        end
    end
    
    local function disableAutoFishing()
        if UpdateAutoFishing then
            UpdateAutoFishing:InvokeServer(false)
        end
    end
    
    local function buyRod(rodId)
        if not rodId then
            warn("⚠️ No rod ID provided!")
            return
        end
        
        local success, err = pcall(function()
            if PurchaseRod then
                PurchaseRod:InvokeServer(rodId)
                print("✅ Bought rod ID:", rodId)
            end
        end)
        
        if not success then
            warn("❌ Buy rod failed:", err)
        end
    end
    
    local function buyBait(baitId)
        if not baitId then
            warn("⚠️ No bait ID provided!")
            return
        end
        
        local success, err = pcall(function()
            if PurchaseBait then
                PurchaseBait:InvokeServer(baitId)
                print("✅ Bought bait ID:", baitId)
            end
        end)
        
        if not success then
            warn("❌ Buy bait failed:", err)
        end
    end
    
    local function autoEquip()
        if isEquipped then return end
        
        local success, err = pcall(function()
            if EquipTool then
                EquipTool:FireServer(1)
                isEquipped = true
                print("✅ Equipped fishing rod")
            end
        end)
        
        if not success then
            warn("❌ Equip failed:", err)
            isEquipped = false
        end
    end
    
    local function sellAllItems()
        local success, err = pcall(function()
            if SellAll then
                SellAll:InvokeServer()
                print("💰 Sold all items!")
            end
        end)
        
        if not success then
            warn("❌ Sell failed:", err)
        end
    end
    
    local function autoEquipRod()
        print("🎣 Starting rod equip...")
        clickAt(POSITIONS.openInventory.x, POSITIONS.openInventory.y, 1)
        clickAt(POSITIONS.equipRod.x, POSITIONS.equipRod.y, 0.5)
        task.wait(2)
        closeInventory()
    end
    
    local function autoEquipBait()
        task.wait(5)
        clickAt(BAIT_POSITIONS.bait1.x, BAIT_POSITIONS.bait1.y, 1)
        clickAt(BAIT_POSITIONS.bait2.x, BAIT_POSITIONS.bait2.y, 1)
        clickAt(BAIT_POSITIONS.bait3.x, BAIT_POSITIONS.bait3.y, 1)
        task.wait(2)
        closeInventory()
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- AUTO FAVORITE FISH SYSTEM
    -- ══════════════════════════════════════════════════════════════════════
    
    -- Rarity list for dropdown (dùng chữ thường để so sánh)
    local RarityList = {"common", "uncommon", "rare", "epic", "legendary", "mythic", "secret"}
    
    -- Get fish name and rarity from item data
    local function getFishNameAndRarity(item)
        local name = item.Identifier or "Unknown"
        local rarity = "common"
        
        -- Try to get from metadata
        if item.Metadata and item.Metadata.Rarity then
            rarity = string.lower(tostring(item.Metadata.Rarity))
        end
        
        -- Try to get proper name from ItemUtility
        local itemID = item.Id
        if ItemUtility and itemID then
            local success, itemData = pcall(function()
                return ItemUtility:GetItemData(itemID)
            end)
            if success and itemData and itemData.Data and itemData.Data.Name then
                name = itemData.Data.Name
            end
            -- Get rarity from TierUtility if not in metadata
            if success and itemData and itemData.Probability and itemData.Probability.Chance and TierUtility then
                pcall(function()
                    local tierName = TierUtility:GetTierFromChance(itemData.Probability.Chance)
                    if tierName then
                        rarity = string.lower(tostring(tierName))
                    end
                end)
            end
        end
        
        return name, rarity
    end
    
    -- Get items that should be favorited (chỉ check rarity)
    local function getItemsToFavorite()
        local replion = GetPlayerDataReplion()
        if not replion then 
            print("⚠️ [Auto Favorite] Không thể lấy Replion data")
            return {} 
        end
        
        local success, inventoryData = pcall(function()
            return replion:GetExpect("Inventory")
        end)
        
        if not success or not inventoryData then
            print("⚠️ [Auto Favorite] Không thể đọc Inventory")
            return {}
        end
        
        -- Fish It inventory structure: inventoryData.Items là array của items
        if not inventoryData.Items then
            print("⚠️ [Auto Favorite] inventoryData.Items không tồn tại")
            -- Debug: xem có gì trong inventory
            print("  → Keys trong inventoryData:")
            for key, value in pairs(inventoryData) do
                print("    →", key, ":", type(value))
            end
            return {}
        end
        
        local items = inventoryData.Items
        
        if type(items) ~= "table" then
            print("⚠️ [Auto Favorite] Items không phải table")
            return {}
        end
        
        local itemsToFavorite = {}
        
        -- No rarity selected = don't favorite anything
        if #selectedRarities == 0 then
            print("⚠️ [Auto Favorite] Chưa chọn rarity nào")
            return {}
        end
        
        print("🔍 [Auto Favorite] Đang scan inventory... Tìm rarity:", table.concat(selectedRarities, ", "))
        
        local totalItems = 0
        local alreadyFavorited = 0
        local matched = 0
        
        -- Dùng ipairs như module macu fake.lua
        for _, item in ipairs(items) do
            if type(item) ~= "table" then continue end
            
            totalItems = totalItems + 1
            
            -- Skip if already favorited (check cả 2 field)
            if item.IsFavorite == true or item.Favorited == true then
                alreadyFavorited = alreadyFavorited + 1
                continue
            end
            
            -- Validate UUID
            local itemUUID = item.UUID
            if typeof(itemUUID) ~= "string" or string.len(itemUUID) < 10 then
                continue
            end
            
            local name, rarity = getFishNameAndRarity(item)
            
            -- Check if rarity matches any selected rarity (đã lowercase)
            local rarityLower = string.lower(rarity)
            for _, selectedRarity in ipairs(selectedRarities) do
                if rarityLower == string.lower(selectedRarity) then
                    matched = matched + 1
                    print(string.format("  ✅ Tìm thấy: %s (%s)", name, rarity))
                    table.insert(itemsToFavorite, itemUUID)
                    break
                end
            end
        end
        
        print(string.format("📊 [Auto Favorite] Tổng: %d | Đã favorite: %d | Khớp: %d", totalItems, alreadyFavorited, matched))
        
        return itemsToFavorite
    end
    
    -- Set item favorite state
    local function setItemFavorite(itemUUID)
        if not FavoriteItem then 
            warn("❌ FavoriteItem remote không tìm thấy!")
            return false 
        end
        
        local success, err = pcall(function()
            FavoriteItem:FireServer(itemUUID)
        end)
        
        if success then
            print("  ⭐ Đã favorite:", itemUUID)
        else
            warn("  ❌ Lỗi favorite:", err)
        end
        
        return success
    end
    
    -- Run auto favorite loop
    local function runAutoFavoriteLoop()
        if autoFavoriteThread then
            task.cancel(autoFavoriteThread)
        end
        
        autoFavoriteThread = task.spawn(function()
            print("⭐ Auto Favorite started!")
            
            while autoFavorite do
                local itemsToFavorite = getItemsToFavorite()
                
                if #itemsToFavorite > 0 then
                    print(string.format("⭐ Favoriting %d items...", #itemsToFavorite))
                    for _, itemUUID in ipairs(itemsToFavorite) do
                        setItemFavorite(itemUUID)
                        task.wait(0.5) -- Delay between favorites to avoid rate limiting
                    end
                end
                
                task.wait(1) -- Check every 1 second
            end
            
            print("⭐ Auto Favorite stopped!")
        end)
    end
    
    local function stopAutoFavorite()
        if autoFavoriteThread then
            task.cancel(autoFavoriteThread)
            autoFavoriteThread = nil
        end
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- DEATH HANDLER
    -- ══════════════════════════════════════════════════════════════════════
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
            local newHRP = newCharacter:WaitForChild("HumanoidRootPart")
            
            updateCharacterReferences()
            task.wait(1)
            
            if selectedLocation and newHRP then
                teleportToLocation(selectedLocation)
                print("📍 Teleported back")
            end
            
            task.wait(0.5)
            autoEquip()
            
            print("✅ Respawned and re-equipped")
            
            if fishing then
                setupDeathHandler()
            end
        end)
        
        print("🔗 Death handler connected")
    end
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI SETUP - FARM TAB
    -- ══════════════════════════════════════════════════════════════════════
    local FarmTab = GUI:Tab({
        Name = "Auto Farm",
        Icon = "rbxassetid://8569322835"
    })
    
    -- Rod Selection
    FarmTab:Dropdown({
        Name = "Select Rod to Buy",
        StartingText = "Select a rod...",
        Description = "Sorted by ID",
        Items = rodNamesList,
        Callback = function(item)
            local rodName = string.match(item, "%] (.+)$") or item
            
            for _, rod in ipairs(rodsWithPrice) do
                if rod.Name == rodName then
                    selectedRod = rod.Id
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
    })
    
    FarmTab:Toggle({
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
                        autoEquipRod()
                        task.wait(60)
                    else
                        warn("⚠️ No rod selected!")
                        task.wait(5)
                    end
                end
            end)
            
            if state then
                print("✅ Auto Buy Rod enabled for ID:", selectedRod)
            else
                print("❌ Auto Buy Rod disabled")
            end
        end
    })
    
    FarmTab:Button({
        Name = "Buy Selected Rod Now",
        Description = "Buy immediately",
        Callback = function()
            if selectedRod then
                print("💰 Purchasing rod ID:", selectedRod)
                buyRod(selectedRod)
                autoEquipRod()
            else
                warn("⚠️ Please select a rod first!")
            end
        end
    })
    
    -- Bait Selection
    FarmTab:Dropdown({
        Name = "Select Bait to Buy",
        StartingText = "Select a bait...",
        Description = "Sorted by ID",
        Items = baitNamesList,
        Callback = function(item)
            local baitName = string.match(item, "%] (.+)$") or item
            
            for _, bait in ipairs(baitsWithPrice) do
                if bait.Name == baitName then
                    selectedBait = bait.Id
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
    })
    
    FarmTab:Toggle({
        Name = "Auto Buy Bait",
        StartingState = false,
        Description = "Auto buy selected bait every 60s",
        Callback = function(state)
            isAutoBuyBait = state
            
            if isAutoBuyBait and not selectedBait then
                warn("⚠️ Please select a bait first!")
                return
            end
            
            task.spawn(function()
                while isAutoBuyBait do
                    if selectedBait then
                        buyBait(selectedBait)
                        autoEquipBait()
                        task.wait(60)
                    else
                        warn("⚠️ No bait selected!")
                        task.wait(5)
                    end
                end
            end)
            
            if state then
                print("✅ Auto Buy Bait enabled for ID:", selectedBait)
            else
                print("❌ Auto Buy Bait disabled")
            end
        end
    })
    
    FarmTab:Button({
        Name = "Buy Selected Bait Now",
        Description = "Buy immediately",
        Callback = function()
            if selectedBait then
                print("💰 Purchasing bait ID:", selectedBait)
                buyBait(selectedBait)
                autoEquipBait()
            else
                warn("⚠️ Please select a bait first!")
            end
        end
    })
    
    -- Location Selection
    FarmTab:Dropdown({
        Name = "Select Location",
        StartingText = "Select fishing spot...",
        Description = "Choose fishing location",
        Items = LocationList,
        Callback = function(item)
            selectedLocation = LocationMap[item]
            if selectedLocation then
                print("📍 Selected location:", item)
                teleportToLocation(selectedLocation)
            else
                warn("⚠️ Location not found:", item)
            end
        end
    })
    
    -- Auto Sell
    FarmTab:Toggle({
        Name = "Auto Sell All",
        StartingState = false,
        Description = "Auto sell all items every 20s",
        Callback = function(state)
            autoSellAll = state
            
            task.spawn(function()
                while autoSellAll do
                    sellAllItems()
                    task.wait(20)
                end
            end)
        end
    })
    
    -- Auto Farm (Main Toggle)
    FarmTab:Toggle({
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
                autoEquip()
                
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
                            autoEquip()
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
    })
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI SETUP - PET TAB
    -- ══════════════════════════════════════════════════════════════════════
    local PetTab = GUI:Tab({
        Name = "Pet Tab",
        Icon = "rbxassetid://8569322835"
    })
    
    PetTab:Button({
        Name = "Coming Soon",
        Description = "Pet features will be added soon",
        Callback = function()
            print("🐾 Pet features coming soon!")
        end
    })
    
    -- ══════════════════════════════════════════════════════════════════════
    -- UI SETUP - FAVORITE TAB
    -- ══════════════════════════════════════════════════════════════════════
    local FavoriteTab = GUI:Tab({
        Name = "Auto Favorite",
        Icon = "rbxassetid://8569322835"
    })
    
    -- Select Rarity to Auto Favorite
    FavoriteTab:Dropdown({
        Name = "Select Rarity",
        StartingText = "Choose rarity...",
        Description = "Chọn rarity → Tự động favorite TẤT CẢ cá loại đó!",
        Items = RarityList,
        Callback = function(item)
            -- Toggle selection
            local index = table.find(selectedRarities, item)
            if index then
                table.remove(selectedRarities, index)
                print("⭐ Đã bỏ chọn:", item)
            else
                table.insert(selectedRarities, item)
                print("⭐ Đã chọn:", item, "→ Sẽ favorite TẤT CẢ cá", item, "!")
            end
            if #selectedRarities > 0 then
                print("⭐ Đang chọn:", table.concat(selectedRarities, ", "))
            else
                print("⭐ Chưa chọn rarity nào")
            end
        end
    })
    
    -- Clear Selection Button
    FavoriteTab:Button({
        Name = "Clear Selection",
        Description = "Bỏ chọn tất cả rarity",
        Callback = function()
            selectedRarities = {}
            print("⭐ Đã bỏ chọn tất cả!")
        end
    })
    
    -- Show Current Selection Button
    FavoriteTab:Button({
        Name = "Show Selection",
        Description = "Hiển thị rarity đang chọn",
        Callback = function()
            print("═══════════════════════════════════")
            print("⭐ ĐANG CHỌN:")
            if #selectedRarities > 0 then
                print("  Rarity:", table.concat(selectedRarities, ", "))
                print("  → Sẽ favorite TẤT CẢ cá có rarity này!")
            else
                print("  Chưa chọn rarity nào")
            end
            print("═══════════════════════════════════")
        end
    })
    
    -- Debug: Scan Inventory Button
    FavoriteTab:Button({
        Name = "🔍 Debug: Scan Inventory",
        Description = "Xem tất cả cá trong inventory và rarity của chúng",
        Callback = function()
            print("═══════════════════════════════════")
            print("🔍 ĐANG SCAN INVENTORY...")
            
            local replion = GetPlayerDataReplion()
            if not replion then 
                warn("❌ Không thể lấy Replion data")
                return
            end
            
            local success, inventoryData = pcall(function()
                return replion:GetExpect("Inventory")
            end)
            
            if not success or not inventoryData then
                warn("❌ Không thể đọc Inventory")
                return
            end
            
            -- In ra cấu trúc inventory để debug
            print("📦 Inventory keys:")
            for key, value in pairs(inventoryData) do
                print("  →", key, ":", type(value))
            end
            
            -- Fish It dùng inventoryData.Items
            if not inventoryData.Items then
                warn("❌ inventoryData.Items không tồn tại!")
                return
            end
            
            local items = inventoryData.Items
            local count = 0
            
            print("")
            print("🐟 DANH SÁCH CÁ:")
            for _, item in ipairs(items) do
                if type(item) == "table" and item.UUID then
                    count = count + 1
                    local name, rarity = getFishNameAndRarity(item)
                    local isFav = item.IsFavorite == true or item.Favorited == true
                    local favText = isFav and "⭐" or ""
                    print(string.format("  %d. %s | Rarity: %s | Fav: %s %s", count, name, rarity, tostring(isFav), favText))
                    
                    -- In thêm metadata để debug
                    if item.Metadata then
                        print(string.format("      → Metadata.Rarity: %s", tostring(item.Metadata.Rarity)))
                    end
                    
                    -- Chỉ in 20 cá đầu
                    if count >= 20 then
                        print("  ... (chỉ hiện 20 cá đầu)")
                        break
                    end
                end
            end
            
            print("")
            print("📊 Tổng số items:", count)
            print("═══════════════════════════════════")
        end
    })
    
    -- Auto Favorite Toggle
    FavoriteTab:Toggle({
        Name = "Enable Auto Favorite",
        StartingState = false,
        Description = "BẬT = Tự động favorite cá theo rarity đã chọn",
        Callback = function(state)
            autoFavorite = state
            
            if autoFavorite then
                -- Check if rarity is selected
                if #selectedRarities == 0 then
                    warn("⚠️ Hãy chọn ít nhất 1 rarity trước!")
                    autoFavorite = false
                    return
                end
                
                -- Check if Replion is available
                if not GetPlayerDataReplion() then
                    warn("⚠️ Không thể load player data!")
                    autoFavorite = false
                    return
                end
                
                -- Show what will be favorited
                print("═══════════════════════════════════")
                print("⭐ AUTO FAVORITE BẬT!")
                print("  → Sẽ favorite TẤT CẢ cá:", table.concat(selectedRarities, ", "))
                print("  → Không phân biệt mutation hay tên cá!")
                print("═══════════════════════════════════")
                
                runAutoFavoriteLoop()
            else
                print("⭐ Auto Favorite TẮT!")
                stopAutoFavorite()
            end
        end
    })
    
    print("✅ Fish It script loaded!")
end

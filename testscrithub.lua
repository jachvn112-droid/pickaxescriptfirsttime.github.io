--[[
================================================================================
    MULTI-GAME AUTO FARM SCRIPT
    Version: 1.3 (Clean & Optimized)
    Games: Pickaxe Simulator & Fish It
    
    Instructions:
    1. Run in your executor
    2. Select your game's tab
    3. Configure settings and enable features
================================================================================
]]

-- ============================================
-- PICKAXE SIMULATOR
-- ============================================
if game.PlaceId == 82013336390273 then
    
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
    
    local GUI = Mercury:Create{
        Name = "Pickaxe Simulator",
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    }
    
    -- ============================================
    -- SERVICES & REFERENCES
    -- ============================================
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    
    local playerStats = ReplicatedStorage.Stats:WaitForChild(player.Name)
    local miningSpeedBoost = playerStats:WaitForChild("MiningSpeedBoost")
    local miningPower = playerStats:WaitForChild("Power")
    
    -- ============================================
    -- STATE VARIABLES
    -- ============================================
    local state = {
        mining = false,
        training = false,
        equipBest = false,
        buyPickaxe = false,
        buyMiner = false,
        hatching = false,
        speedBoost = false,
        powerBoost = false,
        autoRebirth = false
    }
    
    local selected = {
        egg = nil,
        speed = nil,
        power = nil,
        rebirth = nil
    }
    
    -- ============================================
    -- CONFIGURATION
    -- ============================================
    local config = {
        speedList = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
        
        rebirthList = {
            1, 5, 20, 50, 100, 250, 500, 1000, 2500, 5000, 
            10000, 25000, 50000, 100000, 250000, 500000, 
            1000000, 2500000, 10000000, 25000000, 100000000, 
            1000000000, 50000000000, 500000000000, 5000000000000, 
            100000000000000, 1000000000000000, 50000000000000000, 
            500000000000000000, 2500000000000000000, 50000000000000000000, 
            500000000000000000000, 5e+21, 1e+23, 1e+24, 5e+25
        },
        
        powerList = {999, 9999, 99999, 999999, 9999999, 99999999},
        
        eggList = {
            "5M Egg", "Angelic Egg", "Aqua Egg", "Aura Egg",
            "Basic Egg", "Beach Egg", "Black Hole Egg", "Cave Egg",
            "Christmas Egg", "Dark Egg", "Electric Egg", "Farm Egg",
            "Forest Egg", "Galaxy Egg", "Garden Egg", "Ice Egg",
            "Lava Egg", "Music Egg", "Pixel Egg", "Rare Egg",
            "Rocket Egg", "Sakura Egg", "Sand Egg", "Snow Egg",
            "Sunny Egg", "Toy Egg", "UFO Egg", "Winter Egg"
        }
    }
    
    -- ============================================
    -- GAME FUNCTIONS
    -- ============================================
    local function callRemote(funcName, ...)
        local args = {...}
        return ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild(funcName)
            :InvokeServer(unpack(args))
    end
    
    local function fireRemote(funcName, ...)
        local args = {...}
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild(funcName)
            :FireServer(unpack(args))
    end
    
    local function toggleAutoMine()
        fireRemote("__remoteevent", "Toggle Setting", "AutoMine")
    end
    
    local function toggleAutoTrain()
        fireRemote("__remoteevent", "Toggle Setting", "AutoTrain")
    end
    
    local function autoEquipBest()
        callRemote("__remotefunction", "Pet", {Action = "EquipBest", Sort = "Power"})
    end
    
    local function autoSellOres()
        callRemote("__remotefunction", "Sell All Ores")
    end
    
    local function buyPickaxe()
        callRemote("__remotefunction", "Buy Pickaxe")
    end
    
    local function buyMiner()
        callRemote("__remotefunction", "Buy Miner")
    end
    
    local function hatchEgg(eggName)
        callRemote("__remotefunction", "Hatch Egg", eggName, 3)
    end
    
    local function performRebirth(amount)
        callRemote("__remotefunction", "Rebirth", amount)
    end
    
    local function setMiningSpeed(speed)
        if miningSpeedBoost then
            miningSpeedBoost.Value = speed
            print("⚡ Mining speed:", speed)
        end
    end
    
    local function setMiningPower(power)
        if miningPower then
            miningPower.Value = power
            print("💪 Mining power:", power)
        end
    end
    
    -- ============================================
    -- UI SETUP
    -- ============================================
    local FarmTab = GUI:Tab{Name = "Auto Farm", Icon = "rbxassetid://8569322835"}
    
    -- REBIRTH
    FarmTab:Dropdown{
        Name = "Select Rebirth Amount",
        StartingText = "Select...",
        Description = "Choose rebirth amount",
        Items = config.rebirthList,
        Callback = function(item) 
            selected.rebirth = item
            print("🔄 Selected rebirth:", item)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Rebirth",
        StartingState = false,
        Description = "Auto rebirth with selected amount",
        Callback = function(enabled) 
            state.autoRebirth = enabled
            task.spawn(function()
                while state.autoRebirth do
                    if selected.rebirth then
                        performRebirth(selected.rebirth)
                        print("🔄 Rebirthing:", selected.rebirth)
                        task.wait(1)
                    else
                        warn("⚠️ No rebirth amount selected!")
                        task.wait(2)
                    end
                end
            end)
        end
    }
    
    -- POWER
    FarmTab:Dropdown{
        Name = "Select Mining Power",
        StartingText = "Select...",
        Description = "Choose mining power",
        Items = config.powerList,
        Callback = function(item) 
            selected.power = item
            print("💪 Selected power:", item)
        end
    }
    
    FarmTab:Toggle{
        Name = "Set Mining Power",
        StartingState = false,
        Description = "Apply selected power",
        Callback = function(enabled) 
            state.powerBoost = enabled
            if enabled and selected.power then
                setMiningPower(selected.power)
            elseif enabled then
                warn("⚠️ Select power first!")
            end
        end
    }
    
    -- SPEED
    FarmTab:Dropdown{
        Name = "Select Mining Speed",
        StartingText = "Select...",
        Description = "Choose speed (1-20)",
        Items = config.speedList,
        Callback = function(item) 
            selected.speed = item
            print("⚡ Selected speed:", item)
        end
    }
    
    FarmTab:Toggle{
        Name = "Set Mining Speed",
        StartingState = false,
        Description = "Apply selected speed",
        Callback = function(enabled) 
            state.speedBoost = enabled
            if enabled and selected.speed then
                setMiningSpeed(selected.speed)
            elseif enabled then
                warn("⚠️ Select speed first!")
            end
        end
    }
    
    -- AUTO BUY
    FarmTab:Toggle{
        Name = "Auto Buy Pickaxe",
        StartingState = false,
        Description = "Auto upgrade pickaxe",
        Callback = function(enabled) 
            state.buyPickaxe = enabled
            task.spawn(function()
                while state.buyPickaxe do
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
        Callback = function(enabled) 
            state.buyMiner = enabled
            task.spawn(function()
                while state.buyMiner do
                    buyMiner()
                    task.wait(30)
                end
            end)
        end
    }
    
    -- AUTO EQUIP & TRAIN
    FarmTab:Toggle{
        Name = "Auto Equip Best",
        StartingState = false,
        Description = "Auto equip strongest pets",
        Callback = function(enabled) 
            state.equipBest = enabled
            task.spawn(function()
                while state.equipBest do
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
        Callback = function(enabled) 
            state.training = enabled
            task.spawn(function()
                while state.training do
                    toggleAutoTrain()
                    task.wait(120)
                end
            end)
        end
    }
    
    -- AUTO MINE
    FarmTab:Toggle{
        Name = "Auto Mine",
        StartingState = false,
        Description = "Auto mine and sell ores",
        Callback = function(enabled) 
            state.mining = enabled
            task.spawn(function()
                while state.mining do
                    toggleAutoMine()
                    task.wait(120)
                    if state.mining then
                        autoSellOres()
                        task.wait(5)
                    end
                end
            end)
        end
    }
    
    -- PET TAB
    local PetTab = GUI:Tab{Name = "Pet Tab", Icon = "rbxassetid://8569322835"}
    
    PetTab:Dropdown{
        Name = "Select Egg",
        StartingText = "Select...",
        Description = "Choose egg to hatch",
        Items = config.eggList,
        Callback = function(item) 
            selected.egg = item
            print("🥚 Selected egg:", item)
        end
    }
    
    PetTab:Toggle{
        Name = "Auto Hatch",
        StartingState = false,
        Description = "Auto hatch selected egg (3x)",
        Callback = function(enabled)
            state.hatching = enabled
            task.spawn(function()
                while state.hatching do
                    if selected.egg then
                        hatchEgg(selected.egg)
                        task.wait(0.5)
                    else
                        warn("⚠️ No egg selected!")
                        task.wait(2)
                    end
                end
            end)
        end
    }
    
    print("✅ Pickaxe Simulator loaded!")
end

-- ============================================
-- FISH IT
-- ============================================
if game.PlaceId == 121864768012064 then
    
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
    
    local GUI = Mercury:Create{
        Name = "Fish It",
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    }
    
    -- ============================================
    -- SERVICES & REFERENCES
    -- ============================================
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local Items = ReplicatedStorage.Items
    local Baits = ReplicatedStorage:FindFirstChild("Baits")
    
    local net = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
    
    -- ============================================
    -- HELPER FUNCTIONS
    -- ============================================
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
    
    -- ============================================
    -- STATE VARIABLES
    -- ============================================
    local state = {
        fishing = false,
        equipped = false,
        autoSell = false,
        autoBuyRod = false,
        autoBuyBait = false
    }
    
    local selected = {
        location = nil,
        rod = nil,      -- Stores rod ID
        bait = nil      -- Stores bait ID
    }
    
    local deathConnection = nil
    
    -- ============================================
    -- LOCATION DATA
    -- ============================================
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
        
        -- ADD NEW LOCATIONS HERE:
        -- ["Your Location"] = {Pos = Vector3.new(X, Y, Z), Look = Vector3.new(X, Y, Z)},
    }
    
    -- Generate location list
    local locationList = {}
    for name, _ in pairs(locationMap) do
        table.insert(locationList, name)
    end
    table.sort(locationList)
    
    -- ============================================
    -- BAIT DATA COLLECTION
    -- ============================================
    local baitsData = {}
    local baitNames = {}
    
    if Baits then
        for _, item in pairs(Baits:GetChildren()) do
            if string.match(item.Name, "Bait$") then
                local ok, data = pcall(function() return require(item) end)
                if ok and data.Price then
                    table.insert(baitsData, {
                        Name = item.Name,
                        Price = data.Price,
                        Id = data.Data and data.Data.Id or 9999,
                        Luck = data.Modifiers and data.Modifiers.BaseLuck or 0
                    })
                end
            end
        end
        
        table.sort(baitsData, function(a, b) return a.Id < b.Id end)
        
        for _, bait in ipairs(baitsData) do
            table.insert(baitNames, string.format("[%d] %s", bait.Id, bait.Name))
        end
        
        print("🪱 Found", #baitsData, "baits")
    end
    
    -- ============================================
    -- ROD DATA COLLECTION
    -- ============================================
    local rodsData = {}
    local rodNames = {}
    
    for _, item in pairs(Items:GetChildren()) do
        if string.match(item.Name, "Rod$") then
            local ok, data = pcall(function() return require(item) end)
            if ok and data.Price then
                table.insert(rodsData, {
                    Name = item.Name,
                    Price = data.Price,
                    Id = data.Data and data.Data.Id or 9999,
                    ClickPower = data.ClickPower or 0,
                    Luck = data.RollData and data.RollData.BaseLuck or 0
                })
            end
        end
    end
    
    table.sort(rodsData, function(a, b) return a.Id < b.Id end)
    
    for _, rod in ipairs(rodsData) do
        table.insert(rodNames, string.format("[%d] %s", rod.Id, rod.Name))
    end
    
    print("🎣 Found", #rodsData, "rods")
    
    -- ============================================
    -- GAME FUNCTIONS
    -- ============================================
    local function enableAutoFishing()
        net:WaitForChild("RF/UpdateAutoFishingState"):InvokeServer(true)
    end
    
    local function disableAutoFishing()
        net:WaitForChild("RF/UpdateAutoFishingState"):InvokeServer(false)
    end
    
    local function buyRod(rodId)
        if not rodId then return end
        pcall(function()
            net:WaitForChild("RF/PurchaseFishingRod"):InvokeServer(rodId)
            print("✅ Bought rod ID:", rodId)
        end)
    end
    
    local function buyBait(baitId)
        if not baitId then return end
        pcall(function()
            net:WaitForChild("RF/PurchaseBait"):InvokeServer(baitId)
            print("✅ Bought bait ID:", baitId)
        end)
    end
    
    local function autoEquip()
        if state.equipped then return end
        pcall(function()
            net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(1)
            state.equipped = true
            print("✅ Equipped rod")
        end)
    end
    
    local function sellAllItems()
        pcall(function()
            net:WaitForChild("RF/SellAllItems"):InvokeServer()
            print("💰 Sold all items")
        end)
    end
    
    local function teleportToLocation(locationData)
        local hrp = getHumanoidRootPart()
        if hrp and locationData then
            local pos = locationData.Pos
            local look = locationData.Look
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.atan2(look.X, look.Z), 0)
            print("📍 Teleported")
        end
    end
    
    local function clickMouse()
        local h = getHumanoid()
        if not h or h.Health <= 0 then return end
        
        pcall(function()
            local pos = UserInputService:GetMouseLocation()
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        end)
    end
    
    local function setupDeathHandler()
        if deathConnection then
            deathConnection:Disconnect()
        end
        
        local h = getHumanoid()
        if not h then return end
        
        deathConnection = h.Died:Connect(function()
            print("💀 Died, respawning...")
            state.equipped = false
            
            local newChar = player.CharacterAdded:Wait()
            newChar:WaitForChild("HumanoidRootPart")
            task.wait(1)
            
            if selected.location then
                teleportToLocation(selected.location)
            end
            
            task.wait(0.5)
            autoEquip()
            
            if state.fishing then
                setupDeathHandler()
            end
        end)
    end
    
    -- ============================================
    -- UI SETUP
    -- ============================================
    local FarmTab = GUI:Tab{Name = "Auto Farm", Icon = "rbxassetid://8569322835"}
    
    -- ROD SELECTION
    FarmTab:Dropdown{
        Name = "Select Rod to Buy",
        StartingText = "Select a rod...",
        Description = "Sorted by ID",
        Items = rodNames,
        Callback = function(item) 
            local name = string.match(item, "%] (.+)$")
            for _, rod in ipairs(rodsData) do
                if rod.Name == name then
                    selected.rod = rod.Id
                    print("═══════════════════════════════════")
                    print("🆔 ID:", rod.Id)
                    print("🎣 Rod:", rod.Name)
                    print("💰 Price:", rod.Price)
                    print("💪 Click Power:", rod.ClickPower)
                    print("🍀 Luck:", rod.Luck)
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
        Callback = function(enabled) 
            state.autoBuyRod = enabled
            if enabled and not selected.rod then
                warn("⚠️ Select a rod first!")
                return
            end
            
            task.spawn(function()
                while state.autoBuyRod do
                    if selected.rod then
                        buyRod(selected.rod)
                        task.wait(60)
                    else
                        task.wait(5)
                    end
                end
            end)
        end
    }
    
    FarmTab:Button{
        Name = "Buy Selected Rod Now",
        Description = "Buy immediately",
        Callback = function()
            if selected.rod then
                buyRod(selected.rod)
            else
                warn("⚠️ Select a rod first!")
            end
        end
    }
    
    -- BAIT SELECTION
    FarmTab:Dropdown{
        Name = "Select Bait to Buy",
        StartingText = "Select a bait...",
        Description = "Sorted by ID",
        Items = baitNames,
        Callback = function(item)
            local name = string.match(item, "%] (.+)$")
            for _, bait in ipairs(baitsData) do
                if bait.Name == name then
                    selected.bait = bait.Id
                    print("═══════════════════════════════════")
                    print("🆔 ID:", bait.Id)
                    print("🪱 Bait:", bait.Name)
                    print("💰 Price:", bait.Price)
                    print("🍀 Luck:", bait.Luck)
                    print("═══════════════════════════════════")
                    break
                end
            end
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Buy Bait",
        StartingState = false,
        Description = "Auto buy selected bait every 60s",
        Callback = function(enabled) 
            state.autoBuyBait = enabled
            if enabled and not selected.bait then
                warn("⚠️ Select a bait first!")
                return
            end
            
            task.spawn(function()
                while state.autoBuyBait do
                    if selected.bait then
                        buyBait(selected.bait)
                        task.wait(60)
                    else
                        task.wait(5)
                    end
                end
            end)
        end
    }
    
    FarmTab:Button{
        Name = "Buy Selected Bait Now",
        Description = "Buy immediately",
        Callback = function()
            if selected.bait then
                buyBait(selected.bait)
            else
                warn("⚠️ Select a bait first!")
            end
        end
    }
    
    -- LOCATION SELECTION
    FarmTab:Dropdown{
        Name = "Select Location",
        StartingText = "Select fishing spot...",
        Description = "Choose fishing location",
        Items = locationList,
        Callback = function(item) 
            selected.location = locationMap[item]
            if selected.location then
                print("📍 Selected:", item)
                teleportToLocation(selected.location)
            else
                warn("⚠️ Location not found!")
            end
        end
    }
    
    -- AUTO SELL
    FarmTab:Toggle{
        Name = "Auto Sell All",
        StartingState = false,
        Description = "Auto sell all items every 20s",
        Callback = function(enabled) 
            state.autoSell = enabled
            task.spawn(function()
                while state.autoSell do
                    sellAllItems()
                    task.wait(20)
                end
            end)
        end
    }
    
    -- AUTO FARM
    FarmTab:Toggle{
        Name = "Auto Farm",
        StartingState = false,
        Description = "Enable auto fishing",
        Callback = function(enabled) 
            state.fishing = enabled
            
            if enabled then
                print("🎣 Auto Farm started!")
                enableAutoFishing()
                setupDeathHandler()
                task.wait(0.5)
                autoEquip()
                
                -- Click loop
                task.spawn(function()
                    while state.fishing do
                        local h = getHumanoid()
                        if h and h.Health > 0 then
                            clickMouse()
                            task.wait(0.3)
                        else
                            task.wait(1)
                        end
                    end
                end)
                
                -- Re-equip loop
                task.spawn(function()
                    while state.fishing do
                        local h = getHumanoid()
                        if h and h.Health > 0 and not state.equipped then
                            autoEquip()
                        end
                        task.wait(5)
                    end
                end)
            else
                print("⏹️ Auto Farm stopped!")
                disableAutoFishing()
                if deathConnection then
                    deathConnection:Disconnect()
                end
                state.equipped = false
            end
        end
    }
    
    -- PET TAB
    local PetTab = GUI:Tab{Name = "Pet Tab", Icon = "rbxassetid://8569322835"}
    
    PetTab:Button{
        Name = "Coming Soon",
        Description = "Pet features will be added soon",
        Callback = function()
            print("🐾 Pet features coming soon!")
        end
    }
    
    print("✅ Fish It loaded!")
end

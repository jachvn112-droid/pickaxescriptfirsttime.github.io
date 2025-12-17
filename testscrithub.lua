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
    
    -- Player References
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
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
    local isAutoBuyRod = false  -- ✅ FIXED: was "falsel"
    
    -- Location Data
    local locationMap = {
        ["Location 1"] = CFrame.new(93.4678192, 6.03939819, 2692.12573, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    }
    
    local farmlocationtable = {"Location 1"}  -- ✅ ADDED: was missing
    
    task.wait(0.5)
    
    -- ============================================
    -- ROD DATA
    -- ============================================
    local rodsWithPrice = {}
    local rodNamesList = {}
    
    -- Get all rods with Price
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
    
    -- Sort by ID
    table.sort(rodsWithPrice, function(a, b)
        return a.Id < b.Id
    end)
    
    -- Create display list "[ID] Name"
    for _, rod in ipairs(rodsWithPrice) do
        local displayName = string.format("[%d] %s", rod.Id, rod.Name)
        table.insert(rodNamesList, displayName)
    end
    
    print("🎣 Found", #rodsWithPrice, "buyable rods (sorted by ID)")
    
    -- ============================================
    -- GAME FUNCTIONS
    -- ============================================
    
    -- ✅ ADDED: was missing
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
    
    -- ✅ FIXED: Added missing end
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
            autoequip()
            
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
    
    local function teleportToLocation(cframe)
        local humanoidRootPart = getHumanoidRootPart()
        if humanoidRootPart and cframe then
            humanoidRootPart.CFrame = cframe
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
    
    FarmTab:Dropdown{
        Name = "Select Location",
        StartingText = "Select...",
        Description = "Choose fishing location",
        Items = farmlocationtable,
        Callback = function(item) 
            selectedlocation = locationMap[item]
            print("📍 Selected location:", item)
            teleportToLocation(selectedlocation)
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
                autoequip()
                
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
                            autoequip()
                        end
                        task.wait(5)
                    end
                    print("🛑 Re-equip loop stopped")
                end)
            else
                print("⏹️ Auto Farm stopped!")
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

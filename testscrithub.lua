-- ============================================
-- PICKAXE SIMULATOR AUTO FARM SCRIPT
-- ============================================

if game.PlaceId == 82013336390273 then
    local CurrentVersion = "pickaxe simulator"

    -- ============================================
    -- LOAD MERCURY UI LIBRARY
    -- ============================================
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

    -- Create main GUI window
    local GUI = Mercury:Create{
        Name = CurrentVersion,
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    }

    -- ============================================
    -- SERVICES & REFERENCES
    -- ============================================
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Players = game:GetService("Players")
    
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Get player stats references
    local playerStats = ReplicatedStorage.Stats:WaitForChild(player.Name)
    local miningSpeedBoost = playerStats:WaitForChild("MiningSpeedBoost")
    local miningPower = playerStats:WaitForChild("Power")

    -- ============================================
    -- STATE VARIABLES
    -- ============================================
    local isMining = false
    local isAutoTraining = false
    local isEquipBestEnabled = false
    local isAutoBuyPickaxe = false
    local isAutoBuyMiner = false
    local isHatching = false
    local isSpeedMiningEnabled = false
    local isPowerEnabled = false
    local isAutoRebirthEnabled = false
    local timeteleback = 0
    local selectedEgg = nil
    local selectedMiningSpeed = nil
    local selectedPower = nil
    local selectedRebirth = nil
    
    task.wait(0.5)

    -- ============================================
    -- LISTS
    -- ============================================
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
        999, 
        9999, 
        99999, 
        999999, 
        9999999, 
        99999999
    }
    
    local EggsList = {
        "5M Egg",
        "Angelic Egg",
        "Aqua Egg",
        "Aura Egg",
        "Basic Egg",
        "Beach Egg",
        "Black Hole Egg",
        "Cave Egg",
        "Christmas Egg",
        "Dark Egg",
        "Electric Egg",
        "Farm Egg",
        "Forest Egg",
        "Galaxy Egg",
        "Garden Egg",
        "Ice Egg",
        "Lava Egg",
        "Music Egg",
        "Pixel Egg",
        "Rare Egg",
        "Rocket Egg",
        "Sakura Egg",
        "Sand Egg",
        "Snow Egg",
        "Sunny Egg",
        "Toy Egg",
        "UFO Egg",
        "Winter Egg"
    }

    -- ============================================
    -- HELPER FUNCTIONS
    -- ============================================
    
    -- Points camera downward at player's feet
    local function pointCameraDown()
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local playerPosition = humanoidRootPart.Position
        camera.CFrame = CFrame.new(
            camera.CFrame.Position, 
            playerPosition + Vector3.new(0, -10, 0)
        )
    end

    -- Simulates mouse click at center of screen
    local function clickMouse()
        local screenSize = camera.ViewportSize
        local centerX = screenSize.X / 2
        local centerY = screenSize.Y / 2
        
        -- Mouse down
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        
        -- Mouse up
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end

    -- Toggles AutoMine setting via remote event
    local function toggleAutoMine()
        local args = {
            "Toggle Setting",
            "AutoMine"
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remoteevent")
            :FireServer(unpack(args))
    end

    -- Toggles AutoTrain setting via remote event
    local function toggleAutoTrain()
        local args = {
            "Toggle Setting",
            "AutoTrain"
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remoteevent")
            :FireServer(unpack(args))
    end

    -- Automatically equips best pets based on power
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

    -- Sells all ores in inventory
    local function autoSellOres()
        local args = {
            "Sell All Ores"
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end

    -- Buys the next available pickaxe
    local function buyPickaxe()
        local args = {
            "Buy Pickaxe"
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end

    -- Buys the next available miner
    local function buyMiner()
        local args = {
            "Buy Miner"
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end

    -- Hatches the selected egg (3x)
    local function hatchEgg(eggName)
        local args = {
            "Hatch Egg",
            eggName,
            3  -- Hatch 3 eggs at once
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end

    -- Performs rebirth with selected amount
    local function performRebirth(rebirthAmount)
        local args = {
            "Rebirth",
            rebirthAmount
        }
        
        ReplicatedStorage:WaitForChild("Paper")
            :WaitForChild("Remotes")
            :WaitForChild("__remotefunction")
            :InvokeServer(unpack(args))
    end

    -- Sets mining speed boost value
    local function setMiningSpeed(speed)
        if miningSpeedBoost then
            miningSpeedBoost.Value = speed
            print("Mining speed set to: " .. speed)
        end
    end

    -- Sets mining power value
    local function setMiningPower(power)
        if miningPower then
            miningPower.Value = power
            print("Mining power set to: " .. power)
        end
    end

    -- ============================================
    -- UI SETUP - FARM TAB
    -- ============================================
    
    local FarmTab = GUI:Tab{
        Name = "Auto Farm",
        Icon = "rbxassetid://8569322835"
    }

    -- Rebirth Selection Dropdown
    local RebirthDropdown = FarmTab:Dropdown{
        Name = "Select Rebirth Amount",
        StartingText = "Select...",
        Description = "Select your rebirth amount",
        Items = RebirthList,
        Callback = function(item) 
            selectedRebirth = item
            print("Selected rebirth amount: " .. selectedRebirth)
        end
    }

    -- Auto Rebirth Toggle
    FarmTab:Toggle{
        Name = "Auto Rebirth",
        StartingState = false,
        Description = "Automatically rebirths with selected amount",
        Callback = function(state) 
            isAutoRebirthEnabled = state
            
            -- Main rebirth loop
            while isAutoRebirthEnabled do
                if selectedRebirth then
                    performRebirth(selectedRebirth)
                    print("Rebirthing with amount: " .. selectedRebirth)
                    task.wait(1) -- Wait 1 second between rebirths
                else
                    warn("No rebirth amount selected! Please select an amount first.")
                    task.wait(2)
                end
            end
        end
    }

    -- Mining Power Selection Dropdown
    local PowerMiningDropdown = FarmTab:Dropdown{
        Name = "Select Your Power",
        StartingText = "Select...",
        Description = "Select your mining power",
        Items = PowerMiningList,
        Callback = function(item) 
            selectedPower = item
            print("Selected mining power: " .. selectedPower)
        end
    }

    -- Mining Power Toggle
    FarmTab:Toggle{
        Name = "Set Mining Power",
        StartingState = false,
        Description = "Applies the selected mining power",
        Callback = function(state) 
            isPowerEnabled = state
            
            if isPowerEnabled then
                if selectedPower then
                    setMiningPower(selectedPower)
                else
                    warn("No mining power selected! Please select a power first.")
                end
            else
                print("Mining power boost disabled")
            end
        end
    }

    -- Mining Speed Selection Dropdown
    local SpeedMiningDropdown = FarmTab:Dropdown{
        Name = "Select Your Mining Speed",
        StartingText = "Select...",
        Description = "Select your mining speed (1-20)",
        Items = SpeedMiningList,
        Callback = function(item) 
            selectedMiningSpeed = item
            print("Selected mining speed: " .. selectedMiningSpeed)
        end
    }

    -- Mining Speed Boost Toggle
    FarmTab:Toggle{
        Name = "Set Mining Speed",
        StartingState = false,
        Description = "Applies the selected mining speed",
        Callback = function(state) 
            isSpeedMiningEnabled = state
            
            if isSpeedMiningEnabled then
                if selectedMiningSpeed then
                    setMiningSpeed(selectedMiningSpeed)
                else
                    warn("No mining speed selected! Please select a speed first.")
                end
            else
                print("Mining speed boost disabled")
            end
        end
    }

    -- Auto Buy Pickaxe Toggle
    FarmTab:Toggle{
        Name = "Auto Buy Pickaxe",
        StartingState = false,
        Description = "Automatically buys next pickaxe upgrade",
        Callback = function(state) 
            isAutoBuyPickaxe = state
            
            -- Main buy pickaxe loop
            while isAutoBuyPickaxe do
                buyPickaxe()
                task.wait(30) -- Check every 30 seconds
            end
        end
    }

    -- Auto Buy Miner Toggle
    FarmTab:Toggle{
        Name = "Auto Buy Miner",
        StartingState = false,
        Description = "Automatically buys next miner upgrade",
        Callback = function(state) 
            isAutoBuyMiner = state
            
            -- Main buy miner loop
            while isAutoBuyMiner do
                buyMiner()
                task.wait(30) -- Check every 30 seconds
            end
        end
    }

    -- Auto Equip Best Pets Toggle
    FarmTab:Toggle{
        Name = "Auto Equip Best",
        StartingState = false,
        Description = "Automatically equips best pets by power",
        Callback = function(state) 
            isEquipBestEnabled = state
            
            -- Main equip loop
            while isEquipBestEnabled do
                autoEquipBest()
                task.wait(20) -- Check every 20 seconds
            end
        end
    }

    -- Auto Train Toggle
    FarmTab:Toggle{
        Name = "Auto Train",
        StartingState = false,
        Description = "Automatically enables training",
        Callback = function(state) 
            isAutoTraining = state
            
            -- Main training loop
            while isAutoTraining do
                toggleAutoTrain()
                task.wait(120) -- Check every 2 minutes
            end
        end
    }

    -- Auto Mine Toggle
    FarmTab:Toggle{
        Name = "Auto Mine",
        StartingState = false,
        Description = "Automatically enables mining and sells ores",
        Callback = function(state) 
            isMining = state
            
            -- Main mining loop
            while isMining do
                toggleAutoMine()
                task.wait(120) -- Mine for 2 minutes
                
                autoSellOres()
                task.wait(5) -- Wait for sell to complete
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

    -- Egg Selection Dropdown
    local EggDropdown = PetTab:Dropdown{
        Name = "Select Egg",
        StartingText = "Select...",
        Description = "Select the egg you want to hatch",
        Items = EggsList,
        Callback = function(item) 
            selectedEgg = item
            print("Selected egg: " .. selectedEgg)
        end
    }

    -- Auto Hatch Toggle
    PetTab:Toggle{
        Name = "Auto Hatch",
        StartingState = false,
        Description = "Auto hatches the selected egg (3x)",
        Callback = function(state)
            isHatching = state
            
            -- Main hatching loop
            while isHatching do
                if selectedEgg then
                    hatchEgg(selectedEgg)
                    task.wait(0.5) -- Wait between hatches
                else
                    warn("No egg selected! Please select an egg first.")
                    task.wait(2) -- Wait before checking again
                end
            end
        end
    }
    
end
-- ============================================
-- PICKAXE SIMULATOR AUTO FARM SCRIPT
-- ============================================

-- ============================================
-- FISH IT AUTO FARM SCRIPT (ĐÃ SỬA LỖI)
-- ============================================

if game.PlaceId == 121864768012064 then
    -- ============================================
    -- CÀI ĐẶT CƠ BẢN
    -- ============================================
    local CurrentVersion = "fish it"

    -- Tải Mercury UI Library
    local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

    -- Tạo cửa sổ GUI
    local GUI = Mercury:Create{
        Name = CurrentVersion,
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/deeeity/mercury-lib"
    }
    local FarmTab = GUI:Tab{
        Name = "Auto Farm",
        Icon = "rbxassetid://8569322835"
    }
    local PetTab = GUI:Tab{
        Name = "Pet Tab",
        Icon = "rbxassetid://8569322835"
    }

    -- ============================================
    -- SERVICES (Dịch vụ game)
    -- ============================================
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    
    -- ============================================
    -- PLAYER REFERENCES (Thông tin người chơi)
    -- ============================================
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Stats của người chơi
    local playerStats = ReplicatedStorage.Stats:WaitForChild(player.Name)
    local miningSpeedBoost = playerStats:WaitForChild("MiningSpeedBoost")
    local miningPower = playerStats:WaitForChild("Power")

    -- ============================================
    -- BIẾN TRẠNG THÁI
    -- ============================================
    local fishing = false
    local selectedlocation = nil
    local isEquipped = false

    -- Map locations
    local locationMap = {
        ["Location 1"] = CFrame.new(-57.7402344, 5.54157162, 2786.78198, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    }

    -- Table cho Dropdown (phải là strings)
    local farmlocationtable = {"Location 1"}

    task.wait(0.5)

    -- ============================================
    -- HÀM CHỨC NĂNG (ĐÃ SỬA)
    -- ============================================
    
    -- Tự động trang bị pickaxe
    local function autoequip()
        if isEquipped then return end -- Tránh spam
        
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
            print("✅ Equipped tool")
        end)
        
        if not success then
            warn("❌ Equip failed:", err)
        end
    end
    
    -- Theo dõi khi nhân vật chết và respawn
    local function setupDeathHandler()
        humanoid.Died:Connect(function()
            print("💀 Character died, waiting for respawn...")
            isEquipped = false
            
            -- Đợi respawn
            character = player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            task.wait(1) -- Đợi character load đầy đủ
            
            -- Teleport về vị trí farm nếu đã chọn
            if selectedlocation then
                humanoidRootPart.CFrame = selectedlocation
            end
            
            -- Trang bị lại
            task.wait(0.5)
            autoequip()
            
            print("✅ Respawned and re-equipped")
        end)
    end
    
    -- Tự động click chuột
    local function clickMouse()
        if not character or not humanoid or humanoid.Health <= 0 then 
            return 
        end
        
        if not humanoidRootPart then 
            return 
        end
        
        -- Lấy vị trí chuột hiện tại trên màn hình
        local mousePos = UserInputService:GetMouseLocation()
        
        local success, err = pcall(function()
            -- Mouse down
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
            task.wait(0.05)
            
            -- Mouse up
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
        end)
        
        if not success then
            warn("❌ Click failed:", err)
        end
    end
    
    -- Teleport đến location
    local function teleportToLocation(cframe)
        if humanoidRootPart and cframe then
            humanoidRootPart.CFrame = cframe
            print("📍 Teleported to location")
        end
    end

    -- ============================================
    -- TẠO UI
    -- ============================================
    
    local locationDropDown = FarmTab:Dropdown{
        Name = "Select Location to farm",
        StartingText = "Select...",
        Description = "Select the location you want to farm",
        Items = farmlocationtable,
        Callback = function(item) 
            selectedlocation = locationMap[item]
            print("Selected location: " .. item)
            
            -- Teleport đến location đã chọn
            teleportToLocation(selectedlocation)
        end
    }
    
    FarmTab:Toggle{
        Name = "Auto Farm",
        StartingState = false,
        Description = "Automatically enables Fishing",
        Callback = function(state) 
            fishing = state
            
            if fishing then
                print("🎣 Auto Farm started!")
                
                -- Setup death handler một lần
                setupDeathHandler()
                
                -- Trang bị lần đầu
                autoequip()
                
                -- Loop auto click
                task.spawn(function()
                    while fishing do
                        if humanoid and humanoid.Health > 0 then
                            clickMouse()
                            task.wait(0.3) -- Đợi 0.3s giữa mỗi click
                        else
                            task.wait(1) -- Đợi respawn
                        end
                    end
                end)
                
                -- Loop kiểm tra và re-equip nếu cần
                task.spawn(function()
                    while fishing do
                        if humanoid and humanoid.Health > 0 and not isEquipped then
                            autoequip()
                        end
                        task.wait(5) -- Kiểm tra mỗi 5 giây
                    end
                end)
            else
                print("⏹️ Auto Farm stopped!")
                isEquipped = false
            end
        end
    }
    
end

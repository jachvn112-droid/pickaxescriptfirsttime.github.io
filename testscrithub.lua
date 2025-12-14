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
    
    -- Get mining speed boost reference (object, not value)
    local playerStats = ReplicatedStorage.Stats:WaitForChild(player.Name)
    local miningSpeedBoost = playerStats:WaitForChild("MiningSpeedBoost")

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
    local timeteleback = 0
    local selectedEgg = nil
    local selectedMiningSpeed = nil
    
    task.wait(0.5)

    -- ============================================
    -- LISTS
    -- ============================================
    local SpeedMiningList = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20
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

    -- Sets mining speed boost value
    local function setMiningSpeed(speed)
        if miningSpeedBoost then
            miningSpeedBoost.Value = speed
            print("Mining speed set to: " .. speed)
        end
    end

    -- ============================================
    -- UI SETUP - FARM TAB
    -- ============================================
    
    local FarmTab = GUI:Tab{
        Name = "Auto Farm",
        Icon = "rbxassetid://8569322835"
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

local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = game.Players.LocalPlayer

-- Danh sách khu vực có rương
local areas = {
    "Colosseum", "Desert", "Fishmen", "Fountain", "Ice", "Jungle", "Magma", "MarineBase", "MarineStart",
    "MobBoss", "Pirate", "Prison", "Sky", "SkyArea1", "SkyArea2", "TeleportSpawn", "Town", "Windmill"
}

-- Hàm nhấn phím
local function pressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Hàm reset nhân vật
local function resetCharacter()
    pressKey(Enum.KeyCode.Escape)
    wait(0.5)
    pressKey(Enum.KeyCode.R)
    wait(0.5)
    pressKey(Enum.KeyCode.Return)
end

-- Hàm dịch chuyển tới rương
local function teleportToChest(area, index)
    local chestPath = workspace.Map:FindFirstChild(area)
    if chestPath then
        local chests = chestPath:FindFirstChild("Chests")
        if chests then
            local targetChest = chests:GetChildren()[index]
            if targetChest and targetChest:IsA("BasePart") then
                lp.Character.HumanoidRootPart.CFrame = targetChest.CFrame
            end
        end
    end
end

-- Biến kiểm soát Auto Collect
local CollectStatus = false 

-- Vòng lặp chính
local function mainLoop()
    local count = 0
    while CollectStatus do
        for _, area in ipairs(areas) do
            for index = 1, 10 do
                if not CollectStatus then return end 
                teleportToChest(area, index)
                wait(0.1)
                count = count + 1
                if count >= 200 then
                    count = 0
                    resetCharacter()
                    wait(3)
                end
            end
        end
    end
end

-- Load UI OrionLib
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "LuxurySigma",
    IntroText = "LuxuryCollectChest",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ConfigLuxurySigma"
})

-- Tạo tab Collect Chest
local Tab = Window:MakeTab({
    Name = "CollectChest",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tạo toggle bật/tắt Auto Collect
Tab:AddToggle({
    Name = "StartCollect",
    Default = false,
    Callback = function(Value)
        CollectStatus = Value
        if Value then
            resetCharacter()
            spawn(mainLoop)
        end
    end    
})

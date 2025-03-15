local lp = game.Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local speed = 350
local flying = false
local targetPosition = nil
local tpIsland = nil
local waterBase = nil
local noclip = false
local runService = game:GetService("RunService")
local CollectStatus = false
local VirtualInputManager = game:GetService("VirtualInputManager")
local areas = {
    "Colosseum", "Desert", "Fishmen", "Fountain", "Ice", "Jungle", "Magma", "MarineBase", "MarineStart",
    "MobBoss", "Pirate", "Prison", "Sky", "SkyArea1", "SkyArea2", "TeleportSpawn", "Town", "Windmill"
}

local function pressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end
local function resetCharacter()
    pressKey(Enum.KeyCode.Escape)
    wait(0.5)
    pressKey(Enum.KeyCode.R)
    wait(0.5)
    pressKey(Enum.KeyCode.Return)
end
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
local function getAllIslands()
    local islands = {}
    local mapFolder = game.Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, island in pairs(mapFolder:GetChildren()) do
            if island:IsA("Model") then
                table.insert(islands, island.Name)
            end
        end
    end
    return islands
end
local function createWaterBase()
    if waterBase then return end
    waterBase = Instance.new("Part")
    waterBase.Size = Vector3.new(50, 1, 50)
    waterBase.Position = Vector3.new(hrp.Position.X, -4.5, hrp.Position.Z)
    waterBase.Anchored = true
    waterBase.Transparency = 0.5
    waterBase.CanCollide = true
    waterBase.Parent = game.Workspace
    game:GetService("RunService").RenderStepped:Connect(function()
        if hrp and waterBase then
            waterBase.Position = Vector3.new(hrp.Position.X, -4.5, hrp.Position.Z)
        end
    end)
end
local function removeWaterBase()
    if waterBase then
        waterBase:Destroy()
        waterBase = nil
    end
end
local function enableNoClip()
    noclip = true
    runService.Stepped:Connect(function()
        if noclip and lp.Character then
            for _, part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end
local function disableNoClip()
    noclip = false
    if lp.Character then
        for _, part in pairs(lp.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end
local function toggleFly(pos)
    if pos then
        targetPosition = pos
        flying = true
    else
        flying = false
        if lp.Character and hrp then
            lp.Character.Humanoid.PlatformStand = false
            hrp.Velocity = Vector3.new(0, -5, 0)
        end
        return
    end
    lp.Character.Humanoid.PlatformStand = true
    while flying and targetPosition do
        hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        local directionToTarget = (targetPosition - hrp.Position).unit
        hrp.Velocity = directionToTarget * speed
        if (hrp.Position - targetPosition).Magnitude < 5 then
            targetPosition = nil
            flying = false
            hrp.Velocity = Vector3.new(0, -5, 0)
            lp.Character.Humanoid.PlatformStand = false
        end
        wait()
    end
end
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "SigmaHub", HidePremium = false, SaveConfig = true, ConfigFolder = "SigmaConfig", IntroText = "SigmaHub"})
local FarmTab = Window:MakeTab({
    Name = "CollectChest",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
FarmTab:AddToggle({
    Name = "StartCollect",
    Default = false,
    Callback = function(Value)
        CollectStatus = Value
        if Value then
            CollectStatus = true
            spawn(mainLoop)
        else
            flying = false
            lp.Character.Humanoid.PlatformStand = false 
        end
    end
})
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
TeleportTab:AddDropdown({
    Name = "Place",
    Default = nil,
    Options = getAllIslands(),
    Callback = function(Value)
        tpIsland = Value
    end    
})
TeleportTab:AddButton({
    Name = "Refresh Places",
    Callback = function()
        dropdown:Refresh(getAllIslands(), true)
    end
})
TeleportTab:AddButton({
    Name = "Teleport",
    Callback = function()
        if tpIsland then
            local mapFolder = game.Workspace:FindFirstChild("Map")
            if mapFolder then
                for _, island in pairs(mapFolder:GetChildren()) do
                    if island:IsA("Model") and island.Name == tpIsland then
                        local islandPos = island:GetBoundingBox().Position
                        enableNoClip()
                        toggleFly(islandPos)
                        disableNoClip()
                        break
                    end
                end
            end
        end
    end    
})
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
MiscTab:AddToggle({
	Name = "NoClip",
	Default = false,
	Callback = function(Value)
		if Value then
            enableNoClip()
        else
            disableNoClip()
        end
	end    
})
MiscTab:AddToggle({
	Name = "WalkOnWater",
	Default = false,
	Callback = function(Value)
		if Value then
            createWaterBase()
        else
            removeWaterBase()
        end
	end    
})
OrionLib:Init()

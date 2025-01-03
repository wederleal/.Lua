local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

local function enableNoclip()
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        player.Character.HumanoidRootPart.CanCollide = false
    end
end

local function findProximityPrompt(object)
    for _, descendant in ipairs(object:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            return descendant
        end
    end
    return nil
end

local function moveToCoal(coalPart)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        local targetPosition = coalPart.Position
        local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = {Position = targetPosition}
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()
        tween.Completed:Wait()
    end
end

local function collectCoal(coalPart)
    local proximityPrompt = findProximityPrompt(coalPart)
    if proximityPrompt then
        fireproximityprompt(proximityPrompt)
    end
end

local function getClosestCoal()
    local closestCoal = nil
    local shortestDistance = math.huge
    local coalStorageFolder = game.Workspace.MiscellaneousStorage.CoalStorage
    for _, coal in pairs(coalStorageFolder:GetChildren()) do
        if coal:IsA("BasePart") then
            local distance = (coal.Position - player.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestCoal = coal
            end
        end
    end
    return closestCoal
end

local function processCoals()
    while true do
        local closestCoal = getClosestCoal()
        if closestCoal then
            moveToCoal(closestCoal)
            collectCoal(closestCoal)
            wait(0.3)
        end
        wait(2)
    end
end

local function onDeath()
    player.CharacterAdded:Wait()
    wait(20)
    enableNoclip()
    processCoals()
end

local function optimizePerformance()
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 0
    game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    game:GetService("SoundService").SoundEnabled = false
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.CanCollide = false
            part.Anchored = true
            part.TextureID = ""
        end
    end
end

optimizePerformance()
enableNoclip()
processCoals()
player.CharacterAdded:Connect(onDeath)

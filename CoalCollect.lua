local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local coalStorage = workspace:FindFirstChild("MiscellaneousStorage") and workspace.MiscellaneousStorage:FindFirstChild("CoalStorage")

if not coalStorage then
    warn("CoalStorage não encontrado no workspace.")
    return
end

local stopProcessing = false

local function enableNoclip()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        character.HumanoidRootPart.CanCollide = false
    end
end

local function floatInAir()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        wait(2)
        humanoid.PlatformStand = false
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

local function moveToCoal(coalPart, instant)
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character.HumanoidRootPart
        local targetPosition = coalPart.Position
        local tweenInfo = TweenInfo.new(instant and 1.5 or 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = {Position = targetPosition}
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()
        tween.Completed:Wait()
    end
end

local function processCoals()
    while not stopProcessing do
        for _, coal in ipairs(coalStorage:GetChildren()) do
            local proximityPrompt = findProximityPrompt(coal)
            if proximityPrompt then
                enableNoclip()
                moveToCoal(coal, false)
                wait(0.5)
                fireproximityprompt(proximityPrompt)
                print("ProximityPrompt acionado para: " .. coal.Name)
                floatInAir()
                wait(2)
            end
        end
        print("Aguardando novos carvões...")
        wait(2)
    end
end

player.CharacterAdded:Connect(function()
    stopProcessing = true
    wait(5)  -- Alterado de 20 para 5 segundos
    character = player.Character or player.CharacterAdded:Wait()
    stopProcessing = false
    processCoals()
end)

processCoals()

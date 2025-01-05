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
    -- Aguarde até o HumanoidRootPart estar validado
    while not character:FindFirstChild("HumanoidRootPart") do
        wait(0.1)
    end

    local humanoidRootPart = character.HumanoidRootPart
    local targetPosition = coalPart.Position
    local tweenInfo = TweenInfo.new(instant and 1.5 or 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {Position = targetPosition}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
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
    wait(5)  -- Espera 5 segundos após o renascimento

    -- Aguarde até o HumanoidRootPart estar carregado
    character = player.Character or player.CharacterAdded:Wait()
    while not character:FindFirstChild("HumanoidRootPart") do
        wait(0.1)
    end

    -- Continue o processamento após garantir que o HumanoidRootPart esteja pronto
    stopProcessing = false
    processCoals()
end)

-- Aguardar até o HumanoidRootPart estar carregado antes de rodar o script
while not character:FindFirstChild("HumanoidRootPart") do
    wait(0.1)
end

processCoals()

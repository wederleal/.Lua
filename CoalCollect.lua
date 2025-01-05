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

    -- Ajustar a posição do personagem antes de mover para evitar queda
    humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))  -- Evitar que o personagem caia para baixo

    local tweenInfo = TweenInfo.new(instant and 1.5 or 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {Position = coalPart.Position}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

local function getClosestCoal()
    local closestCoal = nil
    local closestDistance = math.huge  -- Inicia com a maior distância possível

    -- Percorre todos os carvões para encontrar o mais próximo
    for _, coal in ipairs(coalStorage:GetChildren()) do
        if coal:IsA("BasePart") then
            local distance = (character.HumanoidRootPart.Position - coal.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestCoal = coal
            end
        end
    end

    return closestCoal
end

local function processCoals()
    while not stopProcessing do
        local coal = getClosestCoal()
        if coal then
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

    -- Ajuste a posição do personagem para garantir que ele não caia através do chão
    character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))

    -- Continue o processamento após garantir que o HumanoidRootPart esteja pronto
    stopProcessing = false
    processCoals()
end)

-- Aguardar até o HumanoidRootPart estar carregado antes de rodar o script
while not character:FindFirstChild("HumanoidRootPart") do
    wait(0.1)
end

-- Ajuste de posição inicial
character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))

processCoals()

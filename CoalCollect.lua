local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local coalStorage = workspace:FindFirstChild("MiscellaneousStorage") and workspace.MiscellaneousStorage:FindFirstChild("CoalStorage")

if not coalStorage then
    warn("CoalStorage não encontrado no workspace.")
    return
end

local stopProcessing = false
local isMoving = false

local function enableNoclip()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        character.HumanoidRootPart.CanCollide = false
    end
end

local function disableNoclip()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        character.HumanoidRootPart.CanCollide = true
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
    if character and character:FindFirstChild("HumanoidRootPart") and not isMoving then
        isMoving = true
        local humanoidRootPart = character.HumanoidRootPart
        local targetPosition = coalPart.Position
        local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = { Position = targetPosition }
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()
        tween.Completed:Wait()
        isMoving = false
    end
end

local function processCoals()
    while not stopProcessing do
        for _, coal in ipairs(coalStorage:GetChildren()) do
            if coal:IsA("BasePart") then
                local proximityPrompt = findProximityPrompt(coal)
                if proximityPrompt then
                    enableNoclip() -- Habilita o noclip para movimento
                    moveToCoal(coal)
                    wait(0.3)
                    fireproximityprompt(proximityPrompt)
                    print("ProximityPrompt acionado para: " .. coal.Name)
                    disableNoclip() -- Restaura a colisão após a coleta
                    wait(1) -- Espera antes de ir para o próximo carvão
                    break
                end
            end
        end
        print("Aguardando novos carvões...")
        wait(2)
    end
end

player.CharacterAdded:Connect(function()
    stopProcessing = true
    wait(20)
    character = player.Character or player.CharacterAdded:Wait()
    stopProcessing = false
    processCoals()
end)

if not stopProcessing then
    processCoals()
end

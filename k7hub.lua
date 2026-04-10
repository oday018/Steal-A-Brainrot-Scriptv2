local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Configuration Table
local Config = {
    SemiTP = false,
    AutoPotion = false,
    SpeedEnabled = false,
    SpeedValue = 31,
    AutoWalk = false
}
local ConfigFileName = "Krypton_Config.json"

-- Attempt to Load Config
pcall(function()
    if isfile and isfile(ConfigFileName) and readfile then
        local fileContent = readfile(ConfigFileName)
        local decoded = HttpService:JSONDecode(fileContent)
        if decoded.SemiTP ~= nil then Config.SemiTP = decoded.SemiTP end
        if decoded.AutoPotion ~= nil then Config.AutoPotion = decoded.AutoPotion end
        if decoded.SpeedEnabled ~= nil then Config.SpeedEnabled = decoded.SpeedEnabled end
        if decoded.SpeedValue ~= nil then Config.SpeedValue = decoded.SpeedValue end
        if decoded.AutoWalk ~= nil then Config.AutoWalk = decoded.AutoWalk end
    end
end)

local pos1 = Vector3.new(-352.98, -7, 74.30)            
local pos2 = Vector3.new(-352.98, -6.49, 45.76)   
local standing1 = Vector3.new(-336.36, -4.59, 99.51)
local standing2 = Vector3.new(-334.81, -4.59, 18.90)

-- Auto Walk Coordinates
local Trigger_A = Vector3.new(-352.885, -7.300, 76.068)
local Target_A = Vector3.new(-348.345, -6.835, 10.607)
local Trigger_B = pos2 
local Target_B = Vector3.new(-347.41278076171875, -7.3000030517578125, 103.7739486694336)

local spot1_sequence = {
    CFrame.new(-370.810913, -7.00000334, 41.2687263, 0.99984771, 1.22364419e-09, 0.0174523517, -6.54859778e-10, 1, -3.2596418e-08, -0.0174523517, 3.25800258e-08, 0.99984771),
    CFrame.new(-336.355286, -5.10107088, 17.2327671, -0.999883354, -2.76150569e-08, 0.0152716246, -2.88224964e-08, 1, -7.88441525e-08, -0.0152716246, -7.9275118e-08, -0.999883354)
}

local spot2_sequence = {
    CFrame.new(-354.782867, -7.00000334, 92.8209305, -0.999997616, -1.11891862e-09, -0.00218066527, -1.11958298e-09, 1, 3.03415071e-10, 0.00218066527, 3.05855785e-10, -0.999997616),
    CFrame.new(-336.942902, -5.10106993, 99.3276443, 0.999914348, -3.63984611e-08, 0.0130875716, 3.67094941e-08, 1, -2.35254749e-08, -0.0130875716, 2.40038975e-08, 0.999914348)
}

if CoreGui:FindFirstChild("KryptonGui") then 
    CoreGui["KryptonGui"]:Destroy() 
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KryptonGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Visual Theme Colors (Updated to Krypton Green/Black)
local ThemeColor = Color3.fromRGB(0, 255, 127) -- Krypton Green
local SecondaryColor = Color3.fromRGB(255, 255, 255)
local DarkBg = Color3.fromRGB(15, 15, 15)

-- List to keep track of UI elements for Minimizing
local MinimizableElements = {} 

local function createESPBox(position, labelText)
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESPBox_" .. labelText
    espFolder.Parent = workspace
    
    local box = Instance.new("Part")
    box.Name = "ESPPart"
    box.Size = Vector3.new(5, 0.5, 5)
    box.Position = position
    box.Anchored = true
    box.CanCollide = false
    box.Transparency = 0.5
    box.Material = Enum.Material.Neon
    box.Color = ThemeColor
    box.Parent = espFolder
    
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = box
    selectionBox.LineThickness = 0.05
    selectionBox.Color3 = SecondaryColor
    selectionBox.Parent = box
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.Adornee = box
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = box
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = ThemeColor
    textLabel.TextSize = 18
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = billboard
    
    return espFolder
end

createESPBox(pos1, "Teleport Here")
createESPBox(pos2, "Teleport Here")

local autoSemiTPCFrameLeft = CFrame.new(-349.325867, -7.00000238, 95.0031433, -0.999048233, -8.29406233e-09, -0.0436184891, -1.03892832e-08, 1, 4.78084594e-08, 0.0436184891, 4.82161227e-08, -0.999048233)
createESPBox(autoSemiTPCFrameLeft.Position, "Auto TP Left")

local autoSemiTPCFrameRight = CFrame.new(-349.560211, -7.00000238, 27.0543289, -0.999961913, 5.50995267e-08, -0.00872585084, 5.48100907e-08, 1, 3.34090586e-08, 0.00872585084, 3.29295204e-08, -0.999961913)
createESPBox(autoSemiTPCFrameRight.Position, "Auto TP Right")


local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 0) 
mainFrame.Position = UDim2.new(1, -255, 0.5, 0) 
mainFrame.AnchorPoint = Vector2.new(0, 0.5)
mainFrame.BackgroundColor3 = DarkBg
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true 
mainFrame.Parent = screenGui

-- Intro Animation
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 370)}):Play()

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 2
uiStroke.Color = ThemeColor 

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, ThemeColor),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 50, 25)),
    ColorSequenceKeypoint.new(1.00, ThemeColor)
})
uiGradient.Parent = uiStroke

task.spawn(function()
    while task.wait() do
        for i = 0, 360, 2 do
            uiGradient.Rotation = i
            task.wait(0.01)
        end
    end
end)

-- Header Frame (Holds Title and Control Buttons)
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 35)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "KRYPTON SEMI"
title.TextColor3 = ThemeColor
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = headerFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = SecondaryColor
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = headerFrame

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -55, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = SecondaryColor
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = headerFrame

-- Button Logic
closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,80,80)}):Play() end)
closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = SecondaryColor}):Play() end)
closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 240, 0, 0)}):Play()
    task.wait(0.3)
    screenGui:Destroy()
end)

local isMinimized = false
local AutoTPLeft_Btn, AutoTPRight_Btn, StealBar_Frame 

minBtn.MouseEnter:Connect(function() TweenService:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = ThemeColor}):Play() end)
minBtn.MouseLeave:Connect(function() TweenService:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = SecondaryColor}):Play() end)
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Shrink
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 135)}):Play()
        if AutoTPLeft_Btn then TweenService:Create(AutoTPLeft_Btn, TweenInfo.new(0.4), {Position = UDim2.new(0.05, 0, 0, 35)}):Play() end
        if AutoTPRight_Btn then TweenService:Create(AutoTPRight_Btn, TweenInfo.new(0.4), {Position = UDim2.new(0.05, 0, 0, 70)}):Play() end
        if StealBar_Frame then TweenService:Create(StealBar_Frame, TweenInfo.new(0.4), {Position = UDim2.new(0.05, 0, 0, 110)}):Play() end
        
        for _, guiObj in ipairs(MinimizableElements) do
            if guiObj:IsA("GuiObject") then guiObj.Visible = false end
        end
    else
        -- Expand
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 370)}):Play()
        if AutoTPLeft_Btn then TweenService:Create(AutoTPLeft_Btn, TweenInfo.new(0.4), {Position = UDim2.new(0.05, 0, 0, 205)}):Play() end
        if AutoTPRight_Btn then TweenService:Create(AutoTPRight_Btn, TweenInfo.new(0.4), {Position = UDim2.new(0.05, 0, 0, 240)}):Play() end
        if StealBar_Frame then TweenService:Create(StealBar_Frame, TweenInfo.new(0.4), {Position = UDim2.new(0.05, 0, 0, 280)}):Play() end
        
        for _, guiObj in ipairs(MinimizableElements) do guiObj.Visible = true end
    end
end)


local dividerLine = Instance.new("Frame")
dividerLine.Size = UDim2.new(0.9, 0, 0, 1)
dividerLine.Position = UDim2.new(0.05, 0, 0, 35)
dividerLine.BackgroundColor3 = ThemeColor
dividerLine.BackgroundTransparency = 0.5
dividerLine.BorderSizePixel = 0
dividerLine.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 15)
subtitle.Position = UDim2.new(0, 0, 0, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "KRYPTON PRIVATE"
subtitle.TextColor3 = Color3.fromRGB(120, 120, 120)
subtitle.TextSize = 9
subtitle.Font = Enum.Font.GothamMedium
subtitle.Parent = mainFrame
table.insert(MinimizableElements, subtitle)

local semiTPEnabled = false
local speedEnabled = false
local speedConnection = nil
local SPEED_BOOST = Config.SpeedValue
local autoWalkEnabled = false
local isAutoWalking = false
local walkDebounce = false
local activeAutoWalkMode = nil 


local function ResetToWork()
    local flags = {
        {"GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000"},
        {"LargeReplicatorWrite5", "true"},
        {"LargeReplicatorEnabled9", "true"},
        {"AngularVelociryLimit", "360"},
        {"TimestepArbiterVelocityCriteriaThresholdTwoDt", "2147483646"},
        {"S2PhysicsSenderRate", "15000"},
        {"DisableDPIScale", "true"},
        {"MaxDataPacketPerSend", "2147483647"},
        {"ServerMaxBandwith", "52"},
        {"PhysicsSenderMaxBandwidthBps", "20000"},
        {"MaxTimestepMultiplierBuoyancy", "2147483647"},
        {"SimOwnedNOUCountThresholdMillionth", "2147483647"},
        {"MaxMissedWorldStepsRemembered", "-2147483648"},
        {"CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth", "1"},
        {"StreamJobNOUVolumeLengthCap", "2147483647"},
        {"DebugSendDistInSteps", "-2147483648"},
        {"MaxTimestepMultiplierAcceleration", "2147483647"},
        {"LargeReplicatorRead5", "true"},
        {"SimExplicitlyCappedTimestepMultiplier", "2147483646"},
        {"GameNetDontSendRedundantNumTimes", "1"},
        {"CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent", "1"},
        {"CheckPVCachedRotVelThresholdPercent", "10"},
        {"LargeReplicatorSerializeRead3", "true"},
        {"ReplicationFocusNouExtentsSizeCutoffForPauseStuds", "2147483647"},
        {"NextGenReplicatorEnabledWrite4", "true"},
        {"CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth", "1"},
        {"GameNetDontSendRedundantDeltaPositionMillionth", "1"},
        {"InterpolationFrameVelocityThresholdMillionth", "5"},
        {"StreamJobNOUVolumeCap", "2147483647"},
        {"InterpolationFrameRotVelocityThresholdMillionth", "5"},
        {"WorldStepMax", "30"},
        {"TimestepArbiterHumanoidLinearVelThreshold", "1"},
        {"InterpolationFramePositionThresholdMillionth", "5"},
        {"TimestepArbiterHumanoidTurningVelThreshold", "1"},
        {"MaxTimestepMultiplierContstraint", "2147483647"},
        {"GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-5000"},
        {"CheckPVCachedVelThresholdPercent", "10"},
        {"TimestepArbiterOmegaThou", "1073741823"},
        {"MaxAcceptableUpdateDelay", "1"},
        {"LargeReplicatorSerializeWrite4", "true"},
    }
    for _, data in ipairs(flags) do
        pcall(function() if setfflag then setfflag(data[1], data[2]) end end)
    end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        char:ClearAllChildren()
        local f = Instance.new("Model", workspace)
        player.Character = f task.wait()
        player.Character = char f:Destroy()
    end
end

local function executeTP(sequence)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")

    if root and hum and backpack then
        local carpet = backpack:FindFirstChild("Flying Carpet")
        if carpet then hum:EquipTool(carpet) end
        task.wait(0.05)
        root.CFrame = sequence[1]
        task.wait(0.1)
        root.CFrame = sequence[2]
    end
end


local function createToggle(text, position, default, callback)
    local container = Instance.new("CanvasGroup")
    container.Size = UDim2.new(0.9, 0, 0, 30)
    container.Position = position
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = mainFrame
    
    table.insert(MinimizableElements, container)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = SecondaryColor
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 18)
    btn.Position = UDim2.new(1, -38, 0.5, -9)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = ""
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local active = default
    local goal = active and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    local col = active and ThemeColor or Color3.fromRGB(35, 35, 35)
    dot.Position = goal
    btn.BackgroundColor3 = col
    
    task.spawn(function() callback(active) end)

    btn.MouseButton1Click:Connect(function()
        active = not active
        local goal = active and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        local col = active and ThemeColor or Color3.fromRGB(35, 35, 35)
        TweenService:Create(dot, TweenInfo.new(0.15), {Position = goal}):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
        callback(active)
    end)
    
    return container
end


createToggle("Half TP", UDim2.new(0.05, 0, 0, 55), Config.SemiTP, function(state) 
    semiTPEnabled = state 
    Config.SemiTP = state
end)

createToggle("Auto Potion", UDim2.new(0.05, 0, 0, 90), Config.AutoPotion, function(state)
    _G.AutoPotion = state
    Config.AutoPotion = state
end)

local speedContainer = Instance.new("CanvasGroup")
speedContainer.Size = UDim2.new(0.9, 0, 0, 30)
speedContainer.Position = UDim2.new(0.05, 0, 0, 125)
speedContainer.BackgroundTransparency = 1
speedContainer.BorderSizePixel = 0
speedContainer.Parent = mainFrame
table.insert(MinimizableElements, speedContainer)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed Boost"
speedLabel.TextColor3 = SecondaryColor
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedContainer

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 30, 0, 20)
speedBox.Position = UDim2.new(1, -85, 0.5, -10)
speedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
speedBox.Text = tostring(SPEED_BOOST)
speedBox.TextColor3 = ThemeColor
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 10
speedBox.Parent = speedContainer
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then SPEED_BOOST = val Config.SpeedValue = val else speedBox.Text = tostring(SPEED_BOOST) end
end)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, 38, 0, 18)
speedBtn.Position = UDim2.new(1, -38, 0.5, -9)
speedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedBtn.Text = ""
speedBtn.Parent = speedContainer
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(1, 0)

local speedDot = Instance.new("Frame")
speedDot.Size = UDim2.new(0, 12, 0, 12)
speedDot.Position = UDim2.new(0, 3, 0.5, -6)
speedDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
speedDot.Parent = speedBtn
Instance.new("UICorner", speedDot).CornerRadius = UDim.new(1, 0)

local function updateSpeedLogic(state)
    speedEnabled = state
    Config.SpeedEnabled = state
    if state then
        if not speedConnection then
            speedConnection = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char then return end
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                    if isAutoWalking then return end 
                    local dir = hum.MoveDirection.Unit
                    hrp.AssemblyLinearVelocity = Vector3.new(dir.X * SPEED_BOOST, hrp.AssemblyLinearVelocity.Y, dir.Z * SPEED_BOOST)
                end
            end)
        end
    else
        if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    end
end

if Config.SpeedEnabled then
    speedEnabled = true
    speedDot.Position = UDim2.new(1, -15, 0.5, -6)
    speedBtn.BackgroundColor3 = ThemeColor
    updateSpeedLogic(true)
end

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    local goal = speedEnabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    local col = speedEnabled and ThemeColor or Color3.fromRGB(35, 35, 35)
    TweenService:Create(speedDot, TweenInfo.new(0.15), {Position = goal}):Play()
    TweenService:Create(speedBtn, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
    updateSpeedLogic(speedEnabled)
end)


createToggle("Auto Walk Base", UDim2.new(0.05, 0, 0, 160), Config.AutoWalk, function(state)
    autoWalkEnabled = state
    Config.AutoWalk = state
    isAutoWalking = false
    walkDebounce = false
    activeAutoWalkMode = nil 
end)


task.spawn(function()
    task.wait(1)
    ResetToWork()
end)

local discordText = Instance.new("TextLabel")
discordText.Size = UDim2.new(1, 0, 0, 15)
discordText.Position = UDim2.new(0, 0, 1, -20)
discordText.BackgroundTransparency = 1
discordText.Text = "KRYPTON.GG/LOAD"
discordText.TextColor3 = Color3.fromRGB(80, 80, 80)
discordText.TextSize = 10
discordText.Font = Enum.Font.GothamMedium
discordText.Parent = mainFrame
table.insert(MinimizableElements, discordText)


local currentEquipTask = nil
local isHolding = false

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, plr)
    if plr ~= player or not semiTPEnabled then return end
    isHolding = true
    if currentEquipTask then task.cancel(currentEquipTask) end
    currentEquipTask = task.spawn(function()
        task.wait(1)
        if isHolding and semiTPEnabled then
            local backpack = player:WaitForChild("Backpack", 2)
            if backpack then
                local carpet = backpack:FindFirstChild("Flying Carpet")
                if carpet and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:EquipTool(carpet) end
            end
        end
    end)
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, plr)
    if plr ~= player then return end
    isHolding = false
    if currentEquipTask then task.cancel(currentEquipTask) end
end)


ProximityPromptService.PromptTriggered:Connect(function(prompt, plr)
    if plr ~= player or not semiTPEnabled then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local d1 = (root.Position - pos1).Magnitude
        local d2 = (root.Position - pos2).Magnitude
        root.CFrame = CFrame.new(d1 < d2 and pos1 or pos2)
        if _G.AutoPotion then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local potion = backpack:FindFirstChild("Giant Potion")
                if potion and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:EquipTool(potion)
                    task.wait(0.1)
                    pcall(function() potion:Activate() end)
                end
            end
        end
    end
    isHolding = false
end)


local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)


local CONFIG = { ANTI_STEAL_ACTIVE = false }
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local allAnimalsCache = {}
local PromptMemoryCache = {}
local InternalStealCache = {}
local IsStealing = false
local StealProgress = 0
local CurrentStealTarget = nil
local AUTO_STEAL_PROX_RADIUS = 200

local function getHRP()
    local char = player.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
end

local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    local sign = plot and plot:FindFirstChild("PlotSign")
    return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled
end

local function scanSinglePlot(plot)
    if not plot or not plot:IsA("Model") or isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            table.insert(allAnimalsCache, { plot = plot.Name, slot = podium.Name, worldPosition = podium:GetPivot().Position, uid = plot.Name .. "_" .. podium.Name })
        end
    end
end

local function initializeScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10)
    for _, plot in ipairs(plots:GetChildren()) do scanSinglePlot(plot) end
    plots.ChildAdded:Connect(scanSinglePlot)
    task.spawn(function() while task.wait(5) do table.clear(allAnimalsCache) for _, plot in ipairs(plots:GetChildren()) do scanSinglePlot(plot) end end end)
end

local function findPrompt(animal)
    if PromptMemoryCache[animal.uid] and PromptMemoryCache[animal.uid].Parent then return PromptMemoryCache[animal.uid] end
    local plot = workspace.Plots:FindFirstChild(animal.plot)
    local podium = plot and plot.AnimalPodiums:FindFirstChild(animal.slot)
    local prompt = podium and podium.Base.Spawn.PromptAttachment:FindFirstChildOfClass("ProximityPrompt")
    if prompt then PromptMemoryCache[animal.uid] = prompt end
    return prompt
end

local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 then for _, c in ipairs(conns1) do table.insert(data.holdCallbacks, c.Function) end end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 then for _, c in ipairs(conns2) do table.insert(data.triggerCallbacks, c.Function) end end
    InternalStealCache[prompt] = data
end

local function executeInternalStealAsync(prompt, animalData, sequence)
    local data = InternalStealCache[prompt]
    if not data or not data.ready or IsStealing then return end
    data.ready = false IsStealing = true StealProgress = 0 CurrentStealTarget = animalData
    local tpDone = false
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        local startTime = tick()
        while tick() - startTime < 1.3 do
            StealProgress = (tick() - startTime) / 1.3
            if StealProgress >= 0.73 and not tpDone then
                tpDone = true
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = sequence[1]
                    task.wait(0.1)
                    hrp.CFrame = sequence[2]
                    task.wait(0.2)
                    local d1 = (hrp.Position - pos1).Magnitude
                    local d2 = (hrp.Position - pos2).Magnitude
                    hrp.CFrame = CFrame.new(d1 < d2 and pos1 or pos2)
                end
            end
            task.wait()
        end
        StealProgress = 1
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.2)
        data.ready = true IsStealing = false StealProgress = 0 CurrentStealTarget = nil CONFIG.ANTI_STEAL_ACTIVE = false
    end)
end

local function getNearestAnimal()
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest, dist = nil, math.huge
    for _, animal in ipairs(allAnimalsCache) do
        local d = (hrp.Position - animal.worldPosition).Magnitude
        if d < dist and d <= AUTO_STEAL_PROX_RADIUS then dist = d nearest = animal end
    end
    return nearest
end


local leftBtn = Instance.new("TextButton", mainFrame)
leftBtn.Size = UDim2.new(0.9, 0, 0, 30)
leftBtn.Position = UDim2.new(0.05, 0, 0, 205)
leftBtn.Text = "AUTO STEAL LEFT"
leftBtn.Font = Enum.Font.GothamBold
leftBtn.TextSize = 13
leftBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
leftBtn.TextColor3 = ThemeColor
Instance.new("UICorner", leftBtn)
AutoTPLeft_Btn = leftBtn

leftBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    local carpet = player.Backpack:FindFirstChild("Flying Carpet")
    if hum and carpet then hum:EquipTool(carpet) end
    activeAutoWalkMode = "Left"
    if IsStealing then return end
    local animal = getNearestAnimal()
    if animal then 
        local prompt = findPrompt(animal) 
        if prompt then buildStealCallbacks(prompt) executeInternalStealAsync(prompt, animal, spot1_sequence) end 
    end
end)

local rightBtn = Instance.new("TextButton", mainFrame)
rightBtn.Size = UDim2.new(0.9, 0, 0, 30)
rightBtn.Position = UDim2.new(0.05, 0, 0, 240) 
rightBtn.Text = "AUTO STEAL RIGHT"
rightBtn.Font = Enum.Font.GothamBold
rightBtn.TextSize = 13
rightBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightBtn.TextColor3 = ThemeColor
Instance.new("UICorner", rightBtn)
AutoTPRight_Btn = rightBtn

rightBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    local carpet = player.Backpack:FindFirstChild("Flying Carpet")
    if hum and carpet then hum:EquipTool(carpet) end
    activeAutoWalkMode = "Right"
    if IsStealing then return end
    local animal = getNearestAnimal()
    if animal then 
        local prompt = findPrompt(animal) 
        if prompt then buildStealCallbacks(prompt) executeInternalStealAsync(prompt, animal, spot2_sequence) end 
    end
end)

local bar = Instance.new("Frame", mainFrame)
bar.Size = UDim2.new(0.9, 0, 0, 10)
bar.Position = UDim2.new(0.05, 0, 0, 280) 
bar.BackgroundColor3 = Color3.fromRGB(10,10,10)
Instance.new("UICorner", bar)
StealBar_Frame = bar

local fill = Instance.new("Frame", bar)
fill.BackgroundColor3 = ThemeColor
fill.Size = UDim2.new(0,0,1,0)
Instance.new("UICorner", fill)

local percentLabel = Instance.new("TextLabel", bar)
percentLabel.Size = UDim2.new(1, 0, 1, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = SecondaryColor
percentLabel.TextSize = 9
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextXAlignment = Enum.TextXAlignment.Center

task.spawn(function()
    while true do
        fill.Size = UDim2.new(math.clamp(StealProgress,0,1),0,1,0)
        percentLabel.Text = (math.floor(StealProgress*100+0.5)).."%"
        task.wait(0.02)
    end
end)

local saveConfigButton = Instance.new("TextButton", mainFrame)
saveConfigButton.Size = UDim2.new(0.9, 0, 0, 30)
saveConfigButton.Position = UDim2.new(0.05, 0, 0, 305) 
saveConfigButton.Text = "SAVE SETTINGS"
saveConfigButton.Font = Enum.Font.GothamBold
saveConfigButton.TextSize = 12
saveConfigButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
saveConfigButton.TextColor3 = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", saveConfigButton)
table.insert(MinimizableElements, saveConfigButton)

saveConfigButton.MouseButton1Click:Connect(function()
    if writefile then
        pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(Config)) end)
        saveConfigButton.Text = "SETTINGS SAVED" saveConfigButton.TextColor3 = ThemeColor task.wait(1)
        saveConfigButton.Text = "SAVE SETTINGS" saveConfigButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

RunService.Heartbeat:Connect(function()
    if not autoWalkEnabled or not activeAutoWalkMode then return end
    local root = getHRP()
    if not root then return end
    local currentTrigger = (activeAutoWalkMode == "Right") and Trigger_A or Trigger_B
    local currentTarget = (activeAutoWalkMode == "Right") and Target_A or Target_B
    local distToTrigger = (root.Position - currentTrigger).Magnitude
    local distToTarget = (root.Position - currentTarget).Magnitude
    if distToTrigger < 6 and not isAutoWalking and not walkDebounce then
        walkDebounce = true
        task.spawn(function() task.wait(0.2) if autoWalkEnabled then isAutoWalking = true else walkDebounce = false end end)
    end
    if distToTarget < 4 and isAutoWalking then
        isAutoWalking = false walkDebounce = false activeAutoWalkMode = nil root.AssemblyLinearVelocity = Vector3.zero
    end
    if isAutoWalking then
        local dir = (currentTarget - root.Position).Unit
        root.AssemblyLinearVelocity = Vector3.new(dir.X * SPEED_BOOST, root.AssemblyLinearVelocity.Y, dir.Z * SPEED_BOOST)
    end
end)

initializeScanner()

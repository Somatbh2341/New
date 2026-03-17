local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 0. CLEANUP OLD UI
if player:WaitForChild("PlayerGui"):FindFirstChild("RivalsProV3") then
    player.PlayerGui.RivalsProV3:Destroy()
end

-- 1. SETTINGS & CONFIG
local Config = {
    Combat = {
        Aimlock = false,
        Trigger = false,
        Sticky = false,
        VisCheck = false,
        Prediction = false,
        PredScale = 0.15,
        Smooth = 0.1,
        Part = "Head"
    },
    Visuals = {
        ESP = false,
        Boxes = false,
        Bones = false,
        Names = false,
        Chams = false,
        Color = Color3.fromRGB(255, 0, 0)
    },
    Keys = {
        Menu = Enum.KeyCode.Insert,
        Aim = Enum.KeyCode.Q,
        Trigger = Enum.KeyCode.E
    }
}

-- 2. UI BASE CONSTRUCTION
local Screen = Instance.new("ScreenGui", player.PlayerGui); Screen.Name = "RivalsProV3"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 500, 0, 380); Main.Position = UDim2.new(0.5, -250, 0.5, -190); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.BorderSizePixel = 0
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -130, 1, 0); Container.Position = UDim2.new(0, 130, 0, 0); Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local f = Instance.new("ScrollingFrame", Container); f.Size = UDim2.new(1, -10, 1, -10); f.Position = UDim2.new(0, 5, 0, 5); f.Visible = false; f.BackgroundTransparency = 1; f.CanvasSize = UDim2.new(0,0,2,0); f.ScrollBarThickness = 2
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5); Pages[name] = f
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 45); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Position = UDim2.new(0, 0, 0, (#Sidebar:GetChildren()-1)*45)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end; f.Visible = true end)
end

-- 3. INTERACTIVE UI HELPERS
local function AddToggle(page, text, ref, key)
    local btn = Instance.new("TextButton", Pages[page]); btn.Size = UDim2.new(0.95, 0, 0, 32); btn.Text = text .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() 
        ref[key] = not ref[key]; btn.Text = text .. ": " .. (ref[key] and "ON" or "OFF")
        btn.BackgroundColor3 = ref[key] and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(45, 45, 45)
    end)
end

local function AddSlider(page, text, ref, key, min, max)
    local label = Instance.new("TextLabel", Pages[page]); label.Size = UDim2.new(0.95, 0, 0, 20); label.Text = text .. ": " .. ref[key]; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", Pages[page]); btn.Size = UDim2.new(0.95, 0, 0, 10); btn.Text = ""; btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    btn.MouseButton1Down:Connect(function()
        local conn; conn = RunService.RenderStepped:Connect(function()
            local percent = math.clamp((mouse.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
            ref[key] = math.floor((min + (max - min) * percent) * 100) / 100
            label.Text = text .. ": " .. ref[key]
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() end
        end)
    end)
end

-- 4. BUILD THE MENU
NewPage("Combat"); NewPage("Visuals"); NewPage("Settings")
AddToggle("Combat", "Aimlock Master", Config.Combat, "Aimlock")
AddToggle("Combat", "Prediction", Config.Combat, "Prediction")
AddToggle("Combat", "Sticky Aim", Config.Combat, "Sticky")
AddToggle("Combat", "Triggerbot", Config.Combat, "Trigger")
AddSlider("Combat", "Aim Smoothness", Config.Combat, "Smooth", 0.01, 1)

AddToggle("Visuals", "Boxes", Config.Visuals, "Boxes")
AddToggle("Visuals", "Nametags", Config.Visuals, "Names")
AddToggle("Visuals", "Chams", Config.Visuals, "Chams")

-- 5. AIMBOT LOGIC WITH PREDICTION
local function GetTargetPos(char)
    local part = char:FindFirstChild(Config.Combat.Part)
    if not part then return nil end
    local pos = part.Position
    if Config.Combat.Prediction then
        local velocity = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Velocity or Vector3.new(0,0,0)
        pos = pos + (velocity * Config.Combat.PredScale)
    end
    return pos
end

RunService.RenderStepped:Connect(function()
    if Config.Combat.Aimlock and (UIS:IsKeyDown(Config.Keys.Aim) or UIS:IsMouseButtonPressed(Config.Keys.Aim)) then
        local t = mouse.Target
        if t and t.Parent:FindFirstChild("Humanoid") and t.Parent ~= player.Character then
            local pos = GetTargetPos(t.Parent)
            if pos then
                local s = Config.Combat.Sticky and (Config.Combat.Smooth / 2) or Config.Combat.Smooth
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, pos), s)
            end
        end
    end
    
    -- Triggerbot
    if Config.Combat.Trigger and (UIS:IsKeyDown(Config.Keys.Trigger) or UIS:IsMouseButtonPressed(Config.Keys.Trigger)) then
        local t = mouse.Target
        if t and t.Parent:FindFirstChild("Humanoid") and t.Parent ~= player.Character then
            if typeof(mouse1click) == "function" then mouse1click() end
        end
    end
end)

-- 6. ESP SYSTEM
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            -- Chams
            local h = char:FindFirstChild("ProHighlight")
            if Config.Visuals.Chams then
                if not h then h = Instance.new("Highlight", char); h.Name = "ProHighlight" end
                h.Enabled = true; h.FillColor = Config.Visuals.Color
            elseif h then h.Enabled = false end
            
            -- Nametags
            local tag = char:FindFirstChild("ProTag")
            if Config.Visuals.Names then
                if not tag then
                    local bb = Instance.new("BillboardGui", char); bb.Name = "ProTag"; bb.Size = UDim2.new(0,100,0,50); bb.Adornee = char:FindFirstChild("Head"); bb.AlwaysOnTop = true
                    local tl = Instance.new("TextLabel", bb); tl.Size = UDim2.new(1,0,1,0); tl.Text = p.Name; tl.TextColor3 = Color3.new(1,1,1); tl.BackgroundTransparency = 1
                end
            elseif tag then tag:Destroy() end
        end
    end
end)

-- 7. MENU TOGGLE
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Config.Keys.Menu then Main.Visible = not Main.Visible end
end)

Pages.Combat.Visible = true
print("Rivals Pro V3 Loaded. Press INSERT to open.")

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 0. CLEANUP PREVIOUS UI
if player:WaitForChild("PlayerGui"):FindFirstChild("RivalsUltraV5") then
    player.PlayerGui.RivalsUltraV5:Destroy()
end

-- 1. CONFIGURATION
local Config = {
    Combat = { 
        Aim = false, Trigger = false, Smooth = 0.1, Pred = 0.15, 
        FOV = 150, ShowFOV = true, VisCheck = true, Target = "Head" 
    },
    Visuals = { 
        Boxes = false, Names = false, Chams = false, 
        Color = Color3.fromRGB(255, 0, 0) 
    },
    Keys = { 
        Menu = Enum.KeyCode.Insert, 
        Aim = Enum.KeyCode.Q, 
        Trigger = Enum.KeyCode.E 
    }
}

-- 2. DRAWING FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.new(1, 1, 1)

-- 3. UI BASE
local Screen = Instance.new("ScreenGui", player.PlayerGui); Screen.Name = "RivalsUltraV5"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 500, 0, 350); Main.Position = UDim2.new(0.5, -250, 0.5, -175); Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Main.BorderSizePixel = 0
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 120, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -120, 1, 0); Container.Position = UDim2.new(0, 120, 0, 0); Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local f = Instance.new("ScrollingFrame", Container); f.Size = UDim2.new(1, -10, 1, -10); f.Position = UDim2.new(0, 5, 0, 5); f.Visible = false; f.BackgroundTransparency = 1; f.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5); Pages[name] = f
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 45); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1,1,1); b.Position = UDim2.new(0, 0, 0, (#Sidebar:GetChildren()-1)*45)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end; f.Visible = true end)
end

-- 4. INTERACTIVE COMPONENTS
local function AddToggle(page, text, ref, key)
    local btn = Instance.new("TextButton", Pages[page]); btn.Size = UDim2.new(0.95, 0, 0, 32); btn.Text = text .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() 
        ref[key] = not ref[key]; btn.Text = text .. ": " .. (ref[key] and "ON" or "OFF")
        btn.BackgroundColor3 = ref[key] and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

local function AddBind(page, text, ref, key)
    local btn = Instance.new("TextButton", Pages[page]); btn.Size = UDim2.new(0.95, 0, 0, 32); btn.Text = text .. ": " .. ref[key].Name; btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."; local c; c = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.MouseButton2 then
                ref[key] = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType; btn.Text = text .. ": " .. ref[key].Name; c:Disconnect()
            end
        end)
    end)
end

local function AddSlider(page, text, ref, key, min, max)
    local label = Instance.new("TextLabel", Pages[page]); label.Size = UDim2.new(0.95, 0, 0, 20); label.Text = text .. ": " .. ref[key]; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", Pages[page]); bar.Size = UDim2.new(0.95, 0, 0, 10); bar.Text = ""; bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    bar.MouseButton1Down:Connect(function()
        local conn; conn = RunService.RenderStepped:Connect(function()
            local p = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            ref[key] = math.floor((min + (max - min) * p) * 100) / 100; label.Text = text .. ": " .. ref[key]
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() end
        end)
    end)
end

-- 5. BUILD MENU
NewPage("Combat"); NewPage("Visuals"); NewPage("Settings")
AddToggle("Combat", "Aimbot", Config.Combat, "Aim"); AddToggle("Combat", "Triggerbot", Config.Combat, "Trigger")
AddToggle("Combat", "Show FOV", Config.Combat, "ShowFOV"); AddSlider("Combat", "FOV Size", Config.Combat, "FOV", 10, 800)
AddSlider("Combat", "Smoothness", Config.Combat, "Smooth", 0.01, 1); AddSlider("Combat", "Prediction", Config.Combat, "Pred", 0, 1)
AddToggle("Visuals", "Box ESP", Config.Visuals, "Boxes"); AddToggle("Visuals", "Nametags", Config.Visuals, "Names"); AddToggle("Visuals", "Chams", Config.Visuals, "Chams")
AddBind("Settings", "Aim Key", Config.Keys, "Aim"); AddBind("Settings", "Trigger Key", Config.Keys, "Trigger"); AddBind("Settings", "Menu Key", Config.Keys, "Menu")

-- 6. COMBAT LOGIC
local function GetTarget()
    local near, dist = nil, Config.Combat.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local part = p.Character:FindFirstChild(Config.Combat.Target)
            if part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if onScreen and mag < dist then
                    if Config.Combat.VisCheck and #camera:GetPartsObscuredByTarget({part.Position}, {player.Character, p.Character}) > 0 then continue end
                    near = p.Character; dist = mag
                end
            end
        end
    end
    return near
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.Combat.ShowFOV; FOVCircle.Radius = Config.Combat.FOV; FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    if Config.Combat.Aim and (UIS:IsKeyDown(Config.Keys.Aim) or UIS:IsMouseButtonPressed(Config.Keys.Aim)) then
        local tar = GetTarget()
        if tar then
            local p = tar[Config.Combat.Target].Position + (tar.HumanoidRootPart.Velocity * Config.Combat.Pred)
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, p), Config.Combat.Smooth)
        end
    end
    if Config.Combat.Trigger then
        local t = mouse.Target; if t and t.Parent:FindFirstChild("Humanoid") and t.Parent ~= player.Character then if typeof(mouse1click) == "function" then mouse1click() end end
    end
end)

-- 7. ESP SYSTEM (Reliable Billboard Boxes)
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            -- Box ESP
            local box = char:FindFirstChild("RivalsBox")
            if Config.Visuals.Boxes then
                if not box then
                    box = Instance.new("BillboardGui", char); box.Name = "RivalsBox"; box.AlwaysOnTop = true; box.Size = UDim2.new(4.5, 0, 6, 0); box.Adornee = char.PrimaryPart
                    local frame = Instance.new("Frame", box); frame.Size = UDim2.new(1,0,1,0); frame.BackgroundTransparency = 1; frame.BorderSizePixel = 2; frame.BorderColor3 = Config.Visuals.Color
                    local uiStroke = Instance.new("UIStroke", frame); uiStroke.Thickness = 2; uiStroke.Color = Config.Visuals.Color
                end
                box.Enabled = true
            elseif box then box.Enabled = false end
            
            -- Chams
            local h = char:FindFirstChild("RivalsCham")
            if Config.Visuals.Chams then
                if not h then h = Instance.new("Highlight", char); h.Name = "RivalsCham"; h.FillColor = Config.Visuals.Color end
                h.Enabled = true
            elseif h then h.Enabled = false end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Config.Keys.Menu then Main.Visible = not Main.Visible end end)
Pages.Combat.Visible = true
print("Rivals Ultra V5 Loaded. Press INSERT.")

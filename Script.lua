local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 0. CLEAR PREVIOUS UI (Ensures the new menu loads)
if player:WaitForChild("PlayerGui"):FindFirstChild("RivalsV7Fix") then
    player.PlayerGui.RivalsV7Fix:Destroy()
end

-- 1. SETTINGS & CONFIG
local Config = {
    Combat = { 
        Aim = false, Trigger = false, Smooth = 0.08, Pred = 0.15, 
        FOV = 150, ShowFOV = true, VisCheck = true, TargetPart = "Head" 
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

-- 2. FOV CIRCLE DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.NumSides = 100; FOVCircle.Filled = false; FOVCircle.Color = Color3.new(1, 1, 1)

-- 3. UI CONSTRUCTION
local Screen = Instance.new("ScreenGui", player.PlayerGui); Screen.Name = "RivalsV7Fix"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 500, 0, 380); Main.Position = UDim2.new(0.5, -250, 0.5, -190); Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 120, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -120, 1, 0); Container.Position = UDim2.new(0, 120, 0, 0); Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local f = Instance.new("ScrollingFrame", Container); f.Size = UDim2.new(1, -10, 1, -10); f.Position = UDim2.new(0, 5, 0, 5); f.Visible = false; f.BackgroundTransparency = 1; f.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5); Pages[name] = f
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 45); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1,1,1); b.Position = UDim2.new(0, 0, 0, (#Sidebar:GetChildren()-1)*45)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end; f.Visible = true end)
end

-- 4. INTERACTIVE HELPERS
local function AddToggle(p, t, r, k)
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 32); b.Text = t .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() r[k] = not r[k]; b.Text = t .. ": " .. (r[k] and "ON" or "OFF"); b.BackgroundColor3 = r[k] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45) end)
end

local function AddBind(p, t, r, k)
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 32); b.Text = t .. ": " .. r[k].Name; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() b.Text = "..."; local c; c = UIS.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.MouseButton2 then r[k] = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType; b.Text = t .. ": " .. r[k].Name; c:Disconnect() end end) end)
end

local function AddSlider(p, t, r, k, min, max)
    local l = Instance.new("TextLabel", Pages[p]); l.Size = UDim2.new(0.95, 0, 0, 20); l.Text = t .. ": " .. r[k]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 10); b.Text = ""; b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    b.MouseButton1Down:Connect(function() local cn; cn = RunService.RenderStepped:Connect(function() local pc = math.clamp((mouse.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1); r[k] = math.floor((min + (max - min) * pc) * 100) / 100; l.Text = t .. ": " .. r[k]; if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then cn:Disconnect() end end) end)
end

-- 5. BUILD PAGES
NewPage("Combat"); NewPage("Visuals"); NewPage("Settings")
AddToggle("Combat", "Aimbot", Config.Combat, "Aim"); AddToggle("Combat", "Triggerbot", Config.Combat, "Trigger")
AddToggle("Combat", "Wallbang (VisCheck OFF)", Config.Combat, "VisCheck"); AddSlider("Combat", "Smoothing", Config.Combat, "Smooth", 0.01, 1)
AddSlider("Combat", "FOV Size", Config.Combat, "FOV", 10, 800)
AddToggle("Visuals", "Boxes", Config.Visuals, "Boxes"); AddToggle("Visuals", "Chams", Config.Visuals, "Chams"); AddToggle("Visuals", "Nametags", Config.Visuals, "Names")
AddBind("Settings", "Aim Key", Config.Keys, "Aim"); AddBind("Settings", "Trigger Key", Config.Keys, "Trigger"); AddBind("Settings", "Menu Key", Config.Keys, "Menu")

-- 6. COMBAT & VISUAL LOGIC
local function IsVisible(part, char)
    if not Config.Combat.VisCheck then return true end
    return #camera:GetPartsObscuredByTarget({part.Position}, {player.Character, char}) == 0
end

local function GetTarget()
    local near, dist = nil, Config.Combat.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
            local root = p.Character:FindFirstChild(Config.Combat.TargetPart) or p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if onScreen and mag < dist and IsVisible(root, p.Character) then near = p.Character; dist = mag end
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
            local p = tar[Config.Combat.TargetPart].Position + (tar.HumanoidRootPart.Velocity * Config.Combat.Pred)
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, p), Config.Combat.Smooth)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("V7Highlight") or Instance.new("Highlight", p.Character)
            h.Name = "V7Highlight"; h.Enabled = Config.Visuals.Chams; h.FillColor = Config.Visuals.Color
            
            local box = p.Character:FindFirstChild("V7Box")
            if Config.Visuals.Boxes then
                if not box then
                    box = Instance.new("BillboardGui", p.Character); box.Name = "V7Box"; box.AlwaysOnTop = true; box.Size = UDim2.new(4,0,5.5,0); box.Adornee = p.Character.PrimaryPart
                    local f = Instance.new("Frame", box); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; Instance.new("UIStroke", f).Color = Config.Visuals.Color
                end
                box.Enabled = true
            elseif box then box.Enabled = false end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Config.Keys.Menu then Main.Visible = not Main.Visible end end)
Pages.Combat.Visible = true
print("Rivals V7 Fixed Loaded. Press INSERT.")


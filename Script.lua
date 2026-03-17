local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 0. FORCE CLEANUP
if player:WaitForChild("PlayerGui"):FindFirstChild("RivalsV8") then player.PlayerGui.RivalsV8:Destroy() end

-- 1. SETTINGS
local Config = {
    Combat = { Aim = false, Trigger = false, Smooth = 0.05, Pred = 0.15, FOV = 150, ShowFOV = true, VisCheck = true, TargetPart = "Head" },
    Visuals = { Boxes = false, Chams = false, Color = Color3.fromRGB(255, 0, 0) },
    Keys = { Menu = Enum.KeyCode.Insert, Aim = Enum.KeyCode.Q, Trigger = Enum.KeyCode.E }
}

-- 2. FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 100; FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Visible = Config.Combat.ShowFOV

-- 3. UI BASE
local Screen = Instance.new("ScreenGui", player.PlayerGui); Screen.Name = "RivalsV8"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 480, 0, 360); Main.Position = UDim2.new(0.5, -240, 0.5, -180); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 120, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -120, 1, 0); Container.Position = UDim2.new(0, 120, 0, 0); Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local f = Instance.new("ScrollingFrame", Container); f.Size = UDim2.new(1, -10, 1, -10); f.Position = UDim2.new(0, 5, 0, 5); f.Visible = false; f.BackgroundTransparency = 1; f.CanvasSize = UDim2.new(0,0,2.5,0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5); Pages[name] = f
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 40); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Position = UDim2.new(0,0,0,(#Sidebar:GetChildren()-1)*40)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end; f.Visible = true end)
end

-- 4. HELPERS
local function AddToggle(p, t, r, k)
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 32); b.Text = t .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() r[k] = not r[k]; b.Text = t .. ": " .. (r[k] and "ON" or "OFF"); b.BackgroundColor3 = r[k] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45) end)
end

local function AddDropdown(p, t, r, k, opts)
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 32); b.Text = t .. ": " .. r[k]; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
    local curr = 1
    b.MouseButton1Click:Connect(function() curr = curr >= #opts and 1 or curr + 1; r[k] = opts[curr]; b.Text = t .. ": " .. r[k] end)
end

NewPage("Combat"); NewPage("Visuals"); NewPage("Settings")
AddToggle("Combat", "Aimbot", Config.Combat, "Aim")
AddToggle("Combat", "Triggerbot", Config.Combat, "Trigger")
AddDropdown("Combat", "Target Part", Config.Combat, "TargetPart", {"Head", "HumanoidRootPart", "UpperTorso"}) -- NEW SELECTOR
AddToggle("Combat", "VisCheck", Config.Combat, "VisCheck")
AddToggle("Visuals", "Boxes", Config.Visuals, "Boxes")
AddToggle("Visuals", "Chams", Config.Visuals, "Chams")

-- 5. AIM & TRIGGER LOGIC
local function GetTarget()
    local near, dist = nil, Config.Combat.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild(Config.Combat.TargetPart) or p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local sPos, onScr = camera:WorldToViewportPoint(root.Position)
                local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(sPos.X, sPos.Y)).Magnitude
                if onScr and mag < dist then near = p.Character; dist = mag end
            end
        end
    end
    return near
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + 36); FOVCircle.Radius = Config.Combat.FOV; FOVCircle.Visible = Config.Combat.ShowFOV
    if Config.Combat.Aim and (UIS:IsKeyDown(Config.Keys.Aim) or UIS:IsMouseButtonPressed(Config.Keys.Aim)) then
        local t = GetTarget()
        if t then
            local part = t:FindFirstChild(Config.Combat.TargetPart) or t:FindFirstChild("HumanoidRootPart")
            local p = part.Position + (t.HumanoidRootPart.Velocity * Config.Combat.Pred)
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, p), Config.Combat.Smooth)
        end
    end
    if Config.Combat.Trigger and mouse.Target and mouse.Target.Parent:FindFirstChild("Humanoid") and mouse.Target.Parent ~= player.Character then
        if typeof(mouse1click) == "function" then mouse1click() end
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Config.Keys.Menu then Main.Visible = not Main.Visible end end)
Pages.Combat.Visible = true

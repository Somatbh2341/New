local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 0. CLEANUP
if player:WaitForChild("PlayerGui"):FindFirstChild("RivalsV7") then player.PlayerGui.RivalsV7:Destroy() end

-- 1. SETTINGS
local Config = {
    Combat = { Aim = false, Trigger = false, Smooth = 0.08, Pred = 0.15, FOV = 150, ShowFOV = true, VisCheck = true, Target = "Head" },
    Visuals = { Boxes = false, Chams = false, Names = false, Color = Color3.fromRGB(255, 0, 0) },
    Keys = { Menu = Enum.KeyCode.Insert, Aim = Enum.KeyCode.Q, Trigger = Enum.KeyCode.E }
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 100; FOVCircle.Filled = false; FOVCircle.Color = Color3.new(1,1,1)

-- 2. UI BASE
local Screen = Instance.new("ScreenGui", player.PlayerGui); Screen.Name = "RivalsV7"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 500, 0, 400); Main.Position = UDim2.new(0.5, -250, 0.5, -200); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 120, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -120, 1, 0); Container.Position = UDim2.new(0, 120, 0, 0); Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local f = Instance.new("ScrollingFrame", Container); f.Size = UDim2.new(1, -10, 1, -10); f.Position = UDim2.new(0, 5, 0, 5); f.Visible = false; f.BackgroundTransparency = 1; f.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5); Pages[name] = f
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 40); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Position = UDim2.new(0,0,0,(#Sidebar:GetChildren()-1)*40)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end; f.Visible = true end)
end

-- 3. INTERACTABLES
local function AddToggle(p, t, r, k)
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 30); b.Text = t .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() r[k] = not r[k]; b.Text = t .. ": " .. (r[k] and "ON" or "OFF"); b.BackgroundColor3 = r[k] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45) end)
end

local function AddBind(p, t, r, k)
    local b = Instance.new("TextButton", Pages[p]); b.Size = UDim2.new(0.95, 0, 0, 30); b.Text = t .. ": " .. r[k].Name; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() b.Text = "..."; local c; c = UIS.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.MouseButton2 then r[k] = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType; b.Text = t .. ": " .. r[k].Name; c:Disconnect() end end) end)
end

NewPage("Combat"); NewPage("Visuals"); NewPage("Settings")
AddToggle("Combat", "Aimbot", Config.Combat, "Aim")
AddToggle("Combat", "VisCheck (Walls)", Config.Combat, "VisCheck") -- NEW TOGGLE
AddToggle("Combat", "Triggerbot", Config.Combat, "Trigger")
AddToggle("Visuals", "Boxes", Config.Visuals, "Boxes")
AddToggle("Visuals", "Chams", Config.Visuals, "Chams")
AddBind("Settings", "Aim Key", Config.Keys, "Aim")
AddBind("Settings", "Trigger Key", Config.Keys, "Trigger")
AddBind("Settings", "Menu Key", Config.Keys, "Menu")

-- 4. VISIBILITY & TARGET LOGIC
local function IsVisible(part, char)
    if not Config.Combat.VisCheck then return true end -- If VisCheck is OFF, everything is "visible"
    local castPoints = {part.Position}
    local ignoreList = {player.Character, char}
    local obscured = camera:GetPartsObscuredByTarget(castPoints, ignoreList)
    return #obscured == 0
end

local function GetTarget()
    local near, dist = nil, Config.Combat.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local root = p.Character:FindFirstChild(Config.Combat.Target) or p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if onScreen and mag < dist then
                    if IsVisible(root, p.Character) then
                        near = p.Character; dist = mag
                    end
                end
            end
        end
    end
    return near
end

-- 5. MAIN LOOP
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.Combat.ShowFOV; FOVCircle.Radius = Config.Combat.FOV; FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    
    if Config.Combat.Aim and (UIS:IsKeyDown(Config.Keys.Aim) or UIS:IsMouseButtonPressed(Config.Keys.Aim)) then
        local targetChar = GetTarget()
        if targetChar then
            local aimPart = targetChar:FindFirstChild(Config.Combat.Target) or targetChar:FindFirstChild("HumanoidRootPart")
            local predictedPos = aimPart.Position + (targetChar.HumanoidRootPart.Velocity * Config.Combat.Pred)
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, predictedPos), Config.Combat.Smooth)
        end
    end

    if Config.Combat.Trigger then
        local t = mouse.Target
        if t and t.Parent:FindFirstChild("Humanoid") and t.Parent ~= player.Character then
            if IsVisible(t, t.Parent) and typeof(mouse1click) == "function" then mouse1click() end
        end
    end
end)

-- 6. ESP
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("RHighlight") or Instance.new("Highlight", p.Character)
            h.Name = "RHighlight"; h.Enabled = Config.Visuals.Chams; h.FillColor = Config.Visuals.Color
            
            local box = p.Character:FindFirstChild("RBox")
            if Config.Visuals.Boxes then
                if not box then
                    box = Instance.new("BillboardGui", p.Character); box.Name = "RBox"; box.AlwaysOnTop = true; box.Size = UDim2.new(4,0,5.5,0); box.Adornee = p.Character.PrimaryPart
                    local f = Instance.new("Frame", box); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; Instance.new("UIStroke", f).Color = Config.Visuals.Color
                end
                box.Enabled = true
            elseif box then box.Enabled = false end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Config.Keys.Menu then Main.Visible = not Main.Visible end end)
Pages.Combat.Visible = true
print("Rivals V7 Loaded. Press INSERT.")

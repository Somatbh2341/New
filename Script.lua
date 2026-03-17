local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 1. CONFIGURATION
local Config = {
    Combat = { Aimlock = false, Triggerbot = false, Smoothness = 0.1 },
    Visuals = { ESP = false },
    Keybinds = { MenuToggle = Enum.KeyCode.Insert, AimKey = Enum.KeyCode.Q }
}

-- 2. UI CONSTRUCTION
local Screen = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
Screen.Name = "RivalsPro"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -120, 1, 0)
Container.Position = UDim2.new(0, 120, 0, 0)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local f = Instance.new("ScrollingFrame", Container)
    f.Size = UDim2.new(1, -10, 1, -10)
    f.Position = UDim2.new(0, 5, 0, 5)
    f.Visible = false
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0,0,1.5,0)
    f.ScrollBarThickness = 2
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    Pages[name] = f
    
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Position = UDim2.new(0, 0, 0, (#Sidebar:GetChildren()-1) * 40)
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        f.Visible = true
    end)
end

-- 3. INTERACTIVE HELPERS (Toggles & Rebinding)
local function AddToggle(page, text, configRef, key)
    local btn = Instance.new("TextButton", Pages[page])
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text .. ": " .. (configRef[key] and "ON" or "OFF")
    btn.BackgroundColor3 = configRef[key] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
    btn.MouseButton1Click:Connect(function()
        configRef[key] = not configRef[key]
        btn.Text = text .. ": " .. (configRef[key] and "ON" or "OFF")
        btn.BackgroundColor3 = configRef[key] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
    end)
end

local function AddKeybind(page, action, configRef, key)
    local btn = Instance.new("TextButton", Pages[page])
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = action .. ": " .. configRef[key].Name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    btn.MouseButton1Click:Connect(function()
        btn.Text = "... Press Key/Mouse ..."
        local conn
        conn = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType.MouseButton1 or input.UserInputType.MouseButton2 then
                local newKey = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                configRef[key] = newKey
                btn.Text = action .. ": " .. newKey.Name
                conn:Disconnect()
            end
        end)
    end)
end

-- 4. SETUP PAGES
CreatePage("Combat")
CreatePage("Visuals")
CreatePage("Keybinds")

AddToggle("Combat", "Aimlock", Config.Combat, "Aimlock")
AddToggle("Combat", "Triggerbot", Config.Combat, "Triggerbot")
AddToggle("Visuals", "Player ESP", Config.Visuals, "ESP")
AddKeybind("Keybinds", "Menu Toggle", Config.Keybinds, "MenuToggle")
AddKeybind("Keybinds", "Aim Key", Config.Keybinds, "AimKey")

Pages.Combat.Visible = true

-- 5. COMBAT & VISUALS LOGIC
local function IsEnemy(char)
    if not char or not char:FindFirstChild("Humanoid") then return false end
    return char ~= player.Character and char.Humanoid.Health > 0
end

RunService.RenderStepped:Connect(function()
    -- Menu Toggle
    UIS.MouseIconEnabled = not Main.Visible
    
    -- Aimlock Logic
    if Config.Combat.Aimlock and UIS:IsKeyDown(Config.Keybinds.AimKey) or UIS:IsMouseButtonPressed(Config.Keybinds.AimKey) then
        local target = mouse.Target
        if target and IsEnemy(target.Parent) then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), Config.Combat.Smoothness)
        end
    end

    -- Triggerbot Logic (Simulates Click)
    if Config.Combat.Triggerbot then
        local target = mouse.Target
        if target and IsEnemy(target.Parent) then
            mouse1click() -- Note: This function depends on your specific executor (Xeno)
        end
    end
end)

-- 6. ESP LOGIC (Highlight System)
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = p.Character:FindFirstChild("MenuESP")
            if Config.Visuals.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "MenuESP"
                    highlight.FillColor = Color3.new(1, 0, 0)
                end
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Config.Keybinds.MenuToggle then Main.Visible = not Main.Visible end
end)

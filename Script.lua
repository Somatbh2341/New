local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- 0. CLEAR OLD UI (Prevents the "No Change" issue)
if player:WaitForChild("PlayerGui"):FindFirstChild("RivalsPro") then
    player.PlayerGui.RivalsPro:Destroy()
end

-- 1. SETTINGS
local Config = {
    Combat = { Aimlock = false, Trigger = false },
    Visuals = { ESP = false },
    Keys = { Menu = Enum.KeyCode.Insert, Aim = Enum.KeyCode.Q }
}

-- 2. CREATE NEW UI
local Screen = Instance.new("ScreenGui", player.PlayerGui)
Screen.Name = "RivalsPro"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Sidebar for TABS
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -120, 1, 0)
Container.Position = UDim2.new(0, 120, 0, 0)
Container.BackgroundTransparency = 1

local Pages = {}
local function NewPage(name)
    local f = Instance.new("ScrollingFrame", Container)
    f.Size = UDim2.new(1, -10, 1, -10)
    f.Position = UDim2.new(0, 5, 0, 5)
    f.Visible = false
    f.BackgroundTransparency = 1
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    Pages[name] = f
    
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Position = UDim2.new(0, 0, 0, (#Sidebar:GetChildren()-1)*40)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        f.Visible = true
    end)
end

-- 3. INTERACTABLE HELPERS
local function AddToggle(page, text, ref, key)
    local btn = Instance.new("TextButton", Pages[page])
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.MouseButton1Click:Connect(function()
        ref[key] = not ref[key]
        btn.Text = text .. ": " .. (ref[key] and "ON" or "OFF")
        btn.BackgroundColor3 = ref[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    end)
end

local function AddBind(page, text, ref, key)
    local btn = Instance.new("TextButton", Pages[page])
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text .. ": " .. ref[key].Name
    btn.MouseButton1Click:Connect(function()
        btn.Text = "... Press Key ..."
        local c; c = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.MouseButton2 then
                ref[key] = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType
                btn.Text = text .. ": " .. ref[key].Name
                c:Disconnect()
            end
        end)
    end)
end

-- 4. BUILD PAGES
NewPage("Combat")
NewPage("Visuals")
NewPage("Settings")

AddToggle("Combat", "Aimlock", Config.Combat, "Aimlock")
AddToggle("Combat", "Triggerbot", Config.Combat, "Trigger")
AddToggle("Visuals", "Player ESP", Config.Visuals, "ESP")
AddBind("Settings", "Menu Key", Config.Keys, "Menu")
AddBind("Settings", "Aim Key", Config.Keys, "Aim")

Pages.Combat.Visible = true

-- 5. ESP & COMBAT LOGIC
RunService.RenderStepped:Connect(function()
    -- Aimlock
    if Config.Combat.Aimlock and (UIS:IsKeyDown(Config.Keys.Aim) or UIS:IsMouseButtonPressed(Config.Keys.Aim)) then
        local t = mouse.Target
        if t and t.Parent:FindFirstChild("Humanoid") and t.Parent ~= player.Character then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, t.Position)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("ESPHighlight")
            if Config.Visuals.ESP then
                if not h then h = Instance.new("Highlight", p.Character); h.Name = "ESPHighlight" end
                h.Enabled = true
            elseif h then h.Enabled = false end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Config.Keys.Menu then Main.Visible = not Main.Visible end
end)

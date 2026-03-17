local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- 1. CENTRALIZED CONFIG
local Config = {
    Aim = { Enabled = true, Sticky = false, Smoothness = 0.1 },
    Visuals = { ESP = false, Boxes = false, Tracers = false },
    Keybinds = { ToggleUI = Enum.KeyCode.RightShift, Aim = Enum.KeyCode.Q }
}

-- 2. UI CORE
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 450, 0, 320)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- Tab Navigation
local navBar = Instance.new("Frame", mainFrame)
navBar.Size = UDim2.new(0, 100, 1, 0)
navBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local container = Instance.new("Frame", mainFrame)
container.Position = UDim2.new(0, 100, 0, 0)
container.Size = UDim2.new(1, -100, 1, 0)
container.BackgroundTransparency = 1

local pages = {
    Combat = Instance.new("ScrollingFrame", container),
    Visuals = Instance.new("ScrollingFrame", container),
}

for name, page in pairs(pages) do
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding =指导 = UDim.new(0, 5)
end
pages.Combat.Visible = true

-- 3. INTERACTIVE HELPERS (Toggles & Sliders)
local function CreateToggle(parent, text, configPath, key)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = configPath[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    btn.Text = text .. ": " .. (configPath[key] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)

    btn.MouseButton1Click:Connect(function()
        configPath[key] = not configPath[key]
        btn.Text = text .. ": " .. (configPath[key] and "ON" or "OFF")
        btn.BackgroundColor3 = configPath[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

-- 4. POPULATE TABS
-- Combat Tab
CreateToggle(pages.Combat, "Aim Assist", Config.Aim, "Enabled")
CreateToggle(pages.Combat, "Sticky Aim", Config.Aim, "Sticky")

-- Visuals Tab
CreateToggle(pages.Visuals, "Master ESP", Config.Visuals, "ESP")
CreateToggle(pages.Visuals, "Boxes", Config.Visuals, "Boxes")

-- Tab Switching Buttons
local function CreateTabBtn(name, pos)
    local b = Instance.new("TextButton", navBar)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Position = UDim2.new(0, 0, 0, pos)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
    end)
end
CreateTabBtn("Combat", 0)
CreateTabBtn("Visuals", 45)

-- 5. COMBAT & ESP LOGIC
RunService.RenderStepped:Connect(function()
    if not Config.Aim.Enabled then return end
    
    local target = mouse.Target
    if target and target.Parent:FindFirstChild("Humanoid") then
        local cam = workspace.CurrentCamera
        local targetPos = target.Position
        
        -- Sticky Aim logic: Reduces smoothness when hovering over target
        local smoothness = Config.Aim.Sticky and 0.02 or Config.Aim.Smoothness
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), smoothness)
    end
end)

-- Basic ESP Box logic (Placeholder - requires Highlight or BillboardGuis)
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local highlight = char:FindFirstChild("ESPHighlight")
            if Config.Visuals.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", char)
                    highlight.Name = "ESPHighlight"
                end
                highlight.Enabled = true
                highlight.FillTransparency = 0.5
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end
RunService.Heartbeat:Connect(UpdateESP)

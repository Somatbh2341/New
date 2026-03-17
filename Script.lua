local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- 1. CONFIG & SETTINGS
local Config = {
    Combat = { Aim = true, Sticky = false, Smooth = 0.1 },
    Visuals = { ESP = false, Boxes = false },
    Keybinds = { Toggle = Enum.KeyCode.RightShift, AimKey = Enum.KeyCode.Q }
}

-- 2. MAIN UI BASE
local Screen = Instance.new("ScreenGui", pGui)
Screen.Name = "RivalsMenu"

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.BorderSizePixel = 0

-- Sidebar for Tabs
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local PageContainer = Instance.new("Frame", Main)
PageContainer.Size = UDim2.new(1, -100, 1, 0)
PageContainer.Position = UDim2.new(0, 100, 0, 0)
PageContainer.BackgroundTransparency = 1

-- 3. TAB LOGIC
local Pages = {}
local function CreatePage(name)
    local f = Instance.new("ScrollingFrame", PageContainer)
    f.Size = UDim2.new(1, -10, 1, -10)
    f.Position = UDim2.new(0, 5, 0, 5)
    f.Visible = false
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0,0,2,0)
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 5)
    
    Pages[name] = f
    
    -- Sidebar Button
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Position = UDim2.new(0, 0, 0, (#Sidebar:GetChildren()-1) * 40)
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        f.Visible = true
    end)
end

-- 4. TOGGLE & SLIDER HELPERS
local function AddToggle(pageName, text, configRef, key)
    local btn = Instance.new("TextButton", Pages[pageName])
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Text = text .. ": " .. (configRef[key] and "ON" or "OFF")
    btn.BackgroundColor3 = configRef[key] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
    
    btn.MouseButton1Click:Connect(function()
        configRef[key] = not configRef[key]
        btn.Text = text .. ": " .. (configRef[key] and "ON" or "OFF")
        btn.BackgroundColor3 = configRef[key] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
    end)
end

-- 5. INITIALIZE CONTENT
CreatePage("Combat")
CreatePage("Visuals")
CreatePage("Settings")

AddToggle("Combat", "Aim Assist", Config.Combat, "Aim")
AddToggle("Combat", "Sticky Aim", Config.Combat, "Sticky")
AddToggle("Visuals", "Master ESP", Config.Visuals, "ESP")
AddToggle("Settings", "Toggle Key: RShift", Config.Keybinds, "Toggle")

Pages["Combat"].Visible = true -- Default page

-- 6. TOGGLE MENU
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.Keybinds.Toggle then
        Main.Visible = not Main.Visible
    end
end)

print("Menu Loaded Successfully!")

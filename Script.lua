local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. CONFIGURATION & STATE
local Config = {
    AimEnabled = true,
    TriggerEnabled = false,
    AimSmoothness = 0.1, -- Adjustable via slider
    Keybinds = {
        ToggleUI = Enum.KeyCode.RightShift,
        Aim = Enum.KeyCode.Q,
        Trigger = Enum.KeyCode.E
    }
}
local UIVisible = true

-- 2. CREATE UI HIERARCHY
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ModMenu"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.4, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0

-- Tab Bar
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- Pages Container
local pages = Instance.new("Frame", mainFrame)
pages.Size = UDim2.new(1, 0, 1, -30)
pages.Position = UDim2.new(0, 0, 0, 30)
pages.BackgroundTransparency = 1

local combatPage = Instance.new("ScrollingFrame", pages)
combatPage.Size = UDim2.new(1, -10, 1, -10)
combatPage.Position = UDim2.new(0, 5, 0, 5)
combatPage.Visible = true

local keybindPage = Instance.new("ScrollingFrame", pages)
keybindPage.Size = UDim2.new(1, -10, 1, -10)
keybindPage.Position = UDim2.new(0, 5, 0, 5)
keybindPage.Visible = false

-- 3. HELPER: CREATE SLIDER
local function CreateSlider(parent, text, min, max, default, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1

    local sliderBg = Instance.new("Frame", parent)
    sliderBg.Size = UDim2.new(0.9, 0, 0, 10)
    sliderBg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

    -- Basic slider click logic (Simple version)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * percent
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. string.format("%.2f", val)
            callback(val)
        end
    end)
end

-- 4. INITIALIZE CONTENT
CreateSlider(combatPage, "Aim Smoothness", 0.01, 1, 0.1, function(v) Config.AimSmoothness = v end)

local kbList = Instance.new("UIListLayout", keybindPage)
for action, key in pairs(Config.Keybinds) do
    local l = Instance.new("TextLabel", keybindPage)
    l.Size = UDim2.new(1, 0, 0, 30)
    l.Text = action .. ": " .. tostring(key.Name)
    l.TextColor3 = Color3.new(1, 1, 1)
    l.BackgroundTransparency = 0.9
end

-- 5. TAB SWITCHING LOGIC
local function showTab(name)
    combatPage.Visible = (name == "Combat")
    keybindPage.Visible = (name == "Keybinds")
end

local btn1 = Instance.new("TextButton", tabBar)
btn1.Size = UDim2.new(0.5, 0, 1, 0)
btn1.Text = "Combat"
btn1.MouseButton1Click:Connect(function() showTab("Combat") end)

local btn2 = Instance.new("TextButton", tabBar)
btn2.Position = UDim2.new(0.5, 0, 0, 0)
btn2.Size = UDim2.new(0.5, 0, 1, 0)
btn2.Text = "Keybinds"
btn2.MouseButton1Click:Connect(function() showTab("Keybinds") end)

-- 6. CORE LOGIC (Keybinds & Combat)
UIS.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Config.Keybinds.ToggleUI then
        UIVisible = not UIVisible
        mainFrame.Visible = UIVisible
    end
end)

RunService.RenderStepped:Connect(function()
    local mouse = player:GetMouse()
    local target = mouse.Target
    if Config.AimEnabled and target and target.Parent:FindFirstChild("Humanoid") then
        local cam = workspace.CurrentCamera
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), Config.AimSmoothness)
    end
end)

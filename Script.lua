local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- 1. CONFIG & SAVE SYSTEM
local Config = {
    AimEnabled = true,
    TriggerEnabled = false,
    AimSmoothness = 0.1,
    Keybinds = {
        ToggleUI = Enum.KeyCode.RightShift,
        Aim = Enum.KeyCode.Q,
        Trigger = Enum.KeyCode.E
    }
}

local function SaveSettings()
    -- Note: In most executors, you use writefile(). In Studio, we print it.
    local encoded = HttpService:JSONEncode(Config)
    print("Settings Saved:", encoded)
    -- If using an executor: writefile("MySettings.json", encoded)
end

-- 2. UI INITIALIZATION
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Visible = true

-- CUSTOM CURSOR (A small dot that follows your mouse when menu is open)
local customCursor = Instance.new("Frame", screenGui)
customCursor.Size = UDim2.new(0, 10, 0, 10)
customCursor.BackgroundColor3 = Color3.new(1, 0, 0)
customCursor.BorderSizePixel = 0
customCursor.ZIndex = 10

-- 3. INTERACTIVE KEYBIND HELPER
local function CreateKeybind(parent, action)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = action .. ": " .. Config.Keybinds[action].Name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "Press any key..."
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Config.Keybinds[action] = input.KeyCode
                btn.Text = action .. ": " .. input.KeyCode.Name
                connection:Disconnect()
                SaveSettings()
            end
        end)
    end)
end

-- 4. INTERACTIVE SLIDER HELPER
local function CreateSlider(parent, text, min, max, start, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. start
    label.TextColor3 = Color3.new(1, 1, 1)

    local sliderBar = Instance.new("TextButton", frame)
    sliderBar.Size = UDim2.new(1, 0, 0, 10)
    sliderBar.Position = UDim2.new(0, 0, 0.6, 0)
    sliderBar.Text = ""
    sliderBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

    sliderBar.MouseButton1Down:Connect(function()
        local moveConn
        moveConn = RunService.RenderStepped:Connect(function()
            local percent = math.clamp((mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * percent) * 100) / 100
            label.Text = text .. ": " .. val
            callback(val)
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                moveConn:Disconnect()
                SaveSettings()
            end
        end)
    end)
end

-- 5. TAB SYSTEM SETUP
local nav = Instance.new("Frame", mainFrame)
nav.Size = UDim2.new(1, 0, 0, 40)
nav.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local content = Instance.new("ScrollingFrame", mainFrame)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.CanvasSize = UDim2.new(0, 0, 2, 0)

-- Fill Content
CreateSlider(content, "Aim Smoothness", 0.01, 1, Config.AimSmoothness, function(v) Config.AimSmoothness = v end)
CreateKeybind(content, "Aim")
CreateKeybind(content, "Trigger")
CreateKeybind(content, "ToggleUI")

-- 6. MENU TOGGLE & CURSOR LOGIC
UIS.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Config.Keybinds.ToggleUI then
        mainFrame.Visible = not mainFrame.Visible
        customCursor.Visible = mainFrame.Visible
        UIS.MouseIconEnabled = not mainFrame.Visible -- Hide real mouse when UI is up
    end
end)

RunService.RenderStepped:Connect(function()
    if mainFrame.Visible then
        customCursor.Position = UDim2.new(0, mouse.X - 5, 0, mouse.Y - 5)
    end
end)

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. CREATE THE UI PROPERLY
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyMenu"
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 100)
panel.Position = UDim2.new(0.5, -100, 0.5, -50)
panel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
panel.Visible = true
panel.Parent = screenGui

local keyLabel = Instance.new("TextLabel", panel)
keyLabel.Size = UDim2.new(1, 0, 0, 20)
keyLabel.Position = UDim2.new(0, 0, 1, -20)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "UI: RShift | Aim: Q | Trigger: E"
keyLabel.TextColor3 = Color3.new(1, 1, 1)
keyLabel.TextScaled = true

-- KEYBINDS
local Keybinds = {
    ToggleUI = Enum.KeyCode.RightShift,
    AimToggle = Enum.KeyCode.Q,
    TriggerToggle = Enum.KeyCode.E
}

local UIVisible = true
local AimEnabled = true
local TriggerEnabled = false

-- TOGGLE HANDLER
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Keybinds.ToggleUI then
        UIVisible = not UIVisible
        panel.Visible = UIVisible
    end

    if input.KeyCode == Keybinds.AimToggle then
        AimEnabled = not AimEnabled
        print("Aim Assist:", AimEnabled)
    end

    if input.KeyCode == Keybinds.TriggerToggle then
        TriggerEnabled = not TriggerEnabled
        print("Trigger:", TriggerEnabled)
    end
end)

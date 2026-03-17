local UIS = game:GetService("UserInputService")

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
if AimEnabled and currentTarget then
    ApplyAssist(currentTarget.part.Position)
end
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

function IsEnemy(target)
    return target and target.Parent ~= player.Character
end

RunService.RenderStepped:Connect(function()
    if not TriggerEnabled then return end

    local target = mouse.Target

    if target and IsEnemy(target) then
        -- fire your weapon
        FireEvent:FireServer(
            workspace.CurrentCamera.CFrame.Position,
            workspace.CurrentCamera.CFrame.LookVector
        )
    end
end)
local keyLabel = Instance.new("TextLabel", panel)
keyLabel.Size = UDim2.new(1,0,0,20)
keyLabel.Position = UDim2.new(0,0,1,-20)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "UI: RShift | Aim: Q | Trigger: E"
keyLabel.TextScaled = true
keyLabel.TextColor3 = Config.Theme.Text
print(input.KeyCode)

local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local aimKey = Enum.KeyCode.E -- Default Key
local toggled = false

-- Create simple UI
local sg = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 150, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 0, 40)
toggleBtn.Text = "AIMBOT: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

local bindBtn = Instance.new("TextButton", frame)
bindBtn.Position = UDim2.new(0, 0, 0, 40)
bindBtn.Size = UDim2.new(1, 0, 0, 40)
bindBtn.Text = "BIND: E"

-- Keybind Customization
bindBtn.MouseButton1Click:Connect(function()
    bindBtn.Text = "PRESS ANY KEY..."
    local input = UIS.InputBegan:Wait()
    if input.UserInputType == Enum.UserInputType.Keyboard then
        aimKey = input.KeyCode
        bindBtn.Text = "BIND: " .. aimKey.Name
    end
end)

-- Aimbot Logic (Visual Snap)
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == aimKey then
        toggled = not toggled
        toggleBtn.Text = toggled and "AIMBOT: ON" or "AIMBOT: OFF"
        toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if toggled then
        local target = nil
        local dist = 500 -- Max range
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local mag = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if mag < dist then target = p.Character.Head dist = mag end
            end
        end
        if target then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position) end
    end
end)


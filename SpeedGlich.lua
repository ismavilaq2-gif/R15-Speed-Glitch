local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Enabled = false
local AirSpeed = 300
local NormalSpeed = 16

local Humanoid
local StateConnection
local JumpConnection
local InputConnection

local function Cleanup()
    if StateConnection then
        StateConnection:Disconnect()
        StateConnection = nil
    end

    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end

    if Humanoid then
        Humanoid.WalkSpeed = NormalSpeed
    end
end

local function Setup(Character)
    Humanoid = Character:WaitForChild("Humanoid")

    if Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        return
    end

    NormalSpeed = Humanoid.WalkSpeed

    StateConnection = Humanoid.StateChanged:Connect(function(_, State)
        if not Enabled then return end

        if State == Enum.HumanoidStateType.Jumping
        or State == Enum.HumanoidStateType.Freefall then
            Humanoid.WalkSpeed = AirSpeed

        elseif State == Enum.HumanoidStateType.Landed
        or State == Enum.HumanoidStateType.Running then
            Humanoid.WalkSpeed = NormalSpeed
        end
    end)

    JumpConnection = UIS.JumpRequest:Connect(function()
        if not Enabled or not Humanoid then return end

        local State = Humanoid:GetState()

        if State == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end)
end

local function Toggle()
    Enabled = not Enabled

    if Enabled then
        if Player.Character then
            Setup(Player.Character)
        end
    else
        Cleanup()
    end
end

InputConnection = UIS.InputBegan:Connect(function(Input, Processed)
    if Processed then return end

    if Input.KeyCode == Enum.KeyCode.E then
        Toggle()
    end
end)

Player.CharacterAdded:Connect(function(Character)
    if Enabled then
        Cleanup()
        Setup(Character)
    end
end)

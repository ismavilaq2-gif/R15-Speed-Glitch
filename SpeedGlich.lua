local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Enabled = false
local AirSpeed = 300
local NormalSpeed = 16
local SpaceHeld = false

local Humanoid
local StateConnection
local CharacterConnection

local function Cleanup()
    if StateConnection then
        StateConnection:Disconnect()
        StateConnection = nil
    end

    if Humanoid then
        Humanoid.WalkSpeed = NormalSpeed
    end
end

local function Setup(Character)
    Cleanup()

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

UIS.InputBegan:Connect(function(Input, Processed)
    if Input.KeyCode == Enum.KeyCode.E and not Processed then
        Toggle()
    end

    if Input.KeyCode == Enum.KeyCode.Space then
        if SpaceHeld then return end
        SpaceHeld = true

        if not Enabled or not Humanoid then return end

        if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

UIS.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Space then
        SpaceHeld = false
    end
end)

CharacterConnection = Player.CharacterAdded:Connect(function(Character)
    if Enabled then
        Setup(Character)
    end
end)

print("R15 Speed System Loaded")

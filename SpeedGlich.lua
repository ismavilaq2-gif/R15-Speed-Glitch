local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- CONFIGURACIÓN
local Enabled = false
local AirSpeed = 300

-- VARIABLES
local Humanoid
local RootPart
local NormalSpeed = 16
local SpaceHeld = false
local StateConnection

-- LIMPIAR PERSONAJE ANTERIOR
local function Cleanup()
    if StateConnection then
        StateConnection:Disconnect()
        StateConnection = nil
    end

    if Humanoid then
        Humanoid.WalkSpeed = NormalSpeed
    end
end

-- CONFIGURAR PERSONAJE
local function Setup(Character)
    Cleanup()

    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")

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

-- ACTIVAR / DESACTIVAR
local function Toggle()
    Enabled = not Enabled

    if Enabled then
        if Player.Character then
            Setup(Player.Character)
        end
        print("Sistema ACTIVADO")
    else
        Cleanup()
        print("Sistema DESACTIVADO")
    end
end

-- CONTROL DE TECLAS
UIS.InputBegan:Connect(function(Input, Processed)

    if Input.KeyCode == Enum.KeyCode.E and not Processed then
        Toggle()
        return
    end

    if Input.KeyCode == Enum.KeyCode.Space then

        -- Evita saltos repetidos al mantener pulsado
        if SpaceHeld then return end
        SpaceHeld = true

        if not Enabled or not Humanoid or not RootPart then
            return
        end

        -- Permite saltar nuevamente mientras está en el aire
        if Humanoid.FloorMaterial == Enum.Material.Air then

            local JumpVelocity

            if Humanoid.UseJumpPower then
                JumpVelocity = Humanoid.JumpPower
            else
                JumpVelocity = math.sqrt(
                    2 * workspace.Gravity * Humanoid.JumpHeight
                )
            end

            local Velocity = RootPart.AssemblyLinearVelocity

            RootPart.AssemblyLinearVelocity = Vector3.new(
                Velocity.X,
                JumpVelocity,
                Velocity.Z
            )
        end
    end
end)

UIS.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Space then
        SpaceHeld = false
    end
end)

-- DETECTAR RESPAWN
Player.CharacterAdded:Connect(function(Character)
    SpaceHeld = false

    if Enabled then
        Setup(Character)
    end
end)

print("R15 Speed System Loaded")
print("Pulsa E para activar o desactivar")

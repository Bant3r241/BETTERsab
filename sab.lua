if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Tabs
    local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local EspTab = Window:MakeTab({Name="ESP", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- Parse "$3.5M/s" to number
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)")
        if not num then return nil end
        num = tonumber(num)
        if not num then return nil end
        local multipliers = {
            K = 1e3,
            M = 1e6,
            B = 1e9,
            T = 1e12
        }
        return num * (multipliers[suffix] or 1)
    end

    -- Find Best Brainrot and return info + the Decoration part for ESP
    local function findBestBrainrot()
        local best = {
            name = "Unknown",
            raw = "N/A",
            value = 0,
            decorationPart = nil,
            generationText = nil
        }

        local plotsFolder = workspace:FindFirstChild("Plots")
        if plotsFolder then
            for _, plot in pairs(plotsFolder:GetChildren()) do
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, podium in pairs(podiums:GetChildren()) do
                        local base = podium:FindFirstChild("Base")
                        if base and base:FindFirstChild("Spawn") then
                            local attach = base.Spawn:FindFirstChild("Attachment")
                            if attach and attach:FindFirstChild("AnimalOverhead") then
                                local animalOverhead = attach.AnimalOverhead
                                local nameLabel
                                for _, child in pairs(animalOverhead:GetChildren()) do
                                    if child:IsA("TextLabel") and child.Name == "DisplayName" then
                                        nameLabel = child
                                    end
                                end
                                local gen = animalOverhead:FindFirstChild("Generation")
                                if gen and gen:IsA("TextLabel") then
                                    local text = gen.Text
                                    if text and text:find("/s") then
                                        local value = parseMoneyPerSec(text)
                                        if value and value > best.value then
                                            best.value = value
                                            best.raw = text
                                            best.generationText = text
                                            if nameLabel then
                                                best.name = nameLabel.Text
                                            end
                                            -- Get Decorations part for ESP (if exists)
                                            local decorations = base:FindFirstChild("Decorations")
                                            if decorations then
                                                local part = decorations:FindFirstChild("Part")
                                                best.decorationPart = part
                                            else
                                                best.decorationPart = nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        return best
    end

    -- Current ESP reference for toggling off
    local currentBrainrotESP = nil

    -- PartESP module (with rainbow name and no "Decorations" suffix)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local PartESP = {}

    function PartESP.AddESP(ObjectName, Object, TextSize, SpeedText)
        local Drawing = Drawing

        local PartTable = {
            Name = Object.Name,
            OldPath = Object:GetFullName(),
            ESP = Drawing.new("Text"),
            GlowName = {},
            GlowSpeed = {},
            GlowDistance = {},
            Connections = {},
            RainbowHue = 0,
        }

        local offsets = {
            Vector2.new(-1, 0), Vector2.new(1, 0), Vector2.new(0, -1), Vector2.new(0, 1),
            Vector2.new(-1, -1), Vector2.new(-1, 1), Vector2.new(1, -1), Vector2.new(1, 1),
        }

        local function createGlowText(color)
            local texts = {}
            for _, offset in ipairs(offsets) do
                local glowText = Drawing.new("Text")
                glowText.Center = true
                glowText.Size = TextSize or 24
                glowText.Color = color
                glowText.Outline = false
                glowText.Transparency = 0.5
                glowText.Font = Drawing.Fonts.UI
                table.insert(texts, {Text = glowText, Offset = offset})
            end
            return texts
        end

        PartTable.GlowName = createGlowText(Color3.fromRGB(255, 0, 0))      -- will override color with rainbow
        PartTable.GlowSpeed = createGlowText(Color3.fromRGB(57, 255, 20))
        PartTable.GlowDistance = createGlowText(Color3.fromRGB(255, 0, 0))

        SpeedText = SpeedText or "N/A"

        PartTable.Connections.ESP = RunService.RenderStepped:Connect(function()
            if PartTable.RainbowHue >= 1 then
                PartTable.RainbowHue = 0
            else
                PartTable.RainbowHue = PartTable.RainbowHue + 0.005
            end

            local rainbowColor = Color3.fromHSV(PartTable.RainbowHue, 1, 1)

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local Vector, OnScreen = Camera:WorldToViewportPoint(Object.Position)
                if OnScreen then
                    for _, glow in pairs(PartTable.GlowName) do glow.Text.Visible = true end
                    for _, glow in pairs(PartTable.GlowSpeed) do glow.Text.Visible = true end
                    for _, glow in pairs(PartTable.GlowDistance) do glow.Text.Visible = true end

                    local basePos = Vector2.new(Vector.X, Vector.Y - 40)

                    PartTable.ESP.Visible = false

                    local NameText = ObjectName
                    local DistanceText = "["..tostring(math.floor((Object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)).."]"

                    -- Rainbow name glow
                    for _, glow in pairs(PartTable.GlowName) do
                        glow.Text.Position = basePos + glow.Offset
                        glow.Text.Text = NameText
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = rainbowColor
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end

                    -- Speed glow (green)
                    local speedPos = basePos + Vector2.new(0, TextSize or 24)
                    for _, glow in pairs(PartTable.GlowSpeed) do
                        glow.Text.Position = speedPos + glow.Offset
                        glow.Text.Text = SpeedText
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = Color3.fromRGB(57, 255, 20)
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end

                    -- Distance glow (red)
                    local distPos = speedPos + Vector2.new(0, TextSize or 24)
                    for _, glow in pairs(PartTable.GlowDistance) do
                        glow.Text.Position = distPos + glow.Offset
                        glow.Text.Text = DistanceText
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = Color3.fromRGB(255, 0, 0)
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end
                else
                    for _, glow in pairs(PartTable.GlowName) do glow.Text.Visible = false end
                    for _, glow in pairs(PartTable.GlowSpeed) do glow.Text.Visible = false end
                    for _, glow in pairs(PartTable.GlowDistance) do glow.Text.Visible = false end
                    PartTable.ESP.Visible = false
                end
            else
                for _, glow in pairs(PartTable.GlowName) do glow.Text.Visible = false end
                for _, glow in pairs(PartTable.GlowSpeed) do glow.Text.Visible = false end
                for _, glow in pairs(PartTable.GlowDistance) do glow.Text.Visible = false end
                PartTable.ESP.Visible = false
            end

            if not Object or Object:GetFullName() ~= PartTable.OldPath then
                PartTable.Connections.ESP:Disconnect()
                PartTable.ESP:Remove()
                for _, glow in pairs

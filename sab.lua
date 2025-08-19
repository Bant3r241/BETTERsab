if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({
        Name = "ABI │ Steal A Brainrot",
        HidePremium = false,
        IntroEnabled = false,
        IntroText = "ABI",
        SaveConfig = true,
        ConfigFolder = "XlurConfig"
    })

    -- Tabs
    local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4299432428", PremiumOnly = false})
    local EspTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4299432428", PremiumOnly = false})
    local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4299432428", PremiumOnly = false})

    -- Utility: Parse money string like "$3.5M/s"
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)")
        if not num then return nil end
        num = tonumber(num)
        if not num then return nil end
        local multipliers = { K = 1e3, M = 1e6, B = 1e9, T = 1e12 }
        return num * (multipliers[suffix] or 1)
    end

    -- Find the best brainrot plot info
    local function findBestBrainrot()
        local best = {
            name = "Unknown",
            raw = "N/A",
            value = 0,
            generationText = "N/A",
            decorationPart = nil
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
                                            -- Get Decorations > Part path for ESP
                                            local decorations = base:FindFirstChild("Decorations")
                                            if decorations then
                                                local part = decorations:FindFirstChild("Part")
                                                if part then
                                                    best.decorationPart = part
                                                else
                                                    best.decorationPart = nil
                                                end
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

    -- Notification button in MainTab
    MainTab:AddButton({
        Name = "Show Best Brainrot",
        Callback = function()
            local bestBrainrot = findBestBrainrot()
            print("Best Brainrot:", bestBrainrot.name, bestBrainrot.raw)
            OrionLib:MakeNotification({
                Name = "Best Brainrot",
                Content = bestBrainrot.name .. " is earning " .. bestBrainrot.raw,
                Time = 5
            })
        end
    })

    -- Player ESP toggle (unchanged)
    EspTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = function(v)
            if v then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/chams/refs/heads/main/ESP.lua"))()
            end
        end
    })

    -- Rainbow function for cycling colors
    local function getRainbowColor(t)
        local frequency = 2
        local r = math.floor(math.sin(frequency * t + 0) * 127 + 128)
        local g = math.floor(math.sin(frequency * t + 2) * 127 + 128)
        local b = math.floor(math.sin(frequency * t + 4) * 127 + 128)
        return Color3.fromRGB(r, g, b)
    end

    -- PartESP module adapted for brainrot ESP
    local PartESP = {}

    local select, next, tostring, pcall, getgenv, mathfloor, mathabs, stringgsub, stringmatch, wait, task_wait = 
        select, next, tostring, pcall, getgenv, math.floor, math.abs, string.gsub, string.match, wait, task.wait
    local Vector2new, Vector3new, Vector3zero, CFramenew, Drawingnew, WorldToViewportPoint, Color3fromRGB = 
        Vector2.new, Vector3.new, Vector3.zero, CFrame.new, Drawing.new, nil, Color3.fromRGB

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    WorldToViewportPoint = function(...)
        return Camera.WorldToViewportPoint(Camera, ...)
    end

    function PartESP.AddESP(ObjectName, Object, TextSize, speedText)
        local PartTable = {
            Name = Object.Name,
            OldPath = Object:GetFullName(),
            ESP = Drawingnew("Text"),
            GlowName = {},
            GlowSpeed = {},
            GlowDistance = {},
            Connections = {}
        }

        local offsets = {
            Vector2new(-1, 0), Vector2new(1, 0), Vector2new(0, -1), Vector2new(0, 1),
            Vector2new(-1, -1), Vector2new(-1, 1), Vector2new(1, -1), Vector2new(1, 1)
        }

        local function createGlowText(color)
            local texts = {}
            for _, offset in ipairs(offsets) do
                local glowText = Drawingnew("Text")
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

        PartTable.GlowName = createGlowText(Color3.fromRGB(255, 0, 0))       -- Neon Red, but we will override color per frame for rainbow
        PartTable.GlowSpeed = createGlowText(Color3.fromRGB(57, 255, 20))    -- Neon Green
        PartTable.GlowDistance = createGlowText(Color3.fromRGB(255, 0, 0))   -- Neon Red

        PartTable.Connections.ESP = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Object and Object.Parent do
                local Vector, OnScreen = WorldToViewportPoint(Object.Position)
                if OnScreen then
                    PartTable.ESP.Visible = true
                    for _, glow in pairs(PartTable.GlowName) do glow.Text.Visible = true end
                    for _, glow in pairs(PartTable.GlowSpeed) do glow.Text.Visible = true end
                    for _, glow in pairs(PartTable.GlowDistance) do glow.Text.Visible = true end

                    local basePos = Vector2new(Vector.X, Vector.Y - 40)

                    PartTable.ESP.Visible = false -- main ESP text hidden (dummy)

                    -- Rainbow color for brainrot name
                    local rainbowColor = getRainbowColor(tick())

                    -- Name text glow update (with rainbow)
                    for _, glow in pairs(PartTable.GlowName) do
                        glow.Text.Position = basePos + glow.Offset
                        glow.Text.Text = ObjectName
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = rainbowColor
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end

                    -- Speed text (generation from best brainrot)
                    local speedPos = basePos + Vector2new(0, TextSize or 24)
                    for _, glow in pairs(PartTable.GlowSpeed) do
                        glow.Text.Position = speedPos + glow.Offset
                        glow.Text.Text = speedText or "N/A"
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = Color3.fromRGB(57, 255, 20)
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end

                    -- Distance text (distance from player)
                    local distPos = speedPos + Vector2new(0, TextSize or 24)
                    local distValue = mathfloor((Object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    for _, glow in pairs(PartTable.GlowDistance) do
                        glow.Text.Position = distPos + glow.Offset
                        glow.Text.Text = "[" .. tostring(distValue) .. "]"
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
                if PartTable.Connections.ESP then
                    PartTable.Connections.ESP:Disconnect()
                    PartTable.Connections.ESP = nil
                end
                if PartTable.ESP then
                    PartTable.ESP.Visible = false
                    PartTable.ESP:Remove()
                    PartTable.ESP = nil
                end
                for _, glow in pairs(PartTable.GlowName or {}) do
                    glow.Text.Visible = false
                    glow.Text:Remove()
                end
                for _, glow in pairs(PartTable.GlowSpeed or {}) do
                    glow.Text.Visible = false
                    glow.Text:Remove()
                end
                for _, glow in pairs(PartTable.GlowDistance or {}) do
                    glow.Text.Visible = false
                    glow.Text:Remove()
                end
            end
        end)

        return PartTable
    end

    -- Store current brainrot ESP table for cleanup
    local currentBrainrotESP = nil

    -- Brainrot ESP toggle
    EspTab:AddToggle({
        Name = "Brainrot ESP",
        Default = false,
        Callback = function(enabled)
            if enabled then
                local bestBrainrot = findBestBrainrot()
                if bestBrainrot.decorationPart then
                    -- Cleanup existing ESP if any
                    if currentBrainrotESP then
                        for _, glow in pairs(currentBrainrotESP.GlowName or {}) do
                            glow.Text.Visible = false
                            glow.Text:Remove()
                        end
                        for _, glow in pairs(currentBrainrotESP.GlowSpeed or {}) do
                            glow.Text.Visible = false
                            glow.Text:Remove()
                        end
                        for _, glow in pairs(currentBrainrotESP.GlowDistance or {}) do
                            glow.Text.Visible = false
                            glow.Text:Remove()
                        end
                        if currentBrainrotESP.ESP then
                            currentBrainrotESP.ESP.Visible = false
                            currentBrainrotESP.ESP:Remove()
                        end
                        if currentBrainrotESP.Connections and currentBrainrotESP.Connections.ESP then
                            currentBrainrotESP.Connections.ESP:Disconnect()
                        end
                        currentBrainrotESP = nil
                    end
                    currentBrainrotESP = PartESP.AddESP(bestBrainrot.name, bestBrainrot.decorationPart, 24, bestBrainrot.generationText or "N/A")
                    print("Brainrot ESP enabled for", bestBrainrot.name)
                else
                    print("No decoration part found for best brainrot")
                end
            else
                if currentBrainrotESP then
                    for _, glow in pairs(currentBrainrotESP.GlowName or {}) do
                        glow.Text.Visible = false
                        glow.Text:Remove()
                    end
                    for _, glow in pairs(currentBrainrotESP.GlowSpeed or {}) do
                        glow.Text.Visible = false
                        glow.Text:Remove()
                    end
                    for _, glow in pairs(currentBrainrotESP.GlowDistance or {}) do
                        glow.Text.Visible = false
                        glow.Text:Remove()
                    end
                    if currentBrainrotESP.ESP then
                        currentBrainrotESP.ESP.Visible = false
                        currentBrainrotESP.ESP:Remove()
                    end
                    if currentBrainrotESP.Connections and currentBrainrotESP.Connections.ESP then
                        currentBrainrotESP.Connections.ESP:Disconnect()
                    end
                    currentBrainrotESP = nil
                    print("Brainrot ESP disabled")
                end
            end
        end
    })

    -- Initialize Orion UI
    OrionLib:Init()
end

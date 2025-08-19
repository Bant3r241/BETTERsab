if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Tabs
    local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local EspTab = Window:MakeTab({Name="ESP", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- More compact ESP toggle
    EspTab:AddToggle({
        Name="Player ESP",
        Default=false,
        Callback=function(v)
            if v then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/chams/refs/heads/main/ESP.lua"))()
            end
        end
    })

    -- Function to parse strings like "$3.5M/s" to number
    local function parseMoneyPerSec(text)
        local num, suffix = text:match("%$([%d%.]+)([KMBT]?)")
        if not num then return nil end
        num = tonumber(num)
        if not num then return nil end
        local multipliers = {K=1e3, M=1e6, B=1e9, T=1e12}
        return num * (multipliers[suffix] or 1)
    end

    -- Find best brainrot plot info, including decorations part
    local function findBestBrainrot()
        local best = {name = "Unknown", raw = "N/A", value = 0, podium = nil, decorationPart = nil}

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
                                            if nameLabel then
                                                best.name = nameLabel.Text
                                            end
                                            best.podium = podium

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

    -- PartESP Module with neon glow text ESP for decorations
    local PartESP = {}

    local select, next, tonumber, pcall, mathfloor, taskwait =
        select, next, tonumber, pcall, math.floor, task.wait
    local Vector2new, Vector3zero, Drawingnew =
        Vector2.new, Vector3.new, Drawing.new

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local function WorldToViewportPoint(...)
        return Camera:WorldToViewportPoint(...)
    end

    function PartESP.AddESP(ObjectName, Object, TextSize)
        local PartTable = {
            Name = Object.Name,
            OldPath = Object:GetFullName(),
            ESP = Drawingnew("Text"),
            GlowTexts = {},
            Connections = {}
        }

        local offsets = {
            Vector2new(-1, 0), Vector2new(1, 0), Vector2new(0, -1), Vector2new(0, 1),
            Vector2new(-1, -1), Vector2new(-1, 1), Vector2new(1, -1), Vector2new(1, 1),
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

        local glowName = createGlowText(Color3.fromRGB(255, 0, 0))
        local glowSpeed = createGlowText(Color3.fromRGB(57, 255, 20))
        local glowDistance = createGlowText(Color3.fromRGB(255, 0, 0))

        PartTable.GlowTexts = {glowName = glowName, glowSpeed = glowSpeed, glowDistance = glowDistance}

        PartTable.Connections.ESP = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local Vector, OnScreen = WorldToViewportPoint(Object.Position)
                if OnScreen then
                    PartTable.ESP.Visible = true
                    for _, glow in pairs(glowName) do glow.Text.Visible = true end
                    for _, glow in pairs(glowSpeed) do glow.Text.Visible = true end
                    for _, glow in pairs(glowDistance) do glow.Text.Visible = true end

                    local basePos = Vector2new(Vector.X, Vector.Y - 40)

                    PartTable.ESP.Visible = false

                    local NameText = ObjectName
                    local SpeedText = "425k/s"
                    local DistanceText = "["..tostring(mathfloor((Object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)).."]"

                    for _, glow in pairs(glowName) do
                        glow.Text.Position = basePos + glow.Offset
                        glow.Text.Text = NameText
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = Color3.fromRGB(255, 0, 0)
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end

                    local speedPos = basePos + Vector2new(0, TextSize or 24)
                    for _, glow in pairs(glowSpeed) do
                        glow.Text.Position = speedPos + glow.Offset
                        glow.Text.Text = SpeedText
                        glow.Text.Size = TextSize or 24
                        glow.Text.Color = Color3.fromRGB(57, 255, 20)
                        glow.Text.Transparency = 0.7
                        glow.Text.Outline = false
                        glow.Text.Font = Drawing.Fonts.UI
                        glow.Text.Center = true
                    end

                    local distPos = speedPos + Vector2new(0, TextSize or 24)
                    for _, glow in pairs(glowDistance) do
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
                    for _, glow in pairs(glowName) do glow.Text.Visible = false end
                    for _, glow in pairs(glowSpeed) do glow.Text.Visible = false end
                    for _, glow in pairs(glowDistance) do glow.Text.Visible = false end
                    PartTable.ESP.Visible = false
                end
            else
                for _, glow in pairs(glowName) do glow.Text.Visible = false end
                for _, glow in pairs(glowSpeed) do glow.Text.Visible = false end
                for _, glow in pairs(glowDistance) do glow.Text.Visible = false end
                PartTable.ESP.Visible = false
            end

            if Object:GetFullName() ~= PartTable.OldPath or not Object then
                PartTable.Connections.ESP:Disconnect()
                PartTable.ESP:Remove()
                for _, glow in pairs(glowName) do glow.Text:Remove() end
                for _, glow in pairs(glowSpeed) do glow.Text:Remove() end
                for _, glow in pairs(glowDistance) do glow.Text:Remove() end
            end
        end)

        return PartTable
    end

    -- Track current ESP instance for cleanup
    local currentBrainrotESP = nil

    -- Add button on MainTab to show best brainrot info
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

    -- Add toggle on ESP tab for Brainrot Decorations ESP with proper add/remove
    EspTab:AddToggle({
        Name = "Brainrot ESP",
        Default = false,
        Callback = function(enabled)
            if enabled then
                local bestBrainrot = findBestBrainrot()
                if bestBrainrot.decorationPart then
                    -- Remove old ESP if any
                    if currentBrainrotESP then
                        if currentBrainrotESP.Connections and currentBrainrotESP.Connections.ESP then
                            currentBrainrotESP.Connections.ESP:Disconnect()
                        end
                        if currentBrainrotESP.ESP then currentBrainrotESP.ESP:Remove() end
                        for _, glowSet in pairs(currentBrainrotESP.GlowTexts or {}) do
                            for _, glow in pairs(glowSet) do
                                if glow.Text then glow.Text:Remove() end
                            end
                        end
                        currentBrainrotESP = nil
                    end
                    -- Add new ESP and save reference
                    currentBrainrotESP = PartESP.AddESP(bestBrainrot.name .. " Decorations", bestBrainrot.decorationPart, 24)
                    print("Brainrot ESP enabled for", bestBrainrot.name)
                else
                    print("No decoration part found for best brainrot")
                end
            else
                -- Remove ESP on toggle off
                if currentBrainrotESP then
                    if currentBrainrotESP.Connections and currentBrainrotESP.Connections.ESP then
                        currentBrainrotESP.Connections.ESP:Disconnect()
                    end
                    if currentBrainrotESP.ESP then currentBrainrotESP.ESP:Remove() end
                    for _, glowSet in pairs(currentBrainrotESP.GlowTexts or {}) do
                        for _, glow in pairs(glowSet) do
                            if glow.Text then glow.Text:Remove() end
                        end
                    end
                    currentBrainrotESP = nil
                end
                print("Brainrot ESP disabled")
            end
        end
    })

    -- Initialize the OrionLib UI
    OrionLib:Init()
end

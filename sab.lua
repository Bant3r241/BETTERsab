if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Tabs
    local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local EspTab = Window:MakeTab({Name="ESP", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- More compact ESP toggle
    EspTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = function(v)
            if v then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/chams/refs/heads/main/ESP.lua"))()
            end
        end
    })

    -- Helper function to parse "$3.5M/s" style strings
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

    -- Find the best brainrot from the workspace
    local function findBestBrainrot()
        local best = {
            name = "Unknown",
            raw = "N/A",
            value = 0
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
                                            if nameLabel then
                                                best.name = nameLabel.Text
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

    -- Add button to show best brainrot
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

    -- Initialize the OrionLib UI
    OrionLib:Init()
end

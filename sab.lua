if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

    -- Tabs
    local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local EspTab = Window:MakeTab({Name="ESP", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    -- More compact ESP toggle
    EspTab:AddToggle({Name="Player ESP", Default=false, Callback=function(v)
        if v then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/chams/refs/heads/main/ESP.lua"))()
        end
    end})

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

    -- Get Best Brainrot from workspace.Plots only
    local function findBestBrainrot()
        local best = {
            name = "Unknown", -- Default name
            raw = "N/A",  -- Default money per second
            value = 0     -- Default value (money per second)
        }

        -- Iterate through all plots in the workspace
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
                                -- Search for the name TextLabel inside AnimalOverhead
                                local nameLabel
                                for _, child in pairs(animalOverhead:GetChildren()) do
                                    if child:IsA("TextLabel") and child.Name == "DisplayName" then
                                        nameLabel = child
                                    end
                                end

                                -- Check if money per second is available
                                local gen = attach.AnimalOverhead:FindFirstChild("Generation")
                                if gen and gen:IsA("TextLabel") then
                                    local text = gen.Text
                                    if text and text:find("/s") then
                                        local value = parseMoneyPerSec(text)
                                        if value and value > best.value then
                                            -- Update the best brainrot if we find a higher earning one
                                            best.value = value
                                            best.raw = text
                                            -- Set the name dynamically based on the found name label
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

    -- Function to show or hide the best brainrot label and log details in console
    local function toggleBestBrainrotVisibility(state)
        local best = findBestBrainrot()
        if best.part then
            if state then
                -- Display in the console
                print("[Best Brainrot] Name: " .. best.name)
                print("[Best Brainrot] Generation: " .. best.raw)
                print("[Best Brainrot] Value per second: " .. best.value)
                
                -- Optionally, you can add logic to create a label in the game, or use `createBrainrotLabel()` from earlier.
                -- createBrainrotLabel(best.part, best.name, best.raw)
            else
                -- If you want to hide or reset the part, you can add that logic here.
                print("[Debug] Best Brainrot visibility toggled off.")
                -- resetPart(best.part)
            end
        else
            print("[Debug] No valid brainrot found.")
        end
    end

    -- Add the Best Brainrot button to the MainTab
    MainTab:AddButton({
        Name = "Toggle Best Brainrot Visibility",
        Callback = function()
            local best = findBestBrainrot()
            if best.part then
                toggleBestBrainrotVisibility(true)  -- Show the best brainrot info when clicked
            else
                print("[Debug] No valid brainrot found.")
            end
        end
    })

    -- Initialize the OrionLib UI
    OrionLib:Init()
end

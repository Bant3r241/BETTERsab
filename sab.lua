if game.PlaceId == 109983668079237 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ Steal A Brainrot", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

--Tabs
   local MainTab = Window:MakeTab({Name = "Main"})
  local ESPTab = Window:MakeTab({Name = "ESP"})

  --Toggles
  ESPTab:AddToggle{Name = "Player ESP", Default = false, Callback = function(s) if s then loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/chams/refs/heads/main/ESP.lua"))() else ESP:Toggle(false) end end}
  MainTab:AddToggle({Name = "Best Brainrot", Default = false, Callback = toggleBestBrainrotVisibility})

-- Money per second parsing
local function parseMoneyPerSec(text)
    local num, suffix = text:match("%$([%d%.]+)([KMBT]?)/s")
    return num and tonumber(num) * ({K = 1e3, M = 1e6, B = 1e9, T = 1e12})[suffix] or nil
end

-- Find the best brainrot
local function findBestBrainrot()
    local best = {value = 0, raw = "", name = "", part = nil}
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return best end

    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, podium in pairs((plot:FindFirstChild("AnimalPodiums") or {}):GetChildren()) do
            local part = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Decorations") and podium.Base.Decorations:FindFirstChild("Part")
            local gen = podium.Base and podium.Base:FindFirstChild("Spawn"):FindFirstChild("Attachment"):FindFirstChild("AnimalOverhead"):FindFirstChild("Generation")
            if gen and gen:IsA("TextLabel") then
                local value = parseMoneyPerSec(gen.Text)
                if value and value > best.value then
                    best = {value = value, raw = gen.Text, name = (podium.Base and podium.Base:FindFirstChild("Spawn"):FindFirstChild("Attachment"):FindFirstChild("AnimalOverhead"):FindFirstChild("DisplayName") and podium.Base.Spawn.Attachment.AnimalOverhead.DisplayName.Text) or "Unknown", part = part}
                end
            end
        end
    end
    return best
end

-- Function to show or hide the best brainrot label
local function toggleBestBrainrotVisibility(state)
    local best = findBestBrainrot()
    if best.part then
        if state then
            createBrainrotLabel(best.part, best.name, best.raw)
            print("[Best Brainrot] Name: " .. best.name .. "\nGeneration: " .. best.raw .. "\nValue per second: " .. best.value)
        else
            resetPart(best.part)
            print("[Debug] Best Brainrot visibility toggled off.")
        end
    else
        print("[Debug] No valid brainrot found.")
    end
end

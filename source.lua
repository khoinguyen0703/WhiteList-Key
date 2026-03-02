-- [[ PLEPORM HUB V79 - THE FINAL MASTERPIECE ]]
-- [ CHECKED: ANTI-LEAK, BYPASS AC, PRECISION TRACK, AUTO-HOP ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local http = game:GetService("HttpService")
local ts = game:GetService("TeleportService")

local Config = getgenv().Plepor_Config
local UserKey = _G.script_key or "No Key"
local MaxPlayers = tonumber(Config["Max Players to Hop"]) or 5

-- 🛡️ 1. BYPASS & CLEANUP SYSTEM
if getgenv().Plepor_Executed then 
    for _, v in pairs(getgenv().PleporM_Connections or {}) do v:Disconnect() end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
end
getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

local function BypassAC(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if hum and root then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        -- Anti-Velocity Bypass
        table.insert(getgenv().PleporM_Connections, rs.Stepped:Connect(function()
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end))
    end
end

-- 🟢 2. TOTAL GOLD DETECTOR (From Log Data)
local function GetTotalGold()
    local gold = "0"
    pcall(function()
        local sb = pgui:FindFirstChild("Scoreboard")
        if sb then
            for _, v in pairs(sb:GetDescendants()) do
                if v:IsA("TextLabel") and (v.Name == "CoinIcon" or v.Parent.Name == "Coins") then
                    local t = v.Text or ""
                    if t:match("%d") and not t:find("/") and not t:find("x") then
                        local n = t:match("[%d%,]+")
                        if n and n ~= "2018" and n ~= "2019" and #n < 10 then gold = n break end
                    end
                end
            end
        end
    end)
    return gold
end

-- 🔵 3. WEBHOOK TRACKING (ASYNC)
local function SendTrack(msg)
    task.spawn(function()
        local url = Config["Webhook Url"]
        if not url or url == "" or not url:find("discord") then return end
        pcall(function()
            request({
                Url = url, Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = http:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = "📈 PleporM Hub - Progress Report",
                        ["description"] = msg,
                        ["color"] = 0x00FF00,
                        ["footer"] = {["text"] = "PleporM Hub v79 • " .. os.date("%X")},
                        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
                    }}
                })
            })
        end)
    end)
end

-- 🟡 4. SERVER HOPPER
local function ServerHop()
    math.randomseed(os.time())
    pcall(function()
        local servers = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        local possible = {}
        for _, v in pairs(servers) do
            if v.playing < MaxPlayers and v.id ~= game.JobId then table.insert(possible, v.id) end
        end
        if #possible > 0 then ts:TeleportToPlaceInstance(game.PlaceId, possible[math.random(1, #possible)]) end
    end)
end

-- 🟠 5. PRECISION FARM ENGINE
local currentCoins = 0
local isResetting = false

task.spawn(function()
    while task.wait(0.05) do
        if Config["Turbo Farm"] and not isResetting then
            -- Map Check
            local map = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map")
            if map and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                
                -- RESET WHEN FULL
                if currentCoins >= 40 then
                    isResetting = true
                    local oldGold = GetTotalGold()
                    lp.Character:BreakJoints()
                    
                    task.delay(6, function()
                        local newGold = GetTotalGold()
                        SendTrack("💰 **Round Completed (40/40)**\nOld Gold: **$"..oldGold.."**\nNew Gold: **$"..newGold.."**")
                        currentCoins = 0 -- Reset counter AFTER tracking
                    end)

                    task.wait(7)
                    if Config["Auto Hop"] and #game.Players:GetPlayers() > MaxPlayers then ServerHop() end
                    isResetting = false
                    continue
                end

                -- COLLECTION LOGIC
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        if v.Transparency < 1 and v:IsDescendantOf(workspace) then
                            root.CFrame = v.CFrame
                            firetouchinterest(root, v, 0)
                            
                            local t = tick()
                            while v.Parent and tick() - t < 0.25 do rs.Heartbeat:Wait() end
                            
                            firetouchinterest(root, v, 1)
                            if not v.Parent or v.Transparency >= 1 then
                                currentCoins = currentCoins + 1
                                task.wait(Config["Farm Speed"] or 0)
                                break 
                            end
                        end
                    end
                end
            else
                currentCoins = 0 -- Auto reset in Lobby
            end
        end
    end
end)

-- ⚪ 6. UI & INITIALIZE
local function CreateUI()
    local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 260); main.Position = UDim2.new(0.5, -210, 0.2, -130); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 2
    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,30); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s; l.Font = Enum.Font.Arcade; l.BackgroundTransparency = 1; return l
    end
    Lbl("PLEPORM HUB V79", UDim2.new(0,0,0,10), Color3.fromRGB(255, 50, 50), 38)
    local tG = Lbl("TOTAL GOLD: $0", UDim2.new(0,0,0,90), Color3.fromRGB(80, 255, 80), 22)
    local cB = Lbl("COIN BAG: 0/40", UDim2.new(0,0,0,125), Color3.fromRGB(255, 255, 100), 20)
    local st = Lbl("STATUS: INITIALIZING", UDim2.new(0,0,0,160), Color3.fromRGB(255, 255, 255), 18)

    task.spawn(function()
        while task.wait(1) do
            if not sg.Parent then break end
            tG.Text = "TOTAL GOLD: $" .. GetTotalGold()
            cB.Text = "COIN BAG: " .. currentCoins .. "/40"
            st.Text = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position.Y < 150) and "STATUS: FARMING (MATCH)" or "STATUS: WAITING (LOBBY)"
        end
    end)
end

-- EXECUTE
table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character then BypassAC(lp.Character) end

table.insert(getgenv().PleporM_Connections, lp.Idled:Connect(function() 
    vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame); task.wait(1); vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame) 
end))

if Config["Delete Map"] then 
    task.spawn(function()
        for _,v in pairs(workspace:GetDescendants()) do 
            if v:IsA("BasePart") and v.Name ~= "Baseplate" and not v.Name:find("Coin") then v.Transparency=1; v.CanCollide=false end 
        end 
    end)
end

CreateUI()
SendTrack("🚀 PleporM Hub V79 Initialized! (Max Players: "..MaxPlayers..")")

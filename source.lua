-- [[ PLEPORM HUB V73 - ULTIMATE & ANTI-MEMORY LEAK ]]
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

-- 🔴 1. CLEANUP PREVIOUS SESSIONS (Prevent Memory Leak)
if getgenv().Plepor_Connection then getgenv().Plepor_Connection:Disconnect() end
if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end

-- 🟢 2. WHITELIST SYSTEM
local function Verify()
    local s, content = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt?t="..tick()) end)
    if s then
        for line in content:gmatch("[^\r\n]+") do
            if line:gsub("%s+", "") == UserKey then return true end
        end
    end
    return false
end
if not Verify() then lp:Kick("❌ INVALID KEY! Contact PleporM Hub.") return end

-- 🔵 3. WEBHOOK TRACKING
local function SendTrack(msg)
    local url = Config["Webhook Url"]
    if not url or url == "" or url:find("webhook") then return end
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "🛡️ PleporM Hub - Tracking Report",
                ["description"] = msg,
                ["color"] = 0x00FF00,
                ["fields"] = {
                    {["name"] = "Username", ["value"] = lp.Name, ["inline"] = true},
                    {["name"] = "Server", ["value"] = #game.Players:GetPlayers() .. " players", ["inline"] = true}
                },
                ["footer"] = {["text"] = "PleporM Hub v73"},
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = http:JSONEncode(data)})
    end)
end

-- 🟡 4. STATS DETECTOR (Optimized for MM2 Log)
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

-- 🟠 5. SERVER HOPPER (Randomized)
local hopping = false
local function ServerHop()
    if hopping then return end
    hopping = true
    math.randomseed(os.time())
    SendTrack("⚠️ Server crowded. Looking for new server...")
    local x = {}
    pcall(function()
        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, v in pairs(res) do if v.playing < MaxPlayers and v.id ~= game.JobId then x[#x+1] = v.id end end
    end)
    if #x > 0 then ts:TeleportToPlaceInstance(game.PlaceId, x[math.random(1,#x)]) else hopping = false end
end

-- 🟣 6. FARM & TRIPLE-RESET LOGIC
local currentCoins = 0
local isResetting = false

task.spawn(function()
    while task.wait(0.1) do
        if Config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and not isResetting then
            local root = lp.Character.HumanoidRootPart
            
            -- RESET WHEN FULL (40/40)
            if currentCoins >= 40 then
                isResetting = true
                local totalInBank = GetTotalGold()
                SendTrack("💰 **Bag Full (40/40)!**\nTotal Gold: **$" .. totalInBank .. "**\nResetting...")

                currentCoins = 0
                pcall(function()
                    lp.Character:BreakJoints()
                    if lp.Character:FindFirstChildOfClass("Humanoid") then
                        lp.Character:FindFirstChildOfClass("Humanoid").Health = 0
                    end
                end)

                task.wait(6.5)
                if Config["Auto Hop"] and #game.Players:GetPlayers() > MaxPlayers then ServerHop() end
                isResetting = false
                continue
            end

            -- COIN COLLECTION
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                    if v.Transparency < 1 and not isResetting then
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0); rs.Heartbeat:Wait(); firetouchinterest(root, v, 1)
                        currentCoins = currentCoins + 1
                        task.wait(Config["Farm Speed"] or 0)
                        break 
                    end
                end
            end
        end
    end
end)

-- ⚪ 7. UI & ANTI-AFK (CLEAN)
local function CreateUI()
    local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 260); main.Position = UDim2.new(0.5, -210, 0.2, -130); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 2
    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,30); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s; l.Font = Enum.Font.Arcade; l.BackgroundTransparency = 1; return l
    end
    Lbl("PLEPORM HUB V73", UDim2.new(0,0,0,10), Color3.fromRGB(255, 50, 50), 38)
    local tG = Lbl("TOTAL GOLD: $0", UDim2.new(0,0,0,90), Color3.fromRGB(80, 255, 80), 22)
    local cB = Lbl("COIN BAG: 0/40", UDim2.new(0,0,0,125), Color3.fromRGB(255, 255, 100), 20)
    local pS = Lbl("Server: " .. #game.Players:GetPlayers() .. " (Max: " .. MaxPlayers .. ")", UDim2.new(0,0,0,160), Color3.fromRGB(255, 255, 255), 18)

    task.spawn(function()
        while task.wait(1.5) do
            if not sg or not sg.Parent then break end -- Stop loop if UI destroyed
            tG.Text = "TOTAL GOLD: $" .. GetTotalGold()
            cB.Text = "COIN BAG: " .. currentCoins .. "/40"
            pS.Text = "Server: " .. #game.Players:GetPlayers() .. " (Max: " .. MaxPlayers .. ")"
        end
    end)
end

getgenv().Plepor_Connection = lp.Idled:Connect(function() 
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
end)

if Config["Delete Map"] then 
    for _,v in pairs(workspace:GetDescendants()) do 
        if v:IsA("BasePart") and v.Name ~= "Baseplate" and not v.Name:find("Coin") then 
            v.Transparency=1; v.CanCollide=false 
        end 
    end 
end

CreateUI()
SendTrack("🚀 PleporM Hub V73 Initialized! (Anti-Leak Mode)")

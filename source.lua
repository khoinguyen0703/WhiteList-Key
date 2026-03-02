-- [[ PLEPORM HUB V96 - MEMORY OPTIMIZED ]]
-- [ FIXED: MEMORY LEAKS | MULTI-LAYER COIN SCAN | AUTO-CLEANUP ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local lighting = game:GetService("Lighting")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")

-- 🔑 1. WHITELIST SYSTEM (KICK ON FAIL)
local script_key = tostring(_G.script_key or "No Key"):gsub("%s+", "")
local whitelist_url = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt"
local is_whitelisted = false

local success, result = pcall(function()
    return game:HttpGet(whitelist_url .. "?t=" .. tostring(math.floor(tick())))
end)

if success and result then
    for line in result:gmatch("[^\r\n]+") do
        if line:gsub("%s+", "") == script_key then
            is_whitelisted = true
            break
        end
    end
else
    return lp:Kick("❌ Whitelist Connection Error (GitHub Issue)!")
end

if not is_whitelisted then 
    return lp:Kick("❌ WRONG KEY. PLEASE CONTACT PLEPORM HUB ❌") 
end

-- 🛡️ 2. ANTI-MEMORY LEAK & CLEANUP
if getgenv().Plepor_Executed then 
    -- Disconnect all old events
    if getgenv().PleporM_Connections then
        for _, v in pairs(getgenv().PleporM_Connections) do 
            if v then v:Disconnect() end 
        end
    end
    -- Destroy old UI & Effects
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    if lighting:FindFirstChild("Pleporm_Blur") then lighting.Pleporm_Blur:Destroy() end
    task.wait(0.1)
end

getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

local function OptimizePerformance()
    local Config = getgenv().Plepor_Config
    if Config["Delete Map"] then
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
        end
        settings().Rendering.QualityLevel = 1
    end
    if Config["Delete Player"] then
        local function clearChar(char)
            if char and char ~= lp.Character then 
                task.delay(0.2, function() if char then char:Destroy() end end) 
            end
        end
        for _, v in pairs(game.Players:GetPlayers()) do if v ~= lp then clearChar(v.Character) end end
        table.insert(getgenv().PleporM_Connections, game.Players.PlayerAdded:Connect(function(p)
            table.insert(getgenv().PleporM_Connections, p.CharacterAdded:Connect(clearChar))
        end))
    end
end

local function BypassAC(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if root then
        local stepConn = rs.Stepped:Connect(function()
            if root and root.Parent then
                root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
                for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end)
        table.insert(getgenv().PleporM_Connections, stepConn)
    end
end

-- 🔵 3. AUTO HOP LOW SERVER
local function ServerHop()
    pcall(function()
        local PlaceId = game.PlaceId
        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        table.sort(res, function(a, b) return a.playing < b.playing end)
        for _, v in pairs(res) do 
            if v.playing < 8 and v.id ~= game.JobId then 
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, v.id)
                return
            end 
        end
    end)
end

-- 🔵 4. UI GLASS DESIGN (CENTERED)
local blur = Instance.new("BlurEffect", lighting)
blur.Name = "Pleporm_Blur"; blur.Size = 18

local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 180); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.4; main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Transparency = 0.4

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "PLEPORM HUB V96"; title.TextColor3 = Color3.fromRGB(255, 60, 60)
title.TextSize = 22; title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

local goldLbl = Instance.new("TextLabel", main)
goldLbl.Size = UDim2.new(1, 0, 0, 30); goldLbl.Position = UDim2.new(0, 0, 0, 65)
goldLbl.TextSize = 18; goldLbl.Font = Enum.Font.GothamSemibold; goldLbl.TextColor3 = Color3.fromRGB(100, 255, 100); goldLbl.BackgroundTransparency = 1

local bagLbl = Instance.new("TextLabel", main)
bagLbl.Size = UDim2.new(1, 0, 0, 30); bagLbl.Position = UDim2.new(0, 0, 0, 95)
bagLbl.TextSize = 18; bagLbl.Font = Enum.Font.GothamSemibold; bagLbl.TextColor3 = Color3.fromRGB(255, 230, 100); bagLbl.BackgroundTransparency = 1

local statusLbl = Instance.new("TextLabel", main)
statusLbl.Size = UDim2.new(1, 0, 0, 25); statusLbl.Position = UDim2.new(0, 0, 0, 140)
statusLbl.TextSize = 13; statusLbl.Font = Enum.Font.GothamMedium; statusLbl.BackgroundTransparency = 1

-- 🟡 5. ULTIMATE COIN ENGINE (MEMORY OPTIMIZED)
local currentCoins, isResetting = 0, false
local lastCoinTick = tick()

local function GetAllCoins()
    local coins = {}
    local folders = {workspace:FindFirstChild("Normal"), workspace:FindFirstChild("Map"), workspace:FindFirstChild("CoinContainer")}
    for _, folder in pairs(folders) do
        if folder then
            for _, v in pairs(folder:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                    if v.Transparency < 0.5 and v.Position.Y < 100 then table.insert(coins, v) end
                end
            end
        end
    end
    return coins
end

task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(0.01)
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isResetting then
            local MaxAllowed = tonumber(Config["Max Players to Hop"]) or 5
            if #game.Players:GetPlayers() > MaxAllowed and Config["Auto Hop"] then ServerHop() break end

            local coins = GetAllCoins()
            if #coins > 0 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                if tick() - lastCoinTick > 180 and Config["Auto Hop"] then ServerHop() break end
                
                if currentCoins >= 40 then
                    isResetting = true; lp.Character:BreakJoints()
                    task.wait(7.5); currentCoins = 0; isResetting = false; continue
                end

                for _, v in pairs(coins) do
                    if v.Parent and v.Transparency < 0.5 then
                        root.CFrame = v.CFrame; firetouchinterest(root, v, 0)
                        task.wait(0.12) -- Optimized touch time
                        firetouchinterest(root, v, 1)
                        if not v.Parent or v.Transparency > 0.5 then
                            currentCoins = currentCoins + 1; lastCoinTick = tick()
                            task.wait(Config["Farm Speed"] or 0.05); break 
                        end
                    end
                end
            else 
                currentCoins = 0; lastCoinTick = tick() 
            end
        end
    end
end)

-- ⚪ 6. INITIALIZE
OptimizePerformance()
task.spawn(function()
    while sg.Parent do
        task.wait(0.5)
        pcall(function()
            local sb = pgui:FindFirstChild("Scoreboard", true)
            local gold = "0"
            if sb then
                for _, v in pairs(sb:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text:match("%d") and not v.Text:find("/") and not v.Text:lower():find("x") then
                        local n = v.Text:match("[%d%,]+")
                        if n and n ~= "2018" and n ~= "2019" then gold = n break end
                    end
                end
            end
            goldLbl.Text = "TOTAL GOLD: $" .. gold
            bagLbl.Text = "COIN BAG: " .. currentCoins .. "/40"
            local isFarming = #GetAllCoins() > 0
            statusLbl.Text = isFarming and "● STATUS: COLLECTING" or "○ STATUS: WAITING"
            statusLbl.TextColor3 = isFarming and Color3.fromRGB

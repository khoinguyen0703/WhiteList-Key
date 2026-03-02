-- [[ PLEPORM HUB V91 - TOTAL REPAIR & AUTO SERVER HOP ]]
-- [ GIỮ NGUYÊN: WHITELIST, UI GLASS, FARM ENGINE ]
-- [ BỔ SUNG: AUTO SERVER HOP KHI QUÁ NGƯỜI CHƠI ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local lighting = game:GetService("Lighting")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")

-- 🔑 1. WHITELIST SYSTEM (GIỮ NGUYÊN)
local script_key = _G.script_key or "No Key"
local whitelist_url = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt"
local is_whitelisted = false

local success, result = pcall(function()
    return game:HttpGet(whitelist_url .. "?t=" .. tick())
end)

if success then
    for line in result:gmatch("[^\r\n]+") do
        if line:gsub("%s+", "") == script_key:gsub("%s+", "") then
            is_whitelisted = true
            break
        end
    end
else
    return lp:Kick("❌ Lỗi kết nối Whitelist!")
end

if not is_whitelisted then return lp:Kick("❌ Sai Key hoặc Key hết hạn!") end

-- 🛡️ 2. BYPASS & CLEANUP (GIỮ NGUYÊN)
if getgenv().Plepor_Executed then 
    for _, v in pairs(getgenv().PleporM_Connections or {}) do if v then v:Disconnect() end end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    if lighting:FindFirstChild("Pleporm_Blur") then lighting.Pleporm_Blur:Destroy() end
end
getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

local function BypassAC(char)
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if root then
        table.insert(getgenv().PleporM_Connections, rs.Stepped:Connect(function()
            if root and root.Parent then
                root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
                for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end))
    end
end

-- 🔵 3. SERVER HOPPER (ĐÃ FIX LOGIC SỐ NGƯỜI)
local function ServerHop()
    pcall(function()
        local PlaceId = game.PlaceId
        local MaxConfig = tonumber(getgenv().Plepor_Config["Max Players to Hop"]) or 5
        
        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, v in pairs(res) do 
            if v.playing < MaxConfig and v.id ~= game.JobId then 
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, v.id)
                return
            end 
        end
    end)
end

-- 🔵 4. UI GLASS (GIỮ NGUYÊN CĂN GIỮA & MỜ ẢO)
local blur = Instance.new("BlurEffect", lighting)
blur.Name = "Pleporm_Blur"; blur.Size = 18

local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 180); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.4; main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Transparency = 0.4

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "PLEPORM HUB V91"; title.TextColor3 = Color3.fromRGB(255, 60, 60)
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

-- 🟡 5. FARM ENGINE (GIỮ NGUYÊN NHẶT VÀNG & BỔ SUNG AUTO HOP)
local currentCoins, isResetting = 0, false
local lastCoinTick = tick()

local function GetMap()
    return workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map") or workspace:FindFirstChild("CoinContainer")
end

task.spawn(function()
    while task.wait(0.01) do
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isResetting then
            -- CHECK SỐ NGƯỜI ĐỂ HOP (PHẦN MỚI BỔ SUNG)
            if Config["Auto Hop"] then
                local CurrentPlayers = #game.Players:GetPlayers()
                local MaxAllowed = tonumber(Config["Max Players to Hop"]) or 5
                if CurrentPlayers > MaxAllowed then
                    ServerHop()
                end
            end

            local mapFound = GetMap()
            if mapFound and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                
                -- Đổi Server nếu kẹt 3 phút
                if tick() - lastCoinTick > 180 and Config["Auto Hop"] then ServerHop() end

                if currentCoins >= 40 then
                    isResetting = true; lp.Character:BreakJoints()
                    task.wait(7.5); currentCoins = 0; isResetting = false; continue
                end

                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        if v.Parent and v.Transparency < 0.5 then
                            root.CFrame = v.CFrame
                            firetouchinterest(root, v, 0)
                            local t = tick()
                            while v.Parent and v.Transparency < 0.5 and tick() - t < 0.2 do rs.Heartbeat:Wait() end
                            firetouchinterest(root, v, 1)
                            if not v.Parent or v.Transparency > 0.5 then
                                currentCoins = currentCoins + 1; lastCoinTick = tick()
                                task.wait(Config["Farm Speed"] or 0.05); break 
                            end
                        end
                    end
                end
            else
                currentCoins = 0; lastCoinTick = tick()
            end
        end
    end
end)

-- ⚪ 6. UI LOOP (GIỮ NGUYÊN)
task.spawn(function()
    while task.wait(0.5) do
        if not sg.Parent then break end
        pcall(function()
            local sb = pgui:FindFirstChild("Scoreboard", true)
            local gold = "0"
            if sb then
                for _, v in pairs(sb:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text:match("%d") and not v.Text:find("/") and not v.Text:lower():find("x") then
                        local n = v.Text:match("[%d%,]+")
                        if n and n ~= "2018" and n ~= "2019" and #n < 10 then gold = n break end
                    end
                end
            end
            goldLbl.Text = "TOTAL GOLD: $" .. gold
            bagLbl.Text = "COIN BAG: " .. currentCoins .. "/40"
            local isFarming = GetMap() ~= nil
            statusLbl.Text = isFarming and "● STATUS: FARMING" or "○ STATUS: WAITING"
            statusLbl.TextColor3 = isFarming and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        end)
    end
end)

table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character

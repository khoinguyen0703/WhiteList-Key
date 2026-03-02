-- [[ PLEPORM HUB - ULTIMATE STABLE VERSION ]]
-- [ GLOW UI | GUARANTEED COIN | FIX AUTO HOP | BYPASS AC ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local pgui = lp:WaitForChild("PlayerGui")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")
local tps = game:GetService("TeleportService")

local ScriptStartTime = tick()
local CurrentAction = "INITIALIZING SCRIPT..."
local isHopping = false 
local currentCoins = 0
local lastCoinTick = tick()

-- 🔑 1. WHITELIST SYSTEM
local script_key = tostring(_G.script_key or "No Key"):gsub("%s+", "")
local whitelist_url = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt"
local is_whitelisted = false

local success, result = pcall(function() return game:HttpGet(whitelist_url .. "?t=" .. tostring(math.floor(tick()))) end)
if success and result then
    for line in result:gmatch("[^\r\n]+") do
        if line:gsub("%s+", "") == script_key then is_whitelisted = true break end
    end
else
    return lp:Kick("❌ Whitelist Connection Error!")
end
if not is_whitelisted then return lp:Kick("❌ WRONG KEY. CONTACT PLEPORM HUB ❌") end

-- 🛡️ 2. CLEANUP OLD SCRIPT
if getgenv().Plepor_Executed then 
    if getgenv().PleporM_Connections then
        for _, v in pairs(getgenv().PleporM_Connections) do if v then v:Disconnect() end end
    end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
end
getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

-- 📡 3. DISCORD WEBHOOK SYSTEM
local function SendWebhook(goldAmount)
    local url = getgenv().Plepor_Config["Webhook Url"]
    if not url or url == "" then return end
    pcall(function()
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "💰 PleporM Hub - Farm Report",
                ["description"] = "✅ **Bag Full! Collected " .. tostring(goldAmount) .. " coins.**\n👤 **Player:** ||" .. lp.Name .. "||\n👥 **Server Players:** " .. tostring(#game.Players:GetPlayers()),
                ["color"] = tonumber(0xFFD700)
            }}
        }
        local requestFunc = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
        if requestFunc then
            requestFunc({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = http:JSONEncode(data)})
        end
    end)
end

-- 🛠️ 4. OPTIMIZE & IMPROVED BYPASS ANTI-CHEAT
local function OptimizePerformance()
    local Config = getgenv().Plepor_Config
    task.spawn(function()
        while getgenv().Plepor_Executed do
            if Config["Delete Map"] then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "Coin_Server" and v.Name ~= "Coin" and not v.Parent:FindFirstChild("Humanoid") then
                        v.Transparency = 1; v.Material = Enum.Material.SmoothPlastic
                    elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
                end
                settings().Rendering.QualityLevel = 1
            end
            task.wait(5)
        end
    end)
    if Config["Delete Player"] then
        local function deleteChar(char) if char then task.wait(0.1); char:Destroy() end end
        for _, p in pairs(game.Players:GetPlayers()) do if p ~= lp and p.Character then deleteChar(p.Character) end end
        table.insert(getgenv().PleporM_Connections, game.Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(char) if getgenv().Plepor_Config["Delete Player"] then deleteChar(char) end end)
        end))
    end
end

local function BypassAC(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if root and hum then
        local stepConn = rs.Stepped:Connect(function()
            if char and char.Parent and root and root.Parent then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                for _, v in pairs(char:GetDescendants()) do 
                    if v:IsA("BasePart") then v.CanCollide = false end 
                end
            end
        end)
        table.insert(getgenv().PleporM_Connections, stepConn)
    end
end
table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character then BypassAC(lp.Character) end

-- 🔵 5. AUTO HOP TARGET SERVER (STABILIZED)
local function ServerHop()
    if isHopping then return end
    isHopping = true
    CurrentAction = "HOPPING SERVER..."
    
    pcall(function()
        local Config = getgenv().Plepor_Config
        local maxP = tonumber(Config["Max Players to Hop"]) or 5
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local req = game:HttpGet(url)
        local data = http:JSONDecode(req)
        
        if data and data.data then
            local servers = data.data
            -- Xáo trộn danh sách server để tránh join trùng
            for i = #servers, 2, -1 do
                local j = math.random(i)
                servers[i], servers[j] = servers[j], servers[i]
            end
            
            for _, v in ipairs(servers) do 
                -- ĐIỀU KIỆN TÌM SERVER: Lớn hơn 2 người VÀ nhỏ hơn/bằng giới hạn Max Players
                if type(v) == "table" and tonumber(v.playing) and v.playing > 2 and v.playing <= maxP and v.id ~= game.JobId then 
                    tps:TeleportToPlaceInstance(game.PlaceId, v.id, lp)
                    task.wait(5)
                end 
            end
        end
    end)
    
    task.wait(3)
    isHopping = false 
end
-- 🔵 6. UI GLASS DESIGN (GLOW EFFECT)
local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 0, 0, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.3; main.BorderSizePixel = 0
main.ClipsDescendants = false 
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Thickness = 1.5; stroke.Transparency = 0.2
local glow = Instance.new("ImageLabel", main); glow.Name = "GlowEffect"; glow.BackgroundTransparency = 1; glow.Position = UDim2.new(0, -30, 0, -30); glow.Size = UDim2.new(1, 60, 1, 60); glow.ZIndex = 0; glow.Image = "rbxassetid://5028857084"; glow.ImageColor3 = Color3.fromRGB(255, 200, 100); glow.ImageTransparency = 0.4; glow.ScaleType = Enum.ScaleType.Slice; glow.SliceCenter = Rect.new(24, 24, 276, 276)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 35); title.Position = UDim2.new(0, 0, 0, 5); title.Text = "PLEPORM HUB - TRACK STATS"; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.TextSize = 22; title.Font = Enum.Font.Arcade; title.BackgroundTransparency = 1; title.ZIndex = 2

-- Cài sẵn Text mặc định thay vì để trống lòi chữ "Label"
local timeLbl = Instance.new("TextLabel", main); timeLbl.Size = UDim2.new(1, 0, 0, 20); timeLbl.Position = UDim2.new(0, 0, 0, 45); timeLbl.TextSize = 18; timeLbl.Font = Enum.Font.Arcade; timeLbl.TextColor3 = Color3.fromRGB(200, 200, 200); timeLbl.BackgroundTransparency = 1; timeLbl.ZIndex = 2; timeLbl.Text = "UPTIME: 00:00:00"

local goldLbl = Instance.new("TextLabel", main); goldLbl.Size = UDim2.new(1, 0, 0, 30); goldLbl.Position = UDim2.new(0, 0, 0, 75); goldLbl.TextSize = 22; goldLbl.Font = Enum.Font.Arcade; goldLbl.TextColor3 = Color3.fromRGB(255, 215, 0); goldLbl.BackgroundTransparency = 1; goldLbl.ZIndex = 2; goldLbl.Text = "TOTAL GOLD: $0"

local bagLbl = Instance.new("TextLabel", main); bagLbl.Size = UDim2.new(1, 0, 0, 30); bagLbl.Position = UDim2.new(0, 0, 0, 105); bagLbl.TextSize = 20; bagLbl.Font = Enum.Font.Arcade; bagLbl.TextColor3 = Color3.fromRGB(200, 160, 100); bagLbl.BackgroundTransparency = 1; bagLbl.ZIndex = 2; bagLbl.Text = "COIN BAG: 0/40"

local playersLbl = Instance.new("TextLabel", main); playersLbl.Size = UDim2.new(1, 0, 0, 25); playersLbl.Position = UDim2.new(0, 0, 0, 135); playersLbl.TextSize = 18; playersLbl.Font = Enum.Font.Arcade; playersLbl.TextColor3 = Color3.fromRGB(150, 200, 255); playersLbl.BackgroundTransparency = 1; playersLbl.ZIndex = 2; playersLbl.Text = "PLAYERS: LOADING..."

local statusLbl = Instance.new("TextLabel", main); statusLbl.Size = UDim2.new(1, 0, 0, 40); statusLbl.Position = UDim2.new(0, 0, 0, 165); statusLbl.TextSize = 16; statusLbl.Font = Enum.Font.Arcade; statusLbl.BackgroundTransparency = 1; statusLbl.ZIndex = 2; statusLbl.TextWrapped = true; statusLbl.Text = "ACTION:\nINITIALIZING..."

ts:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 215)}):Play()

-- 🟡 7. SUPER TURBO FARM (GUARANTEED SERVER VALIDATION & ANTI-CHEAT BYPASS)
task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(0.1) 
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isHopping then
            pcall(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- KIỂM TRA ĐIỀU KIỆN HOP (CHỈ HOP KHI SỐ NGƯỜI VƯỢT QUÁ GIỚI HẠN)
                local maxPlayers = tonumber(Config["Max Players to Hop"]) or 5
                if Config["Auto Hop"] and #game.Players:GetPlayers() > maxPlayers then
                    ServerHop()
                    return
                end

                -- Check 40 Vàng
                if currentCoins >= 40 then
                    CurrentAction = "BAG FULL! WAITING FOR MATCH END..."
                    if tick() - lastCoinTick > 10 then 
                        SendWebhook(currentCoins)
                        lastCoinTick = tick() + 9999 
                    end
                    return
                end

                local foundCoin = false
                
                -- QUÉT TOÀN MAP (Không phụ thuộc thư mục Normal, không check Transparency)
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name == "Coin_Server" or v.Name == "Coin") then
                        foundCoin = true
                        CurrentAction = "COLLECTING COINS..."
                        
                        -- Bay thẳng tới và hãm phanh lại để chống Anti-Cheat
                        root.CFrame = v.CFrame
                        root.Velocity = Vector3.new(0, 0, 0)
                        
                        -- Kích hoạt chạm
                        if firetouchinterest then
                            firetouchinterest(root, v, 0)
                            task.wait(0.05)
                            firetouchinterest(root, v, 1)
                        end
                        
                        task.wait(0.1) -- Đợi server load nhịp
                        
                        -- Đổi tên và giấu đi để quét cục khác, tránh kẹt 1 chỗ
                        v.Name = "PleporM_Done"
                        v.CFrame = CFrame.new(0, -9999, 0)
                        
                        currentCoins = currentCoins + 1
                        lastCoinTick = tick()
                        
                        task.wait(Config["Farm Speed"] or 0)
                        break -- Lụm xong 1 cục, ngắt vòng lặp để lụm cục tiếp theo
                    end
                end
                
                -- Xử lý reset túi vàng khi ván đấu kết thúc
                if not foundCoin then 
                    CurrentAction = "WAITING FOR MATCH / COINS..."
                    -- Nếu hơn 15 giây không có cục vàng nào trong map -> Hết ván, reset túi vàng
                    if tick() - lastCoinTick > 15 then
                        currentCoins = 0
                    end
                end
            end)
        end
    end
end)

-- ⚪ 8. INITIALIZE UI LOOP
OptimizePerformance()
task.spawn(function()
    while sg.Parent do
        task.wait(0.5)
        pcall(function()
            local elapsed = tick() - ScriptStartTime
            local hours = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = math.floor(elapsed % 60)
            timeLbl.Text = string.format("UPTIME: %02d:%02d:%02d", hours, mins, secs)

            local sb = pgui:FindFirstChild("Scoreboard", true)
            local gold = "0"
            if sb then
                for _, v in pairs(sb:GetDescendants()) do
                    -- Check an toàn v.Text để không bị lỗi nhịp
                    if v:IsA("TextLabel") and type(v.Text) == "string" and v.Text ~= "" then
                        if v.Text:match("%d") and not v.Text:find("/") then
                            local n = v.Text:match("[%d%,]+")
                            if n and n ~= "2018" and n ~= "2019" then gold = n break end
                        end
                    end
                end
            end
            
            goldLbl.Text = "TOTAL GOLD: $" .. gold
            bagLbl.Text = "COIN BAG: " .. tostring(currentCoins) .. "/40"
            
            local players = game.Players:GetPlayers()
            playersLbl.Text = "PLAYERS: " .. tostring(#players) .. "/12"
            
            statusLbl.Text = "ACTION:\n" .. tostring(CurrentAction)
            
            -- Chỉnh màu text theo trạng thái
            if CurrentAction:find("COLLECTING") then statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif CurrentAction:find("WAITING") then statusLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
            elseif CurrentAction:find("FULL") or CurrentAction:find("HOPPING") then statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            else statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end)
    end
end)

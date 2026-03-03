-- [[ PLEPORM HUB - SOURCE SCRIPT ]]
-- [ DO NOT SHARE THIS FILE DIRECTLY ]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local rs = game:GetService("RunService")
local pgui = lp:WaitForChild("PlayerGui")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")
local tps = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")

local ScriptStartTime = tick()
local CurrentAction = "INITIALIZING SCRIPT..."
local isHopping = false 
local currentCoins = 0

-- 🔧 ĐỒNG BỘ CONFIG
getgenv().Plepor_Config = getgenv().Plepor_Config or {}
local Config = getgenv().Plepor_Config
Config["Turbo Farm"] = Config["Turbo Farm"] == nil and true or Config["Turbo Farm"]
Config["Delete Map"] = Config["Delete Map"] == nil and true or Config["Delete Map"]
Config["Delete Player"] = Config["Delete Player"] == nil and false or Config["Delete Player"]
Config["Ghost Character"] = Config["Ghost Character"] == nil and true or Config["Ghost Character"]
Config["Farm Speed"] = Config["Farm Speed"] or 0.05
Config["Max Players to Hop"] = Config["Max Players to Hop"] or 8
Config["Auto Hop"] = Config["Auto Hop"] == nil and true or Config["Auto Hop"]
Config["Webhook Url"] = Config["Webhook Url"] or ""

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

-- 🛡️ 2. CLEANUP OLD SCRIPT & BLUR
if getgenv().Plepor_Executed then 
    if getgenv().PleporM_Connections then
        for _, v in pairs(getgenv().PleporM_Connections) do if v then v:Disconnect() end end
    end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    if lighting:FindFirstChild("Pleporm_Blur") then lighting.Pleporm_Blur:Destroy() end
end
getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

-- 🕒 4. HÀM CHECK UI (DEEP SCAN TOÀN MÀN HÌNH)
local function IsMatchUI()
    local inMatch = false
    pcall(function()
        local mainGui = pgui:FindFirstChild("MainGUI") or pgui:FindFirstChild("MainGui")
        if not mainGui then return end
        
        -- Quét sâu toàn bộ MainGUI để tìm Đồng hồ đếm ngược (Bất chấp game giấu ở đâu)
        local timerUI = mainGui:FindFirstChild("Timer", true)
        if timerUI and timerUI:IsA("TextLabel") then
            local text = timerUI.Text:upper()
            -- Nếu có các chữ này -> Rõ ràng đang ở sảnh
            if text:find("INTERMISSION") or text:find("VOTING") or text:find("STARTING") or text:find("WAITING") then
                return false 
            -- Nếu nhảy số kiểu "2:30" hoặc "59" -> Đang trong trận cmnr!
            elseif text:match("%d+:%d+") or text:match("^%d+$") then
                inMatch = true
            end
        end

        -- Quét sâu tìm bảng Sinh tồn (Survival) hoặc Vai trò (Role)
        local survivalUI = mainGui:FindFirstChild("Survival", true)
        local roleUI = mainGui:FindFirstChild("Role", true)
        if (survivalUI and survivalUI.Visible) or (roleUI and roleUI.Visible) then
            inMatch = true
        end
    end)
    return inMatch
end

-- 🛠️ 5. OPTIMIZE
local function OptimizePerformance()
    task.spawn(function()
        while getgenv().Plepor_Executed do
            if Config["Delete Map"] then
                pcall(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            local name = v.Name:lower()
                            if name:find("coin") or name:find("gold") or name:find("server") then continue end
                            if not v.Parent:FindFirstChild("Humanoid") then
                                v.Transparency = 1; v.Material = Enum.Material.SmoothPlastic
                            end
                        elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
                    end
                    settings().Rendering.QualityLevel = 1
                end)
            end
            task.wait(5)
        end
    end)
end
OptimizePerformance()

local function BypassAC(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    
    if Config["Ghost Character"] then
        task.spawn(function()
            task.wait(0.5)
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 1 end
            end
        end)
    end

    if root and hum then
        local stepConn = rs.Stepped:Connect(function()
            if char and char.Parent and root and root.Parent then
                root.Velocity = Vector3.new(0, 0, 0); root.RotVelocity = Vector3.new(0, 0, 0)
                for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end)
        table.insert(getgenv().PleporM_Connections, stepConn)
    end
end
table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character then BypassAC(lp.Character) end

-- 🔵 6. AUTO HOP 
local function ServerHop()
    if isHopping then return end
    isHopping = true; CurrentAction = "FINDING NEW SERVER..."
    pcall(function()
        local maxP = tonumber(Config["Max Players to Hop"]) or 5
        local cursor = ""; local foundServer = false
        while not foundServer and getgenv().Plepor_Executed do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            local req = game:HttpGet(url); local data = http:JSONDecode(req)
            if data and data.data then
                local servers = data.data
                for i = #servers, 2, -1 do local j = math.random(i); servers[i], servers[j] = servers[j], servers[i] end
                for _, v in ipairs(servers) do 
                    if type(v) == "table" and tonumber(v.playing) then
                        local playing = tonumber(v.playing)
                        if playing > 2 and playing <= maxP and v.id ~= game.JobId then 
                            foundServer = true; CurrentAction = "JOINING SERVER (" .. playing .. " PLAYERS)..."
                            tps:TeleportToPlaceInstance(game.PlaceId, v.id, lp)
                            task.wait(10); break
                        end 
                    end
                end
                if not foundServer and data.nextPageCursor then cursor = data.nextPageCursor else break end
            else break end
        end
    end)
    task.wait(5); isHopping = false 
end

task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(3) 
        if Config["Auto Hop"] and not isHopping then
            local currentPlayers = #Players:GetPlayers()
            local maxPlayers = tonumber(Config["Max Players to Hop"]) or 5
            if currentPlayers > maxPlayers then ServerHop() end
        end
    end
end)

local function GetCoinFromUI()
    local coinCount = currentCoins -- Giữ nguyên số cũ nếu không tìm thấy
    pcall(function()
        local mainGui = pgui:FindFirstChild("MainGUI") or pgui:FindFirstChild("MainGui")
        if mainGui then
            -- Quét sâu tìm khu vực chứa túi tiền
            local coinContainer = mainGui:FindFirstChild("CoinBags", true) or mainGui:FindFirstChild("CoinBag", true)
            if coinContainer then
                -- Lục lọi các TextLabel bên trong túi tiền
                for _, v in pairs(coinContainer:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local text = v.Text
                        -- Lọc lấy con số (VD: "40 Full!" -> lấy 40, "6" -> lấy 6)
                        local num = tonumber(string.match(text, "%d+"))
                        if num and num <= 50 then -- Đề phòng quét nhầm số to đùng nào đó
                            coinCount = num
                        end
                    end
                end
            end
        end
    end)
    return coinCount
end

-- Vòng lặp cập nhật bảng Hub
task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(0.5) -- Nửa giây update 1 lần cho nhẹ máy
        pcall(function()
            -- Lấy số xu trực tiếp từ UI game
            currentCoins = GetCoinFromUI()
            
            UptimeLabel.Text = "UPTIME: " .. GetUptime()
            CoinBagLabel.Text = "COIN BAG: " .. currentCoins .. "/40"
            TotalGoldLabel.Text = "TOTAL GOLD: $" .. (currentCoins + (math.floor(GetUptimeSeconds() / 180) * 40)) -- Ước tính tạm thời nếu fen ko xài leaderstats
            ActionLabel.Text = "ACTION:\n" .. CurrentAction
            PlayersLabel.Text = "PLAYERS: " .. #game:GetService("Players"):GetPlayers() .. "/" .. game:GetService("Players").MaxPlayers
        end)
    end
end)

-- 📊 6.1. TRACK STATS (ĐỌC UI TÚI TIỀN VÀ RESET CHUẨN)
local currentMapName = "" -- Biến check map để reset túi

local function GetCoinFromUI()
    local count = 0
    pcall(function()
        local mainGui = pgui:FindFirstChild("MainGUI") or pgui:FindFirstChild("MainGui")
        -- Tìm đến con số hiển thị chính xác trên túi tiền MM2
        local gameUI = mainGui and mainGui:FindFirstChild("Game")
        local cashUI = gameUI and gameUI:FindFirstChild("CoinBag") and gameUI.CoinBag:FindFirstChild("Container")
        local amountText = cashUI and cashUI:FindFirstChild("Amount")
        
        if amountText and amountText.Text ~= "" then
            -- Loại bỏ các ký tự lạ, chỉ lấy số (Ví dụ "40/40" -> 40)
            local cleanText = amountText.Text:match("%d+")
            count = tonumber(cleanText) or 0
        end
    end)
    return count
end

task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(0.5)
        pcall(function()
            -- Lấy tên map hiện tại để kiểm tra ván mới
            local currentMap = "None"
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("CoinContainer") then
                    currentMap = v.Name
                    break
                end
            end

            -- Nếu phát hiện sang Map mới, ép túi tiền về 0 ngay lập tức (Chống bug kẹt túi đầy ván cũ)
            if currentMap ~= currentMapName and currentMap ~= "None" then
                currentMapName = currentMap
                currentCoins = 0 
                print("New Map Detected: " .. currentMapName .. " | Resetting Bag Stats.")
            end

            if IsMatchUI() then
                currentCoins = GetCoinFromUI()
            end
            
            UptimeLabel.Text = "UPTIME: " .. GetUptime()
            CoinBagLabel.Text = "COIN BAG: " .. currentCoins .. "/40"
            TotalGoldLabel.Text = "TOTAL GOLD: $" .. (currentCoins + (math.floor(GetUptimeSeconds() / 180) * 40))
            ActionLabel.Text = "ACTION:\n" .. CurrentAction
        end)
    end
end)

-- 🔵 7. UI DESIGN CHIẾN TỪ HÌNH ẢNH (BLUR + ROWS)
local screenBlur = Instance.new("BlurEffect", lighting)
screenBlur.Name = "Pleporm_Blur"; screenBlur.Size = 20

local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999; sg.IgnoreGuiInset = true
local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 0, 0, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5); main.BackgroundColor3 = Color3.fromRGB(35, 40, 45); main.BackgroundTransparency = 0.1; main.BorderSizePixel = 0; main.ClipsDescendants = false; Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(255, 80, 50); stroke.Thickness = 2.5; stroke.Transparency = 0.1

local blurGlow1 = Instance.new("ImageLabel", main); blurGlow1.BackgroundTransparency = 1; blurGlow1.Position = UDim2.new(0, -45, 0, -45); blurGlow1.Size = UDim2.new(1, 90, 1, 90); blurGlow1.ZIndex = -2; blurGlow1.Image = "rbxassetid://5028857084"; blurGlow1.ImageColor3 = Color3.fromRGB(255, 60, 40); blurGlow1.ImageTransparency = 0.5; blurGlow1.ScaleType = Enum.ScaleType.Slice; blurGlow1.SliceCenter = Rect.new(24, 24, 276, 276)
local blurGlow2 = Instance.new("ImageLabel", main); blurGlow2.BackgroundTransparency = 1; blurGlow2.Position = UDim2.new(0, -20, 0, -20); blurGlow2.Size = UDim2.new(1, 40, 1, 40); blurGlow2.ZIndex = -1; blurGlow2.Image = "rbxassetid://5028857084"; blurGlow2.ImageColor3 = Color3.fromRGB(255, 100, 50); blurGlow2.ImageTransparency = 0.3; blurGlow2.ScaleType = Enum.ScaleType.Slice; blurGlow2.SliceCenter = Rect.new(24, 24, 276, 276)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 40); title.Position = UDim2.new(0, 0, 0, 5); title.Text = "PLEPORM HUB - TRACK STATS"; title.TextColor3 = Color3.fromRGB(80, 220, 255); title.TextSize = 22; title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1; title.ZIndex = 2

local rowContainer = Instance.new("Frame", main); rowContainer.Size = UDim2.new(1, -30, 1, -55); rowContainer.Position = UDim2.new(0, 15, 0, 45); rowContainer.BackgroundTransparency = 1; rowContainer.ZIndex = 2
local layout = Instance.new("UIListLayout", rowContainer); layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createRow(name, color, order)
    local row = Instance.new("Frame", rowContainer); row.Size = UDim2.new(1, 0, 0, 35); row.BackgroundColor3 = Color3.fromRGB(25, 30, 35); row.LayoutOrder = order; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local textLabel = Instance.new("TextLabel", row); textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1; textLabel.TextColor3 = color; textLabel.TextSize = 18; textLabel.Font = Enum.Font.GothamBold; textLabel.ZIndex = 3
    return textLabel
end

local timeLbl = createRow("UPTIME: 00:00:00", Color3.fromRGB(240, 240, 240), 1)
local goldLbl = createRow("TOTAL GOLD: $0", Color3.fromRGB(255, 220, 50), 2)
local bagLbl = createRow("💰 COIN BAG: 0/40", Color3.fromRGB(255, 150, 50), 3)
local playersLbl = createRow("PLAYERS: LOADING...", Color3.fromRGB(150, 255, 180), 4)
local statusLbl = createRow("ACTION: INITIALIZING...", Color3.fromRGB(100, 255, 100), 5)

ts:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 380, 0, 280)}):Play()

-- 🟡 8. SPEED-UNCAPPED TURBO FARM (FIX LỖI KẸT LOBBY KHI SANG VÁN MỚI)
task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait() 
        
        if Config["Turbo Farm"] and not isHopping then
            pcall(function()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local inMatch = IsMatchUI()
                
                -- NẾU ĐANG Ở SẢNH CHỜ (Chưa vô map)
                if not inMatch then
                    CurrentAction = "WAITING NEXT MATCH..."
                    currentCoins = 0 -- ÉP RESET TÚI TIỀN VỀ 0 NGAY LẬP TỨC!
                    root.Anchored = false -- Thả lỏng cơ thể để game Teleport vào map
                    return 
                end

                -- ===== ĐÃ VÀO TRẬN =====
                if currentCoins >= 40 then
                    CurrentAction = "BAG FULL! HIDING SAFE..."
                    root.Anchored = true
                    root.CFrame = CFrame.new(root.Position.X, 300, root.Position.Z)
                    task.wait(0.5)
                    return
                end

                local nearestCoin = nil
                local minDistance = math.huge

                -- Quét tìm đồng xu hợp lệ
                local function checkCoin(v)
                    if v and v:IsA("BasePart") and not v.Name:find("Collected") then
                        if v.Name == "Coin_Server" or v.Name == "Coin" or v.Name:match("_Server$") then
                            local dist = (root.Position - v.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                nearestCoin = v
                            end
                        end
                    end
                end

                -- Tìm rổ xu của map mới (Đổi từ GetChildren sang tìm kiếm bao quát hơn)
                local container = nil
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChild("CoinContainer") then
                        container = obj.CoinContainer
                        break
                    end
                end

                if container then
                    for _, coinNode in ipairs(container:GetChildren()) do
                        local target = coinNode
                        if coinNode:IsA("Model") then target = coinNode.PrimaryPart or coinNode:FindFirstChildWhichIsA("BasePart", true) end
                        checkCoin(target)
                    end
                else
                    for _, v in ipairs(workspace:GetDescendants()) do checkCoin(v) end
                end

                -- TIẾN HÀNH THU HOẠCH
                if nearestCoin then
                    CurrentAction = "SPEED FARMING..."
                    
                    local dist = (root.Position - nearestCoin.Position).Magnitude
                    local safeSpeed = 55 
                    local duration = dist / safeSpeed
                    if duration < 0.1 then duration = 0.1 end

                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end

                    root.Anchored = true 
                    root.Velocity = Vector3.zero
                    
                    local targetCFrame = nearestCoin.CFrame + Vector3.new(0, 0.5, 0)
                    local tween = ts:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                    tween:Play()

                    local maxWait = tick() + duration + 0.2
                    while nearestCoin.Parent and IsMatchUI() and tick() < maxWait do
                        local currentDist = (root.Position - nearestCoin.Position).Magnitude
                        if currentDist <= 3.5 then 
                            tween:Cancel() 
                            break 
                        end
                        task.wait()
                    end

                    root.CFrame = nearestCoin.CFrame
                    root.Anchored = false 
                    task.wait(0.03) 
                    
                    if firetouchinterest then
                        firetouchinterest(root, nearestCoin, 0)
                        firetouchinterest(root, nearestCoin, 1)
                    end
                    task.wait(0.03) 
                    
                    nearestCoin.Name = "Collected"
                    pcall(function() nearestCoin.Transparency = 1; nearestCoin.CFrame = CFrame.new(0, -9999, 0) end)

                    root.Anchored = true
                    root.CFrame = root.CFrame + Vector3.new(0, 40, 0)
                else
                    CurrentAction = "SCANNING FOR COINS..."
                    root.Anchored = true
                    root.Velocity = Vector3.zero
                    task.wait(0.5) 
                end
            end)
        end
    end
end)

-- ⚪ 9. UI UPDATE LOOP
task.spawn(function()
    while sg.Parent do
        task.wait(0.5)
        pcall(function()
            local elapsed = tick() - ScriptStartTime
            local hours = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = math.floor(elapsed % 60)
            timeLbl.Text = string.format("UPTIME: %02d:%02d:%02d", hours, mins, secs)

            local mainGui = pgui:FindFirstChild("MainGUI") or pgui:FindFirstChild("MainGui")
            if mainGui then
                local sb = mainGui:FindFirstChild("Scoreboard", true)
                local gold = "0"
                if sb then
                    for _, v in pairs(sb:GetDescendants()) do
                        if v:IsA("TextLabel") and type(v.Text) == "string" and v.Text ~= "" then
                            if v.Text:match("%d") and not v.Text:find("/") then
                                local n = v.Text:match("[%d%,]+")
                                if n and n ~= "2018" and n ~= "2019" then gold = n break end
                            end
                        end
                    end
                end
                goldLbl.Text = "TOTAL GOLD: $" .. gold

                local coinTextObj = mainGui:FindFirstChild("CoinText", true)
                if not coinTextObj then
                    for _, v in pairs(mainGui:GetDescendants()) do
                        if v:IsA("TextLabel") and (v.Name == "CoinText" or v.Name == "CoinAmount") then coinTextObj = v break end
                    end
                end
                
                if coinTextObj and tonumber(coinTextObj.Text) then currentCoins = tonumber(coinTextObj.Text) end
            end
            
            bagLbl.Text = "💰 COIN BAG: " .. tostring(currentCoins) .. "/40"
            local players = Players:GetPlayers()
            playersLbl.Text = "PLAYERS: " .. tostring(#players) .. "/12"
            statusLbl.Text = "ACTION: " .. tostring(CurrentAction)
            
            if CurrentAction:find("FARMING") then statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif CurrentAction:find("WAITING") then statusLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
            elseif CurrentAction:find("FULL") or CurrentAction:find("FINDING") or CurrentAction:find("JOINING") then statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            else statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end)
    end
end)

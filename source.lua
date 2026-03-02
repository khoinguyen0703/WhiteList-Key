-- [[ PLEPORM HUB V107 - FINAL MASTERPIECE ]]
-- [ RESTORED: WAIT FOR MATCH | ADDED: UI OPEN TWEEN | IMPROVED: BYPASS ANTI-CHEAT ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local pgui = lp:WaitForChild("PlayerGui")
local lighting = game:GetService("Lighting")
local http = game:GetService("HttpService")
local ts = game:GetService("TweenService")

local ScriptStartTime = tick()
local CurrentAction = "INITIALIZING SCRIPT..."

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
                ["description"] = "✅ **Successfully collected " .. tostring(goldAmount) .. " coins!**\n👤 **Player:** ||" .. lp.Name .. "||",
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
                    if v:IsA("BasePart") and not (v.Name:lower():find("coin") or v.Name:lower():find("gold")) and not v.Parent:FindFirstChild("Humanoid") then
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

-- Nâng cấp Bypass Anti-cheat & Noclip: Giam Velocity về 0 cực chặt, chống game phát hiện bay nhanh
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

-- 🔵 5. AUTO HOP TARGET SERVER
local function ServerHop()
    CurrentAction = "HOPPING SERVER..."
    pcall(function()
        local Config = getgenv().Plepor_Config
        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        table.sort(res, function(a, b) return a.playing < b.playing end)
        for _, v in pairs(res) do 
            if v.playing > 2 and v.playing <= (tonumber(Config["Max Players to Hop"]) or 5) and v.id ~= game.JobId then 
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id); return
            end 
        end
    end)
end

-- 🔵 6. UI GLASS DESIGN (PIXEL FONT + TWEEN OPEN EFFECT)
local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
-- Bắt đầu với Size 0 để làm hiệu ứng bật lên
main.Size = UDim2.new(0, 0, 0, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.4; main.BorderSizePixel = 0
main.ClipsDescendants = true -- Ẩn chữ bên trong khi Frame chưa mở hết
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 35); title.Text = "PLEPORM HUB V107"; title.TextColor3 = Color3.fromRGB(255, 60, 60); title.TextSize = 25; title.Font = Enum.Font.Arcade; title.BackgroundTransparency = 1
local timeLbl = Instance.new("TextLabel", main); timeLbl.Size = UDim2.new(1, 0, 0, 20); timeLbl.Position = UDim2.new(0, 0, 0, 35); timeLbl.TextSize = 16; timeLbl.Font = Enum.Font.Arcade; timeLbl.TextColor3 = Color3.fromRGB(200, 200, 200); timeLbl.BackgroundTransparency = 1
local goldLbl = Instance.new("TextLabel", main); goldLbl.Size = UDim2.new(1, 0, 0, 30); goldLbl.Position = UDim2.new(0, 0, 0, 60); goldLbl.TextSize = 22; goldLbl.Font = Enum.Font.Arcade; goldLbl.TextColor3 = Color3.fromRGB(100, 255, 100); goldLbl.BackgroundTransparency = 1
local bagLbl = Instance.new("TextLabel", main); bagLbl.Size = UDim2.new(1, 0, 0, 30); bagLbl.Position = UDim2.new(0, 0, 0, 90); bagLbl.TextSize = 22; bagLbl.Font = Enum.Font.Arcade; bagLbl.TextColor3 = Color3.fromRGB(255, 230, 100); bagLbl.BackgroundTransparency = 1
local statusLbl = Instance.new("TextLabel", main); statusLbl.Size = UDim2.new(1, 0, 0, 25); statusLbl.Position = UDim2.new(0, 0, 0, 140); statusLbl.TextSize = 14; statusLbl.Font = Enum.Font.Arcade; statusLbl.BackgroundTransparency = 1

-- Bật hiệu ứng mở Track Stat (Pop-up mượt mà)
ts:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 190)}):Play()

-- 🟡 7. SUPER TURBO FARM (WITH UI SCANNER & LOGGING)
local currentCoins, isResetting = 0, false
local lastCoinTick = tick()

task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait() -- Bỏ 0.05, dùng task.wait() trần để luồng chính quét nhanh nhất
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isResetting then
            pcall(function()
                -- QUÉT UI CHỜ VÀO TRẬN (Giữ nguyên không đụng)
                local isWaitingForMap = false
                for _, v in pairs(pgui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible and v.Text ~= "" then
                        local txt = string.lower(v.Text)
                        if txt:find("waiting for your turn") or 
                           txt:find("receive your weapon") or 
                           txt:find("loading") or 
                           txt:find("intermission") or 
                           txt:find("voting") then
                            isWaitingForMap = true
                            break
                        end
                    end
                end

                if isWaitingForMap then
                    CurrentAction = "WAITING FOR MATCH..."
                    return
                end

                -- LOGIC NHẶT VÀNG & BYPASS
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                if tick() - lastCoinTick > 180 and Config["Auto Hop"] then 
                    print("⚠️ [LOG] Stuck for 3 minutes, hopping server...")
                    ServerHop(); return 
                end

                if currentCoins >= 40 then
                    CurrentAction = "BAG FULL! RESETTING..."
                    isResetting = true
                    print("💰 [LOG] Bag full (40 coins)! Sending Webhook and Resetting character...")
                    SendWebhook(currentCoins)
                    char:BreakJoints()
                    task.wait(7.5)
                    currentCoins = 0
                    isResetting = false
                    return
                end

                local foundCoin = false
                local searchArea = workspace:FindFirstChild("Normal") or workspace
                
                for _, v in ipairs(searchArea:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        if v.Transparency < 0.9 then
                            foundCoin = true
                            CurrentAction = "COLLECTING COINS..."
                            print("🔍 [LOG] Found coin: [" .. v.Name .. "]")
                            
                            local timeout = tick()
                            
                            -- VÒNG LẶP XÁC THỰC: Bám dính và gửi lệnh chạm cho đến khi Server game thực sự xóa vàng
                            while v and v.Parent and v.Transparency < 0.9 do
                                if tick() - timeout > 1.5 then 
                                    print("⚠️ [LOG] Timeout! Server is lagging or coin is bugged.")
                                    break -- Tránh kẹt vĩnh viễn ở 1 cục vàng bị lỗi (Timeout 1.5s)
                                end
                                
                                if char and root and root.Parent then
                                    root.CFrame = v.CFrame
                                    firetouchinterest(root, v, 0)
                                    firetouchinterest(root, v, 1)
                                end
                                rs.Heartbeat:Wait() -- Bơm lệnh chạm siêu tốc theo FPS máy
                            end
                            
                            -- Kiểm tra lại: Nếu vàng thực sự đã bị Game làm mờ/xóa thì mới tính điểm
                            if not v or not v.Parent or v.Transparency >= 0.9 then
                                print("✅ [LOG] Server confirmed collection!")
                                currentCoins = currentCoins + 1
                                lastCoinTick = tick()
                            else
                                -- Nếu quá thời gian mà vàng vẫn trơ ra đó -> Giấu nó đi để qua cục khác
                                print("❌ [LOG] Failed to collect. Hiding bugged coin.")
                                v.Name = "Bugged_PleporM"
                                v.Transparency = 1
                                v.CFrame = CFrame.new(0, -9999, 0)
                            end
                            
                            task.wait(Config["Farm Speed"] or 0) -- Để Speed bằng 0 sẽ là tốc độ bàn thờ
                            break -- Xong cục này mới vòng lại tìm cục khác
                        end
                    end
                end
                
                if not foundCoin then 
                    CurrentAction = workspace:FindFirstChild("Normal") and "WAITING FOR COIN SPAWN..." or "WAITING FOR NEXT MATCH..."
                    lastCoinTick = tick() 
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
                    if v:IsA("TextLabel") and v.Text:match("%d") and not v.Text:find("/") then
                        local n = v.Text:match("[%d%,]+")
                        if n and n ~= "2018" and n ~= "2019" then gold = n break end
                    end
                end
            end
            goldLbl.Text = "TOTAL GOLD: $" .. gold
            bagLbl.Text = "COIN BAG: " .. currentCoins .. "/40"
            
            statusLbl.Text = "STATUS: " .. CurrentAction
            if CurrentAction:find("COLLECTING") then statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif CurrentAction:find("WAITING") then statusLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
            elseif CurrentAction:find("RESETTING") or CurrentAction:find("HOPPING") then statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            else statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end)
    end
end)

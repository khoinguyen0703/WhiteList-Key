-- [[ PLEPORM HUB - ULTIMATE TRACK STATS ]]
-- [ GLOW UI | PLAYER TRACKER | GUARANTEED COLLECTION | BYPASS AC ]

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
                ["description"] = "✅ **Successfully collected " .. tostring(goldAmount) .. " coins!**\n👤 **Player:** ||" .. lp.Name .. "||\n👥 **Server Players:** " .. tostring(#game.Players:GetPlayers()),
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

-- 🔵 6. UI GLASS DESIGN (WITH GLOW EFFECT & NEW LAYOUT)
local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 0, 0, 0); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.3; main.BorderSizePixel = 0
main.ClipsDescendants = false -- Cho phép phần mờ (Glow) tràn ra ngoài khung
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

-- Hiệu ứng vạch đỏ viền mảnh xung quanh bảng UI
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 50, 50)
stroke.Thickness = 1.5
stroke.Transparency = 0.2

-- HIỆU ỨNG MỜ TỎA RA XUNG QUANH (GLOW BACKGROUND)
local glow = Instance.new("ImageLabel", main)
glow.Name = "GlowEffect"
glow.BackgroundTransparency = 1
glow.Position = UDim2.new(0, -30, 0, -30) -- Tràn ra ngoài 30 pixel mỗi góc
glow.Size = UDim2.new(1, 60, 1, 60)
glow.ZIndex = 0
glow.Image = "rbxassetid://5028857084" -- Hình ảnh Bóng mờ mặc định của Roblox
glow.ImageColor3 = Color3.fromRGB(255, 200, 100) -- Chỉnh sang màu Vàng nhạt tỏa ra như hình
glow.ImageTransparency = 0.4
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)

-- Các dòng thông số (ZIndex = 2 để nổi lên trên Glow)
local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 35); title.Position = UDim2.new(0, 0, 0, 5); title.Text = "PLEPORM HUB - TRACK STATS"; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.TextSize = 22; title.Font = Enum.Font.Arcade; title.BackgroundTransparency = 1; title.ZIndex = 2
local timeLbl = Instance.new("TextLabel", main); timeLbl.Size = UDim2.new(1, 0, 0, 20); timeLbl.Position = UDim2.new(0, 0, 0, 45); timeLbl.TextSize = 18; timeLbl.Font = Enum.Font.Arcade; timeLbl.TextColor3 = Color3.fromRGB(200, 200, 200); timeLbl.BackgroundTransparency = 1; timeLbl.ZIndex = 2
local goldLbl = Instance.new("TextLabel", main); goldLbl.Size = UDim2.new(1, 0, 0, 30); goldLbl.Position = UDim2.new(0, 0, 0, 75); goldLbl.TextSize = 22; goldLbl.Font = Enum.Font.Arcade; goldLbl.TextColor3 = Color3.fromRGB(255, 215, 0); goldLbl.BackgroundTransparency = 1; goldLbl.ZIndex = 2
local bagLbl = Instance.new("TextLabel", main); bagLbl.Size = UDim2.new(1, 0, 0, 30); bagLbl.Position = UDim2.new(0, 0, 0, 105); bagLbl.TextSize = 20; bagLbl.Font = Enum.Font.Arcade; bagLbl.TextColor3 = Color3.fromRGB(200, 160, 100); bagLbl.BackgroundTransparency = 1; bagLbl.ZIndex = 2
local playersLbl = Instance.new("TextLabel", main); playersLbl.Size = UDim2.new(1, 0, 0, 25); playersLbl.Position = UDim2.new(0, 0, 0, 135); playersLbl.TextSize = 18; playersLbl.Font = Enum.Font.Arcade; playersLbl.TextColor3 = Color3.fromRGB(150, 200, 255); playersLbl.BackgroundTransparency = 1; playersLbl.ZIndex = 2
local statusLbl = Instance.new("TextLabel", main); statusLbl.Size = UDim2.new(1, 0, 0, 40); statusLbl.Position = UDim2.new(0, 0, 0, 165); statusLbl.TextSize = 16; statusLbl.Font = Enum.Font.Arcade; statusLbl.BackgroundTransparency = 1; statusLbl.ZIndex = 2; statusLbl.TextWrapped = true

-- Hiệu ứng Mở Track Stat cực ngầu (mở rộng về size 320x210)
ts:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 215)}):Play()

-- 🟡 7. SUPER TURBO FARM (GUARANTEED COLLECTION)
local currentCoins, isResetting = 0, false
local lastCoinTick = tick()

task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(0.05) -- Để 0.05s thay vì tick() trần để tránh crash Game
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isResetting then
            pcall(function()
                -- QUÉT UI CHỜ VÀO TRẬN
                local isWaitingForMap = false
                for _, v in pairs(pgui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible and v.Text ~= "" then
                        local txt = string.lower(v.Text)
                        if txt:find("waiting for your turn") or txt:find("receive your weapon") or txt:find("intermission") or txt:find("voting") then
                            isWaitingForMap = true; break
                        end
                    end
                end

                if isWaitingForMap then CurrentAction = "WAITING FOR MATCH..."; return end

                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                if tick() - lastCoinTick > 180 and Config["Auto Hop"] then ServerHop(); return end

                if currentCoins >= 40 then
                    CurrentAction = "BAG FULL! RESETTING..."
                    isResetting = true
                    SendWebhook(currentCoins)
                    char:BreakJoints(); task.wait(7.5)
                    currentCoins = 0; isResetting = false; return
                end

                local foundCoin = false
                local searchArea = workspace:FindFirstChild("Normal") or workspace
                
                for _, v in ipairs(searchArea:GetDescendants()) do
                    -- Tìm đúng Vàng Thật (Có chứa TouchTransmitter)
                    if v:IsA("BasePart") and (v.Name == "Coin_Server" or v.Name == "Coin") then
                        if v.Transparency < 0.9 and v:FindFirstChild("TouchTransmitter") then
                            foundCoin = true
                            CurrentAction = "COLLECTING COINS"
                            
                            -- Bay tới vị trí Vàng
                            root.CFrame = v.CFrame
                            task.wait(0.02) -- Nghỉ một nhịp siêu nhỏ để nhân vật load vị trí
                            
                            -- Chạm 1 lần dứt khoát (An toàn không bị Game kick)
                            firetouchinterest(root, v, 0)
                            task.wait(0.01)
                            firetouchinterest(root, v, 1)
                            
                            -- Đánh dấu đã nhặt trên máy mình để qua cục khác luôn
                            v.Name = "Collected_PleporM"
                            v.Transparency = 1
                            v.CFrame = CFrame.new(0, -9999, 0)
                            
                            currentCoins = currentCoins + 1
                            lastCoinTick = tick()
                            
                            -- Khuyến nghị Farm Speed nên để 0.05 hoặc 0.1 cho an toàn
                            task.wait(Config["Farm Speed"] or 0.05)
                            break 
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

-- ⚪ 8. INITIALIZE UI LOOP (UPDATE TRACK STATS)
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
            
            -- TRACK THÊM SỐ NGƯỜI CHƠI TRONG SERVER
            playersLbl.Text = "PLAYERS: " .. tostring(#game.Players:GetPlayers()) .. "/12"
            
            statusLbl.Text = "ACTION:\n" .. CurrentAction
            if CurrentAction:find("COLLECTING") then statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif CurrentAction:find("WAITING") then statusLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
            elseif CurrentAction:find("RESETTING") or CurrentAction:find("HOPPING") then statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            else statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end)
    end
end)

-- [[ PLEPORM HUB V75 - MATCH-BASED FARM & PRECISION TRACK ]]
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

-- 🔴 1. DỌN DẸP BỘ NHỚ (ANTI-LEAK)
if getgenv().Plepor_Executed then 
    for _, v in pairs(getgenv().Plepor_Connections or {}) do v:Disconnect() end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
end
getgenv().Plepor_Executed = true
getgenv().Plepor_Connections = {}

-- 🟢 2. WHITELIST
local function Verify()
    local s, content = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt?t="..tick()) end)
    if s then
        for line in content:gmatch("[^\r\n]+") do
            if line:gsub("%s+", "") == UserKey then return true end
        end
    end
    return false
end
if not Verify() then lp:Kick("❌ INVALID KEY!") return end

-- 🟡 3. HÀM LẤY TIỀN TRONG KHO (TOTAL GOLD)
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

-- 🔵 4. KIỂM TRA ĐANG TRONG TRẬN HAY Ở SẢNH
local function IsInMatch()
    -- MM2 đặt map ở workspace.Normal hoặc dựa trên vị trí nhân vật
    local map = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map")
    if map and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        -- Kiểm tra nếu nhân vật không nằm ở tọa độ Sảnh (thường sảnh nằm ở tầm Y > 200 hoặc khu vực riêng)
        if lp.Character.HumanoidRootPart.Position.Y < 150 then 
            return true 
        end
    end
    return false
end

-- 🟠 5. LOGIC FARM CHUẨN (CHỈ NHẶT KHI VÀO TRẬN)
local currentCoins = 0
local isResetting = false
local lastGold = GetTotalGold() -- Lưu số tiền trước khi farm

task.spawn(function()
    while task.wait(0.1) do
        if Config["Turbo Farm"] and not isResetting then
            
            -- CHỈ CHẠY KHI ĐÃ VÀO MAP
            if IsInMatch() then
                local root = lp.Character.HumanoidRootPart
                
                -- ĐỦ 40 THÌ RESET
                if currentCoins >= 40 then
                    isResetting = true
                    
                    -- Reset nhân vật
                    pcall(function()
                        lp.Character:BreakJoints()
                        lp.Character.Humanoid.Health = 0
                    end)

                    -- ĐỢI TIỀN TĂNG RỒI MỚI TRACK
                    task.delay(5, function()
                        local newGold = GetTotalGold()
                        if newGold ~= lastGold then -- Tiền thực sự tăng mới báo
                            local url = Config["Webhook Url"]
                            if url and url:find("discord") then
                                local data = {["embeds"] = {{
                                    ["title"] = "💰 Round Completed!",
                                    ["description"] = "Successfully collected 40 coins.\nOld Gold: **$"..lastGold.."**\nNew Gold: **$"..newGold.."**",
                                    ["color"] = 0x00FF00
                                }}}
                                request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = http:JSONEncode(data)})
                            end
                            lastGold = newGold
                        end
                    end)

                    task.wait(7) -- Chờ hồi sinh sạch sẽ
                    currentCoins = 0
                    if Config["Auto Hop"] and #game.Players:GetPlayers() > MaxPlayers then 
                        -- Hàm ServerHop tự viết ở bản trước
                    end
                    isResetting = false
                else
                    -- QUÉT COIN TRONG MAP
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                            if v.Transparency < 1 and v.Parent and v.Parent.Name ~= "Temp" then -- Tránh coin rác
                                root.CFrame = v.CFrame
                                firetouchinterest(root, v, 0); rs.Heartbeat:Wait(); firetouchinterest(root, v, 1)
                                currentCoins = currentCoins + 1
                                task.wait(Config["Farm Speed"] or 0)
                                break 
                            end
                        end
                    end
                end
            else
                -- NẾU ĐANG Ở SẢNH (LOBBY)
                currentCoins = 0 -- Reset bộ đếm túi khi hết trận
                -- Có thể thêm thông báo "Waiting for match..." lên UI tại đây
            end
        end
    end
end)

-- ⚪ 6. UI PLEPORM V75
local function CreateUI()
    local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 260); main.Position = UDim2.new(0.5, -210, 0.2, -130); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 2
    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,30); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s; l.Font = Enum.Font.Arcade; l.BackgroundTransparency = 1; return l
    end
    Lbl("PLEPORM HUB V75", UDim2.new(0,0,0,10), Color3.fromRGB(255, 50, 50), 38)
    local tG = Lbl("TOTAL GOLD: $" .. GetTotalGold(), UDim2.new(0,0,0,90), Color3.fromRGB(80, 255, 80), 22)
    local cB = Lbl("COIN BAG: 0/40", UDim2.new(0,0,0,125), Color3.fromRGB(255, 255, 100), 20)
    local st = Lbl("STATUS: WAITING FOR MATCH", UDim2.new(0,0,0,160), Color3.fromRGB(255, 255, 255), 18)

    task.spawn(function()
        while task.wait(1) do
            if not sg.Parent then break end
            tG.Text = "TOTAL GOLD: $" .. GetTotalGold()
            cB.Text = "COIN BAG: " .. currentCoins .. "/40"
            st.Text = IsInMatch() and "STATUS: FARMING IN MATCH" or "STATUS: WAITING FOR MATCH"
        end
    end)
end

-- ANTI-AFK
table.insert(getgenv().PleporM_Connections, lp.Idled:Connect(function() 
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
end))

CreateUI()

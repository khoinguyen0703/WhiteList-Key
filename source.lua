-- [[ PLEPORM HUB V55 - FINAL OPTIMIZED ]]
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")

-- 1. GIỮ NGUYÊN WEBHOOK CỦA BẠN (Điền URL của bạn vào đây)
local WebhookURL = "URL_WEBHOOK_CỦA_BẠN_Ở_ĐÂY"

-- 2. HÀM GỬI WEBHOOK (KHÔNG XÓA)
local function SendWebhook(msg)
    if WebhookURL == "" or WebhookURL == "URL_WEBHOOK_CỦA_BẠN_Ở_ĐÂY" then return end
    pcall(function()
        local data = {["content"] = msg}
        local userdata = game:GetService("HttpService"):JSONEncode(data)
        request({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = userdata})
    end)
end

-- 3. HÀM TRÍCH XUẤT THÔNG SỐ TỪ SCOREBOARD (Dựa trên kết quả dò tìm)
local function GetStats()
    local lvl = "0"
    local gold = "0"
    pcall(function()
        -- Quét Level từ các mode Classic/Scary/Assassin
        local sb = pgui:FindFirstChild("Scoreboard")
        if sb then
            for _, mode in pairs(sb:GetChildren()) do
                local lTxt = mode:FindFirstChild("LevelText", true) or mode:FindFirstChild("Level", true)
                if lTxt and lTxt:IsA("TextLabel") and lTxt.Text ~= "" then
                    lvl = lTxt.Text:match("%d+") or "0"
                    break
                end
            end
            -- Quét Gold từ CoinIcon
            for _, mode in pairs(sb:GetChildren()) do
                local cIcon = mode:FindFirstChild("CoinIcon", true) or mode:FindFirstChild("Coins", true)
                if cIcon then
                    local gTxt = cIcon.Parent:FindFirstChildOfClass("TextLabel") or cIcon:FindFirstChildOfClass("TextLabel")
                    if gTxt and gTxt.Text ~= "" then
                        gold = gTxt.Text:match("[%d%,%s]+") or "0"
                        break
                    end
                end
            end
        end
    end)
    return lvl, gold
end

-- 4. COIN FARM + AUTO RESET 40 COINS
local coinCount = 0
task.spawn(function()
    while task.wait() do
        local config = getgenv().Plepor_Config
        if config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            
            -- Reset sau 40 coins
            if coinCount >= 40 then
                SendWebhook("🛡️ PleporM Hub: Đã nhặt đủ 40 coin, đang Reset nhân vật...")
                coinCount = 0
                lp.Character.Humanoid.Health = 0
                task.wait(5)
                continue
            end

            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        rs.Heartbeat:Wait()
                        firetouchinterest(root, v, 1)
                        coinCount = coinCount + 1
                        task.wait(config["Farm Speed"] or 0)
                        break 
                    end
                end
            end)
        end
    end
end)

-- 5. UI PIXEL CHUẨN
local function CreateUI()
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 260); main.Position = UDim2.new(0.5, -210, 0.2, -130); main.BackgroundTransparency = 1

    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,35); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s
        l.Font = Enum.Font.Arcade; l.TextStrokeTransparency = 0; l.BackgroundTransparency = 1; return l
    end

    Lbl("PLEPORM HUB", UDim2.new(0,0,0,0), Color3.fromRGB(255, 50, 50), 45)
    local st = Lbl("> Status: Ghost Active", UDim2.new(0,0,0,55), Color3.fromRGB(255, 200, 100), 22)
    local gr = Lbl("LVL: 0 | GOLD: $0", UDim2.new(0,0,0,95), Color3.fromRGB(80, 255, 80), 24)
    local cnLabel = Lbl("Session Coins: 0/40", UDim2.new(0,0,0,135), Color3.fromRGB(255, 255, 100), 20)
    local tm = Lbl("Uptime: 0H 0M 0S", UDim2.new(0,0,0,175), Color3.fromRGB(200, 200, 200), 18)

    task.spawn(function()
        local start = tick()
        while task.wait(1) do
            local d = tick() - start
            local clvl, cgold = GetStats() -- Cập nhật Level/Gold thực tế
            
            tm.Text = string.format("Uptime: %dH %dM %dS", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
            gr.Text = "LVL: " .. clvl .. " | GOLD: $" .. cgold
            cnLabel.Text = "Session Coins: " .. coinCount .. "/40"
        end
    end)
end

-- [ Whitelist & Anti-AFK giữ nguyên ]
if not game:IsLoaded() then game.Loaded:Wait() end
CreateUI()
SendWebhook("✅ PleporM Hub V55 đã khởi chạy cho người dùng: " .. lp.Name)

-- [[ PLEPORM HUB V68 - MASTER CUSTOM HOP ]]
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local http = game:GetService("HttpService")
local ts = game:GetService("TeleportService")

local Config = getgenv().Plepor_Config
local UserKey = _G.script_key or "No Key"
-- Lấy số lượng người tối đa từ khách, mặc định là 5
local MaxPlayers = Config["Max Players to Hop"] or 5

-- 🔴 1. WEBHOOK TRACKING (GỬI VỀ CHO KHÁCH)
local function SendTrack(msg)
    local url = Config["Webhook Url"]
    if not url or url == "" or url:find("webhook") then return end
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "🛡️ PleporM Hub - Tracking",
                ["description"] = msg,
                ["color"] = 0xFF3232,
                ["fields"] = {
                    {["name"] = "Player", ["value"] = lp.Name, ["inline"] = true},
                    {["name"] = "Server", ["value"] = #game.Players:GetPlayers() .. " players", ["inline"] = true}
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = http:JSONEncode(data)})
    end)
end

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
if not Verify() then lp:Kick("❌ SAI KEY!") return end

-- 🔵 3. AUTO HOP (Tối ưu theo số lượng khách nhập)
local hopping = false
local function ServerHop()
    if hopping then return end
    hopping = true
    SendTrack("⚠️ Server hiện tại có " .. #game.Players:GetPlayers() .. " người (Giới hạn: " .. MaxPlayers .. "). Đang tìm Server vắng hơn...")
    
    local x = {}
    pcall(function()
        local servers = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, v in pairs(servers) do
            if v.playing < MaxPlayers and v.id ~= game.JobId then
                x[#x + 1] = v.id
            end
        end
    end)

    if #x > 0 then
        ts:TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
    else
        hopping = false
    end
end

-- 🟡 4. TRACKSTAT SIÊU CẤP (Dựa trên log của khách)
local function GetStats()
    local lvl, gold = "0", "0"
    pcall(function()
        local l = pgui:FindFirstChild("LevelText", true) or pgui:FindFirstChild("Level", true)
        if l and l.Text ~= "" then lvl = l.Text:match("%d+") or lvl end
        
        for _, v in pairs(pgui:GetDescendants()) do
            if v:IsA("TextLabel") and (v.Name == "CoinIcon" or v.Parent.Name == "Coins" or v.Name == "CashAmount") then
                local t = v.Text ~= "" and v.Text or (v.Parent:FindFirstChildOfClass("TextLabel") and v.Parent:FindFirstChildOfClass("TextLabel").Text)
                if t and t:match("%d") and not t:find("x") then
                    local n = t:match("[%d%,]+")
                    if n and n ~= "2018" and n ~= "2019" and #n < 8 then
                        gold = n
                        break
                    end
                end
            end
        end
    end)
    return lvl, gold
end

-- 🟠 5. GHOST FARM & RESET 40 COINS
local coinCount = 0
task.spawn(function()
    while task.wait() do
        -- Kiểm tra số người để Hop
        if Config["Auto Hop"] and #game.Players:GetPlayers() > MaxPlayers then
            ServerHop()
            task.wait(10)
        end

        if Config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            if coinCount >= 40 then
                local clvl, cgold = GetStats()
                SendTrack("💰 Đã nhặt đủ 40 coins!\n**Level:** " .. clvl .. "\n**Vàng:** $" .. cgold)
                coinCount = 0
                lp.Character:BreakJoints()
                task.wait(7)
                continue
            end
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                    root.CFrame = v.CFrame
                    firetouchinterest(root, v, 0); rs.Heartbeat:Wait(); firetouchinterest(root, v, 1)
                    coinCount = coinCount + 1
                    task.wait(Config["Farm Speed"] or 0)
                    break 
                end
            end
        end
    end
end)

-- ⚪ 6. UI & BOOT
local function CreateUI()
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 260); main.Position = UDim2.new(0.5, -210, 0.2, -130); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 2
    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,30); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s; l.Font = Enum.Font.Arcade; l.BackgroundTransparency = 1; return l
    end
    Lbl("PLEPORM HUB V68", UDim2.new(0,0,0,10), Color3.fromRGB(255, 50, 50), 38)
    local gr = Lbl("LVL: 0 | GOLD: $0", UDim2.new(0,0,0,90), Color3.fromRGB(80, 255, 80), 22)
    local cn = Lbl("Session Coins: 0/40", UDim2.new(0,0,0,125), Color3.fromRGB(255, 255, 100), 20)
    local ps = Lbl("Players: " .. #game.Players:GetPlayers() .. " (Max: " .. MaxPlayers .. ")", UDim2.new(0,0,0,160), Color3.fromRGB(255, 255, 255), 18)

    task.spawn(function()
        while task.wait(1.5) do
            local clvl, cgold = GetStats()
            gr.Text = "LVL: " .. clvl .. " | GOLD: $" .. cgold
            cn.Text = "Session Coins: " .. coinCount .. "/40"
            ps.Text = "Players: " .. #game.Players:GetPlayers() .. " (Max: " .. MaxPlayers .. ")"
        end
    end)
end

lp.Idled:Connect(function() vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
CreateUI()
SendTrack("🚀 Script khởi chạy! Server limit: " .. MaxPlayers)

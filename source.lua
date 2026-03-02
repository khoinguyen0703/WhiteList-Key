-- [[ PLEPORM HUB V30 - UI + FARM + OPTIMIZE ]]
local request = (syn and syn.request) or (http and http.request) or http_request or (Fluxus and Fluxus.request) or request

-- 1. HỆ THỐNG WHITELIST
local UserKey = _G.script_key or script_key
local WhitelistURL = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt?t=" .. tick()

local function Verify()
    local success, content = pcall(function() return game:HttpGet(WhitelistURL) end)
    if success then
        local function clean(str) return tostring(str):gsub("%s+", ""):gsub("%c+", "") end
        local cleanUserKey = clean(UserKey)
        for line in content:gmatch("[^\r\n]+") do
            if clean(line) == cleanUserKey then return true end
        end
    end
    return false
end

if not Verify() then
    game.Players.LocalPlayer:Kick("❌ WRONG KEY! Liên hệ PleporM Hub.")
    return
end

-- 2. BIẾN HỆ THỐNG & CẤU HÌNH
local Config = getgenv().Plepor_Config
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local HTTP = game:GetService("HttpService")

-- 3. TẠO GIAO DIỆN (UI) GIỐNG FENNIR HUB MẪU
local function CreateUI()
    local sg = Instance.new("ScreenGui", lp.PlayerGui)
    sg.Name = "PlepormHub_UI"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 350, 0, 200)
    main.Position = UDim2.new(0.5, -175, 0.4, -100)
    main.BackgroundTransparency = 1 -- Trong suốt như ảnh mẫu

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "Pleporm Hub"
    title.TextColor3 = Color3.fromRGB(255, 60, 60) -- Màu đỏ Fennir
    title.TextSize = 35
    title.Font = Enum.Font.SourceSansBold
    title.BackgroundTransparency = 1

    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 40)
    status.Text = "Status: Loading"
    status.TextColor3 = Color3.fromRGB(255, 200, 100) -- Màu cam vàng
    status.TextSize = 22
    status.Font = Enum.Font.SourceSansSemibold
    status.BackgroundTransparency = 1

    local timer = Instance.new("TextLabel", main)
    timer.Size = UDim2.new(1, 0, 0, 25)
    timer.Position = UDim2.new(0, 0, 0, 70)
    timer.Text = "0 Hours, 0 Minutes, 0 Seconds (v3.0)"
    timer.TextColor3 = Color3.fromRGB(200, 200, 200)
    timer.TextSize = 18
    timer.BackgroundTransparency = 1

    local stats = Instance.new("TextLabel", main)
    stats.Size = UDim2.new(1, 0, 0, 30)
    stats.Position = UDim2.new(0, 0, 0, 110)
    stats.Text = "Level: -- | Coins Bag: $0"
    stats.TextColor3 = Color3.fromRGB(150, 255, 200) -- Màu xanh mint
    stats.TextSize = 24
    stats.Font = Enum.Font.SourceSansBold
    stats.BackgroundTransparency = 1

    -- Cập nhật thời gian & Status
    local startTime = tick()
    task.spawn(function()
        while task.wait(1) do
            status.Text = "Status: Running Smoothly"
            local diff = tick() - startTime
            local h = math.floor(diff/3600)
            local m = math.floor((diff%3600)/60)
            local s = math.floor(diff%60)
            timer.Text = string.format("%d Hours, %d Minutes, %d Seconds (v3.0)", h, m, s)
            
            -- Cập nhật Level/Vàng (Tùy theo game bạn chơi)
            pcall(function()
                local lv = lp.leaderstats.Level.Value or 0
                local co = lp.leaderstats.Coins.Value or 0
                stats.Text = "Level: "..lv.." | Coins Bag: $"..co
            end)
        end
    end)
end

-- 4. CÁC TÍNH NĂNG CẢI TIẾN (FARM, GHOST, DELETE MAP)
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    CreateUI()

    -- Delete Map
    if Config["Delete Map"] then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Name:find("Coin") then
                v.Transparency = 1
                v.CanCollide = false
            end
        end
    end

    -- Ghost Character
    rs.RenderStepped:Connect(function()
        if Config["Ghost Character"] and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                    v.CanCollide = false
                end
            end
        end
    end)
end)

-- 5. TURBO FARM & WEBHOOK
task.spawn(function()
    local gold_total = 0
    while task.wait() do
        if Config["Turbo Farm"] then
            pcall(function()
                local root = lp.Character.HumanoidRootPart
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("Coin") and v:IsA("BasePart") then
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        firetouchinterest(root, v, 1)
                        v:Destroy()
                        gold_total = gold_total + 1
                    end
                end
            end)
        end
    end
end)

print("✅ Pleporm Hub V30 Loaded!")

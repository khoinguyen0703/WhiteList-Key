-- [[ PLEPORM HUB V33 - THE FINAL COMPLETE SCRIPT ]]
-- 0. FIX LỖI REQUEST (DÒNG 13) & KHỞI TẠO HÀM
local request = (syn and syn.request) or (http and http.request) or http_request or (Fluxus and Fluxus.request) or request
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local httpService = game:GetService("HttpService")

-- 1. HỆ THỐNG WHITELIST (KIỂM TRA KEY TỪ GITHUB)
local UserKey = _G.script_key or script_key
local WhitelistURL = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt?t=" .. tick()

local function Verify()
    local success, content = pcall(function() return game:HttpGet(WhitelistURL) end)
    if success then
        local function clean(str) return tostring(str):gsub("%s+", ""):gsub("%c+", "") end
        local cleanUserKey = clean(UserKey)
        if cleanUserKey == "" then return false end
        for line in content:gmatch("[^\r\n]+") do
            if clean(line) == cleanUserKey then return true end
        end
    end
    return false
end

if not Verify() then
    lp:Kick("WRONG KEY OR DONT USE IT AT ALL!!!!.")
    return
end

-- 2. GIAO DIỆN THEO DÕI (PIXEL FONT - MINECRAFT STYLE)
local function CreateUI()
    if lp.PlayerGui:FindFirstChild("PlepormHub_UI") then lp.PlayerGui.PlepormHub_UI:Destroy() end
    
    local sg = Instance.new("ScreenGui", lp.PlayerGui)
    sg.Name = "PlepormHub_UI"
    sg.ResetOnSpawn = false

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 450, 0, 250)
    main.Position = UDim2.new(0.5, -225, 0.35, -125)
    main.BackgroundTransparency = 1 

    local PixelFont = Enum.Font.Arcade -- Font chuẩn Pixel Minecraft

    local function CreateLabel(text, pos, color, size)
        local lbl = Instance.new("TextLabel", main)
        lbl.Size = UDim2.new(1, 0, 0, 40)
        lbl.Position = pos
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.TextSize = size
        lbl.Font = PixelFont
        lbl.TextStrokeTransparency = 0 -- Viền đen đậm phong cách Pixel
        lbl.BackgroundTransparency = 1
        return lbl
    end

    local title = CreateLabel("PLEPORM HUB", UDim2.new(0,0,0,0), Color3.fromRGB(255, 60, 60), 45)
    local status = CreateLabel("> Status: Running", UDim2.new(0,0,0,65), Color3.fromRGB(255, 200, 100), 22)
    local timer = CreateLabel("Time: 0H 0M 0S (v3.3)", UDim2.new(0,0,0,100), Color3.fromRGB(255, 255, 255), 18)
    local stats = CreateLabel("LVL: -- | GOLD: $0", UDim2.new(0,0,0,140), Color3.fromRGB(85, 255, 85), 25)

    -- Cập nhật dữ liệu thời gian và Leaderstats
    local startTick = tick()
    task.spawn(function()
        while task.wait(1) do
            local d = tick() - startTick
            timer.Text = string.format("Time: %dH %dM %dS (v3.3)", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
            pcall(function()
                local lv = lp.leaderstats.Level.Value or 0
                local co = lp.leaderstats.Coins.Value or 0
                stats.Text = "LVL: "..lv.." | GOLD: $"..co
            end)
        end
    end)
end

-- 3. CÁC TÍNH NĂNG CẢI TIẾN (FARM, GHOST, DELETE MAP)
local Config = getgenv().Plepor_Config or {}

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    CreateUI()

    -- Delete Map: Làm trong suốt map để giảm lag
    if Config["Delete Map"] then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Name:find("Coin") and v.Name ~= "Baseplate" then
                v.Transparency = 1
                v.CanCollide = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end

    -- Ghost Character: Nhân vật tàng hình (Tránh Report)
    rs.Stepped:Connect(function()
        if Config["Ghost Character"] and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.CanCollide = false
                    v.Transparency = 0.5
                end
            end
        end
    end)
end)

-- 4. TURBO FARM COIN SIÊU TỐC
task.spawn(function()
    while task.wait() do
        if Config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if (v.Name:find("Coin") or v.Name:find("Gold")) and v:IsA("BasePart") then
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        firetouchinterest(root, v, 1)
                        -- Không wait() ở đây để đạt tốc độ Turbo
                    end
                end
            end)
        end
    end
end)

-- 5. WEBHOOK LOGS (FENNIR STYLE)
local function SendWebhook(goldCount)
    local url = Config["Webhook Url"]
    if not url or url == "" or url:find("Link") then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "Webhook Logs\n\nWebhook Report",
            ["color"] = 0x2b2d31,
            ["fields"] = {
                {["name"] = "**Player:**", ["value"] = "||" .. lp.Name .. "||", ["inline"] = false},
                {["name"] = "**Gold Collected:**", ["value"] = "```" .. (goldCount or 0) .. "```", ["inline"] = false},
                {["name"] = "**Time:**", ["value"] = "lúc " .. os.date("%H:%M %A, %d/%m/%Y"), ["inline"] = false},
                {["name"] = "ℹ️ **Notes**", ["value"] = "```Script by PleporM Hub V33.```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "PleporM Hub • " .. os.date("%X")},
            ["thumbnail"] = {["url"] = "https://i.imgur.com/your_image.png"}
        }}
    }
    
    if request then
        pcall(function()
            request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = httpService:JSONEncode(data)
            })
        end)
    end
end

-- Tự động gửi Webhook mỗi khi nhặt được 1 lượng vàng nhất định
task.spawn(function()
    while task.wait(300) do -- Gửi báo cáo mỗi 5 phút
        pcall(function()
            local co = lp.leaderstats.Coins.Value or 0
            SendWebhook(co)
        end)
    end
end)

print("✅ PleporM Hub V33 (Final Edition) Loaded Successfully!")

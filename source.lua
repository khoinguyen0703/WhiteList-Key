-- [[ PLEPORM HUB V32 - MINECRAFT PIXEL FONT EDITION ]]
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
    game.Players.LocalPlayer:Kick("❌ SAI KEY! Vui lòng kiểm tra lại.")
    return
end

-- 2. GIAO DIỆN PLEPORM HUB (PHONG CÁCH PIXEL MINECRAFT)
local lp = game.Players.LocalPlayer
local function CreateUI()
    if lp.PlayerGui:FindFirstChild("PlepormHub_UI") then lp.PlayerGui.PlepormHub_UI:Destroy() end
    
    local sg = Instance.new("ScreenGui", lp.PlayerGui)
    sg.Name = "PlepormHub_UI"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 450, 0, 250)
    main.Position = UDim2.new(0.5, -225, 0.35, -125)
    main.BackgroundTransparency = 1 

    -- Font Arcade trong Roblox có nét Pixel rất giống Minecraft
    local PixelFont = Enum.Font.Arcade 

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Text = "PLEPORM HUB"
    title.TextColor3 = Color3.fromRGB(255, 60, 60)
    title.TextSize = 45
    title.Font = PixelFont
    title.TextStrokeTransparency = 0 -- Đậm nét pixel
    title.BackgroundTransparency = 1

    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 65)
    status.Text = "> Status: Running"
    status.TextColor3 = Color3.fromRGB(255, 200, 100)
    status.TextSize = 22
    status.Font = PixelFont
    status.BackgroundTransparency = 1

    local timer = Instance.new("TextLabel", main)
    timer.Size = UDim2.new(1, 0, 0, 25)
    timer.Position = UDim2.new(0, 0, 0, 100)
    timer.Text = "Time: 0H 0M 0S (v3.2)"
    timer.TextColor3 = Color3.fromRGB(255, 255, 255)
    timer.TextSize = 18
    timer.Font = PixelFont
    timer.BackgroundTransparency = 1

    local stats = Instance.new("TextLabel", main)
    stats.Size = UDim2.new(1, 0, 0, 40)
    stats.Position = UDim2.new(0, 0, 0, 140)
    stats.Text = "LVL: -- | GOLD: $0"
    stats.TextColor3 = Color3.fromRGB(85, 255, 85) -- Màu xanh lá Minecraft
    stats.TextSize = 25
    stats.Font = PixelFont
    stats.TextStrokeTransparency = 0
    stats.BackgroundTransparency = 1

    -- Cập nhật thông số Real-time
    local start = tick()
    task.spawn(function()
        while task.wait(1) do
            local d = tick() - start
            timer.Text = string.format("Time: %dH %dM %dS (v3.2)", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
            pcall(function()
                local lv = lp.leaderstats.Level.Value or 0
                local co = lp.leaderstats.Coins.Value or 0
                stats.Text = "LVL: "..lv.." | GOLD: $"..co
            end)
        end
    end)
end

-- 3. LOGIC HỆ THỐNG (FARM + GHOST + DELETE MAP)
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    CreateUI()
    
    local Config = getgenv().Plepor_Config
    if Config["Delete Map"] then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Name:find("Coin") and v.Name ~= "Baseplate" then
                v.Transparency = 1
                v.CanCollide = false
            end
        end
    end

    game:GetService("RunService").Stepped:Connect(function()
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

-- 4. TURBO FARM
task.spawn(function()
    while task.wait() do
        local Config = getgenv().Plepor_Config
        if Config["Turbo Farm"] and lp.Character then
            pcall(function()
                local root = lp.Character.HumanoidRootPart
                for _, v in pairs(workspace:GetDescendants()) do
                    if (v.Name:find("Coin") or v.Name:find("Gold")) and v:IsA("BasePart") then
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        firetouchinterest(root, v, 1)
                    end
                end
            end)
        end
    end
end)

print("✅ PleporM Hub V32 (Pixel Edition) Loaded!")

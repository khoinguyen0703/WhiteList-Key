-- [[ 1. HỆ THỐNG KIỂM TRA KEY (WHITELIST) ]]
local UserKey = _G.script_key or script_key
local WhitelistURL = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt" 

local function Verify()
    local success, content = pcall(function() return game:HttpGet(WhitelistURL) end)
    if success then
        for line in content:gmatch("[^\r\n]+") do
            if line:gsub("%s+", "") == UserKey then return true end
        end
    end
    return false
end

if not Verify() then
    game.Players.LocalPlayer:Kick("❌ WRONG KEY! Liên hệ PleporM để mua Key.\nYour Key: " .. tostring(UserKey))
    return
end

-- [[ 2. CẤU HÌNH HỆ THỐNG ]]
local Config = getgenv().Plepor_Config
local lp = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local HTTP = game:GetService("HttpService")

-- [[ 3. HÀM WEBHOOK PHONG CÁCH FENNIR HUB (VIP) ]]
local function SendWebhook(goldCount)
    local url = Config["Webhook Url"]
    if not url or url == "" or url:find("Link_Webhook") then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "Webhook Logs\n\nWebhook Report",
            ["color"] = 0xFF0000, 
            ["fields"] = {
                {["name"] = "Player:", ["value"] = "||" .. lp.Name .. "||", ["inline"] = false},
                {["name"] = "Gold Collected:", ["value"] = "```" .. (goldCount or 0) .. "```", ["inline"] = false},
                {["name"] = "Time:", ["value"] = os.date("lúc %H:%M %A, %d/%m/%Y"), ["inline"] = false},
                {["name"] = "ℹ️ Notes", ["value"] = "```Running smoothly on PleporM Hub.```", ["inline"] = false}
            },
            ["footer"] = {
                ["text"] = "PleporM Hub • discord.gg/PlepormHub • " .. os.date("%X"),
                ["icon_url"] = "https://i.imgur.com/your_icon.png" -- Fen có thể thay icon hub của mình
            },
            ["thumbnail"] = {["url"] = "https://i.imgur.com/your_image.png"} -- Thay ảnh đại diện hub của fen
        }}
    }

    pcall(function()
        if request then
            request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HTTP:JSONEncode(data)
            })
        end
    end)
end

-- [[ 4. LOGIC FARM & TỐI ƯU HÓA ]]
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait(1) until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

-- Tối ưu máy ngay lập tức
if Config["Low CPU"] then
    setfpscap(Config["FPS Cap"] or 10)
    settings().Rendering.QualityLevel = 1
    game:GetService("Lighting").GlobalShadows = false
end

-- Vòng lặp Farm Vàng
task.spawn(function()
    local count = 0
    SendWebhook(0) -- Báo cáo khi bắt đầu
    
    while Config["Turbo Farm"] do
        task.wait(Config["Farm Speed"] or 0.1)
        pcall(function()
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local target = nil
            local minDist = math.huge
            
            -- Tìm vàng gần nhất
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Coin_Server" and v:IsA("BasePart") then
                    local d = (root.Position - v.Position).Magnitude
                    if d < minDist then minDist = d target = v end
                end
            end
            
            if target then
                root.CFrame = target.CFrame
                firetouchinterest(root, target, 0)
                firetouchinterest(root, target, 1)
                count = count + 1
            end
            
            -- Gửi Webhook mỗi 100 vàng
            if count % 100 == 0 and count > 0 then
                SendWebhook(count)
            end
        end)
    end
end)

-- Anti-AFK & Ghost Mode
lp.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

RS.Stepped:Connect(function()
    pcall(function()
        if lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then 
                    v.CanCollide = false 
                    if Config["Ghost Mode"] and v.Parent.Name ~= lp.Name and not v.Name:find("Coin") then
                        v.Transparency = 1
                    end
                end
            end
        end
    end)
end)

print("PleporM Hub v22 Loaded!")

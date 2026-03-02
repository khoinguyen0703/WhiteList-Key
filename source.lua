-- [[ 1. HỆ THỐNG KIỂM TRA KEY - WHITELIST ]]
local UserKey = _G.script_key or script_key
local WhitelistURL = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/refs/heads/main/key.txt?token=GHSAT0AAAAAADWYPFEUPCNNOZC54SQUVE2A2NF5TUA" 

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
    game.Players.LocalPlayer:Kick("❌ WRONG KEY! Liên hệ PleporM để mua Key Premium.")
    return
end

-- [[ 2. KHAI BÁO BIẾN & CẤU HÌNH ]]
local Config = getgenv().Plepor_Config
local lp = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- [[ 3. HÀM GỬI WEBHOOK (GIAO TIẾP DISCORD) ]]
local function SendWebhook(msg)
    local url = Config["Webhook Url"]
    if not url or url == "" or url == "putyourwebhook" then return end
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({
                ["embeds"] = {{
                    ["title"] = "🚀 **PLEPORM HUB REPORT**",
                    ["description"] = msg,
                    ["color"] = 0x00A2FF,
                    ["footer"] = {["text"] = "Server: " .. game.JobId}
                }}
            })
        })
    end)
end

-- [[ 4. LOGIC FARM CHÍNH (V21) ]]
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait(1) until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

-- Tối ưu máy (FPS, Low CPU)
if Config["Low CPU"] then
    setfpscap(Config["FPS Cap"])
    settings().Rendering.QualityLevel = 1
end

-- Farm Vàng
task.spawn(function()
    SendWebhook("✅ **" .. lp.Name .. "** đã bắt đầu farm!")
    local count = 0
    while Config["Turbo Farm"] do
        task.wait(Config["Farm Speed"])
        pcall(function()
            local root = lp.Character.HumanoidRootPart
            local target = nil
            local minDist = math.huge
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
            if count % 100 == 0 and count > 0 then
                SendWebhook("💰 Đã nhặt được: " .. count .. " vàng.")
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
    if lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

print("PleporM Hub Loaded Successfully!")

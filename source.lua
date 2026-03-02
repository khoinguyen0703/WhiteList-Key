-- [[ PLEPORM HUB V89 - ULTIMATE FIX & WHITELIST ]]
-- [ STATUS: FIXED GOLD SPAWN | GLASS UI | SECURITY ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local lighting = game:GetService("Lighting")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")

-- 🔑 1. HỆ THỐNG WHITELIST KEY (QUAN TRỌNG)
local script_key = _G.script_key or "No Key"
local whitelist_url = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt"
local is_whitelisted = false

local success, result = pcall(function()
    return game:HttpGet(whitelist_url .. "?t=" .. tick()) -- Thêm tick để tránh bị cache key cũ
end)

if success then
    for line in result:gmatch("[^\r\n]+") do
        if line:gsub("%s+", "") == script_key:gsub("%s+", "") then
            is_whitelisted = true
            break
        end
    end
else
    lp:Kick("❌ Lỗi kết nối Server Whitelist (Kiểm tra mạng)!")
    return
end

if not is_whitelisted then
    lp:Kick("❌ Key không hợp lệ hoặc đã hết hạn!")
    return
end

-- 🛡️ 2. CLEANUP & BYPASS SYSTEM
if getgenv().Plepor_Executed then 
    for _, v in pairs(getgenv().PleporM_Connections or {}) do if v then v:Disconnect() end end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    if lighting:FindFirstChild("Pleporm_Blur") then lighting.Pleporm_Blur:Destroy() end
end
getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

local function BypassAC(char)
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if root then
        table.insert(getgenv().PleporM_Connections, rs.Stepped:Connect(function()
            if root and root.Parent then
                root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
                for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end))
    end
end

-- 🟢 3. DATA FUNCTIONS
local function GetTotalGold()
    local gold = "0"
    pcall(function()
        local sb = pgui:FindFirstChild("Scoreboard", true)
        if sb then
            for _, v in pairs(sb:GetDescendants()) do
                if v:IsA("TextLabel") and v.Text:match("%d") and not v.Text:find("/") and not v.Text:lower():find("x") then
                    local n = v.Text:match("[%d%,]+")
                    if n and n ~= "2018" and n ~= "2019" and #n < 10 then gold = n break end
                end
            end
        end
    end)
    return gold
end

-- 🔵 4. UI GLASS (CENTERED)
local blur = Instance.new("BlurEffect", lighting)
blur.Name = "Pleporm_Blur"; blur.Size = 0
ts:Create(blur, TweenInfo.new(1.5), {Size = 18}):Play()

local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 180); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.4; main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Transparency = 0.4

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "PLEPORM HUB V89"; title.TextColor3 = Color3.fromRGB(255, 60, 60)
title.TextSize = 22; title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

local goldLbl = Instance.new("TextLabel", main)
goldLbl.Size = UDim2.new(1, 0, 0, 30); goldLbl.Position = UDim2.new(0, 0, 0, 65)
goldLbl.TextSize = 18; goldLbl.Font = Enum.Font.GothamSemibold; goldLbl.TextColor3 = Color3.fromRGB(100, 255, 100); goldLbl.BackgroundTransparency = 1

local bagLbl = Instance.new("TextLabel", main)
bagLbl.Size = UDim2.new(1, 0, 0, 30); bagLbl.Position = UDim2.new(0, 0, 0, 95)
bagLbl.TextSize = 18; bagLbl.Font = Enum.Font.GothamSemibold; bagLbl.TextColor3 = Color3.fromRGB(255, 230, 100); bagLbl.BackgroundTransparency = 1

local statusLbl = Instance.new("TextLabel", main)
statusLbl.Size = UDim2.new(1, 0, 0, 25); statusLbl.Position = UDim2.new(0, 0, 0, 140)
statusLbl.TextSize = 13; statusLbl.Font = Enum.Font.GothamMedium; statusLbl.BackgroundTransparency = 1

-- 🟡 5. FIXED FARM ENGINE (NHẶT VÀNG SIÊU NHẠY)
local currentCoins, isResetting = 0, false
local lastCoinTick = tick()

task.spawn(function()
    while task.wait(0.01) do
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isResetting then
            -- Quét vàng trên toàn bộ Workspace để không sót
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                
                -- Đổi Server nếu đứng im 5 phút
                if tick() - lastCoinTick > 300 and Config["Auto Hop"] then
                    pcall(function()
                        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
                        for _, v in pairs(res) do if v.playing < tonumber(Config["Max Players to Hop"]) and v.id ~= game.JobId then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id) break end end
                    end)
                end

                -- Reset khi đầy túi
                if currentCoins >= 40 then
                    isResetting = true
                    lp.Character:BreakJoints()
                    task.wait(7.5)
                    currentCoins = 0
                    isResetting = false
                    continue
                end

                -- HÀM NHẶT VÀNG ĐÃ FIX
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        -- Check xem đồng vàng có "sống" không (không tàng hình, có cha là Map)
                        if v.Parent and v.Transparency < 0.5 then
                            -- Ép nhân vật tới và gửi tín hiệu chạm liên tục cho đến khi nhặt được
                            root.CFrame = v.CFrame
                            firetouchinterest(root, v, 0)
                            
                            local t = tick()
                            -- Đợi tối đa 0.3s cho đồng vàng biến mất
                            while v.Parent and v.Transparency < 0.5 and tick() - t < 0.3 do
                                rs.Heartbeat:Wait()
                            end
                            
                            firetouchinterest(root, v, 1)
                            
                            -- Nếu vàng biến mất => Nhặt thành công
                            if not v.Parent or v.Transparency > 0.5 then
                                currentCoins = currentCoins + 1
                                lastCoinTick = tick()
                                task.wait(Config["Farm Speed"] or 0.05)
                                break 
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ⚪ 6. INITIALIZE UI LOOP
task.spawn(function()
    while task.wait(0.5) do
        if not sg.Parent then break end
        goldLbl.Text = "TOTAL GOLD: $" .. GetTotalGold()
        bagLbl.Text = "COIN BAG: " .. currentCoins .. "/40"
        local inMatch = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position.Y < 150)
        statusLbl.Text = inMatch and "● STATUS: FARMING" or "○ STATUS: WAITING LOBBY"
        statusLbl.TextColor3 = inMatch and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end)

table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character then BypassAC(lp.Character) end
table.insert(getgenv().PleporM_Connections, lp.Idled:Connect(function() 
    vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame); task.wait(1); vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame) 
end))

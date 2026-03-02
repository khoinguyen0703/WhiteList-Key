-- [[ PLEPORM HUB V46 - THE ABSOLUTE PERFECTION ]]
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local ts = game:GetService("TeleportService")
local ht = game:GetService("HttpService")
local vu = game:GetService("VirtualUser")

-- 1. WHITELIST SYSTEM (BẢO MẬT TUYỆT ĐỐI)
local UserKey = _G.script_key or script_key
local WhitelistURL = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt?t=" .. tick()

local function Verify()
    local s, content = pcall(function() return game:HttpGet(WhitelistURL) end)
    if s then
        local cleanUserKey = tostring(UserKey):gsub("%s+", "")
        for line in content:gmatch("[^\r\n]+") do
            if line:gsub("%s+", "") == cleanUserKey then return true end
        end
    end
    return false
end

if not Verify() then
    lp:Kick("❌ SAI KEY! Liên hệ PleporM Hub.")
    return
end

-- 2. SIÊU TỐI ƯU XÓA MAP (FPS BOOST)
local function ProcessPart(v)
    if not getgenv().Plepor_Config["Delete Map"] then return end
    pcall(function()
        if v:IsA("BasePart") and v.Parent then
            local n = v.Name:lower()
            -- Đảm bảo không xóa vật phẩm quý và sàn
            if n:find("coin") or n:find("gold") or n:find("diamond") or v:FindFirstChild("TouchInterest") then 
                v.CanCollide = false -- Đi xuyên qua vàng để nhặt mượt hơn
                return 
            end
            if v.Name ~= "Baseplate" and v.Name ~= "Floor" then
                v.Transparency = 1
                v.CanCollide = false
                v.CastShadow = false -- Tắt bóng đổ để cứu RAM
            end
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end)
end
workspace.DescendantAdded:Connect(ProcessPart)

-- 3. GHOST FARM BYPASS (CẢI TIẾN NHẶT VÀNG)
task.spawn(function()
    while task.wait() do
        local config = getgenv().Plepor_Config
        if config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) and v.Parent then
                        -- Bypass vận tốc
                        root.Velocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                        
                        -- Nhặt vàng bằng CFrame đồng bộ
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        rs.Heartbeat:Wait() -- Chờ nhịp tim server
                        firetouchinterest(root, v, 1)
                        
                        task.wait(config["Farm Speed"] or 0.01)
                        break -- Nhặt từng cái để chống văng
                    end
                end
            end)
        end
    end
end)

-- 4. FIX TRACKING STATS (HIỂN THỊ GOLD & LVL)
local function FindStat(keywords)
    -- Tìm trong leaderstats, Stats và Data
    local folder = lp:FindFirstChild("leaderstats") or lp:FindFirstChild("Stats") or lp:FindFirstChild("Data")
    if folder then
        for _, v in pairs(folder:GetChildren()) do
            for _, key in pairs(keywords) do
                if v.Name:lower():find(key:lower()) then return tostring(v.Value) end
            end
        end
    end
    return "0"
end

local function CreateUI()
    if lp.PlayerGui:FindFirstChild("PlepormHub_UI") then lp.PlayerGui.PlepormHub_UI:Destroy() end
    local sg = Instance.new("ScreenGui", lp.PlayerGui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 240); main.Position = UDim2.new(0.5, -210, 0.2, -120); main.BackgroundTransparency = 1

    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,35); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s
        l.Font = Enum.Font.Arcade; l.TextStrokeTransparency = 0; l.BackgroundTransparency = 1; return l
    end

    Lbl("PLEPORM HUB", UDim2.new(0,0,0,0), Color3.fromRGB(255, 50, 50), 45)
    local st = Lbl("> Status: Ghost Active", UDim2.new(0,0,0,55), Color3.fromRGB(255, 200, 100), 22)
    local gr = Lbl("LVL: 0 | GOLD: $0", UDim2.new(0,0,0,100), Color3.fromRGB(80, 255, 80), 26) -- Dòng stats chính
    local pl = Lbl("SERVER: " .. #game.Players:GetPlayers() .. "/20", UDim2.new(0,0,0,140), Color3.fromRGB(255, 255, 255), 20)
    local tm = Lbl("Uptime: 0H 0M 0S", UDim2.new(0,0,0,175), Color3.fromRGB(200, 200, 200), 18)

    local startTick = tick()
    task.spawn(function()
        while task.wait(1) do
            if not main.Parent then break end
            local d = tick() - startTick
            tm.Text = string.format("Uptime: %dH %dM %dS", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
            pcall(function()
                -- Tự động cập nhật số liệu
                gr.Text = "LVL: " .. FindStat({"level", "lvl", "rank"}) .. " | GOLD: $" .. FindStat({"gold", "coins", "money", "cash"})
                pl.Text = "SERVER: " .. #game.Players:GetPlayers() .. "/20"
            end)
        end
    end)
end

-- 5. ANTI-AFK & AUTO-HOP (SAFE > 5 PLAYERS)
lp.Idled:Connect(function() vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(0.5); vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)

task.spawn(function()
    while task.wait(30) do
        if #game.Players:GetPlayers() > 5 then -- Tự đổi server để tránh bị soi
            pcall(function()
                local s = ht:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
                for _, v in pairs(s) do if v.playing < v.maxPlayers and v.id ~= game.JobId then ts:TeleportToPlaceInstance(game.PlaceId, v.id); break end end
            end)
        end
    end
end)

if not game:IsLoaded() then game.Loaded:Wait() end
CreateUI()
for _, v in pairs(workspace:GetDescendants()) do ProcessPart(v) end
print("✅ PleporM Hub V46 (Absolute Perfection) Loaded!")

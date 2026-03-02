-- [[ PLEPORM HUB V41 - ANTI-MEMORY LEAK & IMMORTAL ]]
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local ts = game:GetService("TeleportService")
local ht = game:GetService("HttpService")
local vu = game:GetService("VirtualUser")

-- 1. WHITELIST SYSTEM
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

-- 2. QUẢN LÝ BỘ NHỚ & XÓA MAP (ANTI-LEAK)
local Janitor = {} -- Bảng quản lý kết nối
local function ProcessPart(v)
    if not getgenv().Plepor_Config["Delete Map"] then return end
    pcall(function()
        if v:IsA("BasePart") and v.Parent then
            local n = v.Name:lower()
            if n:find("coin") or n:find("gold") or n:find("diamond") or v:FindFirstChild("TouchInterest") then return end
            if v.Name ~= "Baseplate" and v.Size.Magnitude > 1 then
                v.Transparency = 1
                v.CanCollide = false
            end
        elseif v:IsA("Decal") then
            v:Destroy()
        end
    end)
end

-- Chỉ kết nối 1 lần duy nhất, tránh chồng chéo
if Janitor.MapEvent then Janitor.MapEvent:Disconnect() end
Janitor.MapEvent = workspace.DescendantAdded:Connect(ProcessPart)

-- 3. SIÊU CẤP TURBO FARM (OPTIMIZED BYPASS)
task.spawn(function()
    while task.wait(0.05) do -- Nghỉ 0.05s để giảm tải CPU, vẫn cực nhanh
        local config = getgenv().Plepor_Config
        if config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            -- Tìm vàng hiệu quả hơn bằng cách giới hạn số lượng quét
            local found = false
            for _, v in pairs(workspace:GetChildren()) do -- Quét lớp ngoài trước để nhanh hơn
                if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                    root.Velocity = Vector3.zero
                    root.CFrame = v.CFrame
                    firetouchinterest(root, v, 0)
                    firetouchinterest(root, v, 1)
                    found = true; break
                end
            end
            
            if not found then -- Nếu không thấy lớp ngoài mới quét sâu vào trong
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        root.Velocity = Vector3.zero
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        firetouchinterest(root, v, 1)
                        break
                    end
                end
            end
        end
    end
end)

-- 4. AUTO HOP & ANTI-AFK (STABLE)
task.spawn(function()
    while task.wait(30) do
        if #game.Players:GetPlayers() > 5 then
            pcall(function()
                local s = ht:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
                for _, v in pairs(s) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        ts:TeleportToPlaceInstance(game.PlaceId, v.id)
                        break
                    end
                end
            end)
        end
    end
end)

lp.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- 5. GIAO DIỆN PIXEL (FIX LỖI CẬP NHẬT)
local function CreateUI()
    local old = lp.PlayerGui:FindFirstChild("PlepormHub_UI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui", lp.PlayerGui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 400, 0, 220); main.Position = UDim2.new(0.5, -200, 0.25, -110); main.BackgroundTransparency = 1

    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,35); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s
        l.Font = Enum.Font.Arcade; l.TextStrokeTransparency = 0; l.BackgroundTransparency = 1; return l
    end

    Lbl("PLEPORM HUB", UDim2.new(0,0,0,0), Color3.fromRGB(255, 50, 50), 40)
    local st = Lbl("> Status: Optimized", UDim2.new(0,0,0,50), Color3.fromRGB(255, 200, 100), 20)
    local tm = Lbl("Time: 0H 0M 0S", UDim2.new(0,0,0,85), Color3.fromRGB(255, 255, 255), 18)
    local gr = Lbl("GOLD: $0 | P: " .. #game.Players:GetPlayers(), UDim2.new(0,0,0,120), Color3.fromRGB(80, 255, 80), 22)

    local start = tick()
    task.spawn(function()
        while task.wait(1) do
            if not main.Parent then break end -- Tự dừng vòng lặp nếu UI bị xóa
            local d = tick() - start
            tm.Text = string.format("Time: %dH %dM %dS", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
            pcall(function()
                local s = lp:FindFirstChild("leaderstats")
                local co = (s and (s:FindFirstChild("Coins") or s:FindFirstChild("Gold")) and (s.Coins or s.Gold).Value) or 0
                gr.Text = "GOLD: $"..co.." | P: " .. #game.Players:GetPlayers()
            end)
        end
    end)
end

-- KHỞI CHẠY
if not game:IsLoaded() then game.Loaded:Wait() end
CreateUI()
for _, v in pairs(workspace:GetDescendants()) do ProcessPart(v) end
print("✅ Pleporm Hub : LOADED")

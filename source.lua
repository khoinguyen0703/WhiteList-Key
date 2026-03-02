-- [[ PLEPORM HUB V51 - THE FINAL MASTERPIECE ]]
local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local ts = game:GetService("TeleportService")
local ht = game:GetService("HttpService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")

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

-- 2. HÀM QUÉT STATS TỪ MÀN HÌNH (SIGHT SYSTEM - FIX LỖI $0)
local function GetStatsFromUI(keywords)
    local found = "0"
    pcall(function()
        for _, v in pairs(pgui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Visible and v.Text ~= "" then
                local txt = v.Text:lower()
                for _, key in pairs(keywords) do
                    if txt:find(key:lower()) and txt:match("%d") then
                        -- Lấy chuỗi số từ Text (Ví dụ: "Gold: 1,500" -> "1,500")
                        local num = v.Text:match("%d[%d%.,%s%k%m%b]*")
                        if num then found = num break end
                    end
                end
            end
        end
    end)
    return found
end

-- 3. GHOST FARM + AUTO RESET 40 COINS
local coinCount = 0
task.spawn(function()
    while task.wait() do
        local config = getgenv().Plepor_Config
        if config["Turbo Farm"] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            
            -- Kiểm tra nếu đã nhặt đủ 40 coin thì Reset
            if coinCount >= 40 then
                coinCount = 0
                if hum then hum.Health = 0 end
                task.wait(5) -- Đợi hồi sinh
                continue
            end

            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) and v.Parent then
                        root.Velocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                        root.CFrame = v.CFrame
                        firetouchinterest(root, v, 0)
                        rs.Heartbeat:Wait()
                        firetouchinterest(root, v, 1)
                        coinCount = coinCount + 1
                        task.wait(config["Farm Speed"] or 0.01)
                        break 
                    end
                end
            end)
        end
    end
end)

-- 4. GIAO DIỆN PIXEL MINECRAFT
local function CreateUI()
    local old = pgui:FindFirstChild("PlepormHub_UI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 420, 0, 260); main.Position = UDim2.new(0.5, -210, 0.2, -130); main.BackgroundTransparency = 1

    local function Lbl(t, p, c, s)
        local l = Instance.new("TextLabel", main); l.Size = UDim2.new(1,0,0,35); l.Position = p; l.Text = t; l.TextColor3 = c; l.TextSize = s
        l.Font = Enum.Font.Arcade; l.TextStrokeTransparency = 0; l.BackgroundTransparency = 1; return l
    end

    Lbl("PLEPORM HUB", UDim2.new(0,0,0,0), Color3.fromRGB(255, 50, 50), 45)
    local st = Lbl("> Status: Ghost Active", UDim2.new(0,0,0,55), Color3.fromRGB(255, 200, 100), 22)
    local gr = Lbl("LVL: 0 | GOLD: 0", UDim2.new(0,0,0,95), Color3.fromRGB(80, 255, 80), 24)
    local cn = Lbl("Session Coins: 0/40", UDim2.new(0,0,0,130), Color3.fromRGB(255, 255, 100), 20)
    local pl = Lbl("SERVER: " .. #game.Players:GetPlayers(), UDim2.new(0,0,0,165), Color3.fromRGB(255, 255, 255), 20)
    local tm = Lbl("Uptime: 0H 0M 0S", UDim2.new(0,0,0,200), Color3.fromRGB(200, 200, 200), 18)

    local startTick = tick()
    task.spawn(function()
        while task.wait(1) do
            if not main.Parent then break end
            local d = tick() - startTick
            tm.Text = string.format("Uptime: %dH %dM %dS", math.floor(d/3600), math.floor((d%3600)/60), math.floor(d%60))
            cn.Text = "Session Coins: " .. coinCount .. "/40"
            
            pcall(function()
                local money = GetStatsFromUI({"gold", "coin", "$", "money", "cash"})
                local level = GetStatsFromUI({"lvl", "level", "stage", "rank"})
                gr.Text = "LVL: " .. level .. " | GOLD: " .. money
            end)
        end
    end)
end

-- 5. DELETE MAP & ANTI-AFK
local function ProcessPart(v)
    if not getgenv().Plepor_Config["Delete Map"] then return end
    pcall(function()
        if v:IsA("BasePart") and v.Parent and v.Name ~= "Baseplate" and v.Name ~= "Floor" then
            if not (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                v.Transparency = 1; v.CanCollide = false; v.CastShadow = false
            end
        end
    end)
end
workspace.DescendantAdded:Connect(ProcessPart)

lp.Idled:Connect(function() vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(0.5); vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)

if not game:IsLoaded() then game.Loaded:Wait() end
CreateUI()
for _, v in pairs(workspace:GetDescendants()) do ProcessPart(v) end
print("✅ PleporM Hub V51: Masterpiece Loaded!")

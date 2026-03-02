-- [[ PLEPORM HUB V87 - THE GOD MODE EDITION ]]
-- [ FINAL CHECK: UI CENTERED | ANTI-STUCK | AUTO-TIMEOUT | BYPASS AC ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local lighting = game:GetService("Lighting")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")

local Config = getgenv().Plepor_Config
local UserKey = _G.script_key or "No Key"
local MaxPlayers = tonumber(Config["Max Players to Hop"]) or 5

-- 🛡️ 1. ULTIMATE CLEANUP & BYPASS
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

-- 🟢 2. DATA TRACKING (PRECISION)
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

local function ServerHop()
    pcall(function()
        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, v in pairs(res) do 
            if v.playing < MaxPlayers and v.id ~= game.JobId then 
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
                return
            end 
        end
    end)
end

-- 🔵 3. GLASS UI (CENTERED & BLURRED)
local blur = Instance.new("BlurEffect", lighting)
blur.Name = "Pleporm_Blur"; blur.Size = 0
ts:Create(blur, TweenInfo.new(1.5), {Size = 18}):Play()

local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 180); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.BackgroundTransparency = 0.4; main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Transparency = 0.4

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "PLEPORM HUB V87"; title.TextColor3 = Color3.fromRGB(255, 60, 60)
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

-- 🟡 4. FARM ENGINE (WITH STUCK DETECTION)
local currentCoins, isResetting = 0, false
local lastCoinTime = tick()

task.spawn(function()
    while task.wait(0.01) do
        if Config["Turbo Farm"] and not isResetting then
            local map = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map")
            if map and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                
                -- STUCK DETECTION: 5 phút không nhặt xu nào -> Tự đổi Server
                if tick() - lastCoinTime > 300 then ServerHop() end

                -- RESET LOGIC
                if currentCoins >= 40 then
                    isResetting = true; local oldG = GetTotalGold()
                    lp.Character:BreakJoints()
                    task.delay(6, function() 
                        local newG = GetTotalGold(); currentCoins = 0
                        -- Gửi Webhook tại đây (Dùng lại code V84)
                    end)
                    task.wait(7.5); isResetting = false; continue
                end

                -- COLLECTION
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        if v.Parent and v.Transparency < 0.5 then
                            root.CFrame = v.CFrame; firetouchinterest(root, v, 0)
                            local t = tick(); repeat rs.Heartbeat:Wait() until not v.Parent or v.Transparency > 0.8 or (tick()-t > 0.25)
                            firetouchinterest(root, v, 1)
                            if not v.Parent or v.Transparency > 0.8 then
                                currentCoins = currentCoins + 1
                                lastCoinTime = tick() -- Reset đồng hồ kẹt
                                task.wait(Config["Farm Speed"] or 0.05); break
                            end
                        end
                    end
                end
            else
                currentCoins = 0
            end
        end
    end
end)

-- ⚪ 5. FINAL INITIALIZE
task.spawn(function()
    while task.wait(0.5) do
        if not sg.Parent then break end
        goldLbl.Text = "TOTAL GOLD: $" .. GetTotalGold()
        bagLbl.Text = "COIN BAG: " .. currentCoins .. "/40"
        local inMatch = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position.Y < 150)
        statusLbl.Text = inMatch and "● STATUS: FARMING" or "○ STATUS: WAITING"
        statusLbl.TextColor3 = inMatch and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end)

table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character then BypassAC(lp.Character) end
table.insert(getgenv().PleporM_Connections, lp.Idled:Connect(function() 
    vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame); task.wait(1); vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame) 
end))

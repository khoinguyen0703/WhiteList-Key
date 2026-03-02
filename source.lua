-- [[ PLEPORM HUB V100 - SMART TARGET HOPPER ]]
-- [ ADDED: MIN/MAX PLAYER HOP LOGIC | UPTIME & DYNAMIC STATUS ]

if not game:IsLoaded() then game.Loaded:Wait() end

local lp = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local vu = game:GetService("VirtualUser")
local pgui = lp:WaitForChild("PlayerGui")
local lighting = game:GetService("Lighting")
local http = game:GetService("HttpService")

local ScriptStartTime = tick()
local CurrentAction = "INITIALIZING SCRIPT..."

-- 🔑 1. WHITELIST SYSTEM
local script_key = tostring(_G.script_key or "No Key"):gsub("%s+", "")
local whitelist_url = "https://raw.githubusercontent.com/khoinguyen0703/WhiteList-Key/main/key.txt"
local is_whitelisted = false

local success, result = pcall(function()
    return game:HttpGet(whitelist_url .. "?t=" .. tostring(math.floor(tick())))
end)

if success and result then
    for line in result:gmatch("[^\r\n]+") do
        if line:gsub("%s+", "") == script_key then
            is_whitelisted = true
            break
        end
    end
else
    return lp:Kick("❌ Whitelist Connection Error!")
end

if not is_whitelisted then return lp:Kick("❌ WRONG KEY. CONTACT PLEPORM HUB ❌") end

-- 🛡️ 2. CLEANUP OLD SCRIPT
if getgenv().Plepor_Executed then 
    if getgenv().PleporM_Connections then
        for _, v in pairs(getgenv().PleporM_Connections) do if v then v:Disconnect() end end
    end
    if pgui:FindFirstChild("PlepormHub_UI") then pgui.PlepormHub_UI:Destroy() end
    if lighting:FindFirstChild("Pleporm_Blur") then lighting.Pleporm_Blur:Destroy() end
end
getgenv().PleporM_Connections = {}
getgenv().Plepor_Executed = true

-- 🛠️ 3. OPTIMIZE (REAL DELETE MAP & PLAYERS)
local function OptimizePerformance()
    local Config = getgenv().Plepor_Config
    task.spawn(function()
        while getgenv().Plepor_Executed do
            if Config["Delete Map"] then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                        v.Transparency = 1; v.Material = Enum.Material.SmoothPlastic
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v:Destroy()
                    end
                end
                for _, v in pairs(lighting:GetChildren()) do
                    if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
                end
                settings().Rendering.QualityLevel = 1
            end
            task.wait(3)
        end
    end)

    if Config["Delete Player"] then
        local function deleteChar(char) if char then task.wait(0.1); char:Destroy() end end
        for _, p in pairs(game.Players:GetPlayers()) do if p ~= lp and p.Character then deleteChar(p.Character) end end
        table.insert(getgenv().PleporM_Connections, game.Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(char) if getgenv().Plepor_Config["Delete Player"] then deleteChar(char) end end)
        end))
    end
end

local function BypassAC(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if root then
        local stepConn = rs.Stepped:Connect(function()
            if root and root.Parent then
                root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
                for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end)
        table.insert(getgenv().PleporM_Connections, stepConn)
    end
end

-- 🔵 4. AUTO HOP TARGET SERVER (FIXED > 2 & <= MAX)
local function ServerHop()
    pcall(function()
        local Config = getgenv().Plepor_Config
        local MaxAllowed = tonumber(Config["Max Players to Hop"]) or 5
        local PlaceId = game.PlaceId
        
        local res = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        
        -- Ưu tiên server vắng trước nhưng phải lớn hơn 2 người
        table.sort(res, function(a, b) return a.playing < b.playing end)
        
        for _, v in pairs(res) do 
            -- CHỈ NHẢY VÀO SERVER CÓ: Số người > 2 VÀ Số người <= Config Khách nhập
            if v.playing > 2 and v.playing <= MaxAllowed and v.id ~= game.JobId then 
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, v.id)
                return
            end 
        end
    end)
end

-- 🔵 5. UI GLASS DESIGN
local blur = Instance.new("BlurEffect", lighting); blur.Name = "Pleporm_Blur"; blur.Size = 18
local sg = Instance.new("ScreenGui", pgui); sg.Name = "PlepormHub_UI"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 190); main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.4; main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 35); title.Text = "PLEPORM HUB V100"; title.TextColor3 = Color3.fromRGB(255, 60, 60); title.TextSize = 22; title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

local timeLbl = Instance.new("TextLabel", main); timeLbl.Size = UDim2.new(1, 0, 0, 20); timeLbl.Position = UDim2.new(0, 0, 0, 35); timeLbl.TextSize = 13; timeLbl.Font = Enum.Font.GothamMedium; timeLbl.TextColor3 = Color3.fromRGB(200, 200, 200); timeLbl.BackgroundTransparency = 1

local goldLbl = Instance.new("TextLabel", main); goldLbl.Size = UDim2.new(1, 0, 0, 30); goldLbl.Position = UDim2.new(0, 0, 0, 60); goldLbl.TextSize = 18; goldLbl.Font = Enum.Font.GothamSemibold; goldLbl.TextColor3 = Color3.fromRGB(100, 255, 100); goldLbl.BackgroundTransparency = 1

local bagLbl = Instance.new("TextLabel", main); bagLbl.Size = UDim2.new(1, 0, 0, 30); bagLbl.Position = UDim2.new(0, 0, 0, 90); bagLbl.TextSize = 18; bagLbl.Font = Enum.Font.GothamSemibold; bagLbl.TextColor3 = Color3.fromRGB(255, 230, 100); bagLbl.BackgroundTransparency = 1

local statusLbl = Instance.new("TextLabel", main); statusLbl.Size = UDim2.new(1, 0, 0, 25); statusLbl.Position = UDim2.new(0, 0, 0, 140); statusLbl.TextSize = 12; statusLbl.Font = Enum.Font.GothamMedium; statusLbl.BackgroundTransparency = 1

-- 🟡 6. FARM ENGINE & STATUS UPDATER
local currentCoins, isResetting = 0, false
local lastCoinTick = tick()

task.spawn(function()
    while getgenv().Plepor_Executed do
        task.wait(0.01)
        local Config = getgenv().Plepor_Config
        if Config and Config["Turbo Farm"] and not isResetting then
            
            -- CHECK NGƯỜI CHƠI ĐỂ HOP (QUÁ ĐÔNG HOẶC QUÁ VẮNG)
            local currentPlayers = #game.Players:GetPlayers()
            local MaxAllowed = tonumber(Config["Max Players to Hop"]) or 5
            
            if Config["Auto Hop"] then
                if currentPlayers > MaxAllowed then
                    CurrentAction = "SERVER TOO FULL! HOPPING..."
                    ServerHop()
                    break
                elseif currentPlayers <= 2 then
                    CurrentAction = "SERVER TOO EMPTY! HOPPING..."
                    ServerHop()
                    break
                end
            end

            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local root = lp.Character.HumanoidRootPart
                
                if tick() - lastCoinTick > 180 and Config["Auto Hop"] then 
                    CurrentAction = "STUCK FOR 3 MINS! HOPPING..."
                    ServerHop() 
                    break 
                end
                
                if currentCoins >= 40 then
                    CurrentAction = "BAG FULL! RESETTING CHAR..."
                    isResetting = true; lp.Character:BreakJoints()
                    task.wait(7.5); currentCoins = 0; isResetting = false; continue
                end

                local foundCoin = false
                local folders = {workspace:FindFirstChild("Normal"), workspace:FindFirstChild("Map"), workspace:FindFirstChild("CoinContainer")}
                
                local hasMap = false
                for _, folder in pairs(folders) do
                    if folder and #folder:GetChildren() > 0 then hasMap = true end
                    if folder and not foundCoin then
                        for _, v in pairs(folder:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gold")) then
                                if v.Parent and v.Transparency < 0.5 then
                                    foundCoin = true
                                    CurrentAction = "COLLECTING COINS..."
                                    root.CFrame = v.CFrame
                                    firetouchinterest(root, v, 0)
                                    
                                    local t = tick()
                                    while v.Parent and v.Transparency < 0.5 and tick() - t < 0.2 do rs.Heartbeat:Wait() end
                                    
                                    firetouchinterest(root, v, 1)
                                    if not v.Parent or v.Transparency > 0.5 then
                                        currentCoins = currentCoins + 1
                                        lastCoinTick = tick()
                                        task.wait(Config["Farm Speed"] or 0.05)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
                
                if not foundCoin then 
                    if hasMap then
                        CurrentAction = "WAITING FOR COIN SPAWN..."
                    else
                        CurrentAction = "WAITING FOR NEXT MATCH..."
                    end
                    lastCoinTick = tick() 
                end
            end
        end
    end
end)

-- ⚪ 7. INITIALIZE UI LOOP
OptimizePerformance()
task.spawn(function()
    while sg.Parent do
        task.wait(0.5)
        pcall(function()
            local elapsed = tick() - ScriptStartTime
            local hours = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = math.floor(elapsed % 60)
            timeLbl.Text = string.format("🕒 UPTIME: %02d:%02d:%02d", hours, mins, secs)

            local sb = pgui:FindFirstChild("Scoreboard", true)
            local gold = "0"
            if sb then
                for _, v in pairs(sb:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text:match("%d") and not v.Text:find("/") then
                        local n = v.Text:match("[%d%,]+")
                        if n and n ~= "2018" and n ~= "2019" then gold = n break end
                    end
                end
            end
            goldLbl.Text = "TOTAL GOLD: $" .. gold
            bagLbl.Text = "COIN BAG: " .. currentCoins .. "/40"
            
            statusLbl.Text = "● STATUS: " .. CurrentAction
            if CurrentAction:find("COLLECTING") then
                statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif CurrentAction:find("WAITING") then
                statusLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
            elseif CurrentAction:find("RESETTING") or CurrentAction:find("HOPPING") then
                statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end
end)

table.insert(getgenv().PleporM_Connections, lp.CharacterAdded:Connect(BypassAC))
if lp.Character then BypassAC(lp.Character) end

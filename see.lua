-- ============================================================
-- SEE 脚本 v1.0  |  作者: seeded
-- ============================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

WindUI:AddTheme({
    Name = "SEE_Pink", Accent = "1a0a14", Outline = "ff69b4",
    Text = "ffffff", Placeholder = "ffb6c1",
})

-- ============================================================
-- 全局队伍检测（透视 + 自瞄共用）
-- ============================================================
local GlobalTeamCheck = true

local function isTeammate(player)
    if player == LocalPlayer then return true end
    if not LocalPlayer.Team then return false end
    if not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

-- ============================================================
-- 欢迎弹窗
-- ============================================================
local Confirmed = false
WindUI:Popup({
    Title = "欢迎使用 SEE 脚本",
    Icon = "sparkles",
    Content = "SEE 脚本 v1.0\n作者: seeded\n\n理智开挂，请勿倒卖。",
    Buttons = {
        { Title = "取消", Callback = function() end, Variant = "Secondary" },
        { Title = "进入", Icon = "arrow-right", Callback = function() Confirmed = true end, Variant = "Primary" },
    }
})
repeat task.wait() until Confirmed

-- ============================================================
-- 主窗口
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "SEE 脚本  •  v1.0", Icon = "zap", Author = "seeded",
    Folder = "SEE_Hub", Size = UDim2.fromOffset(560, 440),
    Transparent = true, Theme = "SEE_Pink",
    User = { Enabled = true, Anonymous = false },
    SideBarWidth = 190, HasOutline = true,
})
WindUI:SetTheme("SEE_Pink")

Window:EditOpenButton({
    Title = "SEE 脚本", Icon = "zap",
    CornerRadius = UDim.new(0, 16), StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("ff69b4"), Color3.fromHex("ff1493")),
    Draggable = true,
})

-- ============================================================
-- 八个选项卡
-- ============================================================
local Tabs = {
    SpeedTab     = Window:Tab({ Title = "速度数据",      Icon = "gauge",     Desc = "速度 / 跳跃 / 血量 / 视角 / 视野" }),
    CommonTab    = Window:Tab({ Title = "通用功能",      Icon = "wrench",    Desc = "穿墙 / 传送 / 飞行 / 实用功能" }),
    ESPTab       = Window:Tab({ Title = "透视",          Icon = "eye",       Desc = "玩家透视" }),
    CollisionTab = Window:Tab({ Title = "Collision box", Icon = "box",       Desc = "碰撞箱 / 头部变大 / 高亮" }),
    AimbotTab    = Window:Tab({ Title = "自瞄",          Icon = "crosshair", Desc = "锁定 / 平滑 / 延迟 / 部位" }),
    TPTab        = Window:Tab({ Title = "传送",          Icon = "send",      Desc = "传送 / 跟随 / 隐身 / 甩飞" }),
    RotateTab    = Window:Tab({ Title = "旋转",          Icon = "rotate-cw", Desc = "角色 / 相机持续旋转" }),
    AnnounceTab  = Window:Tab({ Title = "公告栏",        Icon = "megaphone", Desc = "脚本信息" }),
}
Window:SelectTab(1)

-- ============================================================
-- 【1】速度数据
-- ============================================================
Tabs.SpeedTab:Section({ Title = "移动速度" })

local speedEnabled  = false
local speedMode     = "Humanoid"
local customSpeed   = 50
local originalSpeed = nil

Tabs.SpeedTab:Dropdown({
    Title = "速度修改方式",
    Values = { "Humanoid.WalkSpeed", "Velocity 位移" },
    Value = "Humanoid.WalkSpeed",
    Callback = function(opt) speedMode = (opt == "Velocity 位移") and "Velocity" or "Humanoid" end,
})

Tabs.SpeedTab:Input({
    Title = "输入速度值", Value = "50", Placeholder = "请输入速度（默认16）",
    Callback = function(txt) customSpeed = tonumber(txt) or 50 end,
})

Tabs.SpeedTab:Toggle({
    Title = "启用速度修改", Value = false,
    Callback = function(state)
        speedEnabled = state
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or speedMode ~= "Humanoid" then return end
        if state then
            originalSpeed = hum.WalkSpeed
            hum.WalkSpeed = customSpeed
        else
            hum.WalkSpeed = originalSpeed or 16
        end
    end,
})

RunService.Heartbeat:Connect(function()
    if not speedEnabled or speedMode ~= "Velocity" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        hrp.Velocity = hum.MoveDirection * customSpeed + Vector3.new(0, hrp.Velocity.Y, 0)
    end
end)

Tabs.SpeedTab:Section({ Title = "跳跃力量" })

local jumpEnabled  = false
local customJump   = 50
local originalJump = nil

Tabs.SpeedTab:Slider({
    Title = "跳跃力量", Value = { Min = 0, Max = 500, Default = 50 },
    Callback = function(v)
        customJump = v
        if jumpEnabled then
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end,
})

Tabs.SpeedTab:Toggle({
    Title = "启用跳跃修改", Value = false,
    Callback = function(state)
        jumpEnabled = state
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if state then
            originalJump = hum.JumpPower
            hum.JumpPower = customJump
        else
            hum.JumpPower = originalJump or 50
        end
    end,
})

Tabs.SpeedTab:Section({ Title = "血量修改" })

local healthEnabled  = false
local customHealth   = 100
local originalHealth = nil

Tabs.SpeedTab:Slider({
    Title = "血量上限", Value = { Min = 1, Max = 10000, Default = 100 },
    Callback = function(v)
        customHealth = v
        if healthEnabled then
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.MaxHealth = v; hum.Health = v end
        end
    end,
})

Tabs.SpeedTab:Toggle({
    Title = "启用血量修改", Value = false,
    Callback = function(state)
        healthEnabled = state
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if state then
            originalHealth = hum.MaxHealth
            hum.MaxHealth = customHealth
            hum.Health    = customHealth
        else
            hum.MaxHealth = originalHealth or 100
            hum.Health    = originalHealth or 100
        end
    end,
})

Tabs.SpeedTab:Section({ Title = "视角" })
Tabs.SpeedTab:Toggle({
    Title = "第一人称视角", Value = false,
    Callback = function(state)
        LocalPlayer.CameraMode = state and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
    end,
})

Tabs.SpeedTab:Section({ Title = "视野距离" })

local fovEnabled  = false
local customFov   = 70
local originalFov = nil
local camera      = workspace.CurrentCamera

Tabs.SpeedTab:Slider({
    Title = "视野距离 (FOV)", Value = { Min = 30, Max = 120, Default = 70 },
    Callback = function(v)
        customFov = v
        if fovEnabled and camera then camera.FieldOfView = v end
    end,
})

Tabs.SpeedTab:Toggle({
    Title = "启用视野修改", Value = false,
    Callback = function(state)
        fovEnabled = state
        if not camera then return end
        if state then
            originalFov = camera.FieldOfView
            camera.FieldOfView = customFov
        else
            camera.FieldOfView = originalFov or 70
        end
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    if speedEnabled and speedMode == "Humanoid" then hum.WalkSpeed = customSpeed end
    if jumpEnabled then hum.JumpPower = customJump end
    if healthEnabled then hum.MaxHealth = customHealth; hum.Health = customHealth end
end)

-- ============================================================
-- 【2】通用功能
-- ============================================================
Tabs.CommonTab:Section({ Title = "穿墙" })

local noclipConn = nil

Tabs.CommonTab:Toggle({
    Title = "穿墙模式", Value = false,
    Callback = function(state)
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local char = LocalPlayer.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
        end
    end,
})

Tabs.CommonTab:Section({ Title = "点击传送" })

local tpActive = false

local function clearTPTool()
    local char = LocalPlayer.Character
    if char then local t = char:FindFirstChild("SEE_传送器"); if t then t:Destroy() end end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then local t = bp:FindFirstChild("SEE_传送器"); if t then t:Destroy() end end
    tpActive = false
end

Tabs.CommonTab:Button({
    Title = "开启点击传送",
    Desc  = "获取传送工具，激活后点击屏幕瞬移",
    Callback = function()
        if tpActive then return end
        local tool = Instance.new("Tool")
        tool.Name = "SEE_传送器"
        tool.RequiresHandle = false
        tool.CanBeDropped   = false
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if mouse and mouse.Hit then
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
            end
        end)
        tool.Parent = LocalPlayer.Backpack
        tpActive = true
        WindUI:Notify({ Title = "点击传送", Content = "已获取传送工具", Icon = "crosshair", Duration = 4 })
    end,
})

Tabs.CommonTab:Button({ Title = "关闭点击传送", Callback = clearTPTool })

-- 踏空而行（加载 UESP）
Tabs.CommonTab:Section({ Title = "踏空而行" })

local uespLoaded = false

Tabs.CommonTab:Button({
    Title = "开启踏空而行",
    Desc  = "点击加载 UESP 脚本",
    Callback = function()
        if uespLoaded then
            WindUI:Notify({ Title = "踏空而行", Content = "UESP 脚本已加载", Icon = "info", Duration = 3 })
            return
        end
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP"))()
        end)
        if ok then
            uespLoaded = true
            WindUI:Notify({ Title = "踏空而行", Content = "UESP 脚本已加载成功", Icon = "check-circle", Duration = 3 })
        else
            WindUI:Notify({ Title = "踏空而行加载失败", Content = tostring(err), Icon = "alert-circle", Duration = 5 })
        end
    end,
})

-- 飞行
Tabs.CommonTab:Section({ Title = "飞行" })

local flyLoaded = false

Tabs.CommonTab:Button({
    Title = "开启飞行",
    Desc  = "点击加载飞行脚本",
    Callback = function()
        if flyLoaded then
            WindUI:Notify({ Title = "飞行", Content = "飞行脚本已加载", Icon = "info", Duration = 3 })
            return
        end
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/Pi-feiche.lua"))()
        end)
        if ok then
            flyLoaded = true
            WindUI:Notify({ Title = "飞行", Content = "飞行脚本已加载成功", Icon = "check-circle", Duration = 3 })
        else
            WindUI:Notify({ Title = "飞行加载失败", Content = tostring(err), Icon = "alert-circle", Duration = 5 })
        end
    end,
})

-- 飞车
Tabs.CommonTab:Section({ Title = "飞车" })

local carLoaded = false

Tabs.CommonTab:Button({
    Title = "开启飞车",
    Desc  = "点击加载飞车脚本",
    Callback = function()
        if carLoaded then
            WindUI:Notify({ Title = "飞车", Content = "飞车脚本已加载", Icon = "info", Duration = 3 })
            return
        end
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/3683e49998644fb7.txt_2024-08-09_094310.OTed.lua"))()
        end)
        if ok then
            carLoaded = true
            WindUI:Notify({ Title = "飞车", Content = "飞车脚本已加载成功", Icon = "check-circle", Duration = 3 })
        else
            WindUI:Notify({ Title = "飞车加载失败", Content = tostring(err), Icon = "alert-circle", Duration = 5 })
        end
    end,
})

-- 快速互动
Tabs.CommonTab:Section({ Title = "快速互动" })

local QuickInteractConn = nil

Tabs.CommonTab:Toggle({
    Title = "快速互动",
    Desc  = "瞬间完成所有 ProximityPrompt 互动（无需长按）",
    Value = false,
    Callback = function(state)
        if state then
            QuickInteractConn = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
                prompt.HoldDuration = 0
            end)
            WindUI:Notify({ Title = "快速互动已开启", Icon = "zap", Duration = 2 })
        else
            if QuickInteractConn then QuickInteractConn:Disconnect(); QuickInteractConn = nil end
        end
    end,
})

-- ============================================================
-- 夜视（亮度范围优化）
-- ============================================================
Tabs.CommonTab:Section({ Title = "夜视" })

local NightVision = {
    Enabled    = false,
    Brightness = 30,        -- 0~100
    Effect     = nil,
    OriginalAmbient        = nil,
    OriginalOutdoorAmbient = nil,
}

-- 亮度映射：0~100 → 0~0.6（更柔和的视觉）
local function mapBrightness(v)
    return (v / 100) * 0.6
end

Tabs.CommonTab:Slider({
    Title = "夜视亮度 (0-100)",
    Value = { Min = 0, Max = 100, Default = 30 },
    Callback = function(v)
        NightVision.Brightness = v
        if NightVision.Enabled and NightVision.Effect then
            NightVision.Effect.Brightness = mapBrightness(v)
            -- 同步微调环境光，让整体更自然
            local lighting = game:GetService("Lighting")
            local amb = (v / 100) * 0.15
            lighting.Ambient        = Color3.new(amb, amb, amb)
            lighting.OutdoorAmbient = Color3.new(amb, amb, amb)
        end
    end,
})

Tabs.CommonTab:Toggle({
    Title = "夜视",
    Desc  = "调亮场景（范围 0-100，默认 30 较柔和）",
    Value = false,
    Callback = function(state)
        NightVision.Enabled = state
        local lighting = game:GetService("Lighting")

        if state then
            -- 保存原环境光
            NightVision.OriginalAmbient        = lighting.Ambient
            NightVision.OriginalOutdoorAmbient = lighting.OutdoorAmbient

            -- 创建 ColorCorrectionEffect
            if not NightVision.Effect or not NightVision.Effect.Parent then
                local e = Instance.new("ColorCorrectionEffect")
                e.Name       = "SEE_NightVision"
                e.Contrast   = 0.05
                e.Saturation = 0
                e.TintColor  = Color3.fromRGB(255, 255, 255)
                e.Parent     = lighting
                NightVision.Effect = e
            end
            NightVision.Effect.Brightness = mapBrightness(NightVision.Brightness)

            -- 环境光也跟着变亮
            local amb = (NightVision.Brightness / 100) * 0.15
            lighting.Ambient        = Color3.new(amb, amb, amb)
            lighting.OutdoorAmbient = Color3.new(amb, amb, amb)

            WindUI:Notify({ Title = "夜视已开启", Icon = "sun", Duration = 2 })
        else
            if NightVision.Effect then
                NightVision.Effect.Brightness = 0
            end
            -- 恢复原环境光
            if NightVision.OriginalAmbient then
                lighting.Ambient = NightVision.OriginalAmbient
            end
            if NightVision.OriginalOutdoorAmbient then
                lighting.OutdoorAmbient = NightVision.OriginalOutdoorAmbient
            end
            WindUI:Notify({ Title = "夜视已关闭", Icon = "moon", Duration = 2 })
        end
    end,
})

-- 无限跳
Tabs.CommonTab:Section({ Title = "无限跳" })

local InfiniteJumpEnabled = false
local InfiniteJumpConn    = nil

Tabs.CommonTab:Toggle({
    Title = "无限跳",
    Desc  = "空中可以无限次跳跃",
    Value = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
        if state then
            InfiniteJumpConn = UserInputService.JumpRequest:Connect(function()
                if not InfiniteJumpEnabled then return end
                local char = LocalPlayer.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
            WindUI:Notify({ Title = "无限跳已开启", Icon = "arrow-up", Duration = 2 })
        else
            if InfiniteJumpConn then InfiniteJumpConn:Disconnect(); InfiniteJumpConn = nil end
            WindUI:Notify({ Title = "无限跳已关闭", Icon = "arrow-down", Duration = 2 })
        end
    end,
})

-- 爬墙
Tabs.CommonTab:Section({ Title = "爬墙" })

local WallClimbEnabled = false
local WallClimbConn    = nil

Tabs.CommonTab:Toggle({
    Title = "爬墙",
    Desc  = "靠近墙壁按方向键可爬上去",
    Value = false,
    Callback = function(state)
        WallClimbEnabled = state
        if state then
            WallClimbConn = RunService.RenderStepped:Connect(function()
                if not WallClimbEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                if hum.MoveDirection.Magnitude > 0 then
                    local origin = hrp.Position
                    local direction = hum.MoveDirection * 2.5

                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = { char }
                    local result = workspace:Raycast(origin, direction, params)
                    if result and result.Instance then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 40, hrp.Velocity.Z)
                    end
                end
            end)
            WindUI:Notify({ Title = "爬墙已开启", Icon = "trending-up", Duration = 2 })
        else
            if WallClimbConn then WallClimbConn:Disconnect(); WallClimbConn = nil end
        end
    end,
})

-- FPS
Tabs.CommonTab:Section({ Title = "FPS 显示" })

local FPS = {
    Enabled = false,
    Gui     = nil,
    Label   = nil,
    Conn    = nil,
}

Tabs.CommonTab:Toggle({
    Title = "FPS 显示",
    Desc  = "屏幕左上角显示当前帧数",
    Value = false,
    Callback = function(state)
        FPS.Enabled = state
        if state then
            if not FPS.Gui then
                local gui = Instance.new("ScreenGui")
                gui.Name = "SEE_FPS"
                gui.ResetOnSpawn = false
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0, 110, 0, 26)
                label.Position = UDim2.new(0, 10, 0, 10)
                label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                label.BackgroundTransparency = 0.5
                label.TextColor3 = Color3.fromRGB(0, 255, 127)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.Text = "FPS: --"
                label.Parent = gui

                Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
                FPS.Gui   = gui
                FPS.Label = label
            end
            FPS.Gui.Enabled = true

            local frames = 0
            local lastTime = tick()
            FPS.Conn = RunService.RenderStepped:Connect(function()
                if not FPS.Enabled then return end
                frames = frames + 1
                if tick() - lastTime >= 1 then
                    FPS.Label.Text = "FPS: " .. frames
                    frames = 0
                    lastTime = tick()
                end
            end)
            WindUI:Notify({ Title = "FPS 显示已开启", Icon = "activity", Duration = 2 })
        else
            if FPS.Gui then FPS.Gui.Enabled = false end
            if FPS.Conn then FPS.Conn:Disconnect(); FPS.Conn = nil end
            WindUI:Notify({ Title = "FPS 显示已关闭", Icon = "activity", Duration = 2 })
        end
    end,
})

-- ============================================================
-- 【3】透视
-- ============================================================
Tabs.ESPTab:Section({ Title = "全局设置" })

local ESP = {
    Enabled      = false,
    ShowName     = false,
    Highlight    = false,
    ShowHealth   = false,
    ShowDistance = false,
    ShowTracer   = false,
    ShowBox      = false,
    Mode         = "Solo",
    UseGameColor = true,
    Color         = Color3.fromRGB(255, 105, 180),
    TeammateColor = Color3.fromRGB(0, 170, 255),
    EnemyColor    = Color3.fromRGB(255, 60, 60),
    Drawings = {},
}

Tabs.ESPTab:Toggle({ Title = "全局开启绘制", Value = false, Callback = function(s) ESP.Enabled = s end })

Tabs.ESPTab:Section({ Title = "显示模式" })

Tabs.ESPTab:Dropdown({
    Title = "选择显示模式",
    Values = { "单人（全部同色）", "区分团队（队友/敌人）", "仅敌人", "仅队友" },
    Value = "单人（全部同色）",
    Callback = function(opt)
        if opt == "单人（全部同色）" then
            ESP.Mode = "Solo"
        elseif opt == "区分团队（队友/敌人）" then
            ESP.Mode = "Team"
        elseif opt == "仅敌人" then
            ESP.Mode = "EnemyOnly"
        elseif opt == "仅队友" then
            ESP.Mode = "TeamOnly"
        end
    end,
})

Tabs.ESPTab:Toggle({
    Title = "使用游戏队伍颜色 ★推荐",
    Desc  = "开启后队友颜色自动跟随你所在队伍",
    Value = true,
    Callback = function(s) ESP.UseGameColor = s end,
})

Tabs.ESPTab:Toggle({
    Title = "队伍检测（不显示队友）★与自瞄共享",
    Desc  = "关闭后队友也会被绘制，自瞄也会锁队友",
    Value = true,
    Callback = function(s)
        GlobalTeamCheck = s
        WindUI:Notify({
            Title = "队伍检测",
            Content = s and "已开启（不画/不锁队友）" or "已关闭（全部显示）",
            Icon = "users",
            Duration = 2,
        })
    end,
})

local function getTeamColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    if player.TeamColor then
        return player.TeamColor.Color
    end
    return nil
end

local function getESPColor(player)
    local teammate = isTeammate(player)

    -- 队伍检测开启 + 是队友
    if GlobalTeamCheck and teammate then
        if ESP.Mode == "Team" then
            -- 区分团队模式：队友仍显示
            if ESP.UseGameColor then
                return getTeamColor(LocalPlayer) or ESP.TeammateColor
            else
                return ESP.TeammateColor
            end
        else
            -- 其它模式：队友不画
            return nil
        end
    end

    -- 模式过滤
    if ESP.Mode == "TeamOnly"  and not teammate then return nil end
    if ESP.Mode == "Solo" then return ESP.Color end

    -- 敌人 / Team 模式
    if ESP.UseGameColor then
        return getTeamColor(player) or ESP.EnemyColor
    else
        return ESP.EnemyColor
    end
end

Tabs.ESPTab:Section({ Title = "透视选项" })
Tabs.ESPTab:Toggle({ Title = "透视玩家名字", Value = false, Callback = function(s) ESP.ShowName = s end })
Tabs.ESPTab:Toggle({ Title = "高亮玩家身体", Value = false, Callback = function(s) ESP.Highlight = s end })
Tabs.ESPTab:Toggle({ Title = "透视玩家血量", Value = false, Callback = function(s) ESP.ShowHealth = s end })
Tabs.ESPTab:Toggle({ Title = "透视玩家距离", Value = false, Callback = function(s) ESP.ShowDistance = s end })
Tabs.ESPTab:Toggle({ Title = "射线",         Value = false, Callback = function(s) ESP.ShowTracer = s end })
Tabs.ESPTab:Toggle({ Title = "方框",         Value = false, Callback = function(s) ESP.ShowBox = s end })

Tabs.ESPTab:Section({ Title = "手动颜色（关闭游戏颜色时生效）" })

Tabs.ESPTab:Colorpicker({ Title = "单人模式颜色", Default = ESP.Color, Callback = function(c) ESP.Color = c end })
Tabs.ESPTab:Colorpicker({ Title = "队友颜色",     Default = ESP.TeammateColor, Callback = function(c) ESP.TeammateColor = c end })
Tabs.ESPTab:Colorpicker({ Title = "敌人颜色",     Default = ESP.EnemyColor, Callback = function(c) ESP.EnemyColor = c end })

local function createDraw(player)
    local d = {}
    d.box = Drawing.new("Square")
    d.box.Thickness = 1; d.box.Filled = false; d.box.Visible = false

    d.name = Drawing.new("Text")
    d.name.Size = 14; d.name.Center = true; d.name.Outline = true; d.name.Visible = false

    d.health = Drawing.new("Text")
    d.health.Size = 13; d.health.Center = true; d.health.Outline = true; d.health.Visible = false

    d.distance = Drawing.new("Text")
    d.distance.Size = 12; d.distance.Center = true; d.distance.Outline = true; d.distance.Visible = false

    d.tracer = Drawing.new("Line")
    d.tracer.Thickness = 1; d.tracer.Visible = false

    ESP.Drawings[player] = d
    return d
end

local function removeDraw(player)
    local d = ESP.Drawings[player]
    if not d then return end
    for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
    ESP.Drawings[player] = nil
end

local function getESPHighlight(char)
    local hl = char:FindFirstChild("SEE_ESP_Highlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "SEE_ESP_Highlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.55
        hl.OutlineTransparency = 0
        hl.Parent = char
    end
    return hl
end

local function hideDraw(player)
    local d = ESP.Drawings[player]
    if d then
        for _, obj in pairs(d) do obj.Visible = false end
    end
    local char = player.Character
    local hl = char and char:FindFirstChild("SEE_ESP_Highlight")
    if hl then hl.Enabled = false end
end

Players.PlayerRemoving:Connect(removeDraw)

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, d in pairs(ESP.Drawings) do
            for _, obj in pairs(d) do obj.Visible = false end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            local c = plr.Character
            local hl = c and c:FindFirstChild("SEE_ESP_Highlight")
            if hl then hl.Enabled = false end
        end
        return
    end

    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local color = getESPColor(player)

            if not color then
                hideDraw(player)
            else
                local char = player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")

                if char and hrp and hum and hum.Health > 0 then
                    local d = ESP.Drawings[player] or createDraw(player)
                    local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    local headPos = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    local feetPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    if onScreen then
                        if ESP.ShowBox then
                            local h = math.abs(headPos.Y - feetPos.Y)
                            local w = h * 0.6
                            d.box.Size = Vector2.new(w, h)
                            d.box.Position = Vector2.new(pos.X - w/2, headPos.Y)
                            d.box.Color = color
                            d.box.Visible = true
                        else d.box.Visible = false end

                        if ESP.ShowName then
                            d.name.Text = player.Name
                            d.name.Position = Vector2.new(pos.X, headPos.Y - 18)
                            d.name.Color = color
                            d.name.Visible = true
                        else d.name.Visible = false end

                        if ESP.ShowHealth then
                            d.health.Text = "HP " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                            d.health.Position = Vector2.new(pos.X, feetPos.Y + 2)
                            d.health.Color = color
                            d.health.Visible = true
                        else d.health.Visible = false end

                        if ESP.ShowDistance and myHRP then
                            local dist = (hrp.Position - myHRP.Position).Magnitude
                            d.distance.Text = math.floor(dist) .. "m"
                            d.distance.Position = Vector2.new(pos.X, feetPos.Y + 18)
                            d.distance.Color = color
                            d.distance.Visible = true
                        else d.distance.Visible = false end

                        if ESP.ShowTracer then
                            d.tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                            d.tracer.To   = Vector2.new(pos.X, pos.Y)
                            d.tracer.Color = color
                            d.tracer.Visible = true
                        else d.tracer.Visible = false end
                    else
                        for _, obj in pairs(d) do obj.Visible = false end
                    end

                    if ESP.Highlight then
                        local hl = getESPHighlight(char)
                        hl.Enabled = true
                        hl.FillColor = color
                        hl.OutlineColor = color
                    else
                        local hl = char:FindFirstChild("SEE_ESP_Highlight")
                        if hl then hl.Enabled = false end
                    end
                else
                    local d = ESP.Drawings[player]
                    if d then for _, obj in pairs(d) do obj.Visible = false end end
                    local hl = char and char:FindFirstChild("SEE_ESP_Highlight")
                    if hl then hl.Enabled = false end
                end
            end
        end
    end
end)

-- ============================================================
-- 【4】Collision box
-- ============================================================
Tabs.CollisionTab:Section({ Title = "全局设置" })

local CB = {
    Enabled = false, IgnoreTeam = false,
    BoxSize = 5, HeadSize = 3,
    BoxEnabled = false, HeadEnabled = false,
    BoxTransparency = 0.3,
    HighlightEnabled = false, HighlightTransparency = 0.5,
    HighlightColor = Color3.fromRGB(255, 105, 180),
    OriginalData = {},
}

local function saveOriginal(player)
    if CB.OriginalData[player] then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    CB.OriginalData[player] = {
        hrpSize = hrp and hrp.Size,
        headSize = head and head.Size,
        hrpTransparency = hrp and hrp.Transparency or 0,
        hrpCanCollide = hrp and hrp.CanCollide or true,
    }
end

local function restoreOriginal(player)
    local data = CB.OriginalData[player]
    if not data then return end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if hrp and data.hrpSize then
            hrp.Size = data.hrpSize
            hrp.Transparency = data.hrpTransparency or 0
            hrp.CanCollide = data.hrpCanCollide ~= false
        end
        if head and data.headSize then head.Size = data.headSize end
        local hl = char:FindFirstChild("SEE_CB_Highlight")
        if hl then hl:Destroy() end
    end
    CB.OriginalData[player] = nil
end

local function applyToPlayer(player)
    if player == LocalPlayer then return end
    if CB.IgnoreTeam and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        restoreOriginal(player); return
    end
    saveOriginal(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local data = CB.OriginalData[player] or {}

    if hrp then
        if CB.BoxEnabled then
            hrp.Size = Vector3.new(CB.BoxSize, CB.BoxSize, CB.BoxSize)
            hrp.Transparency = CB.BoxTransparency
            hrp.CanCollide = false
        else
            if data.hrpSize then hrp.Size = data.hrpSize end
            hrp.Transparency = data.hrpTransparency or 0
            hrp.CanCollide = data.hrpCanCollide ~= false
        end
    end

    if head then
        if CB.HeadEnabled then
            head.Size = Vector3.new(CB.HeadSize, CB.HeadSize, CB.HeadSize)
        else
            if data.headSize then head.Size = data.headSize end
        end
    end

    local hl = char:FindFirstChild("SEE_CB_Highlight")
    if CB.HighlightEnabled then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "SEE_CB_Highlight"
            hl.Adornee = char
            hl.Parent = char
        end
        hl.FillColor = CB.HighlightColor
        hl.FillTransparency = CB.HighlightTransparency
        hl.OutlineColor = CB.HighlightColor
        hl.OutlineTransparency = 0
    else
        if hl then hl:Destroy() end
    end
end

Tabs.CollisionTab:Toggle({
    Title = "全局开启修改碰撞箱", Value = false,
    Callback = function(s)
        CB.Enabled = s
        if not s then
            for _, player in ipairs(Players:GetPlayers()) do restoreOriginal(player) end
        end
    end,
})

Tabs.CollisionTab:Section({ Title = "碰撞箱大小" })
Tabs.CollisionTab:Input({
    Title = "输入碰撞箱范围大小", Value = "5", Placeholder = "例如: 5",
    Callback = function(txt) CB.BoxSize = tonumber(txt) or 5 end,
})
Tabs.CollisionTab:Toggle({
    Title = "启用碰撞箱大小修改", Value = false,
    Callback = function(s) CB.BoxEnabled = s end,
})

Tabs.CollisionTab:Section({ Title = "头部变大" })
Tabs.CollisionTab:Input({
    Title = "输入头部大小", Value = "3", Placeholder = "例如: 3",
    Callback = function(txt) CB.HeadSize = tonumber(txt) or 3 end,
})
Tabs.CollisionTab:Toggle({
    Title = "启用头部变大", Value = false,
    Callback = function(s) CB.HeadEnabled = s end,
})

Tabs.CollisionTab:Section({ Title = "碰撞箱高亮" })
Tabs.CollisionTab:Toggle({
    Title = "启用碰撞箱高亮", Value = false,
    Callback = function(s) CB.HighlightEnabled = s end,
})
Tabs.CollisionTab:Slider({
    Title = "高亮透明度", Value = { Min = 0, Max = 1, Default = 0.5 },
    Callback = function(v) CB.HighlightTransparency = v end,
})
Tabs.CollisionTab:Colorpicker({
    Title = "高亮颜色", Default = CB.HighlightColor,
    Callback = function(c) CB.HighlightColor = c end,
})

Tabs.CollisionTab:Section({ Title = "碰撞箱透明度" })
Tabs.CollisionTab:Slider({
    Title = "碰撞箱透明度", Value = { Min = 0, Max = 1, Default = 0.3 },
    Callback = function(v) CB.BoxTransparency = v end,
})

Tabs.CollisionTab:Section({ Title = "团队设置" })
Tabs.CollisionTab:Toggle({
    Title = "忽略队友（不修改队友碰撞箱）", Value = false,
    Callback = function(s) CB.IgnoreTeam = s end,
})

local lastCBUpdate = 0
RunService.Heartbeat:Connect(function()
    if not CB.Enabled then return end
    if tick() - lastCBUpdate < 0.2 then return end
    lastCBUpdate = tick()
    for _, player in ipairs(Players:GetPlayers()) do applyToPlayer(player) end
end)

Players.PlayerRemoving:Connect(function(player) CB.OriginalData[player] = nil end)

Tabs.CollisionTab:Section({ Title = "单独玩家修改" })

local selectedPlayerName = nil

local function getPlayerNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local playerDropdown
playerDropdown = Tabs.CollisionTab:Dropdown({
    Title = "选择玩家",
    Values = getPlayerNames(),
    Multi = false, AllowNone = true,
    Callback = function(opt) selectedPlayerName = opt end,
})

Tabs.CollisionTab:Button({
    Title = "应用碰撞箱到该玩家",
    Callback = function()
        if not selectedPlayerName then
            WindUI:Notify({ Title = "提示", Content = "请先选择玩家", Icon = "alert-circle", Duration = 3 })
            return
        end
        local target = Players:FindFirstChild(selectedPlayerName)
        if not target or not target.Character then return end
        saveOriginal(target)
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(CB.BoxSize, CB.BoxSize, CB.BoxSize)
            hrp.Transparency = CB.BoxTransparency
        end
    end,
})

Tabs.CollisionTab:Button({
    Title = "应用头部变大到该玩家",
    Callback = function()
        if not selectedPlayerName then
            WindUI:Notify({ Title = "提示", Content = "请先选择玩家", Icon = "alert-circle", Duration = 3 })
            return
        end
        local target = Players:FindFirstChild(selectedPlayerName)
        if not target or not target.Character then return end
        saveOriginal(target)
        local head = target.Character:FindFirstChild("Head")
        if head then head.Size = Vector3.new(CB.HeadSize, CB.HeadSize, CB.HeadSize) end
    end,
})

Tabs.CollisionTab:Button({
    Title = "恢复该玩家碰撞箱",
    Callback = function()
        if not selectedPlayerName then return end
        local target = Players:FindFirstChild(selectedPlayerName)
        if target then restoreOriginal(target) end
    end,
})

Tabs.CollisionTab:Button({
    Title = "刷新服务器玩家",
    Callback = function()
        playerDropdown:Refresh(getPlayerNames())
        WindUI:Notify({ Title = "已刷新", Content = "服务器玩家列表已更新", Icon = "refresh-cw", Duration = 3 })
    end,
})

-- ============================================================
-- 【5】自瞄
-- ============================================================
Tabs.AimbotTab:Section({ Title = "全局设置" })

local Aimbot = {
    Enabled      = false,
    FOV          = 150,
    Smoothness   = 0.18,
    Delay        = 0.05,
    ShowTracer   = false,
    WallCheck    = true,
    Color        = Color3.fromRGB(255, 105, 180),
    LockedTarget = nil,
    LockStart    = 0,
    TracerLine   = nil,
    FovCircle    = nil,
    Part         = "Head",
    Prediction   = 0.05,
}

local canDrawing = pcall(function() return Drawing.new("Circle") end)

if canDrawing then
    Aimbot.FovCircle = Drawing.new("Circle")
    Aimbot.FovCircle.Thickness    = 1.5
    Aimbot.FovCircle.NumSides     = 64
    Aimbot.FovCircle.Filled       = false
    Aimbot.FovCircle.Transparency = 0.6
    Aimbot.FovCircle.Visible      = false
end

Tabs.AimbotTab:Toggle({
    Title = "全局开启自瞄", Value = false,
    Callback = function(s)
        Aimbot.Enabled = s
        if not s then
            Aimbot.LockedTarget = nil
            if Aimbot.FovCircle then Aimbot.FovCircle.Visible = false end
            if Aimbot.TracerLine then Aimbot.TracerLine.Visible = false end
        end
    end,
})

Tabs.AimbotTab:Section({ Title = "瞄准部位" })

Tabs.AimbotTab:Dropdown({
    Title = "选择瞄准部位",
    Values = { "头部（Head）", "身体（RootPart）", "随机部位", "最近部位" },
    Value = "头部（Head）",
    Callback = function(opt)
        if opt == "头部（Head）" then
            Aimbot.Part = "Head"
        elseif opt == "身体（RootPart）" then
            Aimbot.Part = "HumanoidRootPart"
        elseif opt == "随机部位" then
            Aimbot.Part = "Random"
        elseif opt == "最近部位" then
            Aimbot.Part = "Nearest"
        end
    end,
})

Tabs.AimbotTab:Section({ Title = "自瞄参数" })

Tabs.AimbotTab:Slider({
    Title = "自瞄圈大小 (FOV)",
    Value = { Min = 20, Max = 600, Default = 150 },
    Callback = function(v) Aimbot.FOV = v end,
})

Tabs.AimbotTab:Slider({
    Title = "自瞄平滑速度",
    Value = { Min = 1, Max = 100, Default = 18 },
    Callback = function(v) Aimbot.Smoothness = v / 100 end,
})

Tabs.AimbotTab:Slider({
    Title = "自瞄延迟 (秒)",
    Value = { Min = 0, Max = 2, Default = 0.05 },
    Callback = function(v) Aimbot.Delay = v end,
})

Tabs.AimbotTab:Slider({
    Title = "速度预判",
    Value = { Min = 0, Max = 0.5, Default = 0.05 },
    Callback = function(v) Aimbot.Prediction = v end,
})

Tabs.AimbotTab:Section({ Title = "自瞄选项" })

Tabs.AimbotTab:Toggle({
    Title = "自瞄射线", Value = false,
    Callback = function(s) Aimbot.ShowTracer = s end,
})

Tabs.AimbotTab:Toggle({
    Title = "检测墙壁（不可穿墙锁定）", Value = true,
    Callback = function(s) Aimbot.WallCheck = s end,
})

Tabs.AimbotTab:Toggle({
    Title = "队伍检测（不锁队友）★与透视共享",
    Desc  = "和透视的队伍检测是同一个开关",
    Value = true,
    Callback = function(s)
        GlobalTeamCheck = s
        WindUI:Notify({
            Title = "队伍检测",
            Content = s and "已开启（不画/不锁队友）" or "已关闭（全部显示）",
            Icon = "users",
            Duration = 2,
        })
    end,
})

Tabs.AimbotTab:Section({ Title = "颜色" })

Tabs.AimbotTab:Colorpicker({
    Title = "自瞄圈/射线颜色", Default = Aimbot.Color,
    Callback = function(c)
        Aimbot.Color = c
        if Aimbot.FovCircle then Aimbot.FovCircle.Color = c end
    end,
})

local function canAimbotTarget(player)
    if player == LocalPlayer then return false end
    if not GlobalTeamCheck then return true end
    return not isTeammate(player)
end

local function getAimPosition(char, camPos)
    if Aimbot.Part == "Head" then
        local head = char:FindFirstChild("Head")
        return head and head.Position or nil
    elseif Aimbot.Part == "HumanoidRootPart" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Position or nil
    elseif Aimbot.Part == "Random" then
        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local options = {}
        if head then table.insert(options, head.Position) end
        if hrp  then table.insert(options, hrp.Position) end
        if #options == 0 then return nil end
        return options[math.random(1, #options)]
    elseif Aimbot.Part == "Nearest" then
        local best, bestDist = nil, math.huge
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local d = (part.Position - camPos).Magnitude
                if d < bestDist then best = part; bestDist = d end
            end
        end
        return best and best.Position or nil
    end
    return nil
end

local function isVisible(targetChar, aimPos)
    if not Aimbot.WallCheck then return true end
    local cam = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local dir = aimPos - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {}
    if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
    if targetChar then table.insert(filterList, targetChar) end
    params.FilterDescendantsInstances = filterList

    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

local function getScreenPos(pos)
    local cam = workspace.CurrentCamera
    local sp, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onScreen
end

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    if not Aimbot.Enabled then
        if Aimbot.FovCircle then Aimbot.FovCircle.Visible = false end
        if Aimbot.TracerLine then Aimbot.TracerLine.Visible = false end
        return
    end

    if Aimbot.FovCircle then
        Aimbot.FovCircle.Position = center
        Aimbot.FovCircle.Radius   = Aimbot.FOV
        Aimbot.FovCircle.Color    = Aimbot.Color
        Aimbot.FovCircle.Visible  = true
    end

    local locked = Aimbot.LockedTarget
    local lockedValid = false
    if locked and locked.Parent and locked.Character then
        local hum = locked.Character:FindFirstChildOfClass("Humanoid")
        local aimPos = getAimPosition(locked.Character, cam.CFrame.Position)
        if hum and hum.Health > 0 and aimPos and canAimbotTarget(locked) then
            local sp, onScreen = getScreenPos(aimPos)
            local inFov = onScreen and (sp - center).Magnitude <= Aimbot.FOV
            local wallOk = isVisible(locked.Character, aimPos)
            if inFov and wallOk then lockedValid = true end
        end
    end

    if not lockedValid then
        Aimbot.LockedTarget = nil
        local closest, closestDist = nil, Aimbot.FOV

        for _, plr in ipairs(Players:GetPlayers()) do
            if canAimbotTarget(plr) then
                local char = plr.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum and hum.Health > 0 then
                    local aimPos = getAimPosition(char, cam.CFrame.Position)
                    if aimPos then
                        local sp, onScreen = getScreenPos(aimPos)
                        if onScreen then
                            local dist = (sp - center).Magnitude
                            if dist <= closestDist and isVisible(char, aimPos) then
                                closest     = plr
                                closestDist = dist
                            end
                        end
                    end
                end
            end
        end

        if closest then
            Aimbot.LockedTarget = closest
            Aimbot.LockStart    = tick()
        end
    end

    local target = Aimbot.LockedTarget
    if target and target.Character then
        local aimPos = getAimPosition(target.Character, cam.CFrame.Position)
        if aimPos and (tick() - Aimbot.LockStart >= Aimbot.Delay) then
            local hrp  = target.Character:FindFirstChild("HumanoidRootPart")
            local vel = hrp and hrp.Velocity or Vector3.zero
            local predicted = aimPos + vel * Aimbot.Prediction

            local myPos   = cam.CFrame.Position
            local desired = CFrame.lookAt(myPos, predicted)
            local alpha   = math.clamp(Aimbot.Smoothness, 0.01, 1)
            cam.CFrame    = cam.CFrame:Lerp(desired, alpha)

            if Aimbot.ShowTracer then
                if not Aimbot.TracerLine then
                    Aimbot.TracerLine = Drawing.new("Line")
                    Aimbot.TracerLine.Thickness = 1.5
                end
                local sp = getScreenPos(aimPos)
                Aimbot.TracerLine.From    = center
                Aimbot.TracerLine.To      = sp
                Aimbot.TracerLine.Color   = Aimbot.Color
                Aimbot.TracerLine.Visible = true
            else
                if Aimbot.TracerLine then Aimbot.TracerLine.Visible = false end
            end
        end
    else
        if Aimbot.TracerLine then Aimbot.TracerLine.Visible = false end
    end
end)

-- ============================================================
-- 【6】传送
-- ============================================================
Tabs.TPTab:Section({ Title = "传送目标" })

local TP = {
    TargetName   = nil,
    Distance     = 3,
    FollowOn     = false,
    FollowPos    = "后面",
    FollowConn   = nil,
    FlingPower   = 600,
}

local function getTPPlayerNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local tpDropdown
tpDropdown = Tabs.TPTab:Dropdown({
    Title = "选择玩家",
    Values = getTPPlayerNames(),
    Multi = false, AllowNone = true,
    Callback = function(opt) TP.TargetName = opt end,
})

Tabs.TPTab:Button({
    Title = "刷新服务器玩家",
    Callback = function()
        tpDropdown:Refresh(getTPPlayerNames())
        WindUI:Notify({ Title = "已刷新", Content = "玩家列表已更新", Icon = "refresh-cw", Duration = 3 })
    end,
})

Tabs.TPTab:Section({ Title = "距离设置" })

Tabs.TPTab:Slider({
    Title = "距离玩家间隔", Value = { Min = 0, Max = 20, Default = 3 },
    Callback = function(v) TP.Distance = v end,
})

local function calcCF(hrp, posName, dist)
    if posName == "头顶" then
        return hrp.CFrame * CFrame.new(0, dist, 0)
    elseif posName == "脚下" then
        return hrp.CFrame * CFrame.new(0, -dist, 0)
    elseif posName == "后面" then
        return hrp.CFrame * CFrame.new(0, 0, dist)
    elseif posName == "前面" then
        return hrp.CFrame * CFrame.new(0, 0, -dist)
    elseif posName == "重叠" then
        return hrp.CFrame
    else
        return hrp.CFrame * CFrame.new(0, 0, dist)
    end
end

local function getTargetParts()
    if not TP.TargetName then
        WindUI:Notify({ Title = "提示", Content = "请先选择玩家", Icon = "alert-circle", Duration = 3 })
        return nil, nil
    end
    local target = Players:FindFirstChild(TP.TargetName)
    if not target or not target.Character then
        WindUI:Notify({ Title = "提示", Content = "目标无角色", Icon = "alert-circle", Duration = 3 })
        return nil, nil
    end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        WindUI:Notify({ Title = "提示", Content = "目标角色异常", Icon = "alert-circle", Duration = 3 })
        return nil, nil
    end
    return target, hrp
end

local function safeTeleport(target, cf)
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        WindUI:Notify({ Title = "传送失败", Content = "角色未加载", Icon = "alert-circle", Duration = 3 })
        return
    end
    hrp.Velocity    = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.CFrame = cf + Vector3.new(
        math.random(-2, 2) / 100,
        math.random(-2, 2) / 100,
        math.random(-2, 2) / 100
    )
    local count = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        count = count + 1
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            h.Velocity    = Vector3.zero
            h.RotVelocity = Vector3.zero
            h.CFrame      = cf
        end
        if count >= 5 then if conn then conn:Disconnect() end end
    end)
    WindUI:Notify({ Title = "传送成功", Icon = "send", Duration = 3 })
end

Tabs.TPTab:Section({ Title = "单次传送" })

Tabs.TPTab:Button({
    Title = "传送到头顶",
    Callback = function()
        local target, hrp = getTargetParts()
        if not target then return end
        safeTeleport(target, calcCF(hrp, "头顶", TP.Distance))
    end,
})

Tabs.TPTab:Button({
    Title = "传送到脚下",
    Callback = function()
        local target, hrp = getTargetParts()
        if not target then return end
        safeTeleport(target, calcCF(hrp, "脚下", TP.Distance))
    end,
})

Tabs.TPTab:Button({
    Title = "传送到后面",
    Callback = function()
        local target, hrp = getTargetParts()
        if not target then return end
        safeTeleport(target, calcCF(hrp, "后面", TP.Distance))
    end,
})

Tabs.TPTab:Button({
    Title = "传送到前面",
    Callback = function()
        local target, hrp = getTargetParts()
        if not target then return end
        safeTeleport(target, calcCF(hrp, "前面", TP.Distance))
    end,
})

Tabs.TPTab:Section({ Title = "持续跟随" })

Tabs.TPTab:Dropdown({
    Title = "跟随位置",
    Values = { "后面", "前面", "头顶", "脚下", "重叠" },
    Value = "后面",
    Callback = function(opt) TP.FollowPos = opt end,
})

local function stopFollow()
    TP.FollowOn = false
    if TP.FollowConn then
        TP.FollowConn:Disconnect()
        TP.FollowConn = nil
    end
end

Tabs.TPTab:Toggle({
    Title = "开启持续跟随（粘住目标）",
    Value = false,
    Callback = function(state)
        if TP.FollowOn == state then return end
        if state then
            if not TP.TargetName then
                WindUI:Notify({ Title = "提示", Content = "请先选择玩家", Icon = "alert-circle", Duration = 3 })
                return
            end
            TP.FollowOn = true
            local frame = 0
            TP.FollowConn = RunService.Heartbeat:Connect(function()
                if not TP.FollowOn then return end
                frame = frame + 1
                local target = Players:FindFirstChild(TP.TargetName)
                if not target or not target.Character then return end
                local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                if not tHRP or not tHum or tHum.Health <= 0 then return end
                local myChar = LocalPlayer.Character
                local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then return end
                local cf = calcCF(tHRP, TP.FollowPos, TP.Distance)
                myHRP.CFrame = cf
                if frame % 3 == 0 then
                    myHRP.Velocity    = Vector3.zero
                    myHRP.RotVelocity = Vector3.zero
                end
            end)
            WindUI:Notify({ Title = "持续跟随已开启", Content = "正在粘住 " .. TP.TargetName, Icon = "anchor", Duration = 3 })
        else
            stopFollow()
            WindUI:Notify({ Title = "持续跟随已关闭", Icon = "anchor", Duration = 2 })
        end
    end,
})

Tabs.TPTab:Button({
    Title = "立即停止跟随",
    Callback = stopFollow,
})

Tabs.TPTab:Section({ Title = "隐身" })

local Invisible = {
    Enabled    = false,
    InvisChair = nil,
    SavedPos   = nil,
}

local function startInvisChair()
    local char = LocalPlayer.Character
    if not char then
        WindUI:Notify({ Title = "隐身失败", Content = "角色未加载", Icon = "alert-circle", Duration = 3 })
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        WindUI:Notify({ Title = "隐身失败", Content = "HumanoidRootPart 缺失", Icon = "alert-circle", Duration = 3 })
        return
    end

    Invisible.SavedPos = hrp.CFrame
    task.wait(0.05)

    char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
    task.wait(0.15)

    local seat = Instance.new("Seat", workspace)
    seat.Anchored      = false
    seat.CanCollide    = false
    seat.Name          = "invischair"
    seat.Transparency  = 1
    seat.Position      = Vector3.new(-25.95, 84, 3537.55)

    local weld = Instance.new("Weld", seat)
    weld.Part0 = seat
    weld.Part1 = char:FindFirstChild("Torso")
              or char:FindFirstChild("UpperTorso")
              or hrp

    task.wait(0.05)

    seat.CFrame = Invisible.SavedPos

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 0.5
        end
    end

    Invisible.InvisChair = seat
    Invisible.Enabled    = true

    WindUI:Notify({ Title = "隐身已开启（隐形椅）", Content = "别人看不到你，可以攻击", Icon = "eye-off", Duration = 3 })
end

local function stopInvisChair()
    Invisible.Enabled = false

    local chair = workspace:FindFirstChild("invischair")
    if chair then chair:Destroy() end
    if Invisible.InvisChair and Invisible.InvisChair.Parent then
        Invisible.InvisChair:Destroy()
    end
    Invisible.InvisChair = nil

    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end

    WindUI:Notify({ Title = "隐身已关闭", Icon = "eye", Duration = 2 })
end

Tabs.TPTab:Toggle({
    Title = "隐身（隐形椅法）",
    Desc  = "TSB 专用：把角色焊在隐形 Seat 上",
    Value = false,
    Callback = function(state)
        if state then
            startInvisChair()
        else
            stopInvisChair()
        end
    end,
})

LocalPlayer.CharacterAdded:Connect(function()
    if Invisible.Enabled then
        task.wait(1)
        stopInvisChair()
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    Invisible.Enabled = false
    local chair = workspace:FindFirstChild("invischair")
    if chair then chair:Destroy() end
    Invisible.InvisChair = nil
end)

Tabs.TPTab:Section({ Title = "甩飞" })

Tabs.TPTab:Slider({
    Title = "甩飞力度", Value = { Min = 100, Max = 2000, Default = 600 },
    Callback = function(v) TP.FlingPower = v end,
})

Tabs.TPTab:Button({
    Title = "甩飞目标",
    Callback = function()
        local target, hrp = getTargetParts()
        if not target then return end
        local power = TP.FlingPower

        hrp.Velocity    = Vector3.new(math.random(-power, power), power, math.random(-power, power))
        hrp.RotVelocity = Vector3.new(math.random(-power, power), math.random(-power, power), math.random(-power, power))

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(math.random(-power, power), power, math.random(-power, power))
        bv.Parent   = hrp

        local bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(math.random(-power, power), math.random(-power, power), math.random(-power, power))
        bav.Parent = hrp

        task.delay(3, function()
            if bv  and bv.Parent  then bv:Destroy()  end
            if bav and bav.Parent then bav:Destroy() end
        end)

        WindUI:Notify({ Title = "甩飞成功", Content = "目标已被甩飞", Icon = "wind", Duration = 3 })
    end,
})

Tabs.TPTab:Button({
    Title = "停止甩飞（清理物理体）",
    Callback = function()
        local target = TP.TargetName and Players:FindFirstChild(TP.TargetName)
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") then
                v:Destroy()
            end
        end
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end,
})

-- ============================================================
-- 【7】旋转
-- ============================================================
Tabs.RotateTab:Section({ Title = "角色旋转" })

local Rotate = {
    Enabled = false,
    Speed   = 10,
    Conn    = nil,
}

Tabs.RotateTab:Input({
    Title = "输入旋转速度（度/秒）",
    Value = "10",
    Placeholder = "例如: 10",
    Callback = function(txt) Rotate.Speed = tonumber(txt) or 10 end,
})

Tabs.RotateTab:Slider({
    Title = "快捷调节速度",
    Value = { Min = 1, Max = 720, Default = 10 },
    Callback = function(v) Rotate.Speed = v end,
})

Tabs.RotateTab:Toggle({
    Title = "开启旋转",
    Desc  = "角色持续自转",
    Value = false,
    Callback = function(state)
        Rotate.Enabled = state
        if state then
            Rotate.Conn = RunService.Heartbeat:Connect(function(dt)
                if not Rotate.Enabled then return end
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Rotate.Speed) * dt, 0)
                end
            end)
            WindUI:Notify({ Title = "旋转已开启", Icon = "rotate-cw", Duration = 2 })
        else
            if Rotate.Conn then Rotate.Conn:Disconnect(); Rotate.Conn = nil end
            WindUI:Notify({ Title = "旋转已关闭", Icon = "rotate-cw", Duration = 2 })
        end
    end,
})

Tabs.RotateTab:Section({ Title = "视角旋转（相机）" })

local CamRotate = {
    Enabled = false,
    Speed   = 5,
    Conn    = nil,
}

Tabs.RotateTab:Input({
    Title = "相机旋转速度（度/秒）",
    Value = "5",
    Placeholder = "例如: 5",
    Callback = function(txt) CamRotate.Speed = tonumber(txt) or 5 end,
})

Tabs.RotateTab:Toggle({
    Title = "开启相机旋转",
    Desc  = "摄像机持续环绕",
    Value = false,
    Callback = function(state)
        CamRotate.Enabled = state
        if state then
            CamRotate.Conn = RunService.RenderStepped:Connect(function(dt)
                if not CamRotate.Enabled then return end
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(CamRotate.Speed) * dt, 0)
                end
            end)
            WindUI:Notify({ Title = "相机旋转已开启", Icon = "video", Duration = 2 })
        else
            if CamRotate.Conn then CamRotate.Conn:Disconnect(); CamRotate.Conn = nil end
            WindUI:Notify({ Title = "相机旋转已关闭", Icon = "video", Duration = 2 })
        end
    end,
})

-- ============================================================
-- 【8】公告栏
-- ============================================================
Tabs.AnnounceTab:Section({ Title = "关于作者" })

Tabs.AnnounceTab:Paragraph({
    Title = "seeded",
    Desc  = "SEE 脚本作者，专注 Roblox 实用工具开发。",
    Image = "user", ImageSize = 40,
})

Tabs.AnnounceTab:Section({ Title = "使用须知" })

Tabs.AnnounceTab:Paragraph({
    Title = "禁止倒卖",
    Desc  = "本脚本完全免费，禁止任何形式的倒卖、转售。",
    Image = "ban", ImageSize = 32, Color = "Red",
})

Tabs.AnnounceTab:Paragraph({
    Title = "理智开挂",
    Desc  = "请适度使用，过度使用可能封号。建议在私人服务器测试。",
    Image = "shield-alert", ImageSize = 32, Color = "Orange",
})

Tabs.AnnounceTab:Section({ Title = "版本信息" })

Tabs.AnnounceTab:Paragraph({
    Title = "SEE 脚本 v1.0",
    Desc  = "发布日期: 2026\n\n功能:\n• 速度/跳跃/血量/视角/FOV\n• 穿墙/点击传送/踏空而行(UESP)/飞行/飞车/快速互动/夜视/无限跳/爬墙/FPS\n• 透视（区分团队，颜色自动跟随游戏队伍）\n• 碰撞箱\n• 自瞄\n• 传送（单次/跟随/隐身/甩飞）\n• 旋转（角色 / 相机）",
    Image = "info", ImageSize = 32,
})

WindUI:Notify({
    Title = "SEE 脚本 v1.0",
    Content = "加载完成！按 G 键开关界面。",
    Icon = "check-circle", Duration = 5,
})
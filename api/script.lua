
local WORKER_URL = "https://keyscrpit.teamgamehub99.workers.dev/getkey"
local GET_KEY_URL = 'https://bbmkts.com/go/scriptroblox"

local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local FILE_NAME = "KeyCache.txt"

-- ----------------------------------------------------------------
-- HWID
-- ----------------------------------------------------------------
local function getHWID()
    local ok, id = pcall(function()
        return tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    end)
    return ok and id or "unknown"
end

-- ----------------------------------------------------------------
-- Validate key với server
-- ----------------------------------------------------------------
local function validateKey(key)
    local ok, res = pcall(function()
        return HttpService:RequestAsync({
            Url    = WORKER_URL .. "/validate",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body   = HttpService:JSONEncode({ key = key, hwid = getHWID() }),
        })
    end)
    if not ok then return false, "Không thể kết nối server" end

    local data = HttpService:JSONDecode(res.Body)
    return data.valid, data.reason, data.remaining_minutes
end

-- ----------------------------------------------------------------
-- Chạy script chính
-- ----------------------------------------------------------------
local function ExecuteMain()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua",
        true
    ))()
end

-- ----------------------------------------------------------------
-- Kiểm tra cache local
-- ----------------------------------------------------------------
if readfile and isfile and isfile(FILE_NAME) then
    local cached = (readfile(FILE_NAME) or ""):gsub("%s+", "")
    if cached ~= "" then
        local valid, reason, mins = validateKey(cached)
        if valid then
            ExecuteMain()
            return
        end
        -- Cache hết hạn → xóa
        if writefile then pcall(function() writefile(FILE_NAME, "") end) end
    end
end

-- ================================================================
-- UI
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystem"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent           = ScreenGui
MainFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.Position         = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size             = UDim2.new(0, 360, 0, 240)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(255, 0, 40)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text               = "🔐 SECURE ACCESS"
Title.Font               = Enum.Font.GothamBold
Title.TextColor3         = Color3.fromRGB(255, 255, 255)
Title.TextSize           = 20
Title.Size               = UDim2.new(1, 0, 0, 55)
Title.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.Text            = "Nhấn GET KEY để lấy key, sau đó nhập vào bên dưới"
SubTitle.Font            = Enum.Font.Gotham
SubTitle.TextColor3      = Color3.fromRGB(180, 180, 180)
SubTitle.TextSize        = 11
SubTitle.Size            = UDim2.new(1, -20, 0, 20)
SubTitle.Position        = UDim2.new(0, 10, 0, 52)
SubTitle.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", MainFrame)
KeyInput.PlaceholderText = "Nhập key tại đây..."
KeyInput.Text            = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
KeyInput.Position        = UDim2.new(0.05, 0, 0, 85)
KeyInput.Size            = UDim2.new(0.90, 0, 0, 42)
KeyInput.TextColor3      = Color3.fromRGB(255, 255, 255)
KeyInput.Font            = Enum.Font.GothamSemibold
KeyInput.TextSize        = 13
KeyInput.ClearTextOnFocus = false
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 10)
local IS = Instance.new("UIStroke", KeyInput)
IS.Color = Color3.fromRGB(255, 0, 40) IS.Thickness = 1.2 IS.Transparency = 0.5

local GetKeyBtn = Instance.new("TextButton", MainFrame)
GetKeyBtn.Text           = "🔑  GET KEY"
GetKeyBtn.Font           = Enum.Font.GothamBold
GetKeyBtn.TextSize       = 12
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 14, 16)
GetKeyBtn.TextColor3     = Color3.fromRGB(255, 80, 90)
GetKeyBtn.Position       = UDim2.new(0.05, 0, 0, 142)
GetKeyBtn.Size           = UDim2.new(0.90, 0, 0, 34)
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)

local ActivateBtn = Instance.new("TextButton", MainFrame)
ActivateBtn.Text         = "ACTIVATE"
ActivateBtn.Font         = Enum.Font.GothamBold
ActivateBtn.TextSize     = 14
ActivateBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 35)
ActivateBtn.TextColor3   = Color3.fromRGB(255, 255, 255)
ActivateBtn.Position     = UDim2.new(0.05, 0, 0, 186)
ActivateBtn.Size         = UDim2.new(0.90, 0, 0, 40)
Instance.new("UICorner", ActivateBtn).CornerRadius = UDim.new(0, 12)

-- Drag
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

-- Notify
local function notify(msg, color)
    local ng  = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local box = Instance.new("Frame", ng)
    local txt = Instance.new("TextLabel", box)
    box.Size                 = UDim2.new(0, 320, 0, 46)
    box.Position             = UDim2.new(0.5, -160, 0, -55)
    box.BackgroundColor3     = Color3.fromRGB(12, 12, 16)
    box.BackgroundTransparency = 0.05
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", box)
    s.Color = color s.Thickness = 2
    txt.Size                 = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text                 = msg
    txt.TextColor3           = Color3.fromRGB(255, 255, 255)
    txt.Font                 = Enum.Font.GothamBold
    txt.TextSize             = 13
    TweenService:Create(box, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -160, 0, 40) }):Play()
    task.wait(2.8)
    TweenService:Create(box, TweenInfo.new(0.3), { Position = UDim2.new(0.5, -160, 0, -55) }):Play()
    task.wait(0.3)
    ng:Destroy()
end

-- GET KEY button
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(GET_KEY_URL)
        notify("✅ Đã copy link lấy key! Mở trình duyệt để lấy key.", Color3.fromRGB(255, 0, 40))
    end
    -- Nếu executor hỗ trợ:
    -- syn.open_url(GET_KEY_URL)
end)

-- ACTIVATE button
ActivateBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text:gsub("%s+", "")
    if key == "" then
        notify("⚠️ Vui lòng nhập key!", Color3.fromRGB(255, 150, 0))
        return
    end

    ActivateBtn.Text             = "ĐANG KIỂM TRA..."
    ActivateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 0)

    local valid, reason, mins = validateKey(key)

    if valid then
        ActivateBtn.Text             = "✅ TRUY CẬP THÀNH CÔNG"
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 70)

        -- Lưu cache
        if writefile then
            pcall(function() writefile(FILE_NAME, key) end)
        end

        local timeMsg = mins and ("Còn " .. mins .. " phút") or ""
        notify("🎉 Kích hoạt thành công! " .. timeMsg, Color3.fromRGB(0, 200, 80))

        task.wait(0.6)
        TweenService:Create(MainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { Size = UDim2.new(0, 0, 0, 0) }):Play()
        task.wait(0.4)
        ScreenGui:Destroy()
        ExecuteMain()
    else
        ActivateBtn.Text             = "❌ THẤT BẠI"
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 20)
        notify("❌ " .. (reason or "Lỗi không xác định"), Color3.fromRGB(255, 0, 40))
        task.wait(2)
        ActivateBtn.Text             = "ACTIVATE"
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 35)
    end
end)

local WORKER_URL = "https://keyscrpit.teamgamehub99.workers.dev"
local GET_KEY_URL = "https://bbmkts.com/go/scriptroblox"

local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local FILE_NAME = "KeyCachebbgmv.txt"

local function getHWID()
    local ok, id = pcall(function()
        return tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    end)
    return ok and id or "unknown"
end

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

local function ExecuteMain()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua",
        true
    ))()
end

-- Cache check
if readfile and isfile and isfile(FILE_NAME) then
    local cached = (readfile(FILE_NAME) or ""):gsub("%s+", "")
    if cached ~= "" then
        local valid, reason, mins = validateKey(cached)
        if valid then
            ExecuteMain()
            return
        end
        if writefile then pcall(function() writefile(FILE_NAME, "") end) end
    end
end

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystem"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent           = ScreenGui
MainFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.Position         = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size             = UDim2.new(0, 380, 0, 250)
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

-- ── Input row: TextBox + Paste button ──────────────────────────────
local InputRow = Instance.new("Frame", MainFrame)
InputRow.BackgroundTransparency = 1
InputRow.Position = UDim2.new(0.05, 0, 0, 85)
InputRow.Size     = UDim2.new(0.90, 0, 0, 42)

local KeyInput = Instance.new("TextBox", InputRow)
KeyInput.PlaceholderText  = "Nhập key tại đây..."
KeyInput.Text             = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
KeyInput.Position         = UDim2.new(0, 0, 0, 0)
KeyInput.Size             = UDim2.new(1, -50, 1, 0)   -- chừa 50px cho nút Paste
KeyInput.TextColor3       = Color3.fromRGB(255, 255, 255)
KeyInput.Font             = Enum.Font.GothamSemibold
KeyInput.TextSize         = 13
KeyInput.ClearTextOnFocus = false
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 10)
local IS = Instance.new("UIStroke", KeyInput)
IS.Color        = Color3.fromRGB(255, 0, 40)
IS.Thickness    = 1.2
IS.Transparency = 0.5

-- ── Nút Paste ──────────────────────────────────────────────────────
local PasteBtn = Instance.new("TextButton", InputRow)
PasteBtn.Text            = "📋 Dán"
PasteBtn.Font            = Enum.Font.GothamBold
PasteBtn.TextSize        = 11
PasteBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
PasteBtn.TextColor3      = Color3.fromRGB(200, 200, 255)
PasteBtn.Position        = UDim2.new(1, -46, 0, 0)
PasteBtn.Size            = UDim2.new(0, 46, 1, 0)
Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0, 10)
local PS = Instance.new("UIStroke", PasteBtn)
PS.Color     = Color3.fromRGB(100, 100, 200)
PS.Thickness = 1

PasteBtn.MouseButton1Click:Connect(function()
    local ok, text = pcall(function()
        return getclipboard and getclipboard() or ""
    end)
    if ok and text and text ~= "" then
        KeyInput.Text = text:gsub("%s+", "")
        notify("📋 Đã dán key!", Color3.fromRGB(100, 100, 255))
    else
        notify("⚠️ Clipboard trống hoặc không hỗ trợ!", Color3.fromRGB(255, 150, 0))
    end
end)
-- ───────────────────────────────────────────────────────────────────

-- ── GET KEY button (blue, nổi bật như Activate) ────────────────────
local GetKeyBtn = Instance.new("TextButton", MainFrame)
GetKeyBtn.Text            = "🔑  GET KEY"
GetKeyBtn.Font            = Enum.Font.GothamBold
GetKeyBtn.TextSize        = 14
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 220)   -- blue nổi bật
GetKeyBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Position        = UDim2.new(0.05, 0, 0, 142)
GetKeyBtn.Size            = UDim2.new(0.90, 0, 0, 36)
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 12)
-- ───────────────────────────────────────────────────────────────────

local ActivateBtn = Instance.new("TextButton", MainFrame)
ActivateBtn.Text          = "ACTIVATE"
ActivateBtn.Font          = Enum.Font.GothamBold
ActivateBtn.TextSize      = 14
ActivateBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 35)
ActivateBtn.TextColor3    = Color3.fromRGB(255, 255, 255)
ActivateBtn.Position      = UDim2.new(0.05, 0, 0, 192)
ActivateBtn.Size          = UDim2.new(0.90, 0, 0, 40)
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

local function notify(msg, color)
    local ng  = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local box = Instance.new("Frame", ng)
    local txt = Instance.new("TextLabel", box)
    box.Size                   = UDim2.new(0, 320, 0, 46)
    box.Position               = UDim2.new(0.5, -160, 0, -55)
    box.BackgroundColor3       = Color3.fromRGB(12, 12, 16)
    box.BackgroundTransparency = 0.05
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", box)
    s.Color = color
    s.Thickness = 2
    txt.Size                   = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text                   = msg
    txt.TextColor3             = Color3.fromRGB(255, 255, 255)
    txt.Font                   = Enum.Font.GothamBold
    txt.TextSize               = 13
    TweenService:Create(box, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -160, 0, 40) }):Play()
    task.wait(2.8)
    TweenService:Create(box, TweenInfo.new(0.3), { Position = UDim2.new(0.5, -160, 0, -55) }):Play()
    task.wait(0.3)
    ng:Destroy()
end

-- ── GET KEY: copy + mở link ────────────────────────────────────────
GetKeyBtn.MouseButton1Click:Connect(function()
    -- 1. Copy link vào clipboard
    if setclipboard then
        pcall(function() setclipboard(GET_KEY_URL) end)
    end

    -- 2. Mở link bằng trình duyệt (thử theo thứ tự executor phổ biến)
    local opened = false

    if not opened and syn and syn.open_url then
        pcall(function() syn.open_url(GET_KEY_URL) end)
        opened = true
    end

    if not opened and (KRNL_LOADED or identifyexecutor and identifyexecutor():lower():find("krnl")) then
        pcall(function() shellexecute(GET_KEY_URL) end)
        opened = true
    end

    if not opened and shellexecute then
        pcall(function() shellexecute(GET_KEY_URL) end)
        opened = true
    end

    if not opened and os and os.execute then
        pcall(function()
            -- Windows
            os.execute('start "" "' .. GET_KEY_URL .. '"')
        end)
        opened = true
    end

    if opened then
        notify("✅ Đã mở trình duyệt & copy link!", Color3.fromRGB(0, 120, 255))
    else
        notify("📋 Đã copy link! Mở trình duyệt thủ công.", Color3.fromRGB(0, 120, 255))
    end
end)
-- ───────────────────────────────────────────────────────────────────

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

        if writefile then
            pcall(function() writefile(FILE_NAME, key) end)
        end

        local timeMsg = mins and ("Còn " .. tostring(mins) .. " phút") or ""
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

local WORKER_URL = "https://keyscrpit.teamgamehub99.workers.dev"
local KEY_LINK = "https://bbmkts.com/go/scriptroblox"

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- HWID đơn giản (có thể dùng cách khác nếu executor hỗ trợ)
local function getHWID()
    return tostring(game:GetService("RbxAnalyticsService"):GetClientId())
end

local function validateKeyOnServer(key)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = WORKER_URL .. "/validate",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = getHWID() })
        })
    end)
    if not success then return false, "Không thể kết nối server" end
    local data = HttpService:JSONDecode(response.Body)
    return data.valid, data.reason
end

local function ExecuteMainScript()
    -- thay bằng URL script thực của bạn
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end

-- Cache key local (tùy executor)
local FILE_NAME = "KeyCache.txt"
local cachedKey = nil
if readfile and isfile and isfile(FILE_NAME) then
    cachedKey = readfile(FILE_NAME):gsub("%s+", "")
    if cachedKey and cachedKey ~= "" then
        local valid, reason = validateKeyOnServer(cachedKey)
        if valid then
            ExecuteMainScript()
            return
        else
            -- Key hết hạn hoặc invalid, xóa cache
            if writefile then pcall(function() writefile(FILE_NAME, "") end) end
            cachedKey = nil
        end
    end
end

---------------------------------------------------------
-- UI
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystem"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.BackgroundTransparency = 0.08
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 230)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 24)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(255, 0, 40)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "SECURE ACCESS"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox")
KeyInput.Parent = MainFrame
KeyInput.PlaceholderText = "Nhập key..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
KeyInput.Position = UDim2.new(0.08, 0, 0.33, 0)
KeyInput.Size = UDim2.new(0.84, 0, 0, 45)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.TextSize = 14
local IC = Instance.new("UICorner", KeyInput) IC.CornerRadius = UDim.new(0, 12)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Parent = MainFrame
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(22, 14, 15)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 80, 90)
GetKeyBtn.Position = UDim2.new(0.08, 0, 0.60, 5)
GetKeyBtn.Size = UDim2.new(0.84, 0, 0, 32)
local GC = Instance.new("UICorner", GetKeyBtn) GC.CornerRadius = UDim.new(0, 10)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Parent = MainFrame
SubmitBtn.Text = "ACTIVATE"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 40)
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Position = UDim2.new(0.08, 0, 0.79, 10)
SubmitBtn.Size = UDim2.new(0.84, 0, 0, 40)
local SC = Instance.new("UICorner", SubmitBtn) SC.CornerRadius = UDim.new(0, 14)

-- Drag
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function notify(msg, color)
    local ng = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local box = Instance.new("Frame", ng)
    local txt = Instance.new("TextLabel", box)
    box.Size = UDim2.new(0, 300, 0, 45)
    box.Position = UDim2.new(0.5, -150, 0, -50)
    box.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", box) s.Color = color s.Thickness = 2
    txt.Size = UDim2.new(1,0,1,0) txt.BackgroundTransparency = 1
    txt.Text = msg txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Font = Enum.Font.GothamBold txt.TextSize = 13
    TweenService:Create(box, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,-150,0,40)}):Play()
    task.wait(2.5)
    TweenService:Create(box, TweenInfo.new(0.3), {Position = UDim2.new(0.5,-150,0,-50)}):Play()
    task.wait(0.3) ng:Destroy()
end

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KEY_LINK)
        notify("Đã copy link lấy key!", Color3.fromRGB(255, 0, 40))
    end
end)

SubmitBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text:gsub("%s+", "")
    if key == "" then
        notify("Vui lòng nhập key!", Color3.fromRGB(255, 0, 40))
        return
    end

    SubmitBtn.Text = "CHECKING..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)

    local valid, reason = validateKeyOnServer(key)

    if valid then
        SubmitBtn.Text = "ACCESS GRANTED!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)

        if writefile then
            pcall(function() writefile(FILE_NAME, key) end)
        end

        task.wait(0.5)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.4)
        ScreenGui:Destroy()
        ExecuteMainScript()
    else
        SubmitBtn.Text = "ACCESS DENIED!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 20)
        notify("Key không hợp lệ: " .. (reason or ""), Color3.fromRGB(255, 0, 40))
        task.wait(2)
        SubmitBtn.Text = "ACTIVATE"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 40)
    end
end)

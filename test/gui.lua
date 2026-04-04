
if not WYNF_OBFUSCATED then
    WYNF_JIT             = function(fn) return fn end
    WYNF_JIT_MAX         = function(fn) return fn end
    WYNF_SECURE_CALLBACK = function(fn) return fn end
    WYNF_NO_UPVALUES     = function(fn) return fn end
end

cloneref = cloneref or function(...) return ... end
local CAS      = cloneref(game:GetService("ContextActionService"))
local UIS      = cloneref(game:GetService("UserInputService"))
local TweenSvc = cloneref(game:GetService("TweenService"))
local Run      = cloneref(game:GetService("RunService"))

local T = {
    BG        = Color3.fromRGB( 11,  11,  14),
    Surface   = Color3.fromRGB( 17,  17,  22),
    Item      = Color3.fromRGB( 22,  22,  28),
    ItemSel   = Color3.fromRGB( 30,  30,  38),
    ItemCheck = Color3.fromRGB( 18,  18,  26),
    Accent    = Color3.fromRGB(215,  40,  40),
    Text      = Color3.fromRGB(230, 230, 232),
    TextDim   = Color3.fromRGB(140, 140, 148),
    TextMuted = Color3.fromRGB(160, 160, 172),
    Track     = Color3.fromRGB( 38,  38,  50),
    TOn       = Color3.fromRGB( 50, 195,  88),
    TOff      = Color3.fromRGB( 60,  60,  72),
    Border    = Color3.fromRGB( 36,  36,  48),
    W         = 242,
    ItemH     = 28,
    SliderH   = 48,
    HeaderH   = 56,
    HintH     = 32,
    Font      = Enum.Font.GothamMedium,
    FontLight = Enum.Font.Gotham,
    FS        = 13,
    TI        = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SoundId   = "rbxassetid://126347354635406",
}

local REPEAT_DELAY        = 0.35
local REPEAT_INTERVAL     = 0.06
local MAX_PANEL_CONTENT_H = 480

local _textInputFocused = false

local _sndInst = Instance.new("Sound")
_sndInst.SoundId = T.SoundId
_sndInst.Volume  = 0.35
_sndInst.Parent  = cloneref(game:GetService("SoundService"))

local function playSound()
    _sndInst:Stop()
    _sndInst:Play()
end

local Signal = {}
Signal.__index = Signal
function Signal.new()
    return setmetatable({ _f = {} }, Signal)
end
function Signal:Connect(fn)
    local key = {}
    self._f[key] = fn
    return { Disconnect = function() self._f[key] = nil end }
end
function Signal:Fire(...)
    for _, fn in pairs(self._f) do task.spawn(fn, ...) end
end
Signal.connect = Signal.Connect
Signal.fire    = Signal.Fire

local function New(cls, props)
    local i = Instance.new(cls)
    for k, v in pairs(props) do i[k] = v end
    return i
end
local function Corner(parent, radius)
    New("UICorner", { CornerRadius = UDim.new(0, radius or 4), Parent = parent })
end
local Tw = WYNF_JIT(function(inst, props)
    TweenSvc:Create(inst, T.TI, props):Play()
end)
local function MakeAccentBar(parent)
    return New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 2,
        Parent           = parent,
    })
end

local Button = {}
Button.__index = Button
Button.Type    = "Button"
function Button.new(parent, name)
    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    local bar = MakeAccentBar(frame)
    local lbl = New("TextLabel", {
        Name                   = "Label",
        Size                   = UDim2.new(1, -36, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    New("TextLabel", {
        Size                   = UDim2.new(0, 18, 1, 0),
        Position               = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text                   = ">",
        Font                   = T.Font,
        TextSize               = 17,
        TextColor3             = T.Accent,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = frame,
    })
    return setmetatable({ Name = name, Object = frame, _bar = bar, _lbl = lbl, Used = Signal.new() }, Button)
end
function Button:SetSelected(v)
    self._bar.Visible = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or T.Item })
    self._lbl.TextColor3 = v and T.Accent or T.Text
end
function Button:Use() playSound() ; self.Used:Fire() end

local Toggle = {}
Toggle.__index = Toggle
Toggle.Type    = "Toggle"
function Toggle.new(parent, name, default)
    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    local bar = MakeAccentBar(frame)
    local lbl = New("TextLabel", {
        Name                   = "Label",
        Size                   = UDim2.new(1, -60, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    local pill = New("Frame", {
        Size             = UDim2.new(0, 36, 0, 16),
        Position         = UDim2.new(1, -44, 0.5, -8),
        BackgroundColor3 = T.TOff,
        BorderSizePixel  = 0,
        Parent           = frame,
    })
    Corner(pill, 8)
    local dot = New("Frame", {
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(210, 210, 215),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = pill,
    })
    Corner(dot, 6)
    local self = setmetatable({
        Name   = name,
        Value  = default or false,
        Object = frame,
        _bar   = bar,
        _lbl   = lbl,
        _pill  = pill,
        _dot   = dot,
        Used   = Signal.new(),
    }, Toggle)
    self:_sync()
    return self
end
function Toggle:_sync()
    local on = self.Value
    Tw(self._pill, { BackgroundColor3 = on and T.TOn or T.TOff })
    Tw(self._dot, {
        Position         = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 215),
    })
end
function Toggle:Enable()      self.Value = true  ; self:_sync() ; self.Used:Fire(true)  end
function Toggle:Disable()     self.Value = false ; self:_sync() ; self.Used:Fire(false) end
function Toggle:Use()         playSound() ; if self.Value then self:Disable() else self:Enable() end end
function Toggle:UpdateState() self:_sync() end
function Toggle:SetSelected(v)
    self._bar.Visible    = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or T.Item })
    self._lbl.TextColor3 = v and T.Accent or T.Text
end

local Slider = {}
Slider.__index = Slider
Slider.Type    = "Slider"
function Slider.new(parent, settings)
    settings   = settings or {}
    local name = settings.Name or "Slider"
    local minV = settings.MinValue or 0
    local maxV = settings.MaxValue or 100
    local val  = math.clamp(settings.Value or (minV + maxV) / 2, minV, maxV)
    local step = settings.Step or 1
    local grad = settings.Gradient

    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.SliderH),
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    local bar = MakeAccentBar(frame)
    New("TextLabel", {
        Size                   = UDim2.new(1, -60, 0, 18),
        Position               = UDim2.new(0, 12, 0, 5),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.FontLight,
        TextSize               = T.FS - 1,
        TextColor3             = T.TextDim,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    local valLbl = New("TextLabel", {
        Name                   = "Value",
        Size                   = UDim2.new(0, 50, 0, 18),
        Position               = UDim2.new(1, -58, 0, 5),
        BackgroundTransparency = 1,
        Text                   = tostring(val),
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.Accent,
        TextXAlignment         = Enum.TextXAlignment.Right,
        Parent                 = frame,
    })
    local track = New("Frame", {
        Size             = UDim2.new(1, -20, 0, 6),
        Position         = UDim2.new(0, 10, 1, -14),
        BackgroundColor3 = grad and Color3.fromRGB(255, 255, 255) or T.Track,
        BorderSizePixel  = 0,
        Parent           = frame,
    })
    Corner(track, 3)
    if grad then grad.Parent = track end

    local fill = nil
    if not grad then
        fill = New("Frame", {
            Size             = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = T.Accent,
            BorderSizePixel  = 0,
            Parent           = track,
        })
        Corner(fill, 3)
    end

    local knob = New("Frame", {
        Size             = UDim2.new(0, 10, 0, 10),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(240, 240, 240),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = track,
    })
    Corner(knob, 5)
    if grad then
        New("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.45, Thickness = 1.5, Parent = knob })
    end

    local self = setmetatable({
        Name          = name,
        Value         = val,
        MinValue      = minV,
        MaxValue      = maxV,
        Step          = step,
        HasGradient   = grad ~= nil,
        Object        = frame,
        _bar          = bar,
        _fill         = fill,
        _knob         = knob,
        _valLbl       = valLbl,
        InUse         = false,
        _leftDown     = false,
        _rightDown    = false,
        _repeatThread = nil,
        ValueChanged  = Signal.new(),
    }, Slider)
    self:_sync()
    return self
end
function Slider:_sync()
    local t = (self.Value - self.MinValue) / math.max(self.MaxValue - self.MinValue, 1)
    self._valLbl.Text = tostring(self.Value)
    if self._fill then Tw(self._fill, { Size = UDim2.new(t, 0, 1, 0) }) end
    Tw(self._knob, { Position = UDim2.new(t, 0, 0.5, 0) })
end
function Slider:SetValue(v)
    local old     = self.Value
    local snapped = math.round(v / self.Step) * self.Step
    self.Value    = math.clamp(snapped, self.MinValue, self.MaxValue)
    self:_sync()
    if self.Value ~= old then self.ValueChanged:Fire(self.Value, old) end
end
function Slider:IncValue(v) self:SetValue(self.Value + v) end
function Slider:Update()    self:_sync() end
function Slider:SetSelected(v)
    self._bar.Visible = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or T.Item })
    if not v then self._bar.BackgroundColor3 = T.Accent end
end
function Slider:_startRepeat()
    if self._repeatThread then task.cancel(self._repeatThread) ; self._repeatThread = nil end
    self._repeatThread = task.spawn(function()
        task.wait(REPEAT_DELAY)
        while self.InUse do
            if self._leftDown then
                self:SetValue(self.Value - self.Step) ; playSound()
            elseif self._rightDown then
                self:SetValue(self.Value + self.Step) ; playSound()
            else
                break
            end
            task.wait(REPEAT_INTERVAL)
        end
        self._repeatThread = nil
    end)
end
function Slider:CaptureFocus()
    if self.InUse then return end
    self.InUse      = true
    self._leftDown  = false
    self._rightDown = false
    self._bar.Visible          = true
    self._bar.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
    if self._fill then Tw(self._fill, { BackgroundColor3 = Color3.fromRGB(70, 150, 255) }) end
    Tw(self._knob, { BackgroundColor3 = Color3.fromRGB(70, 150, 255) })

    local function onStep(action, state)
        if state == Enum.UserInputState.Begin then
            playSound()
            self:SetValue(self.Value + (action == "sLeft" and -self.Step or self.Step))
            if action == "sLeft" then self._leftDown = true else self._rightDown = true end
            self:_startRepeat()
        elseif state == Enum.UserInputState.End then
            if action == "sLeft" then self._leftDown = false else self._rightDown = false end
            if not self._leftDown and not self._rightDown then
                if self._repeatThread then task.cancel(self._repeatThread) ; self._repeatThread = nil end
            end
        end
        return Enum.ContextActionResult.Sink
    end
    local function onExit(_, state)
        if state == Enum.UserInputState.Begin then self:ReleaseFocus() end
        return Enum.ContextActionResult.Sink
    end
    local pri = Enum.ContextActionPriority.High.Value + 2
    CAS:BindActionAtPriority("sLeft",  onStep, false, pri, Enum.KeyCode.Left)
    CAS:BindActionAtPriority("sRight", onStep, false, pri, Enum.KeyCode.Right)
    CAS:BindActionAtPriority("sExit",  onExit, false, pri,
        Enum.KeyCode.Return, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.ButtonB)
end
function Slider:ReleaseFocus()
    if not self.InUse then return end
    self.InUse      = false
    self._leftDown  = false
    self._rightDown = false
    if self._repeatThread then task.cancel(self._repeatThread) ; self._repeatThread = nil end
    self._bar.BackgroundColor3 = T.Accent
    if self._fill then Tw(self._fill, { BackgroundColor3 = T.Accent }) end
    Tw(self._knob, { BackgroundColor3 = Color3.fromRGB(240, 240, 240) })
    CAS:UnbindAction("sLeft")
    CAS:UnbindAction("sRight")
    CAS:UnbindAction("sExit")
end
function Slider:Use()
    if self.InUse then self:ReleaseFocus() else self:CaptureFocus() end
end

local TextInput = {}
TextInput.__index = TextInput
TextInput.Type    = "TextInput"
function TextInput.new(parent, name, settings)
    settings = settings or {}
    local placeholder = settings.Placeholder or "Type here..."
    local default     = settings.Default     or ""

    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    local bar = MakeAccentBar(frame)
    New("TextLabel", {
        Size                   = UDim2.new(0, 72, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.TextDim,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    local box = New("TextBox", {
        Size              = UDim2.new(1, -90, 1, -8),
        Position          = UDim2.new(0, 84, 0, 4),
        BackgroundColor3  = T.Track,
        BorderSizePixel   = 0,
        Text              = default,
        PlaceholderText   = placeholder,
        Font              = T.FontLight,
        TextSize          = T.FS - 1,
        TextColor3        = T.Text,
        PlaceholderColor3 = T.TextMuted,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ClearTextOnFocus  = false,
        Parent            = frame,
    })
    New("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = box })
    Corner(box, 3)

    local self = setmetatable({
        Name         = name,
        Value        = default,
        Object       = frame,
        _bar         = bar,
        _box         = box,
        _focused     = false,
        ValueChanged = Signal.new(),
    }, TextInput)

    box.Focused:Connect(WYNF_SECURE_CALLBACK(function()
        self._focused     = true
        _textInputFocused = true
        Tw(box, { BackgroundColor3 = Color3.fromRGB(45, 45, 60) })
    end))
    box.FocusLost:Connect(WYNF_SECURE_CALLBACK(function(enterPressed)
        self._focused     = false
        _textInputFocused = false
        self.Value        = box.Text
        Tw(box, { BackgroundColor3 = T.Track })
        self.ValueChanged:Fire(box.Text, enterPressed)
    end))

    return self
end
function TextInput:SetValue(v)
    self.Value     = tostring(v)
    self._box.Text = self.Value
end
function TextInput:Use()
    self._box:CaptureFocus()
end
function TextInput:SetSelected(v)
    self._bar.Visible = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or T.Item })
end

local ColorPicker = {}
ColorPicker.__index = ColorPicker
ColorPicker.Type    = "ColorPicker"

local HUE_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,   1, 1)),
    ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
    ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
    ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
    ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
    ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
    ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,   1, 1)),
})

function ColorPicker.new(parent, name, settings)
    settings = settings or {}
    local defaultColor = settings.DefaultColor or Color3.fromRGB(255, 0, 0)
    local h0, s0, v0   = Color3.toHSV(defaultColor)
    h0 = math.clamp(math.floor(h0 * 360 + 0.5), 0, 360)
    s0 = math.clamp(math.floor(s0 * 100 + 0.5), 0, 100)
    v0 = math.clamp(math.floor(v0 * 100 + 0.5), 0, 100)

    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    local bar    = MakeAccentBar(frame)
    local header = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundTransparency = 1,
        Parent                 = frame,
    })
    local lbl = New("TextLabel", {
        Name                   = "Label",
        Size                   = UDim2.new(1, -82, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = header,
    })
    local swatch = New("Frame", {
        Size             = UDim2.new(0, 40, 0, 16),
        Position         = UDim2.new(1, -58, 0.5, -8),
        BackgroundColor3 = defaultColor,
        BorderSizePixel  = 0,
        Parent           = header,
    })
    Corner(swatch, 3)
    New("UIStroke", { Color = T.Border, Thickness = 1, Parent = swatch })
    local arrow = New("TextLabel", {
        Size                   = UDim2.new(0, 16, 1, 0),
        Position               = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text                   = ">",
        Font                   = T.Font,
        TextSize               = 11,
        TextColor3             = T.TextMuted,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = header,
    })
    local childFrame = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible                = false,
        Parent                 = frame,
    })
    New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = childFrame,
    })
    New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingBottom = UDim.new(0, 4), Parent = childFrame })

    local hueGrad = Instance.new("UIGradient") ; hueGrad.Color = HUE_SEQ
    local satGrad = Instance.new("UIGradient")
    local valGrad = Instance.new("UIGradient")

    local hSlider = Slider.new(childFrame, { Name = "Hue", MinValue = 0, MaxValue = 360, Value = h0, Step = 1, Gradient = hueGrad })
    local sSlider = Slider.new(childFrame, { Name = "Sat", MinValue = 0, MaxValue = 100, Value = s0, Step = 1, Gradient = satGrad })
    local vSlider = Slider.new(childFrame, { Name = "Val", MinValue = 0, MaxValue = 100, Value = v0, Step = 1, Gradient = valGrad })

    local self = setmetatable({
        Name         = name,
        Type         = "ColorPicker",
        IsOpen       = false,
        H            = h0,
        S            = s0,
        V            = v0,
        Color        = defaultColor,
        Object       = frame,
        _bar         = bar,
        _lbl         = lbl,
        _swatch      = swatch,
        _arrow       = arrow,
        _children    = childFrame,
        _satGrad     = satGrad,
        _valGrad     = valGrad,
        SelectedIdx  = 1,
        Children     = { hSlider, sSlider, vSlider },
        ListFrame    = childFrame,
        Parent       = nil,
        ColorChanged = Signal.new(),
    }, ColorPicker)

    self:_updateGradients()

    local function onChange()
        local c = Color3.fromHSV(self.H / 360, self.S / 100, self.V / 100)
        self.Color                    = c
        self._swatch.BackgroundColor3 = c
        self:_updateGradients()
        self.ColorChanged:Fire(c)
    end

    hSlider.ValueChanged:Connect(function(v) self.H = v ; onChange() end)
    sSlider.ValueChanged:Connect(function(v) self.S = v ; onChange() end)
    vSlider.ValueChanged:Connect(function(v) self.V = v ; onChange() end)

    return self
end
function ColorPicker:_updateGradients()
    local h = self.H / 360
    local v = math.max(self.V / 100, 0.35)
    local s = math.max(self.S / 100, 0.4)
    self._satGrad.Color = ColorSequence.new(Color3.fromHSV(h, 0, v), Color3.fromHSV(h, 1, v))
    self._valGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, s, 1))
end
function ColorPicker:Open()
    self.IsOpen            = true
    self._children.Visible = true
    self._arrow.Text       = "v"
    Tw(self._arrow, { TextColor3 = T.Accent })
    Tw(self.Object, { BackgroundColor3 = T.Surface })
    self._lbl.TextColor3   = T.Text
end
function ColorPicker:Close()
    for _, child in ipairs(self.Children) do
        if child.Type == "Slider" and child.InUse then child:ReleaseFocus() end
    end
    self.IsOpen            = false
    self._children.Visible = false
    self._arrow.Text       = ">"
    Tw(self._arrow, { TextColor3 = T.TextMuted })
    Tw(self.Object, { BackgroundColor3 = T.Item })
    self._lbl.TextColor3   = T.TextDim
end
function ColorPicker:Toggle() if self.IsOpen then self:Close() else self:Open() end end
function ColorPicker:Use()
    for _, sibling in ipairs(self.Parent.Children) do
        if sibling ~= self and (sibling.Type == "Tab" or sibling.Type == "ColorPicker") and sibling.IsOpen then
            sibling:Close()
        end
    end
    playSound()
    self:Toggle()
end
function ColorPicker:SetSelected(v)
    self._bar.Visible    = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or (self.IsOpen and T.Surface or T.Item) })
    self._lbl.TextColor3 = v and T.Accent or (self.IsOpen and T.Text or T.TextDim)
end

local Dropdown = {}
Dropdown.__index = Dropdown
Dropdown.Type    = "Dropdown"

function Dropdown.new(parent, name, settings)
    settings      = settings or {}
    local values  = settings.Values       or {}
    local multi   = settings.MultiSelect  == true
    local default = settings.DefaultValue

    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
        ClipsDescendants = false,
    })
    local bar    = MakeAccentBar(frame)
    local header = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Parent                 = frame,
    })
    local lbl = New("TextLabel", {
        Name                   = "Label",
        Size                   = UDim2.new(1, -36, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = header,
    })
    local arrow = New("TextLabel", {
        Size                   = UDim2.new(0, 18, 1, 0),
        Position               = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text                   = ">",
        Font                   = T.Font,
        TextSize               = 11,
        TextColor3             = T.TextMuted,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = header,
    })
    local optFrame = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 0),
        Position               = UDim2.new(0, 0, 0, T.ItemH),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible                = false,
        Parent                 = frame,
    })
    New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = optFrame,
    })
    New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = optFrame })

    local self = setmetatable({
        Name         = name,
        Object       = frame,
        _bar         = bar,
        _lbl         = lbl,
        _arrow       = arrow,
        _optFrame    = optFrame,
        IsOpen       = false,
        MultiSelect  = multi,
        Selected     = {},
        OptionItems  = {},
        SelectedIdx  = 1,
        ValueChanged = Signal.new(),
        _parentList  = nil,
    }, Dropdown)

    if default then
        if type(default) == "table" then
            for _, v in ipairs(default) do self.Selected[tostring(v)] = true end
        else
            self.Selected[tostring(default)] = true
        end
    elseif #values > 0 and not multi then
        self.Selected[tostring(values[1])] = true
    end

    self:_buildOptions(values)
    return self
end
function Dropdown:_buildOptions(values)
    for _, item in ipairs(self.OptionItems) do
        pcall(function() item.frame:Destroy() end)
    end
    self.OptionItems = {}
    for _, v in ipairs(values) do
        local vStr = tostring(v)
        local isOn = self.Selected[vStr] == true
        local row  = New("Frame", {
            Size             = UDim2.new(1, 0, 0, T.ItemH),
            BackgroundColor3 = isOn and T.ItemCheck or T.Item,
            BorderSizePixel  = 0,
            Parent           = self._optFrame,
        })
        local check = New("Frame", {
            Size             = UDim2.new(0, 6, 0, 6),
            Position         = UDim2.new(0, 6, 0.5, -3),
            BackgroundColor3 = isOn and T.TOn or T.TextMuted,
            BorderSizePixel  = 0,
            ZIndex           = 2,
            Parent           = row,
        })
        Corner(check, 3)
        local rowLbl = New("TextLabel", {
            Size                   = UDim2.new(1, -20, 1, 0),
            Position               = UDim2.new(0, 18, 0, 0),
            BackgroundTransparency = 1,
            Text                   = vStr,
            Font                   = T.FontLight,
            TextSize               = T.FS - 1,
            TextColor3             = isOn and T.Text or T.TextDim,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = row,
        })
        table.insert(self.OptionItems, { value = vStr, frame = row, check = check, lbl = rowLbl })
    end
end
function Dropdown:SetValues(values)
    self.Selected    = {}
    self.SelectedIdx = 1
    if self.IsOpen then self:Close() end
    self:_buildOptions(values)
end
function Dropdown:_syncRow(item)
    local on = self.Selected[item.value] == true
    Tw(item.frame, { BackgroundColor3 = on and T.ItemCheck or T.Item })
    Tw(item.check, { BackgroundColor3 = on and T.TOn or T.TextMuted })
    item.lbl.TextColor3 = on and T.Text or T.TextDim
end
function Dropdown:_toggleValue(vStr)
    if not self.MultiSelect then
        for k in pairs(self.Selected) do self.Selected[k] = nil end
        self.Selected[vStr] = true
    else
        self.Selected[vStr] = not self.Selected[vStr] or nil
    end
    for _, item in ipairs(self.OptionItems) do self:_syncRow(item) end
    self.ValueChanged:Fire(self:GetSelected())
end
function Dropdown:GetSelected()
    local out = {}
    for v in pairs(self.Selected) do table.insert(out, v) end
    return self.MultiSelect and out or out[1]
end
function Dropdown:Open()
    self.IsOpen            = true
    self._optFrame.Visible = true
    self._arrow.Text       = "v"
    Tw(self._arrow, { TextColor3 = T.Accent })
    self.SelectedIdx       = 1
    self:_highlightOption()
end
function Dropdown:Close()
    self.IsOpen            = false
    self._optFrame.Visible = false
    self._arrow.Text       = ">"
    Tw(self._arrow, { TextColor3 = T.TextMuted })
    for _, item in ipairs(self.OptionItems) do self:_syncRow(item) end
end
function Dropdown:_highlightOption()
    for i, item in ipairs(self.OptionItems) do
        if i == self.SelectedIdx then
            Tw(item.frame, { BackgroundColor3 = T.ItemSel })
            item.lbl.TextColor3 = T.Accent
        else
            self:_syncRow(item)
        end
    end
end
function Dropdown:NavigateOptions(dir)
    self.SelectedIdx = self.SelectedIdx + dir
    if self.SelectedIdx < 1                 then self.SelectedIdx = #self.OptionItems end
    if self.SelectedIdx > #self.OptionItems then self.SelectedIdx = 1                 end
    self:_highlightOption()
end
function Dropdown:SelectCurrent()
    local item = self.OptionItems[self.SelectedIdx]
    if item then playSound() ; self:_toggleValue(item.value) ; self:_highlightOption() end
end
function Dropdown:Use()
    playSound()
    if self.IsOpen then self:Close() else self:Open() end
end
function Dropdown:SetSelected(v)
    self._bar.Visible    = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or T.Item })
    self._lbl.TextColor3 = v and T.Accent or T.Text
end

local KeyBind = {}
KeyBind.__index = KeyBind
KeyBind.Type    = "KeyBind"

local KB_MODES = { "AlwaysOn", "Hold", "Toggle" }

function KeyBind.new(parent, name, settings)
    settings = settings or {}
    local defMode = settings.DefaultMode or "AlwaysOn"
    local defKey  = settings.DefaultKey

    local frame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    local bar      = MakeAccentBar(frame)
    local lbl      = New("TextLabel", {
        Size                   = UDim2.new(1, -148, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    local modePill = New("Frame", {
        Size             = UDim2.new(0, 62, 0, 16),
        Position         = UDim2.new(1, -142, 0.5, -8),
        BackgroundColor3 = T.Track,
        BorderSizePixel  = 0,
        Parent           = frame,
    })
    Corner(modePill, 4)
    local modeLbl = New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = defMode,
        Font                   = T.FontLight,
        TextSize               = 10,
        TextColor3             = T.TextDim,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = modePill,
    })
    local keyPill = New("Frame", {
        Size             = UDim2.new(0, 68, 0, 16),
        Position         = UDim2.new(1, -72, 0.5, -8),
        BackgroundColor3 = T.Track,
        BorderSizePixel  = 0,
        Parent           = frame,
    })
    Corner(keyPill, 4)
    local keyLbl = New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = defKey and defKey.Name or "None",
        Font                   = T.Font,
        TextSize               = 10,
        TextColor3             = defKey and T.Accent or T.TextDim,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = keyPill,
    })

    local modeIdx = 1
    for i, m in ipairs(KB_MODES) do
        if m == defMode then modeIdx = i ; break end
    end

    return setmetatable({
        Name         = name,
        Object       = frame,
        _bar         = bar,
        _lbl         = lbl,
        _modeLbl     = modeLbl,
        _modePill    = modePill,
        _keyLbl      = keyLbl,
        _keyPill     = keyPill,
        BoundKey     = defKey,
        BoundKeyType = "keyboard",
        Mode         = defMode,
        _modeIdx     = modeIdx,
        _listening   = false,
        _listenConn  = nil,
        Toggled      = false,
        KeyChanged   = Signal.new(),
        ModeChanged  = Signal.new(),
    }, KeyBind)
end
function KeyBind:_updateKeyDisplay()
    if self.BoundKey then
        self._keyLbl.Text       = self.BoundKey.Name
        self._keyLbl.TextColor3 = T.Accent
    else
        self._keyLbl.Text       = "None"
        self._keyLbl.TextColor3 = T.TextDim
    end
end
function KeyBind:CycleMode()
    self._modeIdx      = (self._modeIdx % #KB_MODES) + 1
    self.Mode          = KB_MODES[self._modeIdx]
    self.Toggled       = false
    self._modeLbl.Text = self.Mode
    Tw(self._modePill, { BackgroundColor3 = T.ItemSel })
    task.delay(0.3, function()
        if self._modePill and self._modePill.Parent then
            Tw(self._modePill, { BackgroundColor3 = T.Track })
        end
    end)
    self.ModeChanged:Fire(self.Mode)
end
function KeyBind:StartListening()
    if self._listening then return end
    self._listening         = true
    self._keyLbl.Text       = "press key..."
    self._keyLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
    Tw(self._keyPill, { BackgroundColor3 = Color3.fromRGB(50, 45, 20) })

    task.spawn(function()
        Run.Heartbeat:Wait()
        if not self._listening then return end

        local function finish(input)
            if not self._listening then return end
            self._listening = false
            if self._listenConn then self._listenConn:Disconnect() ; self._listenConn = nil end
            Tw(self._keyPill, { BackgroundColor3 = T.Track })
            if input then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    self.BoundKey     = input.KeyCode
                    self.BoundKeyType = "keyboard"
                else
                    self.BoundKey     = input.UserInputType
                    self.BoundKeyType = "mouse"
                end
                self:_updateKeyDisplay()
                self.KeyChanged:Fire(self.BoundKey, self.BoundKeyType, self.Mode)
            else
                self:_updateKeyDisplay()
            end
        end

        self._listenConn = UIS.InputBegan:Connect(WYNF_SECURE_CALLBACK(function(inp, _gpe)
            if inp.KeyCode == Enum.KeyCode.Escape then
                finish(nil)
            elseif inp.UserInputType == Enum.UserInputType.Keyboard
                or inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.MouseButton2
                or inp.UserInputType == Enum.UserInputType.MouseButton3
            then
                playSound()
                finish(inp)
            end
        end))
    end)
end
function KeyBind:IsActive()
    if self.Mode == "AlwaysOn" then return true end
    if self.Mode == "Hold" and self.BoundKey then
        local ok, result = pcall(function()
            if self.BoundKeyType == "keyboard" then
                return UIS:IsKeyDown(self.BoundKey)
            else
                return UIS:IsMouseButtonPressed(self.BoundKey)
            end
        end)
        return ok and result or false
    end
    return self.Toggled == true
end
function KeyBind:HandleInput(input)
    if self.Mode ~= "Toggle" or not self.BoundKey then return end
    local match = self.BoundKeyType == "keyboard"
        and input.KeyCode == self.BoundKey
        or  input.UserInputType == self.BoundKey
    if match then self.Toggled = not self.Toggled end
end
function KeyBind:Use()
    playSound()
    self:StartListening()
end
function KeyBind:SetSelected(v)
    self._bar.Visible    = v
    Tw(self.Object, { BackgroundColor3 = v and T.ItemSel or T.Item })
    self._lbl.TextColor3 = v and T.Accent or T.Text
end

local Tab = {}
Tab.__index = Tab
Tab.Type    = "Tab"

function Tab:Open()
    self.IsOpen            = true
    self._children.Visible = true
    self._arrow.Text       = "v"
    Tw(self._arrow, { TextColor3 = T.Accent })
    Tw(self.Object, { BackgroundColor3 = T.Surface })
    self.Object.Label.TextColor3 = T.Text
end
function Tab:Close()
    for _, child in ipairs(self.Children) do
        if child.Type == "Tab" or child.Type == "ColorPicker"    then child:Close() end
        if child.Type == "Dropdown"  and child.IsOpen            then child:Close() end
        if child.Type == "Slider"    and child.InUse             then child:ReleaseFocus() end
        if child.Type == "TextInput" and child._focused          then child._box:ReleaseFocus() end
        if child.Type == "KeyBind"   and child._listening        then
            child._listening = false
            if child._listenConn then child._listenConn:Disconnect() ; child._listenConn = nil end
            child:_updateKeyDisplay()
        end
    end
    self.IsOpen            = false
    self._children.Visible = false
    self._arrow.Text       = ">"
    Tw(self._arrow, { TextColor3 = T.TextMuted })
    self.Object.Label.TextColor3 = T.TextDim
end
function Tab:Toggle() if self.IsOpen then self:Close() else self:Open() end end
function Tab:Use()
    for _, sibling in ipairs(self.Parent.Children) do
        if sibling ~= self and (sibling.Type == "Tab" or sibling.Type == "ColorPicker") and sibling.IsOpen then
            sibling:Close()
        end
    end
    playSound()
    self:Toggle()
end
function Tab:SetSelected(v)
    self._bar.Visible = v
    if not v then
        Tw(self.Object, { BackgroundColor3 = self.IsOpen and T.Surface or T.Item })
    else
        Tw(self.Object, { BackgroundColor3 = T.ItemSel })
    end
end

local Container = {}

function Container:AddButton(name)
    local b = Button.new(self.ListFrame, name)
    table.insert(self.Children, b)
    return b
end
function Container:AddToggle(name, settings)
    local tog = Toggle.new(self.ListFrame, name, (settings or {}).Value)
    table.insert(self.Children, tog)
    return tog
end
function Container:AddSlider(settings)
    local s = Slider.new(self.ListFrame, settings or {})
    table.insert(self.Children, s)
    return s
end
function Container:AddDropdown(name, settings)
    local dd = Dropdown.new(self.ListFrame, name, settings or {})
    dd._parentList = self
    table.insert(self.Children, dd)
    return dd
end
function Container:AddKeyBind(name, settings)
    local kb = KeyBind.new(self.ListFrame, name, settings or {})
    table.insert(self.Children, kb)
    return kb
end
function Container:AddColorPicker(name, settings)
    local cp = ColorPicker.new(self.ListFrame, name, settings or {})
    cp.Parent = self
    table.insert(self.Children, cp)
    return cp
end
function Container:AddTextInput(name, settings)
    local ti = TextInput.new(self.ListFrame, name, settings or {})
    table.insert(self.Children, ti)
    return ti
end
function Container:AddTab(name)
    local headerFrame = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.ItemH),
        BackgroundColor3 = T.Item,
        BorderSizePixel  = 0,
        Parent           = self.ListFrame,
    })
    local bar = MakeAccentBar(headerFrame)
    New("TextLabel", {
        Name                   = "Label",
        Size                   = UDim2.new(1, -32, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        Font                   = T.Font,
        TextSize               = T.FS,
        TextColor3             = T.TextDim,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = headerFrame,
    })
    local arrow = New("TextLabel", {
        Name                   = "Arrow",
        Size                   = UDim2.new(0, 18, 1, 0),
        Position               = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text                   = ">",
        Font                   = T.Font,
        TextSize               = 11,
        TextColor3             = T.TextMuted,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = headerFrame,
    })
    local childFrame = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible                = false,
        Parent                 = self.ListFrame,
    })
    New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = childFrame,
    })
    New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = childFrame })

    local t = setmetatable({
        Name        = name,
        Type        = "Tab",
        IsOpen      = false,
        SelectedIdx = 1,
        Children    = {},
        Object      = headerFrame,
        ListFrame   = childFrame,
        _bar        = bar,
        _arrow      = arrow,
        _children   = childFrame,
        Parent      = self,
    }, Tab)

    table.insert(self.Children, t)
    return t
end

for k, v in pairs(Container) do Tab[k] = v end

local Menu = setmetatable({}, { __index = Container })
Menu.__index = Menu

function Menu.new(settings)
    settings    = settings or {}
    local title = settings.Title      or "Menu"
    local sub   = settings.Subtitle   or ""
    local key   = settings.ToggleKey  or Enum.KeyCode.Semicolon
    local color = settings.AccentColor
    if color then T.Accent = color end

    local sg = New("ScreenGui", {
        Name         = "TabGUI_" .. title,
        DisplayOrder = 9999,
        ResetOnSpawn = false,
        Parent       = cloneref(game:GetService("CoreGui")),
    })

    local panel = New("Frame", {
        Name             = "Panel",
        Size             = UDim2.new(0, T.W, 0, T.HeaderH + T.HintH),
        Position         = UDim2.new(1, -(T.W + 16), 0, 16),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = sg,
    })
    Corner(panel, 6)
    New("UIStroke", { Color = T.Border, Thickness = 1, Transparency = 0, Parent = panel })
    New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = panel,
    })

    local header = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.HeaderH),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
        Parent           = panel,
    })
    New("Frame", {
        Size             = UDim2.new(0, 3, 1, -10),
        Position         = UDim2.new(0, 0, 0, 5),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Parent           = header,
    })
    New("TextLabel", {
        Size                   = UDim2.new(1, -90, 0, 26),
        Position               = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text                   = title:upper(),
        Font                   = T.Font,
        TextSize               = 16,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = header,
    })
    if sub ~= "" then
        New("TextLabel", {
            Size                   = UDim2.new(1, -90, 0, 14),
            Position               = UDim2.new(0, 12, 0, 32),
            BackgroundTransparency = 1,
            Text                   = sub,
            Font                   = T.FontLight,
            TextSize               = 10,
            TextColor3             = T.Accent,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = header,
        })
    end
    local keyBadge = New("Frame", {
        Size             = UDim2.new(0, 72, 0, 18),
        Position         = UDim2.new(1, -80, 0.5, -9),
        BackgroundColor3 = T.Track,
        BorderSizePixel  = 0,
        Parent           = header,
    })
    Corner(keyBadge, 4)
    New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "[" .. key.Name .. "] hide",
        Font                   = T.Font,
        TextSize               = 11,
        TextColor3             = T.Text,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = keyBadge,
    })
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = header,
    })

    local listScroll = New("ScrollingFrame", {
        Name                   = "ListScroll",
        Size                   = UDim2.new(1, 0, 0, 0),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = T.Accent,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        LayoutOrder            = 1,
        Parent                 = panel,
    })
    local listFrame = New("Frame", {
        Name                   = "List",
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent                 = listScroll,
    })
    local listLayout = New("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = listFrame,
    })
    New("UIPadding", { PaddingBottom = UDim.new(0, 4), Parent = listFrame })

    local hintBar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, T.HintH),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
        Parent           = panel,
    })
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = hintBar,
    })
    New("TextLabel", {
        Size                   = UDim2.new(1, -8, 1, 0),
        Position               = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "↑/↓ move   →/Enter open   ← back   →(on bind) cycle mode",
        Font                   = T.Font,
        TextSize               = 10,
        TextColor3             = T.TextMuted,
        TextXAlignment         = Enum.TextXAlignment.Center,
        TextWrapped            = true,
        Parent                 = hintBar,
    })

    local self = setmetatable({
        Title       = title,
        Type        = "Menu",
        SelectedIdx = 1,
        Children    = {},
        ListFrame   = listFrame,
        Panel       = panel,
        ScreenGui   = sg,
        _listScroll = listScroll,
        Visible     = true,
        _inside     = nil,
        _toggleKey  = key,
    }, Menu)

    local function updatePanelHeight()
        local contentH = math.min(listLayout.AbsoluteContentSize.Y, MAX_PANEL_CONTENT_H)
        contentH = math.max(contentH, 0)
        listScroll.Size = UDim2.new(1, 0, 0, contentH)
        Tw(panel, { Size = UDim2.new(0, T.W, 0, T.HeaderH + contentH + T.HintH) })
    end

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePanelHeight)
    task.defer(updatePanelHeight)
    self:_bindKeys(key)
    task.defer(function() self:_updateHighlight() end)
    return self
end

function Menu:_list() return self._inside or self end
function Menu:_sel()  local l = self:_list() ; return l.Children[l.SelectedIdx] end
function Menu:_updateHighlight()
    local l = self:_list()
    if l.SelectedIdx < 1           then l.SelectedIdx = #l.Children end
    if l.SelectedIdx > #l.Children then l.SelectedIdx = 1           end
    for i, child in ipairs(l.Children) do
        if child.SetSelected then child:SetSelected(i == l.SelectedIdx) end
    end
    local sel = l.Children[l.SelectedIdx]
    if sel and sel.Object and self._listScroll then
        task.defer(function()
            local obj = sel.Object
            if not obj or not obj.Parent then return end
            local scroll = self._listScroll
            local relY   = obj.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
            local itemH  = obj.AbsoluteSize.Y
            local viewH  = scroll.AbsoluteSize.Y
            local curY   = scroll.CanvasPosition.Y
            if relY < curY then
                scroll.CanvasPosition = Vector2.new(0, math.max(0, relY))
            elseif relY + itemH > curY + viewH then
                scroll.CanvasPosition = Vector2.new(0, relY + itemH - viewH)
            end
        end)
    end
end
function Menu:_navigate(dir)
    local item = self:_sel()
    if item and item.Type == "Dropdown" and item.IsOpen then
        item:NavigateOptions(dir) ; return
    end
    self:_list().SelectedIdx = self:_list().SelectedIdx + dir
    self:_updateHighlight()
end
function Menu:_enterTab()
    local item = self:_sel()
    if not item then return end
    if item.Type == "Tab" or item.Type == "ColorPicker" then
        if not item.IsOpen then item:Open() end
        if #item.Children > 0 then
            self._inside         = item
            item.SelectedIdx     = 1
            self:_updateHighlight()
        end
    elseif item.Type == "KeyBind" then
        playSound() ; item:CycleMode()
    end
end
function Menu:_leaveTab()
    local item = self:_sel()
    if item and item.Type == "Dropdown" and item.IsOpen then
        playSound() ; item:Close() ; return
    end
    local current = self:_list()
    if current == self then return end
    local parent = current.Parent
    if current.Type == "Tab" or current.Type == "ColorPicker" then current:Close() end
    self._inside = (parent.Type == "Menu") and nil or parent
    self:_updateHighlight()
end
function Menu:_use()
    local item = self:_sel()
    if not item then return end
    if item.Type == "Tab" or item.Type == "ColorPicker" then
        if not item.IsOpen then item:Open() end
        if #item.Children > 0 then
            self._inside     = item
            item.SelectedIdx = 1
            self:_updateHighlight()
        end
    elseif item.Type == "Dropdown" then
        if item.IsOpen then item:SelectCurrent() else item:Use() end
    else
        item:Use()
    end
end
function Menu:SetVisibility(v)
    self.Visible           = v
    self.ScreenGui.Enabled = v
    if not v then
        local sel = self:_sel()
        if sel and sel.Type == "Slider" and sel.InUse then sel:ReleaseFocus() end
        for _, child in ipairs(self.Children) do
            if child.Type == "Dropdown"    and child.IsOpen then child:Close() end
            if child.Type == "ColorPicker" and child.IsOpen then child:Close() end
        end
    end
end
function Menu:SetToggleKey(k)
    pcall(function() CAS:UnbindAction("tgToggle") end)
    CAS:BindActionAtPriority("tgToggle", WYNF_SECURE_CALLBACK(function(_, s)
        if s == Enum.UserInputState.Begin then
            playSound()
            self:SetVisibility(not self.Visible)
        end
    end), false, Enum.ContextActionPriority.High.Value + 1, k)
end
function Menu:SetColor(c3) T.Accent = c3 end
function Menu:Cleanup()
    local actions = { "tgUp","tgDown","tgRight","tgLeft","tgUse","tgToggle","sLeft","sRight","sExit" }
    for _, a in ipairs(actions) do pcall(function() CAS:UnbindAction(a) end) end
    pcall(function() _sndInst:Destroy() end)
    pcall(function() self.ScreenGui:Destroy() end)
end
function Menu:_bindKeys(toggleKey)
    local pri = Enum.ContextActionPriority.High.Value + 1
    local onInput = WYNF_SECURE_CALLBACK(function(action, state)
        if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
        if not self.Visible                   then return Enum.ContextActionResult.Pass end
        if _textInputFocused                  then return Enum.ContextActionResult.Pass end
        local sel = self:_sel()
        if sel and sel.Type == "Slider"  and sel.InUse     then return Enum.ContextActionResult.Pass end
        if sel and sel.Type == "KeyBind" and sel._listening then return Enum.ContextActionResult.Pass end
        if     action == "tgUp"    then self:_navigate(-1)
        elseif action == "tgDown"  then self:_navigate( 1)
        elseif action == "tgRight" then self:_enterTab()
        elseif action == "tgLeft"  then self:_leaveTab()
        elseif action == "tgUse"   then self:_use()
        end
        return Enum.ContextActionResult.Sink
    end)
    CAS:BindActionAtPriority("tgUp",    onInput, false, pri, Enum.KeyCode.Up)
    CAS:BindActionAtPriority("tgDown",  onInput, false, pri, Enum.KeyCode.Down)
    CAS:BindActionAtPriority("tgRight", onInput, false, pri, Enum.KeyCode.Right)
    CAS:BindActionAtPriority("tgLeft",  onInput, false, pri, Enum.KeyCode.Left)
    CAS:BindActionAtPriority("tgUse",   onInput, false, pri, Enum.KeyCode.Return)
    self:SetToggleKey(toggleKey)
end

for k, v in pairs(Container) do Menu[k] = v end

getgenv().development_base = Menu
return Menu

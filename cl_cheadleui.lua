-- UI Utility library fully coded by codabro#2146, https://github.com/codabro

CheadleUI = CheadleUI or {}
CheadleUI.Fonts = CheadleUI.Fonts or {}
CheadleUI.Materials = CheadleUI.Materials or {}

local color_transparent = Color(0, 0, 0, 0)
local color_hover = Color(255, 255, 255, 5)
local color_100 = Color(100, 100, 100)
local color_250 = Color(250, 250, 250)

function CheadleUI.GetMaterial(mat)
    if CheadleUI.Materials[mat] then return CheadleUI.Materials[mat] end
    local newMat = Material(mat)
    CheadleUI.Materials[mat] = newMat
    return newMat
end

function CheadleUI.CreateFont(face, size)
    surface.CreateFont("CheadleUI_" .. face .. size, {
        font = face,
        extended = false,
        size = ScrH()*(size/1000),
        weight = 500,
        antialias = true,
    })
    CheadleUI.Fonts[size] = true
end

function CheadleUI.GetFont(face, size)
    if not CheadleUI.Fonts[size] then
        CheadleUI.CreateFont(face, size)
    end
    return "CheadleUI_" .. face .. size
end

function CheadleUI.SetX(panel, percent, align)
    local parent = panel:GetParent()
    local _, oldY = panel:GetPos()
    local offset = 0
    if align == TEXT_ALIGN_CENTER then offset = panel:GetWide()/2 end
    if align == TEXT_ALIGN_RIGHT then offset = panel:GetWide() end
    panel:SetPos(parent:GetWide() * (percent/100) - offset, oldY)
end

function CheadleUI.SetY(panel, percent, align)
    local parent = panel:GetParent()
    local oldX = panel:GetPos()
    local offset = 0
    if align == TEXT_ALIGN_CENTER then offset = panel:GetTall()/2 end
    if align == TEXT_ALIGN_BOTTOM then offset = panel:GetTall() end
    panel:SetPos(oldX, parent:GetTall() * (percent/100) - offset)
end

function CheadleUI.SetPos(panel, x, xAlign, y, yAlign)
    CheadleUI.SetX(panel, x, xAlign)
    CheadleUI.SetY(panel, y, yAlign)
end

function CheadleUI.SetW(panel, percent)
    local parent = panel:GetParent()
    local _, oldH = panel:GetSize()
    panel:SetSize(parent:GetWide() * (percent/100), oldH)
end

function CheadleUI.SetH(panel, percent)
    local parent = panel:GetParent()
    local oldW = panel:GetSize()
    panel:SetSize(oldW, parent:GetTall() * (percent/100))
end

function CheadleUI.SetSize(panel, percentW, percentH)
    CheadleUI.SetW(panel, percentW)
    CheadleUI.SetH(panel, percentH)
end

function CheadleUI.CenterW(panel)
    CheadleUI.SetX(panel, 50, TEXT_ALIGN_CENTER)
end

local mat_blur = CheadleUI.GetMaterial("pp/blurscreen")
function CheadleUI.Frame(w, h, title, font, color, color_top, closeBtn, blur)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(w, h)
    frame:Center()
    //frame:MakePopup()
    gui.EnableScreenClicker(true)
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)

    surface.SetFont(font)
    local titleW, titleH = surface.GetTextSize(title)

    local start = SysTime()
    frame.Paint = function(s, w1, h1)
        if blur then
            local x, y = s:LocalToScreen(0, 0)
            surface.SetMaterial(mat_blur)
            surface.SetDrawColor(255, 255, 255)
            for i=0.33, 1, 0.33 do
                mat_blur:SetFloat("$blur", 10 * i) -- Increase number 5 for more blur
                mat_blur:Recompute()
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
            end
        end
        draw.RoundedBox(4, 0, 0, w1, h1, color)
        if color_top then
            draw.RoundedBox(4, 0, 0, w1, titleH, color_top)
        end
    end

    local title = CheadleUI.Label(frame, title, font, color_white)
    CheadleUI.CenterW(title)
    //CheadleUI.SetY(title, titleH/2, TEXT_ALIGN_CENTER)
    title:SetY(titleH/2-title:GetTall()/2)

    if closeBtn then
        local closeButton = CheadleUI.Button(frame, "✕", CheadleUI.GetFont("Montserrat", 20), color_transparent)
        CheadleUI.SetX(closeButton, 99, TEXT_ALIGN_RIGHT)
        //CheadleUI.SetY(closeButton, 3.5, TEXT_ALIGN_CENTER)
        closeButton:SetY(titleH/2-closeButton:GetTall()/2)

        closeButton.DoClick = function()
            frame:Remove()
            gui.EnableScreenClicker(false)
        end
    end
    return frame
end

function CheadleUI.Panel(parent, color)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, color)
    end
    return panel
end

function CheadleUI.Label(parent, text, font, color)
    local label = vgui.Create("DLabel", parent)
    label:SetText(text)
    label:SetColor(color)
    label:SetFont(font)
    label:SizeToContents()
    return label
end

function CheadleUI.Button(parent, text, font, color, textColor)
    local button = vgui.Create("DButton", parent)
    button:SetText(text)
    button:SetFont(font)
    button:SetTextColor(textColor or color_white)
    button:SizeToContents()
    button.hover = 0
    button.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, color)
    end
    return button
end

function CheadleUI.HoverEffect(panel, color)
    panel.Hover = panel.Hover or 0

    local doHover = function(s, w, h)
        local frames = 1/FrameTime()
        local max = w-6
        if panel:IsHovered() then
            panel.Hover = math.Approach(panel.Hover, max, 1000/frames)
        else
            panel.Hover = math.Approach(panel.Hover, 0, 1000/frames)
        end
        if panel.selected then panel.Hover = max end
    end
    
    if not color then
        panel.PaintOver = function(s, w, h)
            local max = w-6
            doHover(s, w, h)
            draw.RoundedBox(0, 3, h*.94-1, max, h*.06, color_100)
            draw.RoundedBox(0, 3, h*.94-1, panel.Hover, h*.06, color_250)

            if panel.selected and not color then
                draw.RoundedBox(0, 0, 0, w, h, color_hover)
            end
        end
    else
        panel.Paint = function(s, w, h)
            doHover(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(color.r, color.g, color.b, s.Hover))
            if panel.selected then
                draw.RoundedBox(4, 0, 0, w, h, color)
            end
        end
    end
end
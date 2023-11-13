local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi
local gc = require("gears.color")
local helpers = require("helpers")

local Button = {}
local Private = {}

Private.draw_template = function (cr, w, h, clicked, args)
    w = math.floor(w)
    h = math.floor(h)
    -- radius - dist as radius (basically to have expected outcomes when knowing height of widget)
    local rad = args.border_radius and args.border_radius - dpi(3) or dpi(3)
    local lw_1 = clicked and dpi(3) or dpi(2)
    local lw_2 = clicked and dpi(2) or dpi(3)
    local dist = dpi(2)
    local rad_offset = dist+rad
    cr:set_source_rgba(gc.parse_color(beautiful.fg_normal))
    cr:new_sub_path()

    cr:set_line_width(lw_1)
    cr:move_to(rad_offset, h-dist)
    cr:arc(rad_offset, h-rad_offset, rad, math.rad(90), math.rad(180))
    cr:line_to(dist, dist+rad)
    cr:arc(rad_offset, rad_offset, rad, math.rad(180), math.rad(270))
    cr:line_to(w-rad-dist, dist)
    local part_path = cr:copy_path()
    cr:stroke()

    cr:set_line_width(lw_2)
    -- create new subpath
    cr:new_sub_path()
    cr:arc(w-rad_offset, rad_offset, rad, math.rad(270), math.rad(0))
    cr:line_to(w-dist, h-rad_offset)
    cr:arc(w-rad_offset, h-rad_offset, rad, math.rad(0), math.rad(90))
    cr:line_to(rad_offset, h-dist)
    cr:stroke_preserve()

    -- append path from above to be able to fill the inside area properly
    cr:append_path(part_path)
    cr:set_source_rgba(gc.parse_color(clicked and beautiful.bg_1 or beautiful.bg_normal))
    cr:fill()

end

Private.draw_release = function(_, cr, w, h, args)
    Private.draw_template(cr, w, h, false, args or {})
end

Private.draw_click = function(_, cr, w, h, args)
    Private.draw_template(cr, w, h, true, args or {})
end

Private.is_in = function(tbl, elem)
    for _, v in ipairs(tbl) do
        if v == elem then
            return true
        end
    end
    return false
end

-- wont connect to the buttons press and release signals
-- the manual draw functions draw_clicked and draw_released are also available here
Button.buttonify = function (args)
    local bg = args.widget or error("no widget supplied")
    local buttons = args.buttons or {}
    local manual = args.manual

    function bg:draw_clicked()
        bg.bgimage = Private.draw_click
    end

    function bg:draw_released()
        bg.bgimage = Private.draw_release
    end

    if #buttons > 0 then
        bg:connect_signal("button::press", function (_, _, _, b)
            if not manual and Private.is_in(buttons, b) then
                bg:draw_clicked()
            end
        end)

        bg:connect_signal("button::release", function (_, _, _, b)
            if not manual and Private.is_in(buttons, b) then
                bg:draw_released()
            end
        end)
    end

    helpers.pointer_on_focus(bg)
    bg.bgimage = Button.draw_release
end

---@class ButtonArgsClickArgs
---@field on_click function The function called on click
---@field on_release function The function called on release
---@param args {manual_draw: boolean, widget: any, margins: integer, border_radius: integer, left: ButtonArgsClickArgs, right: ButtonArgsClickArgs} Arguments
---create a simple button wrapper for given widget
Button.new = function(args)
    if not args.widget then
        error("need inside widget for button")
    end

    ---@class Button
    ---@field private bgimage any wibox.widget
    ---@field private add_button function wibox.widget
    ---@field private border_width integer wibox.widget
    ---@field private _buttonargs table private data
    ---@field toggle_state boolean State wether button is drawn as clicked or released
    local button = wibox.widget {
        widget = wibox.container.background,
        border_color = beautiful.bg_1,
        {
            widget = wibox.container.margin,
            margins = args.margins or dpi(5),
            args.widget
        }
    }

    button._buttonargs = args
    ---@diagnostic disable-next-line: cast-local-type
    args = nil  -- gc pls!

    local function released_with_args (ctx, cr, w, h)
        Private.draw_release(ctx, cr, w, h, button._buttonargs)
    end
    -- set initial state
    button.bgimage = released_with_args

    local function clicked_with_args (ctx, cr, w, h)
        Private.draw_click(ctx, cr, w, h, button._buttonargs)
    end

    -- highlight the button
    function button:highlight()
        self.border_width = dpi(2)
    end

    -- remove button highlight
    function button:unhighlight()
        self.border_width = 0
    end

    -- explicitly draw button as clicked
    function button:draw_clicked()
        self.toggle_state = true
        self.bgimage = clicked_with_args
    end

    -- explicitly draw button as not clicked
    function button:draw_released()
        self.toggle_state = false
        self.bgimage = released_with_args
    end

    -- toggle button draw state
    function button:toggle()
        if self.toggle_state then
            self:draw_released()
        else
            self:draw_clicked()
        end
    end

    -- cycle through buttons
    for _, btn in ipairs({"left", "right"}) do
        if button._buttonargs[btn] then
            local bargs = button._buttonargs[btn]
            bargs.on_click = bargs.on_click or function () end
            bargs.on_release = bargs.on_release or function () end
            button:add_button(
                awful.button {
                    mod = {"Any"},
                    button = awful.button.names[string.upper(btn)],
                    on_press = button._buttonargs.manual_draw and
                        bargs.on_click or function ()
                            button:draw_clicked()
                            bargs.on_click()
                        end,
                    on_release = button._buttonargs.manual_draw and
                        bargs.on_release or function()
                            button:draw_released()
                            bargs.on_release()
                        end
                }
            )
        end
    end

    helpers.pointer_on_focus(button)
    return button
end

return setmetatable(Button, {
    __call = function (_, ...)
        return  Button.new(...)
    end
})

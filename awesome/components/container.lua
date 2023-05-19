local wibox = require "wibox"
local beautiful = require "beautiful"
local shape = require "gears.shape"
local awful = require "awful"
local Cairo = require "lgi".cairo
local gcol = require "gears.color"
local dpi = beautiful.xresources.apply_dpi
local helpers = require "helpers"

local container = {}


local button_draw_template = function (cr, w, h, fill, tl, br)
    w = math.floor(w)
    h = math.floor(h)
    cr:set_source_rgba(gcol.parse_color(fill))
    cr:rectangle(0,0,w,h)
    cr:fill()
    cr:set_line_width(dpi(2))
    cr:set_source_rgba(gcol.parse_color(tl))
    cr:move_to(w-dpi(1),dpi(1))
    cr:line_to(w-dpi(1),h-dpi(1))
    cr:line_to(dpi(1),h-dpi(1))
    cr:stroke()
    cr:set_source_rgba(gcol.parse_color(br))
    cr:move_to(dpi(1),h-dpi(1))
    cr:line_to(dpi(1),dpi(1))
    cr:line_to(w-dpi(1),dpi(1))
    cr:stroke()

end

local button_draw_release = function(_, cr, w, h)
    button_draw_template(cr, w, h, beautiful.bg_normal, beautiful.bg_dark_edge, beautiful.bg_light_edge)
end

local button_draw_click = function(_, cr, w, h)
    button_draw_template(cr, w, h, beautiful.bg_normal, beautiful.bg_light_edge, beautiful.bg_dark_edge)
end


---create a simple button wrapper for given widget
---@class args table
---@field args.widget wibox_widget
---@field args.manual_draw boolean
---@field args.bg string
---@field args.right.on_click function
---@field args.right.on_release function
---@field args.left.on_click function
---@field args.left.on_release function
---@class button
---@field button.toggle function(self)
---@return button
container.button = function(args)
    local widget = args.widget
    local button = wibox.widget {
        widget = wibox.container.background,
        border_color = beautiful.bg_focus_dark,
        bgimage = button_draw_release,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            widget
        }
    }

    args.right = args.right or {}
    
    if args.left and type(args.left) == "table" then
        args.left.on_click = args.left.on_click or function () end
        args.left.on_release = args.left.on_release or function () end
        button:add_button(
            awful.button {
                mod = {"Any"},
                button = awful.button.names.LEFT,
                on_press = args.manual_draw and
                    args.left.on_click or function ()
                        button.bgimage = button_draw_click
                        args.left.on_click()
                    end,
                on_release = args.manual_draw and
                    args.left.on_release or function()
                        button.bgimage = button_draw_release
                        args.left.on_release()
                    end
            }
        )
    end
    
    function button:highlight()
        self.border_width = dpi(2)
    end
    function button:unhighlight()
        self.border_width = 0
    end
    function button:toggle()
        self.bgimage = self.toggle_state and button_draw_release or button_draw_click
        self.toggle_state = not self.toggle_state
    end
    function button:draw_clicked()
        self.toggle_state = true
        self.bgimage = button_draw_click
    end
    function button:draw_released()
        self.toggle_state = false
        self.bgimage = button_draw_release
    end

    helpers.pointer_on_focus(button)

    return button
end

return container

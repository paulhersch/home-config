local wibox = require "wibox"
local beautiful = require "beautiful"
--local shape = require "gears.shape"
local awful = require "awful"
--local Cairo = require "lgi".cairo
local gcol = require "gears.color"
local gt = require "gears.table"
local dpi = beautiful.xresources.apply_dpi
local helpers = require "helpers"

local container = {}

local function is_in(table, elem)
    for _, v in ipairs(table) do
        if v == elem then
            return true
        end
    end
    return false
end

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

---@param bg any background container widget (has to be background container!!)
---@param buttons table buttons that should be considered clicks. If none supplied this function
-- wont connect to the buttons press and release signals
-- the manual draw functions draw_clicked and draw_released are also available here
container.buttonify = function (bg, buttons)
    function bg:draw_clicked()
        bg.bgimage = button_draw_click
    end

    function bg:draw_released()
        bg.bgimage = button_draw_release
    end

    if #buttons > 0 then
        bg:connect_signal("button::press", function (_, _, _, b)
            if is_in(buttons, b) then
                bg:draw_clicked()
            end
        end)

        bg:connect_signal("button::release", function ()
            bg:draw_released()
        end)
    end

    helpers.pointer_on_focus(bg)
    bg.bgimage = button_draw_release
end

---create a simple button wrapper for given widget
container.button = function(args)
    local widget = args.widget
    ---@class Button
    ---@field private bgimage any wibox.widget
    ---@field private add_button function wibox.widget
    ---@field private border_width integer wibox.widget
    ---@field private _buttonargs table private data
    ---@field toggle_state boolean State wether button is drawn as clicked or released
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
    button._buttonargs = args

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
                    on_press = args.manual_draw and
                        bargs.on_click or function ()
                            button.bgimage = button_draw_click
                            bargs.on_click()
                        end,
                    on_release = args.manual_draw and
                        bargs.on_release or function()
                            button.bgimage = button_draw_release
                            bargs.on_release()
                        end
                }
            )
        end
    end

    -- highlight the button
    function button:highlight()
        self.border_width = dpi(2)
    end

    -- remove button highlight
    function button:unhighlight()
        self.border_width = 0
    end

    -- toggle button draw state
    function button:toggle()
        self.bgimage = self.toggle_state and button_draw_release or button_draw_click
        self.toggle_state = not self.toggle_state
    end

    -- explicitly draw button as clicked
    function button:draw_clicked()
        self.toggle_state = true
        self.bgimage = button_draw_click
    end

    -- explicitly draw button as not clicked
    function button:draw_released()
        self.toggle_state = false
        self.bgimage = button_draw_release
    end

    helpers.pointer_on_focus(button)

    return button
end

return container

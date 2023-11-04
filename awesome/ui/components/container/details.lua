local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

local Private = {}
local Details = {}

Private.shape = function (cr, w, h)
    return gears.shape.rounded_rect(cr, w, h, dpi(9))
end

Private.materialicons = gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

-- Args:
-- {
--   widget = nil,
--   open = false,
--   deletable = false,
--   delete_callback = function() end,
--   title = "",
--   bg = beautiful.bg_normal
-- }
--
--The returned container will also have the functions collapse and expand
--with the instance as the first function argument
Details.new = function (args)
    local _args = {
        widget = nil,
        open = false,
        deletable = false,
        delete_callback = function () end,
        title = "",
        bg = beautiful.bg_normal,
    }

    gears.table.crush(_args, args)

    local DetailsWidget = wibox.widget {
        widget = wibox.container.background,
        border_width = dpi(1),
        bg = _args.bg,
        shape = Private.shape,
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            {
                id = "details_layout",
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(6),
                {
                    layout = wibox.layout.align.horizontal,
                    spacing = dpi(7),
                    {
                        id = "expandbutton",
                        widget = wibox.widget.imagebox,
                        image = Private.materialicons .. "expand_more.svg",
                        forced_height = beautiful.get_font_height(beautiful.font)
                    },
                    {
                        id = "titletext",
                        widget = wibox.widget.textbox,
                        text = _args.title,
                        font = beautiful.font
                    },
                    {
                        id = "deletebutton",
                        widget = wibox.widget.imagebox,
                        image = Private.materialicons .. "clear_all.svg",
                        forced_height = beautiful.get_font_height(beautiful.font)
                    },
                },
            }
        }
    }

    DetailsWidget._det_args = _args
    _args = nil --gc doesnt fully pick this up otherwise for some reason
    DetailsWidget._det_args.expander = setmetatable({}, {__index = DetailsWidget:get_children_by_id('expandbutton')[1]})
    DetailsWidget._det_args.deleter = setmetatable({}, {__index = DetailsWidget:get_children_by_id('deletebutton')[1]})

    ---
    -- Object functions
    ---

    function DetailsWidget:set_children(children)
        self._det_args.widget = children
    end

    function DetailsWidget:get_children()
        return { self._det_args.widget }
    end

    function DetailsWidget:set_title(title)
        DetailsWidget:get_children_by_id('titletext')[1].text = title
    end

    function DetailsWidget:get_title()
        return DetailsWidget:get_children_by_id('titletext')[1].text
    end

    function DetailsWidget:expand()
        if not self._det_args.widget then return end
        local layout = self:get_children_by_id('details_layout')[1]
        if #layout.children == 1 then
            layout:insert(2, self._det_args.widget)
            self._det_args.expander.image = Private.materialicons .. "expand_less.svg"
            DetailsWidget._det_args.open = true
        end
    end

    function DetailsWidget:collapse()
        local layout = self:get_children_by_id('details_layout')[1]
        if #layout.children == 2 then
            layout:remove(2)
            self._det_args.expander.image = Private.materialicons .. "expand_more.svg"
            DetailsWidget._det_args.open = false
        end
    end

    function DetailsWidget:toggle()
        if self._det_args.open then
            self:collapse()
        else
            self:expand()
        end
    end

    ---
    -- signal stuffs
    ---

    DetailsWidget._det_args.expander:add_button(awful.button {
        modifiers = {},
        button = awful.button.names.LEFT,
        on_press = function ()
            DetailsWidget:toggle()
        end
    })

    DetailsWidget._det_args.deleter:add_button(awful.button {
        modifiers = {},
        button = awful.button.names.LEFT,
        on_press = DetailsWidget._det_args.delete_callback
    })

    helpers.pointer_on_focus(DetailsWidget._det_args.expander)
    helpers.pointer_on_focus(DetailsWidget._det_args.deleter)

    ---
    -- set initial state
    ---
    if DetailsWidget._det_args.open then
        DetailsWidget:expand()
    end

    return DetailsWidget
end

return Details.new

local wibox = require "wibox"
local beautiful = require "beautiful"
local awful = require "awful"
local lgi = require "lgi"
local cairo = lgi.cairo
local pango = lgi.Pango
local pangoCairo = lgi.PangoCairo
local gears = require("gears")
local gc = gears.color
local gt = gears.table
local dpi = beautiful.xresources.apply_dpi
local helpers = require "helpers"
local math = math
local table = table
local unpack = unpack or table.unpack

materialicons = gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local Container = {}
-- "private" Fields for Container Widgets
local Button = {}
local Description = {}
local Details = {}

local function is_in(tbl, elem)
    for _, v in ipairs(tbl) do
        if v == elem then
            return true
        end
    end
    return false
end

Button.draw_template = function (cr, w, h, clicked, args)
    w = math.floor(w)
    h = math.floor(h)
    -- radius - dist as radius (basically to have expected outcomes when knowing height of widget)
    local rad = args.border_radius and args.border_radius - dpi(2) or dpi(2)
    local lw_1 = clicked and dpi(2) or dpi(1)
    local lw_2 = clicked and dpi(1) or dpi(2)
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

Button.draw_release = function(_, cr, w, h, args)
    Button.draw_template(cr, w, h, false, args or {})
end

Button.draw_click = function(_, cr, w, h, args)
    Button.draw_template(cr, w, h, true, args or {})
end

---@param bg any background container widget (has to be background container!!)
---@param buttons table buttons that should be considered clicks. If none supplied this function
-- wont connect to the buttons press and release signals
-- the manual draw functions draw_clicked and draw_released are also available here
Container.buttonify = function (bg, buttons)
    function bg:draw_clicked()
        bg.bgimage = Button.draw_click
    end

    function bg:draw_released()
        bg.bgimage = Button.draw_release
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
    bg.bgimage = Button.draw_release
end

---@class ButtonArgsClickArgs
---@field on_click function The function called on click
---@field on_release function The function called on release

---@param args {manual_draw: boolean, widget: any, margins: integer, border_radius: integer, left: ButtonArgsClickArgs, right: ButtonArgsClickArgs} Arguments
---create a simple button wrapper for given widget
Container.button = function(args)
    local widget = args.widget
    ---@class Button
    ---@field private bgimage any wibox.widget
    ---@field private add_button function wibox.widget
    ---@field private border_width integer wibox.widget
    ---@field private _buttonargs table private data
    ---@field toggle_state boolean State wether button is drawn as clicked or released
    local button = wibox.widget {
        widget = wibox.container.background,
        border_color = beautiful.bg_1,
        bgimage = function (ctx, cr, w, h)
            Button.draw_release(ctx, cr, w, h, args)
        end,
        {
            widget = wibox.container.margin,
            margins = args.margins or dpi(5),
            widget
        }
    }
    button._buttonargs = args

    local function released_with_args (ctx, cr, w, h)
        Button.draw_release(ctx, cr, w, h, button._buttonargs)
    end

    local function clicked_with_args (ctx, cr, w, h)
        Button.draw_click(ctx, cr, w, h, button._buttonargs)
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
                    on_press = args.manual_draw and
                        bargs.on_click or function ()
                            button:draw_clicked()
                            bargs.on_click()
                        end,
                    on_release = args.manual_draw and
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

Description.draw_border = function (_, cr, w, h, args)
    local gap_half = args.margin/2
    local line_width = args.border_width
    cr:set_line_width(line_width)
    local top = args.description and gap_half or line_width

    cr:move_to(gap_half, top)
    -- top right
    cr:line_to(w-gap_half-line_width, top)
    cr:arc(w-gap_half-line_width, top+gap_half, gap_half, math.rad(270), math.rad(0))
    -- bottom right
    cr:line_to(w-line_width, h-gap_half-line_width)
    cr:arc(w-gap_half-line_width, h-gap_half-line_width, gap_half, math.rad(0), math.rad(90))
    -- bottom left
    cr:line_to(gap_half+line_width, h-line_width)
    cr:arc(gap_half+line_width, h-gap_half-line_width, gap_half, math.rad(90), math.rad(180))
    -- top left
    cr:line_to(line_width, top+gap_half)
    cr:arc(gap_half+line_width, top+gap_half, gap_half, math.rad(180), math.rad(270))

    if args.border_width ~= 0 then
        cr:set_source_rgba(gc.parse_color(args.border_color))
        cr:set_line_width(dpi(2))
        cr:stroke_preserve()
        cr:set_line_width(dpi(1))
    end
    if args.bgimage then
        -- crop and scale image to fit target size
        -- using w and h although they are not the "real" size but you usually
        -- wont see much of the image anyways
        local img_surf = helpers.crop_surface(w/h, args.bgimage)
        local img_w, img_h = gears.surface.get_size(img_surf)
        -- create temp surface to scale to desired output size
        local target_surf = cairo.ImageSurface(cairo.Format.ARGB32, w, h)
        local target_surf_cr = cairo.Context(target_surf)
        target_surf_cr:scale(w/img_w, h/img_h)
        target_surf_cr:set_source_surface(img_surf)
        target_surf_cr:paint()
        -- actually paint bg image
        cr:set_source_surface(target_surf)
        cr:clip()
        cr:paint()
        cr:reset_clip()
    else
        cr:set_source_rgba(gc.parse_color(args.bg))
        cr:fill()
    end


    -- add text
    if args.description then
        -- parse text, if it can be parsed pango will render
        local attr, parsed = pango.parse_markup(args.description, -1, 0)
        if not attr then
            gears.debug.print_error(debug.traceback("Error parsing markup " .. parsed .. " for " .. args.description))
            return
        end

        local pango_ctx = pangoCairo.font_map_get_default():create_context()
        local pangoLayout = pango.Layout.new(pango_ctx)

        local fontDesc = beautiful.get_font(args.font)
        fontDesc:set_absolute_size(math.floor(args.margin*(5/6)) * pango.SCALE)
        pangoLayout:set_font_description(fontDesc)

        pangoLayout.text = parsed
        pangoLayout.attributes = attr

        local _, extents = pangoLayout:get_pixel_extents()
        local width = extents.width

        -- clear space around text
        local margin_double = args.margin
        local right_anchor = margin_double+gap_half+width
        local left_anchor = margin_double+gap_half
        cr:move_to(right_anchor, 1)
        cr:arc(right_anchor, gap_half, gap_half-1, math.rad(270), math.rad(90))
        cr:line_to(left_anchor, args.margin-1)
        cr:arc(left_anchor, gap_half, gap_half-1, math.rad(90), math.rad(270))
        cr:line_to(right_anchor, 1)

        if args.border_width ~= 0 then
            cr:set_source_rgba(gc.parse_color(args.border_color))
            cr:stroke_preserve()
        end
        cr:set_source_rgba(gc.parse_color(args.text_bg))
        cr:fill()

        -- set text
        cr:set_source_rgba(gc.parse_color(args.text_fg))
        cr:move_to(left_anchor, -dpi(1))
        cr:show_layout(pangoLayout)
    end
end

-- defaults
-- args = {
--     widget = nil,
--     description = nil,
--     margin = dpi(18),
--     font = beautiful.font,
--     fg = beautiful.fg_normal,
--     bg = beautiful.bg_normal,
--     bgimage = nil,
--     text_bg = beautiful.bg_normal,
--     text_fg = beautiful.fg_normal,
--     border_color = beautiful.fg_normal,
--     border_width = dpi(1),
--     group_buttons = {}
-- }
-- group_buttons should be a table of widgets that are already buttons
-- bgimage has to be a cairo imagesurface and can be overwritten with another surface
-- description and group_buttons are optional, if not supplied the top margin will be smaller
---@return wibox.widget
Container.description = function (args)
    local _args = {
        widget = nil,
        description = nil,
        margin = dpi(18),
        font = beautiful.font,
        fg = beautiful.fg_normal,
        bg = beautiful.bg_1,
        text_bg = beautiful.bg_normal,
        text_fg = beautiful.fg_normal,
        border_color = beautiful.fg_normal,
        border_width = dpi(1),
        group_buttons = {}
    }

    gt.crush(_args, args)

    _args.reserve_top_space = (#_args.group_buttons > 0 or args.description)
    local DescriptionWidget = wibox.widget {
        widget = wibox.container.background,
        bgimage = function (surf, cr, w, h)
            Description.draw_border(surf, cr, w, h, _args)
        end,
        {
            id = "outside_margins",
            widget = wibox.container.margin,
            margins = {
                left = _args.margin/2,
                bottom = _args.margin/2,
                right = _args.margin/2,
                -- "reverse" logic, spacing has to be missing if no top render of buttons is needed
                top = _args.reserve_top_space and 0 or _args.margin/2
            },
            _args.reserve_top_space and {
                id = "buttons_and_widget",
                layout = wibox.layout.fixed.vertical,
                spacing = _args.margin/2,
                {
                    widget = wibox.container.place,
                    fill_horizontal = true,
                    halign = "right",
                    {
                        widget = wibox.container.margin,
                        right = _args.margin,
                        {
                            id = "buttons_layout",
                            layout = wibox.layout.fixed.horizontal,
                            spacing = _args.margin,
                            forced_height = _args.margin,
                            unpack(_args.group_buttons)
                        }
                    }
                },
                _args.widget
            } or _args.widget
        }
    }

    -- override set_bgimage so that bgimage function wont be reset
    function DescriptionWidget:set_bgimage (image)
        _args.bgimage = image
        self:emit_signal("widget::redraw_needed")
        self:emit_signal("property::bgimage", image)
        collectgarbage("collect")
    end

    -- same here
    function DescriptionWidget:set_bg (color)
        _args.bg = color
        self:emit_signal("widget::redraw_needed")
        self:emit_signal("property::bg", color)
    end

    -- override set_children
    -- only uses the first table element, but still uses a table to be compatible with
    -- awm widget system
    function DescriptionWidget:set_children(tbl)
        if _args.reserve_top_space then
            local layout = self:get_children_by_id("buttons_and_widget")[1]
            layout:set(2, tbl[1])
        else
            self.outside_margin:set_children(tbl)
        end
    end

    function DescriptionWidget:add_button(btn_widget)
        if _args.reserve_top_space then
            local layout = self:get_children_by_id("buttons_layout")[1]
            layout:add(btn_widget)
        end
    end

    return DescriptionWidget
end

Details.shape = function (cr, w, h)
    return gears.shape.rounded_rect(cr, w, h, dpi(9))
end

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
Container.details = function (args)
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
        shape = Details.shape,
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
                        image = materialicons .. "expand_more.svg",
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
                        image = materialicons .. "clear_all.svg",
                        forced_height = beautiful.get_font_height(beautiful.font)
                    },
                },
            }
        }
    }

    DetailsWidget._det_args = _args
    DetailsWidget._det_args.expander = DetailsWidget:get_children_by_id('expandbutton')[1]
    DetailsWidget._det_args.deleter = DetailsWidget:get_children_by_id('deletebutton')[1]

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
            self._det_args.expander.image = materialicons .. "expand_less.svg"
            DetailsWidget._det_args.open = true
        end
    end

    function DetailsWidget:collapse()
        local layout = self:get_children_by_id('details_layout')[1]
        if #layout.children == 2 then
            layout:remove(2)
            self._det_args.expander.image = materialicons .. "expand_more.svg"
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

    print(DetailsWidget.title)

    return DetailsWidget
end

return Container

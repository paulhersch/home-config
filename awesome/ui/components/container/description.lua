local wibox = require "wibox"
local beautiful = require "beautiful"
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

local Private = {}
local Description = {}

Private.draw_border = function (_, cr, w, h, args)
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
        local img_surf = gears.surface.crop_surface{
            ratio = w/h,
            surface = args.bgimage
        }
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
            gears.debug.print_error(debug.traceback("Error parsing markup for " .. args.description))
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
Description.new = function (args)
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
            Private.draw_border(surf, cr, w, h, _args)
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

    function DescriptionWidget:add_button_widget(btn_widget)
        if _args.reserve_top_space then
            local layout = self:get_children_by_id("buttons_layout")[1]
            layout:add(btn_widget)
        end
    end

    return DescriptionWidget
end

return Description.new

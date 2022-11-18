---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi
local beautiful = require ("beautiful")
local gears = require("gears")
local cairo = require("lgi").cairo

local col_shift = require("helpers").color.col_shift
local col_mix = require("helpers").color.col_mix

local themes_path = gears.filesystem.get_themes_dir()
local homedir = os.getenv("HOME")

local theme = {}

theme.wallpaper = homedir .. "/Bilder/Hintergrundbilder/dark-water.jpg"

theme.font          = "Inter Medium"
theme.font_thin     = "Inter Regular"
theme.font_bold     = "Inter Bold"

local xres = xresources.get_current_theme()

local function is_dark(hexCol)
    local re,gr,bl,op = gears.color.parse_color(hexCol)
    return (re+gr+bl)/3 <= 0.5
end

local dark_theme = is_dark(xres.background)

theme.red           = xres.color1
theme.green         = xres.color2
theme.yellow        = xres.color3
theme.blue          = xres.color4
theme.magenta       = xres.color5
theme.cyan          = xres.color6
theme.gray          = xres.color7

theme.bg_normal     = xres.background
theme.bg_focus_dark = dark_theme
            and col_shift(theme.bg_normal, 8)
            or col_shift (theme.bg_normal, -8)
theme.bg_focus      = dark_theme
            and col_shift(theme.bg_normal, 16)
            or col_shift(theme.bg_normal, -16)
theme.bg_urgent     = xres.color1
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = xres.foreground
theme.fg_focus      = dark_theme
            and col_shift(theme.fg_normal, 20)
            or col_shift(theme.fg_normal, -20)
theme.fg_urgent     = theme.fg_normal
theme.fg_minimize   = theme.fg_normal
theme.fg_dark       = dark_theme
            and col_shift(theme.fg_normal, -20)
            or col_shift(theme.fg_normal, 20)

theme.useless_gap = dpi(5)

theme.systray_icon_spacing = dpi(8)

theme.border_width        = 0
theme.border_color_urgent = theme.bg_urgent
theme.border_color_normal = theme.bg_normal
theme.border_color_new = theme.border_color_normal
theme.border_color_active = theme.bg_focus
theme.border_focus = theme.border_color_active
theme.border_color_marked = theme.bg_normal

theme.tooltip_bg        = theme.bg_normal
theme.tooltip_fg        = theme.fg_normal

theme.layoutlist_bg_selected = theme.bg_focus
theme.layoutlist_shape_selected = theme.theme_shape

theme.menubar_bg_normal = theme.bg_normal
theme.menubar_bg_focus = theme.bg_focus
theme.menubar_fg_normal = theme.fg_normal
theme.menubar_fg_focus = theme.fg_focus

theme.menu_font = theme.font .. " 11"
theme.menu_height = beautiful.get_font_height(theme.menu_font) + dpi(2)
theme.menu_border_color = theme.bg_normal
theme.menu_border_width = dpi(5)
theme.menu_fg_focus = theme.fg_focus
theme.menu_bg_focus = theme.bg_focus
theme.menu_fg_normal = theme.fg_normal
theme.menu_bg_normal = theme.bg_normal
theme.menu_submenu_icon = function ()
    local icon = cairo.ImageSurface.create(cairo.Format.ARGB32,theme.menu_height/3,theme.menu_height/3)
    local cr = cairo.Context(icon)
    cr:set_source(gears.color(beautiful.fg_normal))
    cr:move_to(0,0)
    cr:line_to(0,theme.menu_height/3)
    cr:line_to(theme.menu_height/3,theme.menu_height/6)
    cr:line_to(0,0)
    cr:close_path()
    cr:fill()
    return icon
end

theme.master_width_factor = 0.65

theme.menu_item_spacing = dpi(5)

theme.theme_shape = function (c, w, h)
	return gears.shape.rounded_rect(c, w, h, 5)
end
theme.notification_shape = theme.shape

theme.tabbed_spawn_in_tab = true  -- whether a new client should spawn into the focused tabbing container

-- some length parameters
theme.wibar_height  = dpi(40)
theme.titlebar_height = dpi(30)

-- You can use your own layout icons like this:
theme.layout_floating  = themes_path.."sky/layouts/floating.png"
theme.layout_tile = themes_path.."sky/layouts/tile.png"
theme.layout_spiral  = themes_path.."sky/layouts/spiral.png"
theme.layout_cornernw = themes_path.."sky/layouts/cornernw.png"

theme = beautiful.theme_assets.recolor_layout(theme, theme.fg_normal)
-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    dpi(50), theme.bg_normal, theme.fg_normal
)

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = col_mix(theme.red,theme.bg_normal), fg = theme.fg_normal }
    }
    rnotification.append_rule {
        rule       = { urgency = 'normal' },
        properties = { bg = theme.bg_focus, fg = theme.fg_normal }
    }
end)

return theme

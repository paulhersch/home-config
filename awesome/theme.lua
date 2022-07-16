---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi
local beautiful = require ("beautiful")
local g = require("gears")
local naughty   = require ("naughty")
local col_shift = require("helpers").color.col_shift

local themes_path = g.filesystem.get_themes_dir()
local homedir = os.getenv("HOME")

local theme = {}

theme.wallpaper = homedir .. "/Bilder/Hintergrundbilder/leaves.jpg"

theme.font          = "Inter Medium"
theme.font_thin     = "Inter Regular"
theme.font_bold     = "Inter Bold"
theme.icon_font     = "Fira Code Nerd Font Mono"

local xres = xresources.get_current_theme()

local function is_dark(hexCol)
    local re,gr,bl,op = g.color.parse_color(hexCol)
    return (re+gr+bl)/3 <= 0.5
end

local dark_theme = is_dark(xres.background)

theme.red           = xres.color1
theme.green         = xres.color2
theme.yellow        = xres.color3
theme.blue          = xres.color4
theme.magenta       = xres.color5
theme.cyan          = xres.color6
theme.dark_red      = xres.color7
theme.dark_green    = xres.color8
theme.dark_yellow   = xres.color9
theme.dark_blue     = xres.color10
theme.dark_magenta  = xres.color11
theme.dark_cyan     = xres.color12

theme.bg_normal     = xres.background
theme.bg_focus      = dark_theme
            and col_shift(theme.bg_normal, 20)
            or col_shift(theme.bg_normal, -20)
theme.bg_urgent     = xres.color1
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = xres.foreground
theme.fg_focus      = dark_theme
            and col_shift(theme.fg_normal,20)
            or col_shift(theme.fg_normal, -20)
theme.fg_urgent     = theme.fg_normal
theme.fg_minimize   = theme.fg_normal

--theme.bg_systray    = theme.bg_normal
theme.systray_icon_spacing = theme.useless_gap

theme.border_width        = dpi(3)
theme.border_color_urgent = theme.bg_urgent
theme.border_color_normal = theme.bg_normal
theme.border_color_new = theme.border_color_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = theme.bg_normal

theme.tooltip_bg        = theme.bg_normal
theme.tooltip_fg        = theme.fg_normal

theme.useless_gap = dpi(5)

theme.rounded_rect = function(cr,w,h)
    return g.shape.rounded_rect(cr,w,h,5)
end
theme.theme_shape = theme.rounded_rect

-- some length parameters
theme.wibar_height  = dpi(30)
theme.bar_date_width= dpi(230)

-- these variables control the popup menu from the bar
theme.menu_item_spacing = theme.wibar_height/5
theme.menu_widget_base_unit  = dpi(50)

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."zenburn/layouts/fairh.png"
theme.layout_floating  = themes_path.."zenburn/layouts/floating.png"
theme.layout_tile = themes_path.."zenburn/layouts/tile.png"
theme.layout_tiletop = themes_path.."zenburn/layouts/tiletop.png"
theme.layout_spiral  = themes_path.."zenburn/layouts/spiral.png"
theme.layout_cornernw = themes_path.."zenburn/layouts/cornernw.png"

theme.layoutlist_bg_selected = theme.bg_normal
theme.layoutlist_shape_selected = theme.theme_shape

theme = beautiful.theme_assets.recolor_layout(theme, theme.fg_normal)
-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_widget_base_unit*2, theme.bg_normal, theme.fg_normal
)

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#ff0000', fg = '#ffffff' }
    }
end)

return theme

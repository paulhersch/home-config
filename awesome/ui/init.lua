require "ui.wallpaper"
require "ui.bar"
require "ui.notifications".init()
--require "ui.titlebar"

local beautiful = require "beautiful"
local dock = require "ui.dock"
local dpi = beautiful.xresources.apply_dpi

screen.connect_signal("request::desktop_decoration", function(s)
	dock.init({
		screen	= s,
		height	= dpi(60),
		shapes	= {
            dock = beautiful.theme_shape,
            status = beautiful.theme_shape,
            bg = beautiful.theme_shape
        },
        sizings = {
            margins = {
                status = {
                    bottom = dpi(4)
                },
                outer = dpi(3)
            }
        },
		pinned_apps = {
			{
				start_cmd	= "librewolf -P YouTube --class youtube youtube.com",
				class		= "youtube",
				icon		= os.getenv("HOME") .. "/.local/share/applications/youtube.png"
			}
		},
        colors = {
            status = {
                focus = beautiful.blue,
                normal = beautiful.fg_normal
            },
            bg = {
                normal = beautiful.bg_normal,
                focus = beautiful.bg_focus,
                hover = beautiful.bg_focus_dark,
            },
            dock = {
                bg = beautiful.bg_normal .. "60"
            }
        },
        animations = {
            transitions = {
                enabled = true
            },
            autohide = {
                enabled = true
            },
            rubato = require "plugins.rubato"
        }
	})
end)

local bar	= require "ui.bar.bar"
local dock	= require "ui.bar.dock"
--local sidebar   = require "bar.sidebar"

local gears	= require "gears"
local beautiful	= require "beautiful"
local dpi	= beautiful.xresources.apply_dpi
local awful	= require "awful"

screen.connect_signal("request::desktop_decoration", function(s)
	bar.init(s)
--	sidebar.init(s)
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


-- NOTE on the hide/show stuff in here: doesnt 100% work if one uses the weird functionality
-- where two tags are displayed on one screen and on both tags hold fullscreened clients.
-- If you were to use it like that, however, you probably have some severe problems and need to visit a psychiatry or smth

client.connect_signal("property::fullscreen", function(c)
	local s	= c.screen
	if c.fullscreen
		then
			bar.hide(s) --the bar thing itself hides the correct bar
		else
			bar.show(s)
	end
end)

client.connect_signal("request::manage", function(c)
	if c.fullscreen then bar.hide(c.screen) end
end)

client.connect_signal("request::unmanage", function(c)
	if c.fullscreen then bar.show(c.screen) end
end)

screen.connect_signal("tag::history::update", function() --some signal for tag switching would come in handy, but this also works
	local s = awful.screen.focused()
	local tags = s.selected_tags
	local hide = false

	if tags then for _,t in ipairs(tags) do --go through selected tags
			local clients = t:clients()
			if #clients > 0 then for _,c in ipairs(clients) do --ignore case where c is the only present client
					if c.fullscreen then --if one client is fullscreened the bar needs to be hidden
						hide = true
					end
				end
			end
		end
	end
	if hide then bar.hide(s) else bar.show(s) end
end)

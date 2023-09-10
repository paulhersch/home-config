local ruled = require("ruled")
local dpi = require("beautiful").xresources.apply_dpi
local awful = require("awful")

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
		rule = {},
		except_any = { type = { "normal", "dialog" } },
		properties = { floating = true, placement = awful.placement.centered }
	}
	ruled.client.append_rule {
		rule_any = {
			class = { "Thunar", "Pcmanfm", "Galculator", "Nemo" }
		},
		properties = {
			floating= true,
			width	= dpi(650),
			height	= dpi(480)
		},
	}
end)


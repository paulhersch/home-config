local bar = require "ui.bar.bar"

local function current_tags_have_fullscreen(screen)
    local tags = screen.selected_tags
    if tags then
        for _, t in ipairs(tags) do
            local clients = t:clients()
            if #clients > 0 then
                for _, c in ipairs(clients) do
                    if c.fullscreen then
                        return not c.hidden
                    end
                end
            end
        end
    end
    return false
end

screen.connect_signal("request::desktop_decoration", function(s)
    bar.init(s)
    s:connect_signal("tag::history::update",
        function() --there are also signals for tag::property::selected or smth but i feel like this would be more fitting
            if current_tags_have_fullscreen(s) then
                bar.hide(s)
            else
                bar.show(s)
            end
        end)
end)

-- This stuff should cover all cases with fullscreened clients i think

client.connect_signal("property::fullscreen", function(c)
    if current_tags_have_fullscreen(c.screen) then
        bar.hide(c.screen) --the bar thing itself hides the correct bar
    else
        bar.show(c.screen)
    end
end)

client.connect_signal("request::manage", function(c)
    if c.fullscreen then
        bar.hide(c.screen)
    end
end)

client.connect_signal("request::unmanage", function(c)
    if not current_tags_have_fullscreen(c.screen) then
        bar.show(c.screen)
        -- no else since nothing needs to change
    end
end)

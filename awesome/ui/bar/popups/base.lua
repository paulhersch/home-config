---------
-- Generic Popup Widget
---------
-- This is a generic implementation of a bar popup. It implements
-- the base for the popup containing a widget (like a calendar) and
-- also creates the widget that will be put in the bar.
--
-- usage/"workflow"
-- 1. create a new widget with the cool {} syntax
-- 2. register bar in widget
-- 3. let widget be shown (either by widget logic or manually)
-- Ideally an "implementing class" should do steps 2 and 3 in its constructor

local wibox = require("wibox")
local gt = require("gears.table")
local beautiful = require("beautiful")
local awful = require("awful")

local button = require("ui.components").container.button

local M = {}

-- collection of currently opened popups, to prevent double opening
-- on the same screen
-- every bar element with popup needs to subclass this generic version
-- to make use of this synchronisation
M.opened_popups = {}

-- replace the currently used trigger widget with the new one set in the
-- object table, similar to a manual draw call on drawables
local function update_trigger_widget(self)
    local config = self._private.config
    local ret = button {
        widget = (type(config.trigger) == "string") and wibox.widget {
            widget = wibox.widget.imagebox,
            image = config.trigger
        } or config.trigger,
        manual_draw = true,
        left = {
            -- toggle
            on_click = function ()
                if self.opened then
                    self:__hide_popup()
                    self.opened = false
                else
                    self:__show_popup()
                    self.opened = true
                end
            end
        }
    }
    if self.opened then
        ---@diagnostic disable-next-line: undefined-field
        ret:draw_clicked()
    end
    return ret
end

---@class PopupWidgetArgs
---@field trigger any Widget to be shown as trigger, can be string for imagepaths or wibox.widget
---@field widget any Wibox.widget for the popup
---@field anchor "left" | "right"

---@param args PopupWidgetArgs Argument Table
---@return PopupWidget
function M.new(args)
    -- crush into default config
    local _config = {
        trigger = wibox.widget.imagebox(beautiful.awesome_icon),
        widget = wibox.widget.textbox("no widget in init :)"),
        anchor = "right"
    }
    gt.crush(_config, args)

    assert(_config.anchor == "left" or _config.anchor == "right", "PopupWidget Anchor value invalid")
    -- Generic Popup Widget class
    -- bar needs functions "add_widget" and "remove_widget".
    -- add_widget and remove_widget need the following signature:
    -- (widget, anchor), where anchor is a string of "left" or "right"
    -- layouts "add", ... functions with extra steps to determine which side of the bar
    -- the widget is gonna be on.
    --
    -- in my case my bar has two "variable zones" that contain the popups
    -- 
    -- the following fields are accessed on the bar:
    --  - screen
    ---@class PopupWidget
    ---@field private _private table holds basic widget information, logic
    ---@field protected __show_popup function Shows the associated popup
    ---@field protected __hide_popup function Hides the associated popup
    ---@field protected register_bar function Tells the widget which bar to connect to
    ---@field protected show_trigger function Displays the trigger widget in the bar
    ---@field protected hide_trigger function Removes the trigger (visually) from the bar
    ---@field protected bound boolean If the Widget is connected to a bar
    ---@field protected opened boolean If the Popup is opened
    local PopupWidget = {
        ---@private
        _private = {
            bar = nil,
            trigger = nil,
            popup = nil,
            config = _config
        },
        bound = false,
        opened = false,
        trigger_shown = false,
        screen = nil
    }

    PopupWidget._private.trigger = update_trigger_widget(PopupWidget)

    ---
    -- Instance Functions
    ---

    ---@private
    function PopupWidget:__show_popup()
        local popup = self._private.popup
        assert(popup, "Popup not initialized")
        popup.visible = true
        self.opened = true
        popup.x = self.screen.geometry.x + (
            self._private.config.anchor == "left" and 2 * beautiful.useless_gap or (
                self.screen.geometry.width - 2 * beautiful.useless_gap - popup.width
        ))
        self._private.trigger:draw_clicked()
        for _, p in ipairs(M.opened_popups) do
            if p.screen == self.screen then
                p:__hide_popup()
            end
        end
        table.insert(M.opened_popups, self)
    end

    ---@private
    function PopupWidget:__hide_popup()
        local popup = self._private.popup
        assert(popup, "Popup not initialized")
        popup.visible = false
        self.opened = false
        self._private.trigger:draw_released()
        for i, p in ipairs(M.opened_popups) do
            if p == self then
                table.remove(M.opened_popups, i)
                break
            end
        end
    end

    ---@protected
    function PopupWidget:show_trigger()
        assert(self.bound, "cant show unbound widget")
        if not self.trigger_shown then
            self._private.bar:add_widget(self._private.trigger, _config.anchor)
            self.trigger_shown = true
        end
    end

    ---@protected
    function PopupWidget:hide_trigger()
        assert(self.bound, "cant hide unbound widget")
        if self.trigger_shown then
            self._private.bar:remove_widget(self._private.trigger, _config.anchor)
            self.trigger_shown = false
        end
    end

    -- The Popup needs the bar as anchor to be displayed properly
    -- so it will be initialised after register has been run
    ---@protected
    function PopupWidget:register_bar(bar)
        self.screen = bar.screen
        self._private.bar = bar
        self._private.popup = awful.popup {
            widget = self._private.config.widget,
            screen = self.screen,
            ontop = true,
            visible = false,
            y = bar.screen.geometry.y + beautiful.wibar_height + 2 * beautiful.useless_gap
        }
        self.bound = true

        bar:connect_signal("property::visible", function (_)
            if self.opened then
                if not bar.visible then
                    self:__hide_popup()
                    self.opened = true -- hack our way around opened being false again
                else
                    self:__show_popup()
                end
            end
        end)
    end

    return PopupWidget
end

return setmetatable(M, {__call = M.new})

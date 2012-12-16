-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
--Dynamic Tagging
require("eminent")
-- Vicious widgets library
vicious = require("vicious")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end

        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/sourav/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"


-- standard programs
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
fm         = "spacefm"
browser = "google-chrome"

--colors
blue    = "#90bddb"
white   = "#ebecec"
black   = "#0c0c0b"
red     = "#ff4444"
green   = "#99cc00"

NameColor = '<span color="#729ab7">'
ItemColor = '<span color="#ff9944">'



-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

--- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
--

myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { 
						{ "terminal", terminal },
						{ "awesome", myawesomemenu, beautiful.awesome_icon }
            }})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}



--Widgets

-- Seperator
brackopen = widget({type = "textbox"})
brackclose = widget({type = "textbox"})
brackopen.text = ' ['
brackclose.text = '] '
spacer = widget({type = "textbox"})
spacer.text = " "

-- Clock Widget
mytextclock = awful.widget.textclock({ align = "right",}, '<span color="#838c8d">%a %b %d</span><span color="grey"> </span><span color="#729ab7">%l:%M %p</span>', 60 )

-- Calendar widget to attach to the textclock
-- require('calendar2')
-- calendar2.addCalendarToWidget(mytextclock)


-- Volume widget

volumecfg = {}
volumecfg.cardid  = 0
volumecfg.channel = "Master"
volumecfg.widget = widget({ type = "textbox", name = "volumecfg.widget", align = "right" })

volumecfg_t = awful.tooltip({ objects = { volumecfg.widget },})
volumecfg_t:set_text(" volume ")

-- command must start with a space!
volumecfg.mixercommand = function (command)
       local fd = io.popen("amixer -c " .. volumecfg.cardid .. command)
       local status = fd:read("*all")
       fd:close()

       local volume = string.match(status, "(%d?%d?%d)%%")
       volume = string.format("% 3d", volume)
       status = string.match(status, "%[(o[^%]]*)%]")
       if string.find(status, "on", 1, true) then
               volume = '<span color="#ff9944">' .. volume .."%" .. '</span >'
       else
               volume = '<span color = "#ff4444">'.. volume ..  "M" .. '</span>'
       end

			 volume = '<span color="#729ab7">' .. "Volume" .. '</span>' .. volume
			 volumecfg.widget.text = volume
end
volumecfg.update = function ()
       volumecfg.mixercommand(" sget " .. volumecfg.channel)
end
volumecfg.up = function ()
       volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%+")
end
volumecfg.down = function ()
       volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%-")
end
volumecfg.toggle = function ()
       volumecfg.mixercommand(" sset " .. volumecfg.channel .. " toggle")
end
volumecfg.widget:buttons({
       button({ }, 4, function () volumecfg.up() end),
       button({ }, 5, function () volumecfg.down() end),
       button({ }, 1, function () volumecfg.toggle() end)
})
volumecfg.update()


--MPD widget

mpdwidget = widget({ type = "textbox" })
 vicious.register(mpdwidget, vicious.widgets.mpd,
   function (widget, args)
     if   args["{state}"] == "Stop" then return ""
		 elseif args["{Artist}"] == "N/A" and args["{Title}"] == "N/A" then return ""
     else return '<span color="#ff9944">'..args["{Artist}"]..'</span>'..
			 ' - '.. '<span color="#036677">'..args["{Title}"]..
			 " - "..'</span>' ..
			 '<span color="grey">' ..
			 args["{Album}"] .. ' - ' ..
			 args["{state}"] ..
			 '</span>'
     end
   end,1)

mpdwidget:buttons({
       button({ }, 4, function () awful.util.spawn_with_shell("mpc next") end),
       button({ }, 5, function () awful.util.spawn_with_shell("mpc prev") end),
       button({ }, 1, function () awful.util.spawn_with_shell("mpc toggle") end)
})

--Network widget

lanwidget = widget({type = "textbox"})
wlanwidget = widget({type = "textbox"})

vicious.register(lanwidget,vicious.widgets.net,
				NameColor .. "Down: " .. '</span>' ..
        ItemColor .. "${eth0 down_kb} "  .. '</span>' ..
				NameColor .. "Up: " .. '</span>' ..
				ItemColor .. "${eth0 up_kb}" .. '</span>',1)


vicious.register(wlanwidget,vicious.widgets.wifi,
			function (widget,args)
				if args["{ssid}"] == "N/A" then
					return ""
				else
					return args["{ssid}"] ..":" .. args["{rate}"]
				end
			end,
			9,"wlan0")

--weather widget VECC
--weatherwidget = widget({type = "textbox"})
--vicious.cache(weatherwidget)
--vicious.register(weatherwidget,vicious.widgets.weather,
--		function (widget, args)
--			if args["{city}"] == "N/A" then
--				return ""
--			else
--				return '<span color = "#ff9944">'.. args["{city}"] .. '</span>'.. " " ..
--				'<span color = "#036677">'.. args["{weather}"] .. '</span>'.. " " ..
--				'<span color = "#036677">'.. args["{tempc}"] .. "°C" .. '</span>'
--			end
--		end,
--		61,"VECC")


-- Sensor widget
thermalwidget = widget({type = "textbox"})
function thermalfunc(widget)
	local fd = io.popen('sensors | grep -G "temp1*.*"')
	local str = fd:read("*all");
	
	local text = string.match(str,"%d+.%d+")
	if tonumber(text) >= 65 then
		widget.text = '<span color="red">' .. text ..'°C' .. '</span>'
	else
		widget.text = ItemColor .. text ..'°C' .. '</span>'
	end
		widget.text = NameColor .. "Temp: ".. '</span>' .. widget.text
end

awful.hooks.timer.register(5,function() thermalfunc(thermalwidget) end)


-- Battery widget
battwidget = widget({type = "textbox"})
battwidget_t = awful.tooltip({ objects = {battwidget },})
battwidget_t:set_text(" Battery ")

function battfunction(widget)
	local fd = io.popen('acpi')
	local str = fd:read("*all")

	if string.match(str,"Discharging") == "Discharging" then
		widget.text = '<span color = "#ff4444">' .. string.match(str,"%d+%%") ..
									'⌁'..'</span>'
		battwidget_t:set_text(" Time remaining: " .. string.match(str,"%d+:%d+:%d+") .. ' ')
		--vicious.suspend()
	else
		widget.text = '<span color="#99cc00">' .. "AC↯" .. '</span>'
		battwidget_t:set_text(" Battery ")

	end
end

awful.hooks.timer.register(3, function () battfunction(battwidget) end)


-- {{{ Wibox
-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mynotifybox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
										 awful.button({ }, 2, function(c)
											 												c:kill()
																					end),

                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
			mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
		s == 1 and mysystray or nil,
		mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
	}

	mynotifybox[s] = awful.wibox({ position = "bottom", screen = s})
	mynotifybox[s].widgets = {
		{
			mpdwidget,
			layout = awful.widget.layout.horizontal.leftright
		},

			brackclose,
			mytextclock,
			brackopen,

			brackclose,
			volumecfg.widget,
			brackopen,

			brackclose,
			thermalwidget,
			brackopen,

			brackclose,
			lanwidget,
			brackopen,

			brackclose,
			battwidget,
			brackopen,

			wlanwidget,

			layout = awful.widget.layout.horizontal.rightleft

	}
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true,coords={x=0, y=5}})  end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey, "Shift" }, "Tab",
        function ()
						awful.client.focus.byidx( 1)
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    awful.key({ modkey}, "b",
        function ()
            mynotifybox[1].visible = not mynotifybox[1].visible
        end),
		awful.key({ modkey,"Shift"}, "b",
        function ()
            mywibox[1].visible = not mywibox[1].visible
        end),
    awful.key({ "Control" }, "Escape", function ()
     -- If you want to always position the menu on the same place set coordinates
        awful.menu.menu_keys.down = { "Down", "Alt_L" }
        local cmenu = awful.menu.clients({width=245}, { keygrabber=true, coords={x=525, y=330} })
        end),
    awful.key({"Control",modkey }, "l", function () awful.util.spawn_with_shell("slock") end),
    awful.key({"Control", "Mod1"}, "s", function () awful.util.spawn("subl") end),
    awful.key({ }, "XF86HomePage", function () awful.util.spawn(browser) end),
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn_with_shell('mpc toggle') end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn_with_shell('mpc next') end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn_with_shell('mpc prev') end),
		awful.key({ }, "Print", function () awful.util.spawn_with_shell('scrot -q 100') end),
    awful.key({modkey}, "v", function () awful.util.spawn("gvim") end),
    awful.key({modkey}, "p", function () awful.util.spawn('spacefm') end),
		awful.key({"Mod1","Control"}, "m", function () awful.util.spawn_with_shell('mpd') end)



)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ }, "XF86AudioRaiseVolume", function () volumecfg.up() end),
        awful.key({ }, "XF86AudioLowerVolume", function () volumecfg.down() end),
        awful.key({ }, "XF86AudioMute", function () volumecfg.toggle() end)
        )

end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
					 size_hints_honor = false } },
    { rule = { instance = "vlc" },
      properties = { floating = true } },
    { rule = { instance = "redshiftgui" },
      properties = { floating = true } },
    { rule = { class = "firefox", role = 'Downloads' },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
	-- awful.titlebar.add(c, { modkey = modkey })


    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
				--	c:raise() 
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

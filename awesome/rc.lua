-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
--require("eminent")

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
    awesome.connect_signal("debug::error", function (err)
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
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "gvim"
editor_cmd = terminal .. " -e " .. editor
browser = "google-chrome"
filemanager = "spacefm"
texteditor = "subl"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
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

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- WIDGETS!

-- Seperator
brackopen = wibox.widget.textbox()
brackclose = wibox.widget.textbox()
brackopen:set_text(' [')
brackclose:set_text('] ')
spacer = wibox.widget.textbox()
spacer:set_text(" ")


NameColor = '<span color="#729ab7">'
ItemColor = '<span color="#ff9944">'

--mytextclock = awful.widget.textclock()
mytextclock = awful.widget.textclock('<span color="#838c8d">%a %b %d</span><span color="grey"> </span><span color="#729ab7">%R</span>', 60 )


volumewidget = wibox.widget.textbox()
volumecfg = {}
volumecfg.cardid  = 0
volumecfg.channel = "Master"
volumecfg.widget = wibox.widget.textbox()

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

       volume = '<span color="#729ab7">' .. "Vol:" .. '</span>' .. volume
       volumecfg.widget:set_markup(volume)
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
volumecfg.widget:buttons(awful.util.table.join(
       awful.button({ }, 4, function () volumecfg.up() end),
       awful.button({ }, 5, function () volumecfg.down() end),
       awful.button({ }, 1, function () volumecfg.toggle() end)
))
volumecfg.update()  

--MPD widget
mpdwidget = wibox.widget.textbox()
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

mpdwidget:buttons(awful.util.table.join(
       awful.button({ }, 4, function () awful.util.spawn_with_shell("mpc next") end),
       awful.button({ }, 5, function () awful.util.spawn_with_shell("mpc prev") end),
       awful.button({ }, 1, function () awful.util.spawn_with_shell("mpc toggle") end)
))

--Lan Widget
lanwidget = wibox.widget.textbox()
vicious.register(lanwidget,vicious.widgets.net,
        NameColor .. "Down: " .. '</span>' ..
        ItemColor .. "${eth0 down_kb} "  .. '</span>' ..
        NameColor .. "Up: " .. '</span>' ..
        ItemColor .. "${eth0 up_kb}" .. '</span>',3)

--Wlan Widget
wlanwidget = wibox.widget.textbox()
vicious.register(wlanwidget,vicious.widgets.wifi,
      function (widget,args)
        if args["{ssid}"] == "N/A" then
          return ""
        else
          return "Wifi :" .. args["{ssid}"]
        end
      end,
      9,"wlan0")

--Battery widget
batwidget =  wibox.widget.textbox()
battwidget_t = awful.tooltip({ objects = {batwidget },})
battwidget_t:set_text(" Battery ")

vicious.register(batwidget, vicious.widgets.bat, 
      function(widget, args) 
        if args[1] == "-" then
          battwidget_t:set_text(" Time remaining: " .. args[3] .. ' ')
          return '<span color = "#ff4444">' .. args[2] .. "%</span>"
        else
          battwidget_t:set_text(" Charging: " .. args[2].. "% ")
          return '<span color="#99cc00">' .. "AC↯" .. '</span>'
        end
      end, 7, "BAT0")


--Launchers go here
browslaunch = wibox.widget.imagebox()
browslaunch:set_image('/usr/share/icons/Faenza/apps/32/browser.png')
termlaunch = wibox.widget.imagebox()
termlaunch:set_image('/usr/share/icons/Faenza/apps/32/terminal.png')
filelaunch = wibox.widget.imagebox()
filelaunch:set_image('/usr/share/icons/Faenza/apps/32/file-manager.png')
musiclaunch = wibox.widget.imagebox()
musiclaunch:set_image('/usr/share/icons/Faenza/apps/32/itunes.png')
torrentlaunch = wibox.widget.imagebox()
torrentlaunch:set_image('/usr/share/icons/Faenza/apps/32/transmission.png')
htoplaunch = wibox.widget.imagebox()
htoplaunch:set_image('/usr/share/icons/Faenza/apps/32/utilities-system-monitor.png')
textlaunch = wibox.widget.imagebox()
textlaunch:set_image('/usr/share/icons/Faenza/apps/32/accessories-text-editor.png')


browslaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn(browser) end)
))
termlaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn(terminal) end)
))
filelaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn(filemanager) end)
))
musiclaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn_with_shell('mpd;mpc play;urxvt -e ncmpcpp') end)
))
torrentlaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn('transmission-gtk') end)
))
htoplaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn_with_shell('urxvt -e htop') end)
))
textlaunch:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn_with_shell(texteditor) end)
))

browse_t = awful.tooltip({ objects = { browslaunch },})
browse_t:set_text(" Browser ")
term_t = awful.tooltip({ objects = { termlaunch },})
term_t:set_text(" Terminal ")
file_t = awful.tooltip({ objects = { filelaunch },})
file_t:set_text(" File Explorer ")
music_t = awful.tooltip({ objects = { musiclaunch },})
music_t:set_text(" Music ")
torrent_t = awful.tooltip({ objects = { torrentlaunch },})
torrent_t:set_text(" Torrent Client ")
htop_t = awful.tooltip({ objects = { htoplaunch },})
htop_t:set_text(" Sys Monitor ")
text_t = awful.tooltip({ objects = { textlaunch },})
text_t:set_text(" Editor ")


-- Create a wibox for each screen and add it
mywibox = {}
mybottombox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
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
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    mybottombox[s] = awful.wibox({ position = "bottom", screen = s})

    -- TOP Widgets that are aligned to the left
    local left_layout_top = wibox.layout.fixed.horizontal()
    --left_layout_top:add(mylauncher)
    left_layout_top:add(mytaglist[s])
    left_layout_top:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout_top = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout_top:add(wibox.widget.systray()) end
    right_layout_top:add(mylayoutbox[s])
  
    -- Now bring it all together (with the tasklist in the middle)
    local top_layout = wibox.layout.align.horizontal()
    top_layout:set_left(left_layout_top)
    top_layout:set_middle(mytasklist[s])
    top_layout:set_right(right_layout_top)

    mywibox[s]:set_widget(top_layout)

    --TOP widget section ends here 

    --BOTTOM widget section here
    local left_layout_bottom = wibox.layout.fixed.horizontal()

    left_layout_bottom:add(brackopen)
    left_layout_bottom:add(termlaunch)
    left_layout_bottom:add(textlaunch)
    left_layout_bottom:add(filelaunch)
    left_layout_bottom:add(browslaunch)
    left_layout_bottom:add(musiclaunch)
    left_layout_bottom:add(torrentlaunch)
    left_layout_bottom:add(htoplaunch)
    left_layout_bottom:add(brackclose)

    left_layout_bottom:add(brackopen)
    left_layout_bottom:add(mpdwidget)
    left_layout_bottom:add(brackclose)

    local right_layout_bottom = wibox.layout.fixed.horizontal()
    right_layout_bottom:add(brackopen)
    right_layout_bottom:add(batwidget)
    right_layout_bottom:add(brackclose)
    right_layout_bottom:add(wlanwidget)
    right_layout_bottom:add(brackopen)
    right_layout_bottom:add(lanwidget)
    right_layout_bottom:add(brackclose)
    right_layout_bottom:add(brackopen)
    right_layout_bottom:add(volumecfg.widget)
    right_layout_bottom:add(brackclose)
    right_layout_bottom:add(brackopen)
    right_layout_bottom:add(mytextclock)
    right_layout_bottom:add(brackclose)
  
    local bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(left_layout_bottom)
    bottom_layout:set_right(right_layout_bottom)

    mybottombox[s]:set_widget(bottom_layout)
    
    
end
-- }}}

-- If at start the bottom box is to remain hidden
-- mybottombox[1].visible = false

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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        -- Tab cycles through every client
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
        -- Tab only with history
        -- function ()
        --     awful.client.focus.history.previous()
        --     if client.focus then
        --         client.focus:raise()
        --     end
        -- end),

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
    awful.key({ "Control" }, "Escape", function ()
     -- If you want to always position the menu on the same place set coordinates
        awful.menu.menu_keys.down = { "j", "Down" }
        local cmenu = awful.menu.clients({width=245}, { keygrabber=true, coords={x=525, y=330} })
        end),
    -- Menubar
    awful.key({ modkey,"Shift" }, "p", function() menubar.show() end),
    awful.key({ modkey,"Shift"}, "b",
        function ()
            mywibox[1].visible = not mywibox[1].visible
        end),
    awful.key({ modkey }, "b",
        function ()
            mybottombox[1].visible = not mybottombox[1].visible
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
    awful.key({ }, "XF86AudioRaiseVolume", function () volumecfg.up() end),
    awful.key({ }, "XF86AudioLowerVolume", function () volumecfg.down() end),
    awful.key({ }, "XF86AudioMute", function () volumecfg.toggle() end),
    awful.key({"Mod1","Control"}, "m", function () awful.util.spawn_with_shell('mpd') end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
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
   keynumber = math.min(9, math.max(#tags[s], keynumber))
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
                  end))
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
    { rule = { instance = "wpa_gui" },
      properties = { floating = true } },  
    { rule = { instance = "audacious" },
      properties = { floating = true } },  
    { rule = { instance = "lxappearance" },
      properties = { floating = true } },  
    { rule = { class = "firefox", role = 'Downloads' },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
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

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

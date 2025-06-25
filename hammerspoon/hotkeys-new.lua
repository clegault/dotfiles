--------------------------------------------------------------------
-- 1.  LOAD YOUR OWN "hyper" MODULE (the one in your first code block)
--------------------------------------------------------------------
local hyper = require("hyper")     --  ‹-- save that file as ~/.hammerspoon/hyper.lua

--------------------------------------------------------------------
-- 2.  MINIMAL HELPERS THAT REPLACE THE SPOON'S sugar
--------------------------------------------------------------------
-- 2.1  send a keystroke later
local function combo(mods, key)
  return function() hs.eventtap.keyStroke(mods, key, 0) end
end

-- 2.2  you used this once to wrap another function
local function copy(fn)  -- keeps the name you used in old code
  return function() fn() end
end

--------------------------------------------------------------------
-- 3.  THE "ACTION TABLE"
--     • Top level key = bundle-ID of an app   (or "fallback").
--     • Second level  = action group          (open / navigate …).
--     • Third level   = sub-action            (up / down / default …)
--     • The value     = a function            (we run it).
--------------------------------------------------------------------
local actions = {
  fallback = {                     -- runs if no specific override found
    copy        = { default = combo({'cmd'}, 'c') },
    paste       = { default = combo({'cmd'}, 'v') },
    insert      = { default = combo({'cmd','shift','alt','ctrl'}, 'i') },
    execute     = { default = combo({'shift','alt','ctrl'}, '.') },
    lock        = { default = combo({'cmd','shift','alt','ctrl'}, 'delete') },

    windowSize  = {
      up     = combo({'cmd','alt','ctrl'}, '8'),
      down   = combo({'cmd','alt','ctrl'}, '2'),
      left   = combo({'cmd','alt','ctrl'}, '4'),
      right  = combo({'cmd','alt','ctrl'}, '6'),
      center = combo({'cmd','alt','ctrl'}, '5'),
    },

    open        = {                          -- launcher shortcuts
      Ghostty   = function() hs.application.launchOrFocus("Ghostty") end,
      console   = function() hs.toggleConsole() end,
      slack     = function() hs.application.launchOrFocus("Slack") end,
      calendar  = function() hs.application.launchOrFocus("Calendar") end,
      teams     = function() hs.application.launchOrFocus("Microsoft Teams") end,
      arc       = function() hs.application.launchOrFocus("Arc") end,
      discord   = function() hs.application.launchOrFocus("Discord") end,
      messages  = function() hs.application.launchOrFocus("Messages") end,
    },

    fullscreen  = { default = combo({'cmd','ctrl'}, 'f') },
    darkToggle  = { default = toggleDarkMode },     -- your own fn
    gridToggle  = { default = hs.grid.toggleShow },
    emoji       = { picker  = startEmojiPicker },   -- your own fn

    changeBrightness = {
      up   = function() changeBrightnessInDirection( 1) end,
      down = function() changeBrightnessInDirection(-1) end,
    },

    startWork      = { default = startWork },       -- your own fn
    listDisplays   = { default = listDisplays },    -- your own fn
  },

  -- 🟣 Slack
  ['com.tinyspeck.slackmacgap'] = {
    open    = { default = combo({'cmd'}, 'k') },
    navigate = {
      up      = combo({'cmd','shift'}, ']'),
      down    = combo({'cmd','shift'}, '['),
      back    = combo({'cmd'}, '['),
      forward = combo({'cmd'}, ']'),
    },
  },

  -- 🟣 Discord
  ['com.hnc.Discord'] = {
    open = { default = combo({'cmd'}, 'k') },
  },

  -- 🟣 Arc browser
  ['company.thebrowser.Browser'] = {
    open    = { default = combo({'cmd'}, 'l') },
    navigate = {
      up      = combo({'cmd','shift'}, ']'),
      down    = combo({'cmd','shift'}, '['),
      back    = combo({'cmd'}, '['),
      forward = combo({'cmd'}, ']'),
    },
  },

  -- 🟣 VS Code
  ['com.microsoft.VSCode'] = {
    open    = { default = combo({'cmd','shift'}, 'p') },
    copy    = { default = copy(combo({'cmd'}, 'c')) },
  },
}

--------------------------------------------------------------------
-- 4.  DISPATCHER + hyperBind (re-creates the old API)
--------------------------------------------------------------------
local function dispatch(actionGroup, subAction)
  local front = hs.application.frontmostApplication()
  local bundle = front and front:bundleID() or "fallback"

  local appTbl   = actions[bundle]     or {}              -- app specific
  local groupTbl = appTbl[actionGroup]                  -- app override?
                 or actions.fallback[actionGroup]        -- else fallback

  if not groupTbl then return end                        -- nothing defined

  local fn = groupTbl[subAction] or groupTbl.default
  if type(fn) == "function" then fn() end
end

-- call like:  hyperBind("o", "open", "default")
function hyperBind(key, actionGroup, subAction)
  hyper:bind({}, key, nil, function()
    dispatch(actionGroup, subAction)
  end)
end

--------------------------------------------------------------------
-- 5.  YOUR ORIGINAL BINDINGS
--------------------------------------------------------------------
-- first row
hyperBind("o", "open",       "default")
hyperBind("h", "navigate",   "back")
hyperBind("j", "navigate",   "down")
hyperBind("k", "navigate",   "up")
hyperBind("l", "navigate",   "forward")
hyperBind("p", "paste",      "default")
hyperBind("y", "copy",       "default")
hyperBind("i", "insert",     "default")
hyperBind("delete", "lock",  "default")
hyperBind(".", "execute",    "default")

-- window-size "numpad"
hyperBind("8", "windowSize", "up")
hyperBind("2", "windowSize", "down")
hyperBind("4", "windowSize", "left")
hyperBind("6", "windowSize", "right")
hyperBind("5", "windowSize", "center")

-- app launchers
hyperBind("m", "open", "messages")
hyperBind("`", "open", "console")
hyperBind("tab","open", "Ghostty")
hyperBind("s", "open", "slack")
hyperBind("t", "open", "teams")
hyperBind("w", "open", "arc")
hyperBind("c", "open", "calendar")
hyperBind("d", "open", "discord")

-- other actions
hyperBind("f",  "fullscreen",       "default")
hyperBind("n",  "noises",           "default")     -- assuming you add that
hyperBind("\\", "darkToggle",       "default")

-- brightness
hyperBind("1", "changeBrightness", "down")         -- Hyper-1  (dimmer)
hyperBind("2", "changeBrightness", "up")           -- Hyper-2  (brighter)

-- grid + emoji
hyperBind("b", "gridToggle", "default")
hyperBind("e", "emoji",      "picker")

-- custom helpers
hyperBind("f1","startWork",     "default")
hyperBind("0", "listDisplays",  "default")

--------------------------------------------------------------------
-- 6.  DONE  - reload Hammerspoon
--------------------------------------------------------------------
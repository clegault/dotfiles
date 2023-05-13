hs.grid.setGrid('12x12') -- allows us to place on quarters, thirds and halves
hs.window.animationDuration = 0 -- disable animations

local screenCount = #hs.screen.allScreens()
local screenGeometries = hs.fnutils.map(hs.screen.allScreens(), function(screen)
  return screen:currentMode().desc
end)
local logLevel = 'debug' -- generally want 'debug' or 'info'
local log = hs.logger.new('wincent', logLevel)
local messagesActive = false

local grid = {
  topHalf = '0,0 12x2',
  topThird = '0,0 12x4',
  topTwoThirds = '0,0 12x8',
  rightHalf = '5,0 5x12',
  rightThird = '8,0 4x12',
  rightTwoThirds = '4,0 8x12',
  bottomHalf = '0,2 12x6',
  bottomThird = '0,8 12x4',
  bottomTwoThirds = '0,4 12x8',
  leftHalf = '0,0 5x12',
  leftThird = '0,0 4x12',
  leftTwoThirds = '0,0 8x12',
  topLeft = '0,0 6x6',
  topRight = '6,0 6x6',
  bottomRight = '6,6 6x6',
  bottomLeft = '0,6 6x6',
  fullScreen = '0,0 12x12',
  centeredBig = '3,3 6x6',
  centeredSmall = '4,4 4x4',
}

function shiftSpace(bundleID)
  local app = hs.application.get(bundleID)
  if app == nil then
      hs.application.open(bundleID)
  else
      hs.application.open(bundleID)
      app:activate()
  end
end

local layoutConfig = {

--   _before_ = (function()
--     hide('com.spotify.client')
--   end),

--   _after_ = (function()
--     -- Make sure Textual appears in front of Skype, and iTerm in front of
--     -- others.
--     activate('com.codeux.irc.textual5')
--     activate('com.googlecode.iterm2')
--   end),

--   ['com.freron.MailMate'] = (function(window, forceScreenCount)
--     local count = forceScreenCount or screenCount
--     if isMailMateMailViewer(window) then
--       if count == 1 then
--         hs.grid.set(window, grid.fullScreen)
--       else
--         hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
--       end
--     end
--   end),

  -- ['com.vivaldi.Vivaldi'] = (function(window)
  --   hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
  -- end),

--   ['com.apple.iCal'] = (function(window)
--     hs.grid.set(window, grid.bottomHalf, externalDisplay())
--     hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
--   end),

  ['com.culturedcode.ThingsMac'] = (function(window)
    hs.grid.set(window, grid.bottomHalf, externalDisplay())
    hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
  end),
  
  ['net.kovidgoyal.kitty'] = (function(window)
    hs.grid.set(window, grid.bottomHalf, externalDisplay())
    hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
  end),

  ['com.apple.MobileSMS'] = (function(window)
    hs.application.launchOrFocus("Messages")
    if messagesActive then
      messagesActive = false
    else
      messagesActive = true
      hs.eventtap.keyStroke({"ctrl", "alt"}, "n")
    end
  end),

  ['com.apple.Music'] = (function(window)
    hs.grid.set(window, grid.bottomHalf, hs.screen.primaryScreen())
    hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
  end),

  -- ['com.microsoft.teams'] = (function(window)
  --   -- shiftSpace('com.tinyspeck.slackmacgap')
  --   dbg("shifting focus to teams")
  --   shiftSpace('com.microsoft.teams')
  --   local app = hs.application.find("Microsoft Teams")
  --   dbg("Finding the right window")
  --   if string.find(window:title(), "| Microsoft Teams") then
  --     dbg("Found the right window")
  --     window:setFullscreen(not window:isFullscreen())
  --     dbg("waiting 1 second")
  --     hs.timer.doAfter(1, function()
  --       dbg("unzooming the window")
  --       hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
  --       dbg("sending window to second screen")
  --       app:selectMenuItem({"Window", "Move to DELL P2415Q"})
  --       -- hs.grid.set(window, grid.bottomHalf, externalDisplay())
  --       dbg("sending zoom command to window")
  --       window:setFullscreen(not window:isFullscreen())
  --       -- hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
  --     end)
  --   end
  -- end),

  ['com.tinyspeck.slackmacgap'] = (function(window)
    local slackWindow = hs.window.find("Slack")
    slackWindow:focus()
    if not slackWindow:isFullScreen() then
      hs.grid.set(window, grid.bottomHalf, externalDisplay())
      hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
    end
  end),

['com.hnc.Discord'] = (function(window)
  --  find discord windows
    local discordWindow = hs.window.find("Discord")
    -- get only the one that is not the Updater window
    if discordWindow and not string.match(discordWindow:title(), "Updater") then
      -- set focus to the main window
      discordWindow:focus()
      -- check if it's full screen already, if it is not, go to full screen
      if not discordWindow:isFullScreen() then
        hs.grid.set(window, grid.topHalf, externalDisplay())
        hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
      end
    end
end),
}


--
-- Utility and helper functions.
--

-- Returns the number of standard, non-minimized windows in the application.
--
-- (For Chrome, which has two windows per visible window on screen, but only one
-- window per minimized window).
function windowCount(app)
  local count = 0
  if app then
    for _, window in pairs(app:allWindows()) do
      if window:isStandard() and not window:isMinimized() then
        count = count + 1
      end
    end
  end
  return count
end

function hide(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:hide()
  end
end

function activate(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:activate()
  end
end

function isMailMateMailViewer(window)
  local title = window:title()
  return title == 'No mailbox selected' or
    string.find(title, '%(%d+ messages?%)')
end

function externalDisplay()
  -- dbg(hs.screen'Dell')
  return hs.screen'Dell'
end

function primaryDisplay()
  -- dbg(hs.screen.primaryScreen())
  return hs.screen.primaryScreen()
end

function activateLayout(forceScreenCount)
  layoutConfig._before_()

  for bundleID, callback in pairs(layoutConfig) do
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        if window:isStandard() then
          callback(window, forceScreenCount)
        end
      end
    end
  end

  layoutConfig._after_()
end

-- Event-handling
--
-- This will become a lot easier once `hs.window.filter`
-- (http://www.hammerspoon.org/docs/hs.window.filter.html) moves out of
-- "experimental" status, but until then, using a manual approach as
-- demonstrated at: https://gist.github.com/tmandry/a5b1ab6d6ea012c1e8c5

local globalWatcher = nil
local watchers = {}
local events = hs.uielement.watcher

function handleGlobalEvent(name, eventType, app)
  if eventType == hs.application.watcher.launched then
    log.df('[event] launched %s', app:bundleID())
    watchApp(app)
  elseif eventType == hs.application.watcher.terminated then
    -- Only the PID is set for terminated apps, so can't log bundleID.
    local pid = app:pid()
    log.df('[event] terminated PID %d', pid)
    unwatchApp(pid)
  end
end

function handleAppEvent(element, event)
  if event == events.windowCreated then
    if pcall(function()
      log.df('[event] window %s created', element:id())
      local win = hs.window.focusedWindow()
      -- dbg(win)
    end) then
      watchWindow(element)
    else
      log.wf('error thrown trying to access element in handleAppEvent')
    end
  else
    log.wf('unexpected app event %d received', event)
  end
end

function handleWindowEvent(window, event, watcher, info)
  if event == events.elementDestroyed then
    log.df('[event] window %s destroyed', info.id)
    watcher:stop()
    watchers[info.pid].windows[info.id] = nil
  else
    log.wf('unexpected window event %d received', event)
  end
end

function handleScreenEvent()
  -- Make sure that something noteworthy (display count, geometry) actually
  -- changed.
  local screens = hs.screen.allScreens()
  if #screens == screenCount then
    local changed = false
    for i, screen in pairs(screens) do
      if screenGeometries[i] ~= screen:currentMode().desc then
        changed = true
      end
    end
    if not changed then
      return
    end
  end

  screenCount = #screens
  activateLayout(screenCount)
end

function watchApp(app)
  local pid = app:pid()
  if watchers[pid] then
    log.wf('attempted watch for already-watched PID %d', pid)
    return
  end

  -- Watch for new windows.
  local watcher = app:newWatcher(handleAppEvent)
  watchers[pid] = {
    watcher = watcher,
    windows = {},
  }
  watcher:start({events.windowCreated})

  -- Watch already-existing windows.
  for _, window in pairs(app:allWindows()) do
    watchWindow(window)
  end
end

function unwatchApp(pid)
  local appWatcher = watchers[pid]
  if not appWatcher then
    log.wf('attempted unwatch for unknown PID %d', pid)
    return
  end

  appWatcher.watcher:stop()
  for _, watcher in pairs(appWatcher.windows) do
    watcher:stop()
  end
  watchers[pid] = nil
end

function watchWindow(window)
  local application = window:application()
  local pid = application:pid()
  local windows = watchers[pid].windows
  if window:isStandard() then
    -- Do initial layout-handling.
    local bundleID = application:bundleID()
    if layoutConfig[bundleID] then
      layoutConfig[bundleID](window)
    end

    -- Watch for window-closed events.
    local id = window:id()
    if id then
      if not windows[id] then
        local watcher = window:newWatcher(handleWindowEvent, {
          id = id,
          pid = pid,
        })
        windows[id] = watcher
        watcher:start({events.elementDestroyed})
      end
    end
  end
end

function initEventHandling()
  -- Watch for application-level events.
  globalWatcher = hs.application.watcher.new(handleGlobalEvent)
  globalWatcher:start()

  -- Watch already-running applications.
  local apps = hs.application.runningApplications()
  for _, app in pairs(apps) do
    if app:bundleID() ~= 'org.hammerspoon.Hammerspoon' then
      watchApp(app)
    end
  end

  -- Watch for screen changes.
  screenWatcher = hs.screen.watcher.new(handleScreenEvent)
  screenWatcher:start()
end

function tearDownEventHandling()
  globalWatcher:stop()
  globalWatcher = nil

  screenWatcher:stop()
  screenWatcher = nil

  for pid, _ in pairs(watchers) do
    unwatchApp(pid)
  end
end

initEventHandling()

local lastSeenChain = nil
local lastSeenWindow = nil

-- Chain the specified movement commands.
--
-- This is like the "chain" feature in Slate, but with a couple of enhancements:
--
--  - Chains always start on the screen the window is currently on.
--  - A chain will be reset after 2 seconds of inactivity, or on switching from
--    one chain to another, or on switching from one app to another, or from one
--    window to another.
--
function chain(movements)
  local chainResetInterval = 2 -- seconds
  local cycleLength = #movements
  local sequenceNumber = 1

  return function()
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local now = hs.timer.secondsSinceEpoch()
    local screen = win:screen()

    if
      lastSeenChain ~= movements or
      lastSeenAt < now - chainResetInterval or
      lastSeenWindow ~= id
    then
      sequenceNumber = 1
      lastSeenChain = movements
    elseif (sequenceNumber == 1) then
      -- At end of chain, restart chain on next screen.
      screen = screen:next()
    end
    lastSeenAt = now
    lastSeenWindow = id

    hs.grid.set(win, movements[sequenceNumber], screen)
    sequenceNumber = sequenceNumber % cycleLength + 1
  end
end



--
-- Key bindings.
--

-- hs.hotkey.bind({'ctrl', 'alt'}, 'up', chain({
--   grid.topHalf,
--   grid.topThird,
--   grid.topTwoThirds,
-- }))

-- hs.hotkey.bind({'ctrl', 'alt'}, 'right', chain({
--   grid.rightHalf,
--   grid.rightThird,
--   grid.rightTwoThirds,
-- }))

-- hs.hotkey.bind({'ctrl', 'alt'}, 'down', chain({
--   grid.bottomHalf,
--   grid.bottomThird,
--   grid.bottomTwoThirds,
-- }))

-- hs.hotkey.bind({'ctrl', 'alt'}, 'left', chain({
--   grid.leftHalf,
--   grid.leftThird,
--   grid.leftTwoThirds,
-- }))

-- hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'up', chain({
--   grid.topLeft,
--   grid.topRight,
--   grid.bottomRight,
--   grid.bottomLeft,
-- }))

-- hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'down', chain({
--   grid.fullScreen,
--   grid.centeredBig,
--   grid.centeredSmall,
-- }))

-- hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f1', (function()
--   hs.alert('One-monitor layout')
--   activateLayout(1)
-- end))

-- hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f2', (function()
--   hs.alert('Two-monitor layout')
--   activateLayout(2)
-- end))

-- hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "F11", function()
--   local win = hs.window.focusedWindow()
--   dbg(win)
-- end)
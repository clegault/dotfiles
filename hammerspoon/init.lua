-- clegault's Hammerspoon config file

-- Clear the console
hs.console.clearConsole()

-- Start profiling
require("profile")

hs.alert.show("hammerspoon starting...")

profileStart('imports')
profileStart('configTotal')

require("hs.ipc")
hs.ipc.cliInstall()

require "hotkeys"
require "preferred_screen"
require "brightness_control"
require "grid"
require "darkmode"
require "server"
require "windowManager"
require "ElgatoKeyControll"
require "choose"
require "emoji"
require "util"
-- require "itunes_albumart"
-- require "link_replace"
-- require "vimwiki.picker"
-- require "pinboard"
-- require "youtubedl"
-- require "volume_control"
-- require "streamdeck"
-- require "window_tweaks"
-- require "flux"
-- require "audio_output"

profileStop('imports')
profileStart('globals')
-- Global 'doc' variable that I can use inside of the Hammerspoon {{{

doc = hs.doc

-- }}}
-- Global 'inspectThing' function for inspecting objects (DEBUGGING?) {{{

-- function inspectThing(thing)
--     return hs.inspect.inspect(thing)
-- end

-- }}}
-- Global variables {{{
-- Hyper Key {{{

hyperKeyDef = {"ctrl", "alt", "shift"}

-- }}}

hs.window.animationDuration = 0.0
-- caffeinateWatcher = nil
pasteboardWatcher = nil
-- }}}
profileStop('globals')
-- Finding all running GUI apps {{{

function allRunningApps()
    local allApps = hs.application.runningApplications()
    local allRunningApps = {}

    for idx,app in pairs(allApps) do
        -- Ignore Hammerspoon
        if app:mainWindow() ~= nil and app:title() ~= "Hammerspoon" then
            table.insert(allRunningApps, app)
        end
    end

    return allRunningApps
end

-- }}}
-- Notifying {{{

function notifySoftly(notificationString)
    hs.alert.show(notificationString)
end

function notify(notificationString)
    local notification = hs.notify.new()
    notification:title(notificationString)
    notification:send()
end

function notifyUrgently(notificationString)
    hs.messages.iMessage("clegault@nextgengeek.com", notificationString)
    local messagesApp = hs.appfinder.appFromName("Messages")
    if messagesApp then
        messagesApp:hide()
    end
end

hs.urlevent.bind("notifySoftly", function(eventName, params)
    local text = params["text"]
    if text then
        notifySoftly(text)
    end
end)

hs.urlevent.bind("notify", function(eventName, params)
    local text = params["text"]
    if text then
        notify(text)
    end
end)

hs.urlevent.bind("notifyUrgently", function(eventName, params)
    local text = params["text"]
    if text then
        notifyUrgently(text)
    end
end)

-- }}}

-- Start zoom spoon
zoomStatusMenuBarItem = hs.menubar.new(true)
zoomStatusMenuBarItem:setClickCallback(function()
    toggleMute()
end)

-- hs.loadSpoon('ElgatoKey'):start()

-- hs.loadSpoon("CCMute")
-- spoon.CCMute:setStatusCallback(updateZoomStatus)
-- spoon.CCMute:start()

-- put mute toggle on hyper-f12
-- hs.hotkey.bind('', 'f12', function()
--   spoon.CCMute:ztoggleMute()
--   spoon.CCMute:ttoggleMute()
-- end)
-- }}}

-- }}}

profileStart('windowCommands')
-- Window Geometry {{{

function windowPaddingForScreen (screen)
    return 0
end

-- }}}
-- Window Sanitizing {{{

function sanitizeWindowPosition (window, frame)
    local windowScreen = window:screen()
    local windowPadding = windowPaddingForScreen(windowScreen)

    local screenFrame = windowScreen:frame()

    local minimumWindowX = screenFrame.x + windowPadding
    local minimumWindowY = screenFrame.y + windowPadding

    local maximumWindowX = (screenFrame.x + screenFrame.w) - (frame.w + windowPadding)
    local maximumWindowY = (screenFrame.y + screenFrame.h) - (frame.h + windowPadding)

    frame.x = math.max(frame.x, minimumWindowX)
    frame.y = math.max(frame.y, minimumWindowY)

    frame.x = math.min(frame.x, maximumWindowX)
    frame.y = math.min(frame.y, maximumWindowY)

    return frame
end

function sanitizeWindowSize (window, frame)
    local windowScreen = window:screen()
    local windowPadding = windowPaddingForScreen(windowScreen)

    local screenFrame = windowScreen:frame()

    local maximumWidth = screenFrame.w - (2 * windowPadding)
    local maximumHeight = screenFrame.h - (2 * windowPadding)

    frame.w = math.min(frame.w, maximumWidth)
    frame.h = math.min(frame.h, maximumHeight)

    return frame
end

function sanitizeWindowFrame (window, frame)
    frame = sanitizeWindowSize(window, frame)
    frame = sanitizeWindowPosition(window, frame)

    return frame
end

-- }}}
-- Window Movement {{{

function moveWindowInDirection (window,direction)
    local newWindowFrame = window:frame()
    oldWindowPosition = hs.geometry.point(newWindowFrame.x, newWindowFrame.y)

    local padding = windowPaddingForScreen(window:screen())
    local screen = window:screen()
    local screenFrame = screen:frame()

    newWindowFrame.x = newWindowFrame.x + (direction.w * screenFrame.w / 10)
    newWindowFrame.y = newWindowFrame.y + (direction.h * screenFrame.h / 4)

    if newWindowFrame.x ~= oldWindowPosition.x then newWindowFrame.x = newWindowFrame.x + padding * direction.w end
    if newWindowFrame.y ~= oldWindowPosition.y then newWindowFrame.y = newWindowFrame.y + padding * direction.h end

    newWindowFrame = sanitizeWindowFrame(window, newWindowFrame)

    window:setFrame(newWindowFrame)
end

function moveForegroundWindowInDirection (direction)
    local window = hs.window.focusedWindow()
    if window == nil then return end
    moveWindowInDirection(window, direction)
end

-- }}}
-- Window Resizing {{{

function amountToResizeForWindow (window, amount, horizontal)
    local screen = window:screen()
    local screenFrame = screen:frame()

    if horizontal == true then minimumWindowDimension = screenFrame.w / 10 end
    if not horizontal then minimumWindowDimension = screenFrame.h / 4 end

    if amount == 1 then amount = minimumWindowDimension end
    if amount == -1 then amount = -1 * minimumWindowDimension end
    if amount == 0 then amount = 0 end

    return amount
end

function resizeWindowByAmount (window, amount)
    local newWindowFrame = window:frame()

    local amountW = amountToResizeForWindow(window, amount.w, true)
    local amountH = amountToResizeForWindow(window, amount.h, false)

    newWindowFrame.w = newWindowFrame.w + amountW
    newWindowFrame.h = newWindowFrame.h + amountH

    newWindowFrame = sanitizeWindowFrame(window, newWindowFrame)

    window:setFrame(newWindowFrame)
end

function resizeForegroundWindowByAmount (amount)
    local window = hs.window.focusedWindow()
    if window == nil then return end
    resizeWindowByAmount(window, amount)
end

-- function moveWindowToDisplay(d)
--   return function()
--     local displays = hs.screen.allScreens()
--     local win = hs.window.focusedWindow()
--     win:moveToScreen(displays[d], false, true)
--   end
-- end

-- hs.hotkey.bind({"ctrl", "alt", "cmd"}, "1", moveWindowToDisplay(1))
-- hs.hotkey.bind({"ctrl", "alt", "cmd"}, "2", moveWindowToDisplay(2))

-- }}}
-- Window Movement Keys {{{

-- Bind hyper-H to move window to the left
hs.hotkey.bind(hyperKeyDef, "h", function()
    moveForegroundWindowInDirection(hs.geometry.size(-1,0))
end)

-- Bind hyper-L to move window to the right

hs.hotkey.bind(hyperKeyDef, "l", function()
    moveForegroundWindowInDirection(hs.geometry.size(1,0))
end)

-- Bind hyper-K to move window up

hs.hotkey.bind(hyperKeyDef, "k", function()
    moveForegroundWindowInDirection(hs.geometry.size(0,-1))
end)

-- Bind hyper-J to move window down

hs.hotkey.bind(hyperKeyDef, "j", function()
    moveForegroundWindowInDirection(hs.geometry.size(0,1))
end)

-- Bind hyper-T to move window to the "next" screen

hs.hotkey.bind(hyperKeyDef, "t", function()
    local win = hs.window.focusedWindow()
    local windowScreen = win:screen()
    
    local newWindowScreen = windowScreen:next()
    win:moveToScreen(newWindowScreen)
end)

-- }}}
-- Window Resizing Keys {{{

-- Bind hyper-Y to resize window width smaller

hs.hotkey.bind(hyperKeyDef, "Y", function()
    resizeForegroundWindowByAmount(hs.geometry.size(-1, 0))
end)

-- Bind hyper-O to resize window width larger

hs.hotkey.bind(hyperKeyDef, "O", function()
    resizeForegroundWindowByAmount(hs.geometry.size(1, 0))
end)

-- Bind hyper-I to resize window height larger

hs.hotkey.bind(hyperKeyDef, "I", function()
    resizeForegroundWindowByAmount(hs.geometry.size(0, 1))
end)

-- Bind hyper-U to resize window height smaller

hs.hotkey.bind(hyperKeyDef, "U", function()
    resizeForegroundWindowByAmount(hs.geometry.size(0, -1))
end)

-- }}}
profileStop('windowCommands')
profileStart('noises')
-- Noises {{{
-- Just playing for now with this config:
-- https://github.com/trishume/dotfiles/blob/master/hammerspoon/hammerspoon.symlink/init.lua
-- sssss to scroll down the whole time you are making the sound
-- POP with your lips to scroll down a little at a time with each POP
listener = nil
popclickListening = false
local scrollDownTimer = nil
function popclickHandler(evNum)
  if evNum == 1 then
    scrollDownTimer = hs.timer.doEvery(0.02, function()
      hs.eventtap.scrollWheel({0,-10},{}, "pixel")
      end)
  elseif evNum == 2 then
    if scrollDownTimer then
      scrollDownTimer:stop()
      scrollDownTimer = nil
    end
  elseif evNum == 3 then
    hs.eventtap.scrollWheel({0,250},{}, "pixel")
  end
end

function popclickPlayPause()
  if not popclickListening then
    listener:start()
    hs.alert.show("listening")
  else
    listener:stop()
    hs.alert.show("stopped listening")
  end
  popclickListening = not popclickListening
end
popclickListening = false
local fn = popclickHandler
listener = hs.noises.new(fn)
-- "s" for listening
hs.hotkey.bind(hyperKeyDef, "s", function()
    popclickPlayPause()
end)
-- }}}
profileStop('noises')
profileStart('screenChanges')
-- {{{ Screen Changes
--- Watch screen change notifications, and reload certain components when the
--screen configuration changes

function handleScreenEvent()
    updateGridsForScreens()
    -- updateFluxiness()
end

-- screenWatcher = hs.screen.watcher.new(handleScreenEvent)
-- screenWatcher:start()

function moveToNextScreen()
  local app = hs.window.focusedWindow()
  app:moveToScreen(app:screen():next())
  hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
end

hs.hotkey.bind({"ctrl", "alt"}, "n", moveToNextScreen)

-- }}}

-- {{{ global mute for zoom and teams
-- Mute Button
-- local muteButton = hs.menubar.new()
-- muteButton:setTitle("Mute Toggle")

function _check(tbl)
  local check = hs.application.get("zoom.us")
  if (check ~= nil) then
    return check:findMenuItem(tbl) ~= nil
  end
end

function getAudioStatus()
  if _check({"Meeting", "Unmute Audio"}) then
    return 'muted'
  elseif _check({"Meeting", "Mute Audio"}) then
    return 'unmuted'
  else
    return 'off'
  end
end

function toggleMute() 
  local teams = hs.application.find("Microsoft Teams")
  if not (teams == null) then
    hs.eventtap.keyStroke({"cmd","shift"}, "m", 0, teams)
  end
  
  -- While we're at it, also support zoom
  local zoom = hs.application.find("us.zoom.xos")
   if not (zoom == nil) then
    hs.eventtap.keyStroke({"cmd","shift"}, "a", 0, zoom)
    if getAudioStatus() == 'unmuted'  then
        audioStatus = 'unmuted'
    elseif getAudioStatus() == 'muted' then
        audioStatus = 'muted'
    end
    updateZoomStatus(audioStatus)
  end
end

-- muteButton:setClickCallback(toggleMute)

-- Edit here, if you want other modifiers or a different hotkey:
-- Example: local modifiers = {"cmd", "alt", "ctrl", "shift"}
--          hs.hotkey.bind(modifiers, "a", toggleMute)

hs.hotkey.bind('', "f12", toggleMute)

updateZoomStatus = function(event)
  hs.printf("updateZoomStatus(%s)", event)
  if (event == "from-running-to-meeting") then
    zoomStatusMenuBarItem:returnToMenuBar()
  elseif (event == "muted") then
    zoomStatusMenuBarItem:setTitle("🔴")
  elseif (event == "unmuted") then
    zoomStatusMenuBarItem:setTitle("🟢")
  elseif (event == "from-meeting-to-running") or (event == "from-running-to-closed") then
    zoomStatusMenuBarItem:removeFromMenuBar()
  end
end

-- Teams Show Button
-- local teamsShowButton = hs.menubar.new()
-- local logo = hs.image.imageFromAppBundle("com.microsoft.teams")
-- logo:size({w=16,h=16})
-- teamsShowButton:setIcon(logo)

-- function showTeams() 
--   local teams = hs.application.find("com.microsoft.teams")
--   if not (teams == null) then
--     teams:activate()
--   end
-- end

-- teamsShowButton:setClickCallback(showTeams)
-- }}}

profileStop('screenChanges')
-- profileStart('caffeinate')
-- -- {{{ Caffeinate

-- function caffeinateCallback(eventType)
--     if (eventType == hs.caffeinate.watcher.screensDidSleep) then
--     elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
--         fluxSignificantTimeDidChange()
--     -- elseif (eventType == hs.caffeinate.watcher.screensDidLock) then
--     --     streamdeck_sleep()
--     -- elseif (eventType == hs.caffeinate.watcher.screensDidUnlock) then
--     --     streamdeck_wake()
--     end
-- end

-- caffeinateWatcher = hs.caffeinate.watcher.new(caffeinateCallback)
-- caffeinateWatcher:start()
-- -- }}}
-- profileStop('caffeinate')
-- profileStart('pasteboard')
-- -- {{{ Pasteboard
-- pasteboardWatcher = hs.pasteboard.watcher.new(function(contents)
--     replacePasteboardLinkIfNecessary(contents)
-- end)
-- -- }}}
-- profileStop('pasteboard')

-- {{ Bootstrapping

-- Flux setup {{{
-- updateFluxiness()
-- }}}

hs.alert.show("Hammerspoon, at your service.")

profileStop('configTotal')


gokuWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.config/karabiner.edn/', function ()
    output = hs.execute('/opt/homebrew/bin/goku')
    hs.notify.new({title = 'Karabiner Config', informativeText = output}):send()
end):start()
 
hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()
hs.notify.new({title = 'Hammerspoon', informativeText = 'Config loaded'}):send()

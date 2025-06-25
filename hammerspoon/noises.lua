profileStart('noises') -- Start profiling the "noises" section

-- Noises {{{
-- This section configures pop-click-based scrolling and interaction
-- Inspired by: https://github.com/trishume/dotfiles/blob/master/hammerspoon/hammerspoon.symlink/init.lua
-- 
-- Functionality:
-- - Making a sustained "ssssss" sound will continuously scroll down.
-- - Making a "POP" sound with lips will scroll down in small increments.

local popclick = require "hs.noises"


-- Creates a new scroller object with a given delay and tick value (scroll speed)
function newScroller(delay, tick)
  return { delay = delay, tick = tick, timer = nil }
end

-- Starts automatic scrolling using the given scroller
function startScroll(scroller)
  if scroller.timer == nil then
    scroller.timer = timer.doEvery(scroller.delay, function()
      eventtap.scrollWheel({0,scroller.tick}, {}, "pixel") -- Scrolls vertically
    end)
  end
end

-- Stops the scrolling associated with the given scroller
function stopScroll(scroller)
  if scroller.timer then
    scroller.timer:stop()
    scroller.timer = nil
  end
end

-- Noise listener variables
listener = nil
popclickListening = false
local tssScrollDown = newScroller(0.02, -10) -- Defines a scroller that scrolls down rapidly

-- Handles noise events
-- evNum = 1 -> Continuous "ssssss" noise (start scrolling)
-- evNum = 2 -> Silence (stop scrolling)
-- evNum = 3 -> "POP" noise (scroll down incrementally or perform app-specific action)
function scrollHandler(evNum)
  -- alert.show(tostring(evNum)) -- Uncomment for debugging
  if evNum == 1 then
    startScroll(tssScrollDown) -- Start continuous scrolling
  elseif evNum == 2 then
    stopScroll(tssScrollDown) -- Stop scrolling
  elseif evNum == 3 then
    -- If the frontmost app is "ReadKit", simulate pressing "j" (next item)
    if application.frontmostApplication():name() == "ReadKit" then
      eventtap.keyStroke({}, "j")
    else
      eventtap.scrollWheel({0, 250}, {}, "pixel") -- Scroll down a bit
    end
  end
end

-- Toggles the noise listener for pop-click detection
function popclickPlayPause()
  if not popclickListening then
    listener:start()
    hs.alert.show("listening") -- Show an alert that listening has started
  else
    listener:stop()
    hs.alert.show("stopped listening") -- Show an alert that listening has stopped
  end
  popclickListening = not popclickListening -- Toggle the listening state
end

-- Bind the "s" key (with hyper key) to toggle noise-based scrolling
-- hs.hotkey.bind(hyperKeyDef, "s", function()
--     popclickPlayPause() -- Start/Stop noise detection
-- end)
-- !! See hotkeys.lua to set the hotkey for this

-- Initializes the pop-click noise detection
function popclickInit()
  popclickListening = false
  local fn = scrollHandler -- Set scrollHandler as the noise event handler
  listener = popclick.new(fn) -- Create a new pop-click listener
end
-- }}}

profileStop('noises') -- Stop profiling the "noises" section
profileStart('muteToggle') -- Start profiling the "muteToggle" section

-- {{{ global mute for zoom and teams
-- Mute Button
-- local muteButton = hs.menubar.new()
-- muteButton:setTitle("Mute Toggle")

-- zoom status bar update
zoomStatusMenuBarItem = hs.menubar.new(true)
zoomStatusMenuBarItem:setClickCallback(function()
    toggleMute()
end)

-- Helper function to check if a Zoom menu item exists
function _check(tbl)
  local zoom = hs.application.get("zoom.us")
  return zoom and zoom:findMenuItem(tbl) ~= nil
end

-- Get Zoom's current audio status
function getAudioStatus()
  if _check({"Meeting", "Unmute Audio"}) then
    return 'muted'
  elseif _check({"Meeting", "Mute Audio"}) then
    return 'unmuted'
  else
    return 'off'
  end
end

-- Toggle Mute in Teams, Zoom, and Slack
function toggleMute() 
  local apps = {
    {name = "Microsoft Teams", bundle = "com.microsoft.teams", keys = {"cmd", "shift"}, key = "m"},
    {name = "Zoom", bundle = "us.zoom.xos", keys = {"cmd", "shift"}, key = "a"},
    {name = "Slack", bundle = "com.tinyspeck.slackmacgap", keys = {"cmd", "shift"}, key = "space"}
  }

  for _, app in ipairs(apps) do
    -- local appInstance = hs.application.find(app.bundle)
    local appInstance = hs.application.get(app.name)
    if appInstance then
      hs.eventtap.keyStroke(app.keys, app.key, 0, appInstance)

      -- Special handling for Zoom
      if app.name == "Zoom" then
        local audioStatus = getAudioStatus()
        if audioStatus == 'unmuted' or audioStatus == 'muted' then
          updateZoomStatus(audioStatus)
        end
      end
    end
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

profileStop('muteToggle') -- Stop profiling the "muteToggle" section

-- }}}

-- {{{ global mute for zoom and teams
-- Mute Button
local muteButton = hs.menubar.new(true)
muteButton:setTitle("Mute Toggle")

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

muteButton:setClickCallback(toggleMute)

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
--[[

 Known issues:
 * Mute is not detected properly during a Zoom Webinar

]]

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Unofficial Zoom/Teams Spoon"
obj.version = "1.0"
obj.author = "Collin LeGault"
obj.license = "MIT"
obj.homepage = ""

obj.callbackFunction = nil

function unpack (t, i)
  i = i or 1
  if t[i] ~= nil then
    return t[i], unpack(t, i + 1)
  end
end

-- via: https://github.com/kyleconroy/lua-state-machine/
local machine = dofile(hs.spoons.resourcePath("statemachine.lua"))

watcher = nil

ZoomAudioStatus = 'off'
ZoomVideoStatus = 'off'
TeamsAudioStatus = 'off'
TeamsVideoStatus = 'off'

zoomState = machine.create({
  initial = 'closed',
  events = {
    { name = 'start',        from = 'closed',  to = 'running' },
    { name = 'startMeeting', from = 'running', to = 'meeting' },
    { name = 'startShare',   from = 'meeting', to = 'sharing' },
    { name = 'endShare',     from = 'sharing', to = 'meeting' },
    { name = 'endMeeting',   from = 'meeting', to = 'running' },
    { name = 'stop',         from = 'running', to = 'closed' },
  },
  callbacks = {
    onstatechange = function(self, event, from, to)
      changeName = "from-" .. from .. "-to-" .. to

      if changeName == "from-running-to-meeting" then
        ZoomAudioStatus = obj:zgetAudioStatus()
        ZoomVideoStatus = obj:zgetVideoStatus()
        obj:_zchange(ZoomAudioStatus)
        obj:_zchange(ZoomVideoStatus)
      elseif changeName == "from-meeting-to-running" then
        ZoomAudioStatus = 'off'
        ZoomVideoStatus = 'off'
      end
      obj:_zchange(changeName)
    end,
  }
})

teamsState = machine.create({
  initial = 'closed',
  events = {
    { name = 'start',        from = 'closed',  to = 'running' },
    { name = 'startMeeting', from = 'running', to = 'meeting' },
    { name = 'startShare',   from = 'meeting', to = 'sharing' },
    { name = 'endShare',     from = 'sharing', to = 'meeting' },
    { name = 'endMeeting',   from = 'meeting', to = 'running' },
    { name = 'stop',         from = 'running', to = 'closed' },
  },
  callbacks = {
    onstatechange = function(self, event, from, to)
      changeName = "from-" .. from .. "-to-" .. to

      if changeName == "from-running-to-meeting" then
        TeamsAudioStatus = obj:tgetAudioStatus()
        TeamsVideoStatus = obj:tgetVideoStatus()
        obj:_change(TeamsAudioStatus)
        obj:_change(TeamsVideoStatus)
      elseif changeName == "from-meeting-to-running" then
        TeamsAudioStatus = 'off'
        TeamsVideoStatus = 'off'
      end
      obj:_change(changeName)
    end,
  }
})

local endMeetingDebouncer = hs.timer.delayed.new(0.2, function()
  -- Only end the meeting if the "Meeting" menu is no longer present
  if not _check({"Meeting", "Invite"}) then
    zoomState:endMeeting()
  end
end)

zoomAppWatcher = hs.application.watcher.new(function (appName, eventType, appObject)
  if (appName == "zoom.us" and eventType == hs.application.watcher.launched) then
    zoomState:start()

    watcher = appObject:newWatcher(function (element, event, watcher, userData)
      local eventName = tostring(event)
      local windowTitle = ""
      if element['title'] ~= nil then
        windowTitle = element:title()
      end

      if(eventName == "AXTitleChanged" and windowTitle == "Zoom Meeting") then
        zoomState:startMeeting()
      elseif(eventName == "AXTitleChanged" and windowTitle == "Zoom Webinar") then
        zoomState:startMeeting()
      elseif(eventName == "AXWindowCreated" and windowTitle == "Zoom Meeting") then
        zoomState:endShare()
      elseif(eventName == "AXWindowCreated" and windowTitle == "Zoom Webinar") then
        zoomState:startMeeting()
      elseif(eventName == "AXWindowCreated" and windowTitle == "Zoom") then
        zoomState:start()
      elseif(eventName == "AXWindowCreated" and windowTitle:sub(1, #"zoom share") == "zoom share") then
        zoomState:startShare()
      elseif(eventName == "AXUIElementDestroyed") then
        endMeetingDebouncer:start()
      end
    end, { name = "zoom.us" })
    watcher:start({hs.uielement.watcher.windowCreated, hs.uielement.watcher.titleChanged, hs.uielement.watcher.elementDestroyed})
  elseif (eventType == hs.application.watcher.terminated) then
    if (watcher ~= nil) then
      watcher:stop()
      if zoomState:is('meeting') then endMeetingDebouncer:start() end
      zoomState:stop()
      watcher = nil
    end
  end
end)

teamsAppWatcher = hs.application.watcher.new(function (appName, eventType, appObject)
  if (appName == "Microsoft Teams" and eventType == hs.application.watcher.launched) then
    teamsState:start()

    watcher = appObject:newWatcher(function (element, event, watcher, userData)
      local eventName = tostring(event)
      local windowTitle = ""
      if element['title'] ~= nil then
        windowTitle = element:title()
      end

      if(eventName == "AXTitleChanged" and string.find(windowTitle, "Meeting with ")) then
        teamsState:startMeeting()
      elseif(eventName == "AXWindowCreated" and string.find(windowTitle, "Meeting with")) then
        teamsState:startMeeting()
      elseif(eventName == "AXWindowCreated" and string.find(windowTitle, "| Microsoft Teams")) then
        teamsState:start()
      elseif(eventName == "AXUIElementDestroyed") then
        endMeetingDebouncer:start()
      end
    end, { name = "Microsoft Teams" })
    watcher:start({hs.uielement.watcher.windowCreated, hs.uielement.watcher.titleChanged, hs.uielement.watcher.elementDestroyed})
  elseif (eventType == hs.application.watcher.terminated) then
    if (watcher ~= nil) then
      watcher:stop()
      if teamsState:is('meeting') then endMeetingDebouncer:start() end
      teamsState:stop()
      watcher = nil
    end
  end
end)

function obj:start()
  zoomAppWatcher:start()
  teamsAppWatcher:start()
end

function obj:stop()
  zoomAppWatcher:stop()
  teamsAppWatcher:stop()
end

function _zcheck(tbl)
  local zcheck = hs.application.get("zoom.us")
  if (zcheck ~= nil) then
    return check:findMenuItem(tbl) ~= nil
  end
end

function _tcheck(tbl)
  local tcheck = hs.application.get("Microsoft Teams")
  if (tcheck ~= nil) then
    return check:findMenuItem(tbl) ~= nil
  end
end

function obj:_zclick(tbl)
  click = hs.application.get("zoom.us")
  if (click ~= nil) then
    return click:selectMenuItem(tbl)
  end
end

function obj:_tclick(tbl)
  click = hs.application.get("Microsoft Teams")
  if (click ~= nil) then
    return click:selectMenuItem(tbl)
  end
end

function obj:_zchange(changeEvent)
  if (self.callbackFunction) then
    self.callbackFunction(changeEvent)
  end
end

function obj:_tchange(changeEvent)
  if (self.callbackFunction) then
    self.callbackFunction(changeEvent)
  end
end

function obj:zgetAudioStatus()
  if _zcheck({"Meeting", "Unmute Audio"}) then
    return 'muted'
  elseif _zcheck({"Meeting", "Mute Audio"}) then
    return 'unmuted'
  else
    return 'off'
  end
end

function obj:zgetVideoStatus()
  if _zcheck({"Meeting", "Start Video"}) then
    return 'videoStopped'
  elseif _zcheck({"Meeting", "Stop Video"}) then
    return 'videoStarted'
  else
    return 'off'
  end
end

--- Zoom:toggleMute()
--- Method
--- Toggles between the 'muted' and 'unmuted states'
function obj:ztoggleMute()
  if ZoomAudioStatus ~= obj:zgetAudioStatus() then
    ZoomAudioStatus = obj:zgetAudioStatus()
    self:_zchange(ZoomAudioStatus)
  end
  if ZoomAudioStatus == 'muted' then
    self:zunmute()
  end
  if ZoomAudioStatus == 'unmuted' then
    self:zmute()
  else
    return nil
  end
end

--- Zoom:ttoggleMute()
--- Method
--- Toggles between the 'muted' and 'unmuted states'
function obj:ttoggleMute()
  if not TeamsAudioStatus then
    TeamsAudioStatus = obj:tgetAudioStatus()
    self:_tchange(TeamsAudioStatus)
  end
  if TeamsAudioStatus == 'muted' then
    self:tunmute()
  end
  if TeamsAudioStatus == 'unmuted' then
    self:tmute()
  else
    return nil
  end
end

--- Zoom:toggleVideo()
--- Method
--- Toggles between the 'videoStarted' and 'videoStopped states'
function obj:ztoggleVideo()
  if ZoomVideoStatus ~= obj:zgetVideoStatus() then
    ZoomVideoStatus = obj:zgetVideoStatus()
    self:_zchange(ZoomVideoStatus)
  end
  if ZoomVideoStatus == 'videoStopped' then
    self:zstartVideo()
  end
  if ZoomVideoStatus == 'videoStarted' then
    self:zstopVideo()
  else
    return nil
  end
end

--- Zoom:zmute()
--- Method
--- Mutes the audio in Zoom, if Zoom is currently unmuted
function obj:zmute()
  if obj:zgetAudioStatus() == 'unmuted' and self:_zclick({"Meeting", "Mute Audio"}) then
    ZoomAudioStatus = 'muted'
    self:_zchange("muted")
  end
end

--- Zoom:tmute()
--- Method
--- Mutes the audio in Teams, if Teams is currently unmuted
function obj:tmute()
  if obj:tgetAudioStatus() == 'unmuted' then
    local teams = hs.application.find("Microsoft Teams")
    hs.eventtap.keyStroke({"cmd","shift"}, "m", 0, teams)
    TeamsAudioStatus = 'muted'
    self:_tchange("muted")
  end
end

--- Zoom:zunmute()
--- Method
--- Unmutes the audio in Zoom, if Zoom is currently muted
function obj:zunmute()
  if obj:zgetAudioStatus() == 'muted' and self:_zclick({"Meeting", "Unmute Audio"}) then
    ZoomAudioStatus = 'unmuted'
    self:_zchange("unmuted")
  end
end

--- Zoom:tunmute()
--- Method
--- Unmutes the audio in Teams, if Teams is currently muted
function obj:tunmute()
  if obj:tgetAudioStatus() == 'muted'  then
    local teams = hs.application.find("Microsoft Teams")
    hs.eventtap.keyStroke({"cmd","shift"}, "m", 0, teams)
    TeamsAudioStatus = 'unmuted'
    self:_tchange("unmuted")
  end
end

--- Zoom:zstopVideo()
--- Method
--- Stops the video in Zoom, if Zoom is currently streaming video
function obj:zstopVideo()
  if obj:zgetVideoStatus() == 'videoStarted' and self:_zclick({"Meeting", "Stop Video"}) then
    ZoomVideoStatus = 'videoStopped'
    self:_zchange("videoStopped")
  end
end

--- Zoom:tstopVideo()
--- Method
--- Stops the video in Teams, if Teams is currently streaming video
function obj:tstopVideo()
  if obj:tgetVideoStatus() == 'videoStarted'  then
    local teams = hs.application.find("Microsoft Teams")
    hs.eventtap.keyStroke({"cmd","shift"}, "o", 0, teams)
    TeamsVideoStatus = 'videoStopped'
    self:_tchange("videoStopped")
  end
end

--- Zoom:zstartVideo()
--- Method
--- Starts the video in Zoom, if Zoom is currently not streaming video
function obj:zstartVideo()
  if obj:zgetVideoStatus() == 'videoStopped' and self:_zclick({"Meeting", "Start Video"}) then
    ZoomVideoStatus = 'videoStarted'
    self:_zchange("videoStarted")
  end
end

--- Zoom:tstartVideo()
--- Method
--- Starts the video in Teams, if Teams is currently not streaming video
function obj:tstartVideo()
  if obj:tgetVideoStatus() == 'videoStopped'  then
    local teams = hs.application.find("Microsoft Teams")
    hs.eventtap.keyStroke({"cmd","shift"}, "o", 0, teams)
    TeamsVideoStatus = 'videoStarted'
    self:_tchange("videoStarted")
  end
end

function obj:zinMeeting()
  return zoomState:is('meeting') or zoomState:is('sharing')
end


--- Zoom:setStatusCallback(func)
--- Method
--- Registers a function to be called whenever Zoom's state changes
---
--- Parameters:
--- * func - A function in the form "function(event)" where "event" is a string describing the state change event
function obj:setStatusCallback(func)
  self.callbackFunction = func
end

return obj

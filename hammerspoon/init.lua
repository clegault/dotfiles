-- clegault's Hammerspoon config file

-- Clear the console
hs.console.clearConsole()

-- Start profiling
require("profile")

hs.alert.show("hammerspoon starting...")

profileStart('configTotal')
profileStart('imports')

require("hs.ipc")
hs.ipc.cliInstall()

require "hotkeys-new"
require "brightness_control"
require "darkmode"
require "windowManager"
require "choose"
require "emoji"
require "util"
require "notify"
require "noises"
require "muteToggle"
require "splitview"
require "work"
-- This is kept in case I want to use hammerspoon for controlling lights
-- require "ElgatoKeyControll"
-- This is kept as an example for how to write a server rest api to hammerspoon
-- require "server"
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

hs.window.animationDuration = 0.0
-- }}}

profileStop('globals')

-- Initialize popclick srolling {{{
popclickInit()
-- }}}

-- function to enable/disable profiling for logging {{{
-- 
function toggleProfiling()
    profileEnabled = not profileEnabled
    hs.alert.show("Profiling " .. (profileEnabled and "Enabled" or "Disabled"))
end
-- }}}

hs.alert.show("Hammerspoon, at your service.")

profileStop('configTotal')

-- Start watching for karabiner configuration changes and reload it if it does {{{
gokuWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.config/karabiner.edn/', function ()
    output = hs.execute('/opt/homebrew/bin/goku')
    hs.notify.new({title = 'Karabiner Config', informativeText = output}):send()
end):start()
 -- }}}

 -- Watch for configuration changes and auto reload
hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()
hs.notify.new({title = 'Hammerspoon', informativeText = 'Config loaded'}):send()

-- Listen for startWork event via urlevent
hs.urlevent.bind("startWork", function(eventName, params)
    startWork()
end)

config = {}
config.applications = {
    ['Arc'] = {
        bundleID = 'company.thebrowser.Browser',
        hyper_key = 'l',
    },
    ['RayCast'] = {
        bundleID = 'com.raycast.macos',
        hyper_key = 'i',
        local_bindings = {'i'}
    },
}
hyper = require('hyper')
hyper.start(config)

-- Random bindings
hyper:bind({}, 'r', nil, function() hs.console.hswindow():focus() end)
hyper:bind({'shift'}, 'r', nil, function() hs.reload() end)
hyper:bind({}, 'b', nil, function()
--   local ok, output = airpods.toggle('Evan's AirPods')
--   if ok then
--     hs.alert.show(output)
--   else
--     hs.alert.show("Couldn't connect to AirPods!")
--   end
    hs.alert.show("Couldn't connect to AirPods!")
end)
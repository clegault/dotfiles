    wm = require('window-management')

    local bundles = {
        [1] = 'com.hnc.Discord',
        [2] = 'com.tinyspeck.slackmacgap',
        [3] = 'com.vivaldi.Vivaldi',
        [4] = 'net.kovidgoyal.kitty',
        [5] = 'com.apple.MobileSMS',
        [6] = 'com.apple.iCal',
        [7] = 'com.culturedcode.ThingsMac',
        [8] = 'com.apple.Music',
        [9] = 'us.zoom.xos',
        [10] = 'com.microsoft.teams',
        [11] = 'com.tinyspeck.slackmacgap',
        [12] = 'barrier'
    }

function values(t)
  local i = 0
  return function() i = i + 1; return t[i] end
end

function startWork()
    for bundleID in values(bundles) do
        dbg(bundleID)
        local app = hs.application.get(bundleID)
        if app == nil then
            hs.application.open(bundleID)
        else
            hs.application.open(bundleID)
            app:activate()
        end
      time=os.time()
      wait=5
      newtime=time+wait
      while (time<newtime)
      do
        time=os.time()
      end
    end
end

function stopWork()
    for bundleID in values(bundles) do
        dbg('Killing:')
        dbg(bundleID)
        hs.application.get(bundleID):kill()
    end
end

startWorkButton = {
    ['name'] = 'Start Work',
    ['image'] = streamdeck_imageFromText('􀜕'),
    ['onClick'] = function()
        startWork()
    end
}

stopWorkButton = {
    ['name'] = 'Stop Work',
    ['image'] = streamdeck_imageFromText('􀜗'),
    ['onClick'] = function()
        stopWork()
    end
}

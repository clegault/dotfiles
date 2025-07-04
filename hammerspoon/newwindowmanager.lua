spaces = require("hs._asm.undocumented.spaces")
wf=hs.window.filter
eventtap=hs.eventtap
timer=hs.timer
internal = require('hs._asm.undocumented.spaces.internal')

spaceIds = {}
maxScreens = 6
sleep_interval = 1

logger = hs.logger.new('windowManager')

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

function setSpaces()
  -- Set spaces
  currentSpace = spaces.activeSpace()
  currentSpaceHotkey = 0
  logger.d('Finding spaces')

  for i=1,maxScreens do
    eventtap.keyStroke("ctrl", tostring(i))
    while spaces.isAnimating() do
      sleep(1)
    end
    timer.usleep(1)
    spaceIds[i] = spaces.activeSpace()
    logger.d('Space '.. i .. ' has id '.. spaceIds[i])
    if (spaces.activeSpace() == currentSpace) then
      currentSpaceHotkey = i
    end
  end

  eventtap.keyStroke("ctrl", tostring(currentSpaceHotkey))
end

function positionApp(appTitle, screen, space)
    logger.d('Positioning ' .. appTitle)
    if (hs.application.get(appTitle) == nil) then
        logger.e('Application ' .. appTitle .. ' not found')
        return
    end

    hs.application.get(appTitle):activate()
    windows = wf.new(appTitle):setCurrentSpace(nil):getWindows()
    if (#windows == 0) then
        logger.w('No windows found for '.. appTitle)
    end
    for k,v in pairs(windows) do
        if (#internal.windowsOnSpaces(v:id()) <= 1) then
            logger.w('Positioning window '..v:id().. ' of app '..appTitle)
            v:moveToScreen(screen)
            spaces.moveWindowToSpace(v:id(), space)
            v:maximize()
            sleep(sleep_interval)
        end
    end
end

function officeMobile()
    -- Window Layout, Office mobile
    setSpaces()

    -- Get screens

    for k,v in pairs(hs.screen.allScreens()) do
        x, y = v:position()

        screen = v
    end

    positionApp('Google Chrome', screen, spaceIds[1])
    positionApp('Fantastical', screen, spaceIds[1])
    positionApp('Mail', screen, spaceIds[1])

    positionApp('iTerm2', screen, spaceIds[2])

    positionApp('IntelliJ IDEA', screen, spaceIds[3])

    positionApp('Microsoft Teams', screen, spaceIds[4])

end

function office()
    -- Window Layout, Office stationary
    setSpaces()

    -- Get screens

    for k,v in pairs(hs.screen.allScreens()) do
        x, y = v:position()

        if x == 0 then
            leftScreen = v
        elseif x == 1 then
            rightScreen = v
        end
    end

    positionApp('Google Chrome', leftScreen, spaceIds[1])
    positionApp('Fantastical', rightScreen, spaceIds[1])
    positionApp('Mail', rightScreen, spaceIds[1])

    positionApp('iTerm2', leftScreen, spaceIds[2])

    positionApp('IntelliJ IDEA', leftScreen, spaceIds[3])

    positionApp('Microsoft Teams', leftScreen, spaceIds[4])

end

menubar = hs.menubar.new()
menubar:setIcon(hs.image.imageFromName("NSHandCursor"))

if menubar then
    menubar:setMenu({
        { title = "Office", fn = office },
        { title = "Office Mobile", fn = officeMobile },
    })
end
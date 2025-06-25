-- This function takes a config object and sets up apps in split view
function launchAppSplitView(config, onComplete)
    local app1Name     = config.app1Name
    local app2Name     = config.app2Name
    local side         = config.side or "left"
    local screenNumber = config.screenNumber or 1
    local maxWaitTime = 15        -- seconds
    local electronAppDelay = 2.0 -- Delay for Electron apps or slow starters

    local screens = hs.screen.allScreens()
    if #screens < screenNumber then screenNumber = 1 end
    local targetScreen = screens[screenNumber]

    local pollTimer         = nil
    local startEpoch        = nil
    local focusCheckTimer   = nil

    -- We need a way to track if we've already done the initial delay for an app
    local appReadyState = {} -- Stores the state for each app being polled

    local function isReady(bundleID)
        local app = hs.application.get(bundleID)

        -- 1. Check if the app object exists
        if not app then
            return false
        end

        -- Initialize state for this app if not already
        if not appReadyState[bundleID] then
            appReadyState[bundleID] = {
                initialDelayDone = false,
                delayStartTime = hs.timer.secondsSinceEpoch()
            }
        end

        -- 2. Apply initial delay if not done
        if not appReadyState[bundleID].initialDelayDone then
            local elapsed = hs.timer.secondsSinceEpoch() - appReadyState[bundleID].delayStartTime
            if elapsed < electronAppDelay then
                -- print("Applying initial delay for " .. bundleID .. ": " .. string.format("%.2f", elapsed) .. "s")
                return false -- Keep polling until delay is over
            else
                print("Initial " .. electronAppDelay .. "s delay completed for " .. bundleID)
                appReadyState[bundleID].initialDelayDone = true
            end
        end

        -- 3. Now that the app exists and initial delay is done, proceed with window checks
        -- (app and app:mainWindow() and app:getMenuItems()) are essential checks
        if not (app:mainWindow() and app:getMenuItems()) then
            return false
        end
        local win = app:mainWindow() or app:focusedWindow()
        if not win then return false end

        -- Ensure app is not full screen and is on the target screen
        if win:isFullScreen() then
            print("Detected full screen for " .. bundleID .. ". Exiting full screen.")
            win:setFullScreen(false)
            return false -- Re-evaluate after un-full-screening
        end
        if win:screen():id() ~= targetScreen:id() then
            print("Moving " .. bundleID .. " to target screen.")
            win:moveToScreen(targetScreen)
            return false -- Re-evaluate after moving
        end

        return true
    end

    local function launchAndPoll(bundleID, nextStepCallback)
        startEpoch = hs.timer.secondsSinceEpoch()

        -- Reset appReadyState for this bundleID when starting a new poll sequence
        appReadyState[bundleID] = nil

        if not hs.application.get(bundleID) then
            print("Launching " .. bundleID .. "...")
            hs.application.launchOrFocusByBundleID(bundleID)
        else
            print(bundleID .. " is already running. Checking if it's ready...")
        end

        pollTimer = hs.timer.doEvery(0.25, function()
            if isReady(bundleID) then
                print(bundleID .. " is ready. Stopping poll.")
                pollTimer:stop()
                if nextStepCallback then nextStepCallback() end
            elseif hs.timer.secondsSinceEpoch() - startEpoch > maxWaitTime then
                print("Timeout launching " .. bundleID .. ". Stopping poll.")
                pollTimer:stop()
                hs.alert.show("[splitView] timeout launching " .. bundleID)
                if onComplete then onComplete() end
            else
                -- print("Waiting for " .. bundleID .. " to become ready...")
            end
        end)
    end

    local function finalizeSplitView()
        print("Both apps are ready. Proceeding with split view layout.")

        local app1 = hs.application.get(app1Name)
        if not app1 then
            print("Error: app1 (" .. app1Name .. ") not found for split view.")
            if onComplete then onComplete() end
            return
        end

        print("Activating " .. app1Name)
        app1:activate()

        focusCheckTimer = hs.timer.doEvery(0.1, function()
            if app1:isFrontmost() then
                focusCheckTimer:stop()
                print(app1Name .. " is now frontmost. Sending split view command.")

                hs.eventtap.keyStroke({"ctrl","cmd"}, side)

                hs.timer.doAfter(1.5, function()
                    print("Attempting to click center of " .. app2Name .. " window.")
                    local success = clickWindowCenter(app2Name)
                    if not success then
                        print("Warning: Failed to click center of " .. app2Name)
                    end
                    if onComplete then onComplete() end
                end)
            end
        end)

        hs.timer.doAfter(5.0, function()
            if focusCheckTimer and focusCheckTimer.running then
                focusCheckTimer:stop()
                print("Warning: Timeout waiting for " .. app1Name .. " to become frontmost.")
                if onComplete then onComplete() end
            end
        end)
    end

    launchAndPoll(app1Name, function()
        launchAndPoll(app2Name, finalizeSplitView)
    end)
end

function clickWindowCenter(appName)
    local app = hs.application.get(appName)
    if not app then
        hs.alert.show("App not found: " .. appName)
        return false
    end
    local win = app:focusedWindow() or app:mainWindow()
    if not win then
        hs.alert.show("No active window for: " .. appName)
        return false
    end
    local frame = win:frame()
    local centerPoint = {
        x = frame.x + (frame.w / 2),
        y = frame.y + (frame.h / 2)
    }
    local originalMousePos = hs.mouse.absolutePosition()
    hs.mouse.absolutePosition(centerPoint)
    hs.eventtap.leftClick(centerPoint)
    hs.mouse.absolutePosition(originalMousePos)
    return true
end

-- -- Function to click the center of a window for an app
-- function clickWindowCenter(appName)
--     -- Find the application
--     local app = hs.application.get(appName)
--     if not app then
--         hs.alert.show("App not found: " .. appName)
--         return
--     end

--     -- Get the frontmost window of the app
--     local win = app:focusedWindow() or app:mainWindow()
--     if not win then
--         hs.alert.show("No active window for: " .. appName)
--         return
--     end

--     -- Get the window's frame (position and size)
--     local frame = win:frame()

--     -- Calculate the center point of the window
--     local centerPoint = {
--         x = frame.x + (frame.w / 2),
--         y = frame.y + (frame.h / 2)
--     }

--     -- Save the current mouse position
--     local originalMousePos = hs.mouse.absolutePosition()

--     -- Move the mouse to the window's center and click
--     hs.mouse.absolutePosition(centerPoint)
--     hs.eventtap.leftClick(centerPoint)

--     -- Restore original mouse position
--     hs.mouse.absolutePosition(originalMousePos)
-- end
    -- Max wait time to avoid hanging
--     local maxWaitTime = 15
--     local startTime = hs.timer.secondsSinceEpoch()

--     hs.timer.waitUntil(
--         function()
--             return areAppsReady() or (hs.timer.secondsSinceEpoch() - startTime > maxWaitTime)
--         end,
--         function()
--             if hs.timer.secondsSinceEpoch() - startTime > maxWaitTime then
--                 print("[ERROR] Timeout waiting for " .. app1Name .. " and " .. app2Name)
--                 if onComplete then onComplete() end -- Ensure execution continues even on timeout
--                 return
--             end

--             -- Ensure BOTH apps are on the correct screen and are not fullscreen
--             local function moveAppToScreen(appName, onComplete)
--                 local app = hs.application.get(appName)
--                 if app then
--                     local win = app:focusedWindow() or app:mainWindow()
--                     if win then
--                         -- Check if the window is in fullscreen mode
--                         if win:isFullScreen() then
--                             win:setFullScreen(false)
--                             -- hs.eventtap.keyStroke({"cmd", "ctrl"}, "f")
--                             hs.timer.doAfter(4, function()  -- Give it a second to exit fullscreen
--                                 local newWin = app:focusedWindow() or app:mainWindow()
--                                 if newWin then
--                                     local newScreen = newWin:screen()
--                                     if newScreen:id() ~= targetScreen:id() then
--                                         newWin:moveToScreen(targetScreen)
--                                     end
--                                 end
--                                 -- Call onComplete if provided
--                                 if onComplete then onComplete() end
--                             end)
--                         else
--                             -- Move the window if it's not already on the correct screen
--                             local winScreen = win:screen()
--                             if winScreen:id() ~= targetScreen:id() then
--                                 win:moveToScreen(targetScreen)
--                             end
--                             -- Call onComplete if provided
--                             if onComplete then onComplete() end
--                         end
--                     else
--                         if onComplete then onComplete() end  -- Ensure callback executes if no window is found
--                     end
--                 else
--                     if onComplete then onComplete() end  -- Ensure callback executes if no app is found
--                 end
--             end

--             -- Move the first app, then move the second after it's done
--             moveAppToScreen(app1Name, function()
--                 moveAppToScreen(app2Name)
--             end)

--             -- Bring app1 to the front
--             local app1 = hs.application.get(app1Name)
--             if app1 then
--                 app1:activate()
--                 hs.timer.doAfter(1, function()
--                     hs.eventtap.keyStroke({"ctrl", "cmd"}, side)
--                 end)
--             end

--             -- Click app2's title bar after app1 action completes
--             hs.timer.doAfter(2, function()
--                 clickWindowCenter(app2Name)
                
--                 -- Ensure that onComplete() is only called **after everything has finished**
--                 if onComplete then onComplete() end
--             end)
--         end
--     )
-- end

-- Function to click the center of a window for an app
-- function clickWindowCenter(appName)
--     -- Find the application
--     local app = hs.application.get(appName)
--     if not app then
--         hs.alert.show("App not found: " .. appName)
--         return
--     end

--     -- Get the frontmost window of the app
--     local win = app:focusedWindow() or app:mainWindow()
--     if not win then
--         hs.alert.show("No active window for: " .. appName)
--         return
--     end

--     -- Get the window's frame (position and size)
--     local frame = win:frame()

--     -- Calculate the center point of the window
--     local centerPoint = {
--         x = frame.x + (frame.w / 2),
--         y = frame.y + (frame.h / 2)
--     }

--     -- Save the current mouse position
--     local originalMousePos = hs.mouse.absolutePosition()

--     -- Move the mouse to the window's center and click
--     hs.mouse.absolutePosition(centerPoint)
--     hs.eventtap.leftClick(centerPoint)

--     -- Restore original mouse position
--     hs.mouse.absolutePosition(originalMousePos)
-- end

-- Function to click on an app's title bar
function clickWindowTitleBar(appName)
    local app = hs.application.get(appName)
    if not app then
        hs.alert.show("App not found: " .. appName)
        return
    end

    local win = app:focusedWindow() or app:mainWindow()
    if not win then
        hs.alert.show("No active window for: " .. appName)
        return
    end

    local frame = win:frame()
    local titleBarHeight = 25 -- Adjust if needed
    local clickPoint = {
        x = frame.x + (frame.w / 2),
        y = frame.y + titleBarHeight / 2
    }

    local originalMousePos = hs.mouse.absolutePosition()
    hs.mouse.absolutePosition(clickPoint)
    hs.eventtap.leftClick(clickPoint)
    hs.mouse.absolutePosition(originalMousePos)
end

-- local config = {
--     app1Name = "Microsoft Teams",
--     side = "right",
--     app2Name = "Slack",
--     screenNumber = 2  -- Will fallback to 1 if only one screen exists
-- }

-- local config2 = {
--     app1Name = "Messages",
--     side = "right",
--     app2Name = "Discord",
--     screenNumber = 2  -- Will fallback to 1 if only one screen exists
-- }

-- Call the function to execute the full sequence
-- launchAppSplitView(config)
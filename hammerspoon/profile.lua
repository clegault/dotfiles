local profileEnabled = false
local profileLogger = hs.logger.new('profile', 'debug')
local profileLogStartTimes = { }

-- Starts profiling `name`
function profileStart(name)
    profileLogger.d("Starting profile: " .. tostring(name))
    profileLogStartTimes[name] = hs.timer.absoluteTime()
end

-- Stops profiling `name`
function profileStop(name)
    local now = hs.timer.absoluteTime()

    -- Check if `profileStart(name)` was actually called before
    if not profileLogStartTimes[name] then
        profileLogger.e("profileStop called without profileStart for: " .. tostring(name))
        return
    end

    local delta = now - profileLogStartTimes[name]
    local deltaNormalized = delta / 1000000000.0
    local logString = name .. ': ' .. deltaNormalized .. 's'
    if profileEnabled then
        profileLogger.i(logString)
    end
end


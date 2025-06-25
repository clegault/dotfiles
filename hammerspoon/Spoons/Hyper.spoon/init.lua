-- Define a local object table to represent the module
local obj = {}
obj.__index = obj  -- Set the metatable index to itself for object-oriented behavior

-- Table to store hyper key mappings
hyperKeys = {}

-- Function to get the bundle ID of the frontmost (active) application
function frontApp()
    return hs.application.frontmostApplication():bundleID()
end

-- Function to check if the currently focused window belongs to a specific application
-- @param bundle: The bundle ID of the application to check against
function focusedWindowIs(bundle)
    return hs.window.focusedWindow():application():bundleID() == bundle
end

-- Utility function to return an existing entry in a table, or create a new one if absent
-- @param mappings: The table to search or insert into
-- @param key: The key to look up or insert
-- @return: The found or newly created table entry
function firstOrInsert(mappings, key)
    if (mappings[key]) then
        return mappings[key]
    end
    mappings[key] = {}
    return mappings[key]
end

-- Hyper key mapping structure with a field to track the application context
hyper = {
    appToMap = "", -- Default application mapping
}

-- Method to define an action for a specific application and key mapping
-- @param action: The action identifier (e.g., "open", "close", etc.)
-- @param mappings: A table mapping target keys to callback functions
-- @return: The hyper object for method chaining
function hyper:action(action, mappings)
    for target, closure in pairs(mappings) do
        -- Ensure the hyperKeys structure exists for this action and target
        firstOrInsert(hyperKeys, action)
        firstOrInsert(hyperKeys[action], target)
        firstOrInsert(hyperKeys[action][target], self.appToMap)
        
        -- Assign the callback function to the specific application context
        hyperKeys[action][target][self.appToMap] = closure
    end
    return self
end

-- Method to define a new application context for key mappings
-- @param app: The application bundle ID to associate with the hyper key mappings
-- @return: A new hyper object instance with the application context set
function hyper:app(app)
    local o = {}  -- Create a new object instance
    setmetatable(o, self)  -- Set the metatable to allow method inheritance
    self.__index = self  -- Ensure object-oriented behavior
    self.appToMap = app  -- Assign the app context
    return o  -- Return the new object
end

-- Define the Hyper Key (F19) as a modal
hyperModal = hs.hotkey.modal.new({}, "F19")

-- Function to bind a hyper key action with multi-level support
function hyperBind(key, action, subAction)
    hyperModal:bind({}, key, function()
        local app = frontApp()  -- Get the currently active application
        local command = nil

        -- Handle multi-level actions like "navigate.up"
        if subAction then
            if hyperKeys[action] and hyperKeys[action][subAction] then
                command = hyperKeys[action][subAction][app] or hyperKeys[action][subAction]["fallback"]
            end
        else
            if hyperKeys[action] and hyperKeys[action][key] then
                command = hyperKeys[action][key][app] or hyperKeys[action][key]["fallback"]
            end
        end

        -- Execute the action if found
        if command then
            command()
        end
    end)
end

-- Hammerspoon URL event handler for triggering hyper key actions
-- This function listens for events triggered via Hammerspoon's URL event system
-- @param _: Unused event name parameter (required by hs.urlevent.bind)
-- @param params: Table containing action and target parameters
-- This is kept for future use of hammerspoon:// actions
-- hs.urlevent.bind("hyper", function(_, params)
--     if (
--         not hyperKeys[params.action] or
--         not hyperKeys[params.action][params.target]
--     ) then
--         return  -- Exit if no mapping exists for the action and target
--     end

--     -- Determine the correct command to execute based on the active application
--     local command = hyperKeys[params.action][params.target][frontApp()]
--     if command == nil then
--         command = hyperKeys[params.action][params.target]["fallback"]  -- Use fallback if no specific app mapping exists
--     end

--     -- Debugging output to show what action and target were triggered
--     print("Hyper action: " .. params.action .. " | Target: " .. params.target)

--     -- Execute the mapped command if found
--     if (command ~= nil) then
--         command()
--     end
-- end)

-- Enter and exit hyper mode when F19 is pressed and released
hs.hotkey.bind({}, "F19", function()
    hyperModal:enter()
end, function()
    hyperModal:exit()
end)

-- Return the module object for external use
return obj

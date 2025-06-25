-- Notifying {{{
-- Function to display a non-intrusive alert on the screen
-- Examples:
-- From the OS (Terminal)
-- open "hammerspoon://notifySoftly?text=Hello%20Soft"
-- open "hammerspoon://notify?text=Hello%20System"
-- open "hammerspoon://notifyUrgently?text=Emergency"
-- From lua:
-- notifySoftly("This is a soft notification!")
-- notify("This is a system notification!")
-- notifyUrgently("This is an urgent message!")
--
-- hs.urlevent.bind("test_notifySoftly", function() notifySoftly("Testing Soft Notification") end)
-- hs.urlevent.bind("test_notify", function() notify("Testing System Notification") end)
-- hs.urlevent.bind("test_notifyUrgently", function() notifyUrgently("Testing Urgent Notification") end)
--
-- Simulate URL events manually
-- hs.urlevent.openURL("hammerspoon://test_notifySoftly")
-- hs.urlevent.openURL("hammerspoon://test_notify")
-- hs.urlevent.openURL("hammerspoon://test_notifyUrgently")
function notifySoftly(notificationString)
    hs.alert.show(notificationString) -- Shows an overlay-style alert
end

-- Function to create and send a system notification
function notify(notificationString)
    local notification = hs.notify.new() -- Creates a new notification object
    notification:title(notificationString) -- Sets the title of the notification
    notification:send() -- Sends the notification to the macOS notification center
end

-- Function to send an urgent message via iMessage
function notifyUrgently(notificationString)
    -- Sends an iMessage to a specific recipient (change the email if needed)
    hs.messages.iMessage("clegault@nextgengeek.com", notificationString)

    -- Finds the Messages app and hides it after sending the message
    local messagesApp = hs.appfinder.appFromName("Messages")
    if messagesApp then
        messagesApp:hide() -- Hides the Messages app from view
    end
end

-- Binds the URL event "notifySoftly" to trigger `notifySoftly`
hs.urlevent.bind("notifySoftly", function(eventName, params)
    local text = params["text"] -- Retrieves the 'text' parameter from the event
    if text then
        notifySoftly(text) -- Calls notifySoftly with the extracted text
    end
end)

-- Binds the URL event "notify" to trigger `notify`
hs.urlevent.bind("notify", function(eventName, params)
    local text = params["text"] -- Retrieves the 'text' parameter from the event
    if text then
        notify(text) -- Calls notify with the extracted text
    end
end)

-- Binds the URL event "notifyUrgently" to trigger `notifyUrgently`
hs.urlevent.bind("notifyUrgently", function(eventName, params)
    local text = params["text"] -- Retrieves the 'text' parameter from the event
    if text then
        notifyUrgently(text) -- Calls notifyUrgently with the extracted text
    end
end)
-- }}}
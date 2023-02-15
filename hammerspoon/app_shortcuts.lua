-- App Shortcuts {{{

-- Option-M for Mail

hs.hotkey.bind({"alt"}, "s", function()
    hs.application.launchOrFocus("Slack")
end)

-- Option-A for Messages

hs.hotkey.bind({"alt"}, "a", function()
    hs.application.launchOrFocus("Messages")
end)

-- Option-Tab for Terminal

hs.hotkey.bind({"alt"}, "tab", function()
    hs.application.launchOrFocus("Alacritty")
end)

-- Option-R for Reeder
hs.hotkey.bind({"alt"}, "c", function()
    hs.application.launchOrFocus("Calendar")
end)

-- Option-T for Textual

hs.hotkey.bind({"alt"}, "t", function()
    hs.application.launchOrFocus("Microsoft Teams")
end)

-- Option-H for HomeAssistant
hs.hotkey.bind({"alt"}, "v", function()
    hs.application.launchOrFocus("Vivaldi")
end)

-- }}}

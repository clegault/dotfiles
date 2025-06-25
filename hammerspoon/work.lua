function startWork()
    local delay = 1.0 -- Base delay time (adjust as needed)

    hs.application.launchOrFocus("Microsoft Outlook")

    local MessagesAndDiscord = {
        app1Name = "com.hnc.Discord", -- Discord
        side = "right",
        app2Name = "com.apple.MobileSMS", -- Messages
        screenNumber = 2
    }

    hs.timer.doAfter(delay * 5, function()
        launchAppSplitView(MessagesAndDiscord)
    end)

    local TeamsAndSlack = {
        app1Name = "com.microsoft.teams2", -- Teams
        side = "right",
        app2Name = "com.tinyspeck.slackmacgap", -- Slack
        screenNumber = 2
    }


    hs.timer.doAfter(delay * 11, function()
        launchAppSplitView(TeamsAndSlack, function()
            print("[DEBUG] Finished TeamsAndSlack setup. Continuing...")
            
            -- Ensure remaining apps launch after TeamsAndSlack
            hs.timer.doAfter(1, function()
                hs.application.launchOrFocus("Arc")
            end)
        
            hs.timer.doAfter(2, function()
                hs.application.launchOrFocus("Ghostty")
            end)
        
            hs.timer.doAfter(3, function()
                hs.application.launchOrFocus("Obsidian")
            end)
        
            hs.timer.doAfter(4, function()
                hs.application.launchOrFocus("Visual Studio Code")
            end)
        end)
    end)
end
require "streamdeck.audio_devices"
require "streamdeck.itunes"
require "streamdeck.terminal"
require "streamdeck.peek"
require "streamdeck.url"
require "streamdeck.lock"
require "streamdeck.clock"
require "streamdeck.weather"
require "streamdeck.app_switcher"
require "streamdeck.window_switcher"
require "streamdeck.animation_demo"
-- require "streamdeck.numpad"
require "streamdeck.window_clone"
require "streamdeck.shortcuts"
require "streamdeck.work"
require "streamdeck.ElgatoKey"
require "streamdeck.zoomApp"

initialButtonState = {
    ['name'] = 'Root',
    ['buttons'] = {
        weatherButton(),
        calendarPeekButton(),
        -- peekButtonFor('com.vivaldi.Vivaldi'),
        downBright,
        upBright,
        Lights,
        lockButton,
        startWorkButton,
        stopWorkButton,
        audioDeviceButton(false),
        audioDeviceButton(true),
        itunesPreviousButton(),
        itunesPlayPuaseButton(),
        itunesNextButton(),
        zoomCamera,
        zoomMute,
        -- appSwitcher(),
        -- windowSwitcher(),
        -- numberPad(),
        -- windowClone(),
        -- shortcuts(),
        -- animationDemo()
    }
}

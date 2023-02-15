require "hyperKeyDef"

-- Brightness Control {{{

function changeBrightnessInDirection (d)
    local brightnessChangeAmount = 16
    local brightness = hs.brightness.get()

    brightness = brightness + (brightnessChangeAmount * d)

    hs.brightness.set(brightness)
end

-- Hyper-1 for brightness down

hs.hotkey.bind(hyperKeyDef, "1", function()
    changeBrightnessInDirection(-1)
end)

-- Hyper-2 for brightness up

hs.hotkey.bind(hyperKeyDef, "2", function()
    changeBrightnessInDirection(1)
end)

-- }}}

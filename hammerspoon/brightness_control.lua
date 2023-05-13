-- Brightness Control {{{

function changeBrightnessInDirection(d)
    local brightnessChangeAmount = 16
    local brightness = hs.brightness.get()

    brightness = brightness + (brightnessChangeAmount * d)

    hs.brightness.set(brightness)
end
-- }}}

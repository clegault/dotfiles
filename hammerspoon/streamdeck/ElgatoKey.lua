Lights = {
    ['name'] = 'Lights on/off',
    ['image'] = streamdeck_imageFromText('􀛮'),
    ['onClick'] = function()
        onOff()
    end
}

upBright = {
    ['name'] = 'brighten up',
    ['image'] = streamdeck_imageFromText('􀇮'),
    ['onClick'] = function()
        brightUp()
    end
}

downBright = {
    ['name'] = 'brighten up',
    ['image'] = streamdeck_imageFromText('􀇭'),
    ['onClick'] = function()
        brightDown()
    end
}
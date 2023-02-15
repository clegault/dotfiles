zoomMute = {
    ['name'] = 'Mute/Unmute mic',
    ['image'] = streamdeck_imageFromText('􀊳'),
    ['onClick'] = function()
        spoon.Zoom:toggleMute()
        -- ['image'] = streamdeck_imageFromText('􀊱')
        -- currentDeck:setButtonImage(15, streamdeck_imageFromText('􀊱'))
    end
}

zoomCamera = {
    ['name'] = 'Toggle Camera',
    ['image'] = streamdeck_imageFromText('􀍎'),
    ['onClick'] = function()
        spoon.Zoom:toggleVideo()
        -- currentDeck:setButtonImage(14, streamdeck_imageFromText('􀍎'))
    end
}
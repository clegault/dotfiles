function onOff()
    local ip1 = '192.168.254.27'
    local ip2 = '192.168.254.28'
    local port = '9123'
    local status, body, headers = hs.http.get("http://" .. ip1 .. ":" .. port .. "/elgato/lights")
    local settings = hs.json.decode(body)
    if settings.lights[1].on == 0 then
        settings.lights[1].on = 1
    else
        settings.lights[1].on = 0
    end
    local status, response, header = hs.http.doRequest("http://" .. ip1 .. ":" .. port .. "/elgato/lights", "PUT", hs.json.encode(settings))
    local status, body, headers = hs.http.get("http://" .. ip2 .. ":" .. port .. "/elgato/lights")
    local settings = hs.json.decode(body)
    if settings.lights[1].on == 0 then
        settings.lights[1].on = 1
    else
        settings.lights[1].on = 0
    end
    local status, response, header = hs.http.doRequest("http://" .. ip2 .. ":" .. port .. "/elgato/lights", "PUT", hs.json.encode(settings))
end

function KeyBrightUpDown(i)
    local ip1 = '192.168.254.27'
    local ip2 = '192.168.254.28'
    local port = '9123'
    local brightStep = 2
    local status, body, headers = hs.http.get("http://" .. ip1 .. ":" .. port .. "/elgato/lights")
    local settings = hs.json.decode(body)
    if i == 1 then
        settings.lights[1].brightness = settings.lights[1].brightness + brightStep
    else
        settings.lights[1].brightness = settings.lights[1].brightness - brightStep
    end
    local status, response, header = hs.http.doRequest("http://" .. ip1 .. ":" .. port .. "/elgato/lights", "PUT", hs.json.encode(settings))
     local status, body, headers = hs.http.get("http://" .. ip2 .. ":" .. port .. "/elgato/lights")
    local settings = hs.json.decode(body)
    if i == 1 then
        settings.lights[1].brightness = settings.lights[1].brightness + brightStep
    else
        settings.lights[1].brightness = settings.lights[1].brightness - brightStep
    end
    local status, response, header = hs.http.doRequest("http://" .. ip2 .. ":" .. port .. "/elgato/lights", "PUT", hs.json.encode(settings))
end

function brightUp()
  KeyBrightUpDown(1)

  return self
end

function brightDown()
  KeyBrightUpDown(0)

  return self
end
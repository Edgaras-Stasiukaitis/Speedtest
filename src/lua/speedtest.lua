local cURL = require "cURL"

local M = {}
local KEY = 'WYlYcRSkCffJUc3Kz5ztOo5WHU9Bdk5E'

function M.get_ip()
    local easy = cURL.easy()
    local data = {}
    easy:setopt{
        url = string.format('https://api.ipify.org'),
    }
    easy:setopt_writefunction(table.insert, data)
    local ok, err = easy:perform()
    if ok then
        local code, url, content = easy:getinfo_effective_url()
        easy:getinfo_response_code()
        table.concat(data)
        print(code, url)
        print(content)
    else
        print(err)
    end
    easy:close()

    return data[1]
end

function M.get_location()
    local file = io.open("/tmp/locationInfo.json", "w")
    local ip = M.get_ip()
    file:write(ip .. "\n")
    cURL.easy{
        url = string.format('https://api.ip2loc.com/%s/%s', KEY, ip),
        writefunction = file
    }
    :perform()
    :close()
    file:close()
end

function M.get_servers()
    local file = io.open("/tmp/servers.json", "w")
    cURL.easy{
        url = 'https://server-list.azurewebsites.net/',
        writefunction = file
    }
    :perform()
    :close()
    file:close()
end

return M

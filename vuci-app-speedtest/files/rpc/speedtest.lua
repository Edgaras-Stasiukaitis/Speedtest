local cURL = require "cURL"

local M = {}
local KEY = 'WYlYcRSkCffJUc3Kz5ztOo5WHU9Bdk5E'

function M.check_connection(server)
    local f = io.open("/dev/null", "w")
    local c = cURL.easy{
        url = server,
        useragent = "libcurl-speedchecker/1.0",
        writefunction = f,
        timeout = 2
    }
    c:perform()
    local code = c:getinfo_response_code()
    local total_time = c:getinfo_total_time()
    print(total_time)
    c:close()
    return server, code, total_time
end

function M.get_ip()
    local easy = cURL.easy()
    local data = {}
    easy:setopt{
        url = string.format('https://api.ipify.org'),
    }
    easy:setopt_writefunction(table.insert, data)
    local ok = easy:perform()
    if ok then
        easy:getinfo_response_code()
        table.concat(data)
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
        url = 'https://server-list.azurewebsites.net/available/',
        writefunction = file
    }
    :perform()
    :close()
    file:close()
end

return M

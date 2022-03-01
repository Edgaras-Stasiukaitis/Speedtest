local speedtest = require "speedtest"
local os = require "os"

local M = {}

function M.get_ip()
    return speedtest.get_ip()
end

function M.get_location()
    local filename = "/tmp/locationInfo.json"
    local file = io.open(filename, "r")
    if file == nil then
        speedtest.get_location()
    elseif file:read() ~= M.get_ip() then
        speedtest.get_location()
    else io.close(file)
    end
    local lines = {}
    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end

    return { data = lines[#lines] }
end

function M.get_servers()
    local filename = "/tmp/servers.json"
    local file = io.open(filename, "r")
    if file ~= nil
        then io.close(file)
        else speedtest.get_servers()
    end
    local lines = {}
    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end

    return { data = lines }
end

function M.find_servers(params)
    os.remove("/tmp/optimal_server")
    local filename = "/tmp/filtered_servers"
    local file = io.open(filename, "w")
    for _, v in pairs(params.servers) do
        file:write(v.host, "\n")
    end
    io.close(file)
    os.execute("lua /usr/bin/speedtest find_servers --dump /tmp/optimal_server --count 5 --quiet &")
    return { message = "Pooling started" }
end

function M.test_download(params)
    os.execute("lua /usr/bin/speedtest measure_download --server speedtest.tele2.net/50MB.zip --quiet &")
    return { message = "Download test started"}
end

function M.test_upload(params)
    os.execute("lua /usr/bin/speedtest measure_upload --server stnet1.balticum.lt --quiet &")
    return { message = "Upload test started"}
end

function Pool(filename, last_line)
    local file = io.open(filename, "r")
    if file == nil then
        return { message = "File is not yet created"}
    end
    local size = file:seek("end")
    io.close(file)
    if size == 0 then
        return { message = "File is empty" }
    end
    local lines = {}
    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end
    if last_line then
        return { data = lines[#lines] }
    end

    return { data = lines }
end

function M.pool_servers()
    return Pool("/tmp/optimal_server", false)
end

function M.pool_download()
    return Pool("/tmp/download_results", true)
end

function M.pool_upload()
    return Pool("/tmp/upload_results", true)
end

return M

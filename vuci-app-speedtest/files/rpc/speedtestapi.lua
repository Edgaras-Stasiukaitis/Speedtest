local speedtest = require "speedtest"
local os = require "os"
local uci = require "uci"

local M = {}

function M.get_router_info()
    local c = uci.cursor()
    local data = {}
    local router_name = c:get("system", "system", "routername")
    local router_firmware = c:get("system", "system", "device_fw_version")
    table.insert(data, { name = router_name })
    table.insert(data, { firmware = router_firmware })

    return { data = data }
end

function M.get_config_option(params)
    local c = uci.cursor()

    return { data = c:get(params.config, params.section, params.option) }
end

function M.set_config_option(params)
    local c = uci.cursor()
    c:set(params.config, params.section, params.option, params.value)
    c:commit(params.config)

    return { message = params.config .. " " .. params.section .. " " .. params.option .. " " .. params.value }
end

function M.check_connection(params)
    local status, _, code, _ = pcall(speedtest.check_connection, params.server)
    if status and code == 200 then
        return { ok = true }
    end

    return { ok = false }
end

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
    os.remove("/tmp/results")
    os.remove("/tmp/optimal")
    local results = io.open("/tmp/results", "a")
    results:write(table.getn(params.servers) .. "\n")
    io.close(results)
    for _, v in pairs(params.servers) do
        os.execute("lua /usr/bin/speedtest find_servers -s " .. v.host .. " -q &")
    end

    return { message = "Optimal server search started" }
end

function M.test_download(params)
    os.remove("/tmp/download_results")
    local processName = "lua /usr/bin/speedtest measure_download"
    os.execute(processName .. " --server " .. params.server .. " --quiet &")
    os.execute("pidof " .. processName .. " | awk '{ print $1 }' > /tmp/processes")

    return { message = "Download test started"}
end

function M.test_upload(params)
    os.remove("/tmp/upload_results")
    local processName = "lua /usr/bin/speedtest measure_upload"
    os.execute(processName .. " --server " .. params.server .. " --quiet &")
    os.execute("pidof " .. processName .. " | awk '{ print $1 }' > /tmp/processes")

    return { message = "Upload test started"}
end

function M.kill_processes()
    local filename = "/tmp/processes"
    local file = io.open(filename, "r")
    if file == nil then return end
    local processes = {}
    for pid in io.lines(filename) do
        processes[#processes+1] = pid
        os.execute("kill -9 " .. pid .. " &")
    end
    os.remove(filename)

    return { message = "Processes killed", data = processes}
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
    local results_filename = "/tmp/results"
    local results_file = io.open(results_filename, "r")
    if results_file == nil then
        return { message = "File is not yet created"}
    end
    local count = -1
    for _ in io.lines(results_filename) do
        count = count + 1
    end
    if tonumber(results_file:read()) == count then
        os.execute("lua /usr/bin/speedtest find_optimal -q &")
        return { message = true}
    end
    return { message = false }
end

function M.pool_optimal()
    local optimal_filename = "/tmp/optimal"
    local optimal_file = io.open(optimal_filename, "r")
    if optimal_file ~= nil then
        io.close(optimal_file)
        local lines = {}
        for line in io.lines(optimal_filename) do
            lines[#lines + 1] = line
        end
        return { data = lines }
    end
    return { message = "Pooling optimal servers" }
end

function M.pool_download()
    return Pool("/tmp/download_results", true)
end

function M.pool_upload()
    return Pool("/tmp/upload_results", true)
end

return M

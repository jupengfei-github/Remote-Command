local Log       = require("log")
local libsocket = require("libsocket")

local LOG_TAG   = "Socket"

local socket_metatable = {}
local function create_socket (sk)
    local socket = sk or {
        ipaddr = nil,
        ipport = nil,
        fd     = -1,
        server = true
    }

    setmetatable(socket, socket_metatable)
    socket_metatable.__index = socket_metatable

    return socket
end

local Socket = {}
function Socket.server (ip, port)
    local ipaddr, ipport
    local fd

    ipaddr = assert(ip)
    ipport = assert(port)

    Log.d(LOG_TAG, "create server socket ["..ipaddr.." "..ipport.."]")
    fd = libsocket.server_socket(ipaddr, ipport)
    if (fd < 0) then
        Log.d(LOG_TAG, "lua mode socket create  server_socket failed")
        return nil
    end

    return create_socket ({
        ipaddr = ipaddr,
        iport  = ipport,
        fd     = fd,
        server = true,
        listening = false,
    })
end

function Socket.client (ip, port)
    local ipaddr, ipport
    local fd

    ipaddr = assert(ip)
    ipport = assert(port)

    Log.d(LOG_TAG, "create client socket ["..ipaddr.." "..ipport.."]")
    fd = libsocket.client_socket(ipaddr, ipport)
    if (fd < 0) then
        Log.d(LOG_TAG, "lua mode socket create client_socket failed")
        return nil
    end

    return create_socket ({
        ipaddr = ipaddr,
        ipport = ipport,
        fd     = fd,
        server = false 
    })
end

function socket_metatable:close()
    if (self.fd > 0) then
        libsocket.close_socket(self.fd)
    end
end

function socket_metatable:send (msg)
    if (msg ~= nil and self.server == false) then
        local msg_table = {
            msg,
            "\n",  --compatibal for windows
        }

        libsocket.send_data(self.fd, msg_table)
    else
        Log.d(LOG_TAG, "must be client socket")
    end
end

function socket_metatable:recv ()
    if (self.server == true) then
        Log.d(LOG_TAG, "must be client socket")
        return nil
    end

    local tb = libsocket.recv_data (self.fd)
    if (tb ~= nil) then
        local msg = table.concat(tb)
        return string.sub(msg, 1, #msg - 1)  --compatibal for windows
    else
        return nil
    end
end

function socket_metatable:listen ()
    if (self.server == false) then
        Log.d(LOG_TAG, "must be server client")
        return nil
    end

    if (self.listening == true) then
        Log.d(LOG_TAG, "have been listen")
        return nil
    end

    local fd = libsocket.listen_connect (self.fd) 
    if (fd >= 0) then
        return create_socket ({
            ipaddr = self.ipaddr,
            ipport = self.ipport,
            fd     = fd,
            server = false 
        })
    else
        Log.e(LOG_TAG, "listen at ["..self.ipaddr.." "..self.ipport.." failed]")
        return nil
    end
end

return Socket

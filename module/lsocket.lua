-- Copyright (C) 2018-2024 The Remote-Command Project
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

--
-- Wrapper For C Module libsocket
--

local Log       = require("log")
local libsocket = require("libsocket")

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

    fd = libsocket.server_socket(ipaddr, ipport)
    if (fd < 0) then
        Log.d("lsocket create server_socket " .. ipaddr .. ":" .. ipport .. " failed")
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

    fd = libsocket.client_socket(ipaddr, ipport)
    if (fd < 0) then
        Log.d("lsocket create client_socket " .. ipaddr .. ":" .. ipport .. " failed")
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
    if (self.server == false) then
        local msg_table = {
            msg,
            "\n",  --compatibal for windows
        }

        libsocket.send_data(self.fd, msg_table)
    else
        Log.d("must be client socket")
    end
end

function socket_metatable:recv ()
    if (self.server == true) then
        Log.d("must be client socket")
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
        Log.d("must be server client")
        return nil
    end

    if (self.listening == true) then
        Log.d("have been listen")
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
        Log.e("listen at ["..self.ipaddr..":"..self.ipport.." failed]")
        return nil
    end
end

return Socket

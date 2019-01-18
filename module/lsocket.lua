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

local Log       = require("log")
local libsocket = require("socket")
local LOG_TAG   = "Socket"

local socket_metatable = {}

local function create_socket (sk)
    local socket = sk or {
        ipaddr = nil,
        ipport = nil,
        sock   = nil,
        server = true,
    }

    setmetatable(socket, socket_metatable)
    socket_metatable.__index = socket_metatable

    return socket
end

local Socket = {}
function Socket.server (ip, port)
    local ipaddr, ipport
    local server

    ipaddr = assert(ip) 
    ipport = assert(port)

    Log.d(LOG_TAG, "create server socket ["..ipaddr.." "..ipport.."]")
    server = libsocket.bind(ipaddr, ipport)  
    if (server == nil) then
        Log.d(LOG_TAG, "lua mode socket create  server_socket failed")
        return nil
    end

    return create_socket ({
        ipaddr = ipaddr,
        iport  = ipport,
        sock   = server,
        server = true,
    })
end

function Socket.client (ip, port)
    local ipaddr, ipport
    local client

    ipaddr = assert(ip)
    ipport = assert(port)

    Log.d(LOG_TAG, "create client socket ["..ipaddr.." "..ipport.."]")
    client = libsocket.connect(ipaddr, ipport)
    if (client == nil) then
        Log.d(LOG_TAG, "lua mode socket create client_socket failed")
        return nil
    end

    return create_socket ({
        ipaddr = ipaddr,
        ipport = ipport,
        sock   = client,
        server = false 
    })
end

function socket_metatable:close()
    if (self.sock) then
        self.sock:close()
    end
end

function socket_metatable:send (msg)
    if (msg ~= nil and self.server == false) then
        self.sock:send(msg.."\n")
    else
        Log.d(LOG_TAG, "must be client socket")
    end
end

function socket_metatable:recv ()
    if (self.server == true) then
        Log.d(LOG_TAG, "must be client socket")
        return nil
    end

    return self.sock:receive ()
end

function socket_metatable:listen ()
    if (self.server == false) then
        Log.d(LOG_TAG, "must be server client")
        return nil
    end

    local client = self.sock:accept ()
    if (client) then
        return create_socket ({
            ipaddr = self.ipaddr,
            ipport = self.ipport,
            sock   = client,
            server = false,
        })
    else
        Log.e(LOG_TAG, "listen at ["..self.ipaddr.." "..self.ipport.." failed]")
        return nil
    end
end

return Socket

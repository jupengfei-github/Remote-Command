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

local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")

local USER_C_PATHS   = {
    RD_ROOT_DIR .. "\lib\\?.dll",
}

local USER_LUA_PATHS = {
    RD_ROOT_DIR .. "\core\\?.lua",
    RD_ROOT_DIR .. "\common\\core\?.lua"
    RD_ROOT_DIR .. "\module\\?.lua",
    RD_ROOT_DIR .. "\common\\module\?.lua"
}

-- cpath
local cpath = package.cpath
for k,v in pairs(USER_C_PATHS) do
    if (not string.match(cpath, v)) then
        package.cpath = package.cpath ..";".. v
    end
end

-- lua path
local path = package.path
for k,v in pairs(USER_LUA_PATHS) do
        if (not string.match(path, v)) then
        package.path = package.path ..";".. v
    end
end

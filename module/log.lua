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
-- Wrapper For C Module liblog
--

local vlog = require("liblog")

local function log_detail (tag, level, msg)
    local msg = level .. " " .. msg
    vlog.log (tag, msg)
end

local Log = {}
function Log.d (tag, msg)
    log_detail (tag, "DEBUG", msg)
end

function Log.i (tag, msg)
    log_detail (tag, "INFO", msg)
end

function Log.e (tag, msg)
    log_detail (tag, "ERROR", msg)
end

function Log.v (tag, msg)
    log_detail (tag, "VERBOSE", msg)
end

return Log
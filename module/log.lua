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

local function log_detail (level, msg)
    local msg = level .. " " .. msg
    vlog.log (msg)
end

local Log = {}
function Log.d (msg)
    log_detail ("DEBUG", msg)
end

function Log.i (msg)
    log_detail ("INFO", msg)
end

function Log.e (msg)
    log_detail ("ERROR", msg)
end

function Log.v (msg)
    log_detail ("VERBOSE", msg)
end

return Log

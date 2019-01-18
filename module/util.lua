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

local util = require("libutil")

local Util = {}
function Util.is_dir (path)
    if (path == nil or type(path) ~= "string") then
        return false
    end

    return not util.is_dir(path)
end

return Util

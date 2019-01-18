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

local Log = setmetatable({
	-- which log used
	log_with_file = false,
	log_with_term = true,

	-- Log object
	log_file = nil,
	},
	{
	__index = function (tb, key) 
		if (type(tb[key]) ~= "function") then
			print("only function can be used")
		end
	end,
	}
)

local function file_log_name ()
	if (config.log_file) then
		return config.log_file
	else
		return GLOBAL_CONSTANT_FLAG.LOG_FILE_NAME
	end
end

local function init_file_log () 
	if (Log.log_file) then
		return
	end

	local log_file_name = file_log_name()

	local fd, status = io.open(log_file_name, "a")
	if (not log_file) then
		print("init_file_log error : "..status)
	end

	Log.log_file = fd
end

local function close_file_log () 
	if (log_file) then
		Log.log_file:close()
	end
end

local function file_log (tag, msg)
	if (Log.log_file) then
		Log.log_file:write(tag.." "..msg.."\n")
	end
end

local function term_log (tag, msg)
	print(tag.." "..msg)
end

local function log_detail (tag, level, msg)
	if (Log.log_with_file) then
		file_log (tag,  level.." "..msg)
	end

	if (Log.log_with_term) then
		term_log (tag, level.." "..msg)
	end
end

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

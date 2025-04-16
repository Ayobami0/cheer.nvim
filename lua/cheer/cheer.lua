local M = {}

local config = require("cheer.config")

---format cheer message based on configuration format
---@param l Label
---@return string the full formated string or an empty string if l has no format
---and default is not specified
local function format_cheer(l)
	local fmt = config.options.labels[l.name] and config.options.labels[l.name].cheer_format
		or config.options.cheer_format

	if not fmt then
		return ""
	end

	local data = {
		label = l.name,
		message = l.message,
		file = l.file,
	}

	local out = fmt:gsub("{(.-)}", function(key)
		return data[key] or ""
	end)

	return out
end

---play a cheer sound
---@param l Label
local function play_cheer_sound(l)
	local file

	file = config.options.labels[l.name] and config.options.labels[l.name].cheer_song or config.options.cheer_song

	if not file then
		return
	end
end

---cheer for label
---@param l Label the label to cheer for
M.cheer = function(l)
	play_cheer_sound(l)
	vim.notify(format_cheer(l))
end

return M

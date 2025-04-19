local M = {}

local config = require("cheer.config")

---format cheer message based on configuration format
---@param l Label @return string the full formated string or an empty string if l has no format
---and default is not specified
local function format_cheer(l)
	local fmt = config.options.labels[l.name] and config.options.labels[l.name].cheer_format
		or config.options.cheer_format

	if not fmt then
		return ""
	end

	local out = fmt:gsub("{(.-)}", function(key)
		return l[key] or ""
	end)

	return out
end

---play a cheer sound
---@param l Label
local function play_cheer_sound(l)
	local file
	local opts = config.options

	file = opts.labels[l.name] and opts.labels[l.name].cheer_song or config.get_cheer_path(opts.cheer_song)

	if not file then
		return
	end

	if vim.fn.filereadable(file) ~= 1 then
		return
	end

	if not opts.player or vim.fn.executable(opts.player.cmd) ~= 1 then
		return
	end

	local on_exit = function(obj)
		if obj.code ~= 0 then
			vim.notify(obj.stderr, vim.log.levels.ERROR)
		end
	end

	local cmd = { opts.player.cmd }

	if opts.player.args and #opts.player.args ~= 0 then
		for _, v in ipairs(opts.player.args) do
			table.insert(cmd, v)
		end
	end

	table.insert(cmd, file)

	vim.system(cmd, { text = true }, on_exit)
end

---cheer for label
---@param l Label the label to cheer for
M.cheer = function(l)
	play_cheer_sound(l)
	vim.notify(format_cheer(l))
end

return M

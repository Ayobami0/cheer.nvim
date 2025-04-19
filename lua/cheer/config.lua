---@class Config
local M = {}

---@type Options
M.options = nil

---@type boolean
M.loaded = false

---@class LabelOptions
---@field cheer_format string
---@field cheer_song string|nil

---@alias cheer
---| 'cheer_applause'
---| 'cheer_clap'
---| 'cheer_group'
---| 'cheer_yay'

---@class Player
---@field cmd string
---@field args string[]|nil

---@class Options
---@field cheer_format string
---@field cheer_song string|cheer|nil
---@field labels table<string, LabelOptions|nil>
---@field ignore string[] file types to ignore
---@field player Player
local default = {
	player = { cmd = "mpv", args = { "--ao=pulse" } },
	ignore = { "^$", "NvimTree", "Neogit*", "markdown", "COMMIT*", "Telescope*" },
	cheer_format = "🎉 {label} {message} CLOSED on line {line}!",
	cheer_song = "cheer_applause",
	labels = {
		TODO = nil,
		FIX = nil,
		FIXME = nil,
		BUG = nil,
		HACK = nil,
		REFACTOR = nil,
		NOTE = nil,
		XXX = nil,
		OPTIMIZE = nil,
		DEPRECATED = nil,
		WIP = nil,
		QUESTION = nil,
	},
}

---setup configurations
---@param opt? Options
M.setup = function(opt)
	if M.loaded then
		return
	end
	M.loaded = true

	if opt then
		opt = vim.tbl_deep_extend("force", default, opt)
	else
		opt = default
	end

	M.options = opt
end

M.regex_labels = function()
	if not M.options or not M.options.labels then
		return ""
	end

	local labels = table.concat(vim.tbl_keys(M.options.labels), "|")
	return labels
end

M.get_cheer_path = function(c)
	if not vim.tbl_contains({
		"cheer_applause",
		"cheer_clap",
		"cheer_group",
		"cheer_yay",
	}, c) then
		return c
	end

	local plugin_path = debug.getinfo(1).source:match("@?(.-)/lua/cheer/config%.lua$")

	local cheer_file = string.format("%s/cheers/%s.mp3", plugin_path, c)

	return cheer_file
end

return M

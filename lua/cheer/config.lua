---@class Config
local M = {}

---@type Options
M.options = nil

---@type boolean
M.loaded = false

---@class LabelOptions
---@field cheer_format string
---@field cheer_song string|nil

---@class Options
---@field cheer_format string
---@field cheer_song string|nil
---@field labels table<string, LabelOptions|nil>
---@field ignore string[] file types to ignore
local default = {
	ignore = { "^$", "NvimTree", "Neogit*", "markdown", "COMMIT*", "Telescope*" },
	cheer_format = "🎉 {label} {message} CLOSED!",
	cheer_song = nil,
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

return M

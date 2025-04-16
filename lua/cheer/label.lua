local M = {}
local config = require("cheer.config")
local cheer = require("cheer.cheer")
local state = require("cheer.state")

M.loaded = false

---@class Label
---@field name string
---@field message string
---@field file string

---@class ParseBufferOpt option specified to parse_buffer
---@field buf integer the buffer
---@field file string the file name

---@class ParseLabelOpt option specified to parse_label
---@field text string the label text
---@field file string the name of the file where the label is

---parse text into tag data structure
---@param opt ParseLabelOpt
---@return Label
local function parse_label(opt)
	local pattern = "(%u+):%s*(.*)"
	local name, message = string.match(opt.text, pattern)
	return { name = name, message = message, file = opt.file }
end

---Parse the tree and extract label, returns nil if treesitter is not enabled
---@param opt ParseBufferOpt options
---@return Label[]?
local function parse_buffer(opt)
	local ft = vim.bo.ft

	for _, v in ipairs(config.options.ignore) do
    local match = ft:find(v)
		if match then
			return
		end
	end

	local ok, parser = pcall(vim.treesitter.get_parser, opt.buf, ft)

	if not ok or not parser then
		vim.notify("cheer: No parser for " .. ft, vim.log.levels.WARN)
		return nil
	end

	local tags = {}
  local query
	ok, query = pcall(vim.treesitter.query.parse,
		ft,
		string.format('(((comment) @comment) (#any-match? @comment "%s:.*") )', config.regex_labels())
	)
	if not ok or not query then
		vim.notify("cheer: " .. ft .. " has no comment type", vim.log.levels.WARN)
		return nil
	end

	local tree = parser:parse()[1]

	for _, node, _ in query:iter_captures(tree:root(), 0) do
		local text = vim.treesitter.get_node_text(node, opt.buf)

		if text then
			table.insert(tags, parse_label({ text = text, file = opt.file }))
		end
	end

	return tags
end

--- loads the label into storage. should be called once
--- @param opt ParseBufferOpt
M.load = function(opt)
	if state:is_loaded(opt) then
		return
	end

	local new_labels = parse_buffer(opt)

	if new_labels then
		state:insert(opt.buf, new_labels)
	end
end

--- loads the label into storage
--- @param opt ParseBufferOpt
M.update = function(opt)
	local new_labels = parse_buffer(opt)
	local old_labels = state:get(opt.buf)

	if new_labels and #old_labels ~= 0 then
		if not vim.deep_equal(old_labels, new_labels) then
			for _, l in ipairs(old_labels) do
				if
					not vim.tbl_contains(new_labels, function(v)
						return vim.deep_equal(l, v)
					end, { predicate = true })
				then
					cheer.cheer(l)
				end
			end
			state:insert(opt.buf, new_labels)
		end
	end
end

return M

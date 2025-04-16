---@class LabelState state for managing lables
---@field private _labels table<integer, Label[]>
local M = {}

---@type table<integer, Label[]>
M._labels = {}

---insert a new label in a buffer table
---@param buf integer
---@param l Label
---@return boolean false if l is empty
function M:insert(buf, l)
	if not self._labels[buf] then
		self._labels[buf] = {}
	end

	if vim.tbl_isempty(l) then
		return false
	end

	self._labels[buf] = l
	return true
end

---retrive the labels belonging to a buffer
---@param buf integer buffer
---@return Label[]
function M:get(buf)
	local labels = self._labels[buf]
	return labels
end

---remove a label from a buffer list
---@param buf integer
---@param l Label
---@return boolean false if nothing was removed
function M:remove(buf, l)
	if not self._labels[buf] then
		return false
	end

	local removed = false

	for i, v in ipairs(self._labels[buf]) do
		if vim.deep_equal(l, v) then
			table.remove(self._labels[buf], i)
			removed = true
			break
		end
	end

	return removed
end

---gets the count of labels in the buffer
---@param buf integer
---@return integer
function M:count(buf)
	if not self._labels[buf] then
		return 0
	end

	return #self._labels[buf]
end

---checks if a buffer has been loaded
---@param buf integer
---@return boolean
function M:is_loaded(buf)
	if self._labels[buf] then
		return true
	end

	return false
end

return M

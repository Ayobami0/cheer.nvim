local M = {}
local config = require("cheer.config")
local labels = require("cheer.label")

---setup
---@param opt? Options
M.setup = function(opt)
	config.setup(opt)

	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function(args)
			labels.load({ buf = args.buf, file = args.file })
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
		callback = function(args)
			labels.update({ buf = args.buf, file = args.file })
		end,
	})
end

return M
